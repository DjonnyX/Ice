package ru.ice.animation;

import haxe.Constraints.Function;
import haxe.io.Error;

import ru.ice.events.Event;
import ru.ice.events.EventDispatcher;
import ru.ice.utils.ArrayUtil;

@:access(ru.ice.animation.Delayer)
@:access(ru.ice.animation.Tween)
/**
 * ...
 * @author Evgenii Grebennikov
 */
class Animator implements IAnimatable
{
    private var mObjects:Array<IAnimatable>;
    private var mElapsedTime:Float;
    
    public function new()
    {
        mElapsedTime = 0;
        mObjects = new Array<IAnimatable>();
    }
	
    public function add(object:IAnimatable):Void
    {
        if (object != null && mObjects.indexOf(object) == -1) 
        {
            mObjects[mObjects.length] = object;
        
            var dispatcher:EventDispatcher = Std.is(object, EventDispatcher) ? cast object : null;
            if (dispatcher != null) dispatcher.addEventListener(Event.REMOVE_FROM_ANIMATOR, onRemove);
        }
    }
    
    public function contains(object:IAnimatable):Bool
    {
        return mObjects.indexOf(object) != -1;
    }
    
    public function remove(object:IAnimatable):Void
    {
		var o:Dynamic = cast object;
        if (object == null) return;
        
        var dispatcher:EventDispatcher = Std.is(object, EventDispatcher) ? cast object : null;
        if (dispatcher != null) dispatcher.removeEventListener(Event.REMOVE_FROM_ANIMATOR, onRemove);

        var index:Int = mObjects.indexOf(object);
        if (index != -1) mObjects[index] = null;
    }
    
    public function removeTweens(target:Dynamic):Void
    {
        if (target == null) return;
        
        var i:Int = mObjects.length - 1;
        while (i >= 0) {
            var tween:Tween = Std.is(mObjects[i], Tween) ? cast mObjects[i] : null;
            if (tween != null && tween.target == target) {
				remove(cast(tween, IAnimatable));
                mObjects[i] = null;
            }
            --i;
        }
    }
    
    public function containsTweens(target:Dynamic):Bool
    {
        if (target == null) return false;
        
        var i:Int = mObjects.length - 1;
        while (i >= 0)
        {
            var tween:Tween = Std.is(mObjects[i], Tween) ? cast mObjects[i] : null;
            if (tween != null && tween.target == target) return true;
            --i;
        }
        
        return false;
    }
    
    public function purge():Void
    {
        var i:Int = mObjects.length - 1;
        while (i >= 0)
        {
            var dispatcher:EventDispatcher = Std.is(mObjects[i], EventDispatcher) ? cast mObjects[i] : null;
            if (dispatcher != null) dispatcher.removeEventListener(Event.REMOVE_FROM_ANIMATOR, onRemove);
            mObjects[i] = null;
            --i;
        }
    }
    
    public function delayCall(call:Function, delay:Float, args:Array<Dynamic> = null):IAnimatable
    {
        if (call == null) return null;
        if (args == null) args = [];
        
        var delayedCall:Delayer = Delayer.fromPool(call, delay, args);
        delayedCall.addEventListener(Event.REMOVE_FROM_ANIMATOR, onPooledDelayedCallComplete);
        add(delayedCall);

        return delayedCall; 
    }
	
    public function repeatCall(call:Function, interval:Float, repeatCount:Int=0, args:Array<Dynamic>):IAnimatable
    {
        if (call == null) return null;
        if (args == null) args = [];
        
        var delayedCall:Delayer = Delayer.fromPool(call, interval, args);
        delayedCall.repeatCount = repeatCount;
        delayedCall.addEventListener(Event.REMOVE_FROM_ANIMATOR, onPooledDelayedCallComplete);
        add(delayedCall);
        
        return delayedCall;
    }
    
    private function onPooledDelayedCallComplete(event:Event):Void
    {
        Delayer.toPool(cast(event.target, Delayer));
    }
	
    public function tween(target:Dynamic, time:Float, properties:Dynamic):IAnimatable
    {
        if (target == null) {
			#if debug
				trace("target must not be null");
			#end
			return null;
		}

        var tween:Tween = Tween.fromPool(target, time);
        
        for (property in Reflect.fields(properties))
        {
            var value:Dynamic = Reflect.field(properties, property);
            
			switch (property) {
				case 'onComplete':
					tween.onComplete = value;
				case 'onCompleteArgs':
					tween.onCompleteArgs = value;
				case 'onRepeat':
					tween.onRepeat = value;
				case 'onRepeatArgs':
					tween.onRepeatArgs = value;
				case 'onStart':
					tween.onStart = value;
				case 'onStartArgs':
					tween.onStartArgs = value;
				case 'onUpdate':
					tween.onUpdate = value;
				case 'onUpdateArgs':
					tween.onUpdateArgs = value;
				case 'transition':
					tween.transition = value;
				case 'transitionFunc':
					tween.transitionFunc = value;
				case 'delay':
					tween.delay = value;
				case 'repeatCount':
					tween.repeatCount = value;
				case 'repeatDelay':
					tween.repeatDelay = value;
				case 'reverse':
					tween.reverse = value;
				case 'roundToInt':
					tween.roundToInt = value;
				default:
					 tween.animate(property, value);
			}
            /*if (Reflect.getProperty(tween, property) != null)
                Reflect.setProperty(tween, property, value);
            else if (Reflect.getProperty(target, property) != null)
                tween.animate(property, value);
            else
                trace("Invalid property: " + property);*/
        }
        
        tween.addEventListener(Event.REMOVE_FROM_ANIMATOR, onPooledTweenComplete);
        add(tween);

        return tween;
    }
    
    private function onPooledTweenComplete(event:Event):Void
    {
        Tween.toPool(cast(event.target, Tween));
    }
    
    public function update(time:Float):Void
    {   
        var numObjects:Int = mObjects.length;
        var currentIndex:Int = 0;
        var i:Int = 0;
        
        mElapsedTime += time;
        if (numObjects == 0) return;
        
        // there is a high probability that the "advanceTime" function modifies the list 
        // of animatables. we must not process new objects right now (they will be processed
        // in the next frame), and we need to clean up any empty slots in the list.

        while (i < numObjects)
        {
            var object:IAnimatable = mObjects[i];
            if (object != null)
            {
                // shift objects into empty slots along the way
                if (currentIndex != i) 
                {
                    mObjects[currentIndex] = object;
                    mObjects[i] = null;
                }
                
                object.update(time);
                ++currentIndex;
            }
            
            ++i;
        }
        
        if (currentIndex != i)
        {
            numObjects = mObjects.length; // count might have changed!

            while (i < numObjects)
                mObjects[currentIndex++] = mObjects[i++];
			ArrayUtil.setLength(mObjects, currentIndex);
        }
    }
    
    private function onRemove(event:Event):Void
    {
        remove(cast(event.target, IAnimatable));
        
       var tween:Tween = Std.is(event.target, Tween) ? cast event.target : null;
        if (tween != null && tween.isComplete)
            add(tween.nextTween);
    }
	
    public var elapsedTime(get, never):Float;
    private function get_elapsedTime():Float { return mElapsedTime; }
	
    private var objects(get, never):Array<IAnimatable>;
    private function get_objects():Array<IAnimatable> { return mObjects; }
}
