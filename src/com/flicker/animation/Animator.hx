package com.flicker.animation;

import haxe.Constraints.Function;
import haxe.io.Error;

import com.flicker.events.Event;
import com.flicker.events.EventDispatcher;
//import ru.ice.utils.ArrayUtil;

@:access(com.flicker.animation.Delayer)
@:access(com.flicker.animation.Tween)
/**
 * ...
 * @author Evgenii Grebennikov
 */
class Animator implements IAnimatable
{
    private var _objects:Array<IAnimatable>;
    private var _elapsedTime:Float;
    
    public function new()
    {
        _elapsedTime = 0;
        _objects = new Array<IAnimatable>();
    }
	
    public function add(object:IAnimatable):Void
    {
        if (object != null && _objects.indexOf(object) == -1) 
        {
            _objects[_objects.length] = object;
        
            var dispatcher:EventDispatcher = Std.is(object, EventDispatcher) ? cast object : null;
            if (dispatcher != null) dispatcher.addEventListener(Event.REMOVE_FROM_ANIMATOR, onRemove);
        }
    }
    
    public function contains(object:IAnimatable):Bool
    {
        return _objects.indexOf(object) != -1;
    }
    
    public function remove(object:IAnimatable):Void
    {
		var o:Dynamic = cast object;
        if (object == null)
			return;
        
        var dispatcher:EventDispatcher = Std.is(object, EventDispatcher) ? cast object : null;
        if (dispatcher != null)
			dispatcher.removeEventListener(Event.REMOVE_FROM_ANIMATOR, onRemove);

        var index:Int = _objects.indexOf(object);
        if (index != -1)
			_objects[index] = null;
    }
    
    public function removeTweens(target:Dynamic):Void
    {
        if (target == null)
			return;
        var i:Int = _objects.length - 1;
        while (i >= 0) {
            var tween:Tween = Std.is(_objects[i], Tween) ? cast _objects[i] : null;
            if (tween != null && tween.target == target) {
				remove(cast(tween, IAnimatable));
                _objects[i] = null;
            }
            --i;
        }
    }
    
    public function containsTweens(target:Dynamic):Bool
    {
        if (target == null) return false;
        
        var i:Int = _objects.length - 1;
        while (i >= 0) {
            var tween:Tween = Std.is(_objects[i], Tween) ? cast _objects[i] : null;
            if (tween != null && tween.target == target)
				return true;
            --i;
        }
        
        return false;
    }
    
    public function purge():Void
    {
        var i:Int = _objects.length - 1;
        while (i >= 0) {
            var dispatcher:EventDispatcher = Std.is(_objects[i], EventDispatcher) ? cast _objects[i] : null;
            if (dispatcher != null) dispatcher.removeEventListener(Event.REMOVE_FROM_ANIMATOR, onRemove);
            _objects[i] = null;
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
        var numObjects:Int = _objects.length;
        var currentIndex:Int = 0;
        var i:Int = 0;
        
        _elapsedTime += time;
        if (numObjects == 0)
			return;
        
        while (i < numObjects) {
            var object:IAnimatable = _objects[i];
            if (object != null) {
                if (currentIndex != i) {
                    _objects[currentIndex] = object;
                    _objects[i] = null;
                }
                
                object.update(time);
                ++currentIndex;
            }
            ++i;
        }
        
        if (currentIndex != i) {
            numObjects = _objects.length;

            while (i < numObjects) {
                _objects[currentIndex++] = _objects[i++];
			}
			while (_objects.length > currentIndex) {
				_objects.pop();
			}
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
    private function get_elapsedTime():Float { return _elapsedTime; }
	
    private var objects(get, never):Array<IAnimatable>;
    private function get_objects():Array<IAnimatable> { return _objects; }
}
