package ru.ice.animation;

import haxe.Constraints.Function;
import haxe.io.Error;

import ru.ice.events.Event;
import ru.ice.events.EventDispatcher;
/**
 * ...
 * @author Evgenii Grebennikov
 */
class Tween extends EventDispatcher implements IAnimatable
{
    private static inline var HINT_MARKER:String = '#';

    private var mTarget:Dynamic;
    private var mTransitionFunc:Float->Float;
    private var mTransitionName:String;
    
    private var mProperties:Array<String>;
    private var mStartValues:Array<Float>;
    private var mEndValues:Array<Float>;
    private var mUpdateFuncs:Array<String->Float->Float->Void>;

    private var mOnStart:Function;
    private var mOnUpdate:Function;
    private var mOnRepeat:Function;
    private var mOnComplete:Function;  
    
    private var mOnStartArgs:Array<Dynamic>;
    private var mOnUpdateArgs:Array<Dynamic>;
    private var mOnRepeatArgs:Array<Dynamic>;
    private var mOnCompleteArgs:Array<Dynamic>;
    
    private var mTotalTime:Float;
    private var mCurrentTime:Float;
    private var mProgress:Float;
    private var mDelay:Float;
    private var mRoundToInt:Bool;
    private var mNextTween:Tween;
    private var mRepeatCount:Int;
    private var mRepeatDelay:Float;
    private var mReverse:Bool;
    private var mCurrentCycle:Int;
    
    public function new(target:Dynamic, time:Float, transition:Dynamic="linear")        
    {
         super();
         reset(target, time, transition);
    }
	
    public function reset(target:Dynamic, time:Float, transition:Dynamic="linear"):Tween
    {
        mTarget = target;
        mCurrentTime = 0.0;
        mTotalTime = Math.max(0.0001, time);
        mProgress = 0.0;
        mDelay = mRepeatDelay = 0.0;
        mOnStart = mOnUpdate = mOnRepeat = mOnComplete = null;
        mOnStartArgs = mOnUpdateArgs = mOnRepeatArgs = mOnCompleteArgs = null;
        mRoundToInt = mReverse = false;
        mRepeatCount = 1;
        mCurrentCycle = -1;
        mNextTween = null;
        
        if (Std.is(transition, String))
            this.transition = cast transition;
        else if (Reflect.isFunction(transition))
            this.transitionFunc = transition;
        else 
            trace("Transition must be either a string or a function");
        
       mProperties  = new Array<String>();
       mStartValues = new Array<Float>();
       mEndValues   = new Array<Float>();
       mUpdateFuncs = new Array<String->Float->Float->Void>();
        
        return this;
    }
	
    public function animate(property:String, endValue:Float):Void
    {
        if (mTarget == null)
			return;

        var pos:Int = mProperties.length;
        var updateFunc:String->Float->Float->Void = getUpdateFuncFromProperty(property);

        mProperties[pos] = getPropertyName(property);
        mStartValues[pos] = Math.NaN;
        mEndValues[pos] = endValue;
        mUpdateFuncs[pos] = updateFunc;
    }
	
    public function scaleTo(factor:Float):Void
    {
        animate("scaleX", factor);
        animate("scaleY", factor);
    }
	
    public function moveTo(x:Float, y:Float):Void
    {
        animate("x", x);
        animate("y", y);
    }
    
    public function fadeTo(alpha:Float):Void
    {
        animate("alpha", alpha);
    }
	
    public function rotateTo(angle:Float, type:String="rad"):Void
    {
        animate("rotation#" + type, angle);
    }
	
    public function update(time:Float):Void
    {
        if (time == 0 || (mRepeatCount == 1 && mCurrentTime == mTotalTime)) return;
        
        var i:Int;
        var previousTime:Float = mCurrentTime;
        var restTime:Float = mTotalTime - mCurrentTime;
        var carryOverTime:Float = time > restTime ? time - restTime : 0.0;
        
        mCurrentTime += time;
        
        if (mCurrentTime <= 0) 
            return; // the delay is not over yet
        else if (mCurrentTime > mTotalTime) 
            mCurrentTime = mTotalTime;
        
        if (mCurrentCycle < 0 && previousTime <= 0 && mCurrentTime > 0)
        {
            mCurrentCycle++;
            if (mOnStart != null) {
                if (mOnStartArgs != null) {
                    mOnStart(mOnStartArgs);
                } else {
                    mOnStart();
                }
            }
        }

        var ratio:Float = mCurrentTime / mTotalTime;
        var reversed:Bool = mReverse && (mCurrentCycle % 2 == 1);
        var numProperties:Int = mStartValues.length;
        mProgress = reversed ? mTransitionFunc(1.0 - ratio) : mTransitionFunc(ratio);

        for (i in 0...numProperties)
        {                
            if (mStartValues[i] != mStartValues[i]) // isNaN check - "isNaN" causes allocation! 
                mStartValues[i] = Reflect.getProperty(mTarget, mProperties[i]);

            var updateFunc:String->Float->Float->Void = mUpdateFuncs[i];
            updateFunc(mProperties[i], mStartValues[i], mEndValues[i]);
        }

        if (mOnUpdate != null) {
            if (mOnUpdateArgs != null) {
                mOnUpdate(mOnUpdateArgs);
            } else {
                mOnUpdate();
            }
        }
        
        if (previousTime < mTotalTime && mCurrentTime >= mTotalTime)
        {
            if (mRepeatCount == 0 || mRepeatCount > 1)
            {
                mCurrentTime = -mRepeatDelay;
                mCurrentCycle++;
                if (mRepeatCount > 1) mRepeatCount--;
                if (mOnRepeat != null) {
                    if (mOnRepeatArgs != null) {
                        mOnRepeat(mOnRepeatArgs);
                    } else {
                        mOnRepeat();
                    }
                }
            }
            else
            {
                var onComplete_:Function = mOnComplete;
                var onCompleteArgs_:Array<Dynamic> = mOnCompleteArgs;
                
                if (onComplete_ != null) {
                    if (onCompleteArgs_ != null) {
                        onComplete_(onCompleteArgs_);
                    } else {
                        onComplete_();
                    }
                }
            }
        }
        
        if (carryOverTime != 0) 
            update(carryOverTime);
    }
	
    private function getUpdateFuncFromProperty(property:String):String->Float->Float->Void
    {
        var updateFunc:String->Float->Float->Void;
        var hint:String = getPropertyHint(property);

        switch (hint)
        {
            case null:  updateFunc = updateStandard;
            case "rgb": updateFunc = updateRgb;
            case "rad": updateFunc = updateRad;
            case "deg": updateFunc = updateDeg;
            default:
                trace("[Starling] Ignoring unknown property hint: " + hint);
                updateFunc = updateStandard;
        }

        return updateFunc;
    }
	
    private static function getPropertyHint(property:String):String
    {
        if (property.indexOf("color") != -1 || property.indexOf("Color") != -1)
            return "rgb";

        var hintMarkerIndex:Int = property.indexOf(HINT_MARKER);
        if (hintMarkerIndex != -1) return property.substr(hintMarkerIndex+1);
        else return null;
    }
	
    private static function getPropertyName(property:String):String
    {
        var hintMarkerIndex:Int = property.indexOf(HINT_MARKER);
        if (hintMarkerIndex != -1) return property.substring(0, hintMarkerIndex);
        else return property;
    }

    private function updateStandard(property:String, startValue:Float, endValue:Float):Void
    {
        var newValue:Float = startValue + mProgress * (endValue - startValue);
        if (mRoundToInt) newValue = Math.round(newValue);
        Reflect.setProperty(mTarget, property, newValue);
    }

    private function updateRgb(property:String, startValue:Float, endValue:Float):Void
    {
        var startColor:UInt = Std.int(startValue);
        var endColor:UInt   = Std.int(endValue);

        var startA:UInt = (startColor >> 24) & 0xff;
        var startR:UInt = (startColor >> 16) & 0xff;
        var startG:UInt = (startColor >>  8) & 0xff;
        var startB:UInt = (startColor      ) & 0xff;

        var endA:UInt = (endColor >> 24) & 0xff;
        var endR:UInt = (endColor >> 16) & 0xff;
        var endG:UInt = (endColor >>  8) & 0xff;
        var endB:UInt = (endColor      ) & 0xff;

        var newA:UInt = Std.int(startA + (endA - startA) * mProgress);
        var newR:UInt = Std.int(startR + (endR - startR) * mProgress);
        var newG:UInt = Std.int(startG + (endG - startG) * mProgress);
        var newB:UInt = Std.int(startB + (endB - startB) * mProgress);

        Reflect.setProperty(mTarget, property, (newA << 24) | (newR << 16) | (newG << 8) | newB);
    }

    private function updateRad(property:String, startValue:Float, endValue:Float):Void
    {
        updateAngle(Math.PI, property, startValue, endValue);
    }

    private function updateDeg(property:String, startValue:Float, endValue:Float):Void
    {
        updateAngle(180, property, startValue, endValue);
    }

    private function updateAngle(pi:Float, property:String, startValue:Float, endValue:Float):Void
    {
        while (Math.abs(endValue - startValue) > pi)
        {
            if (startValue < endValue) endValue -= 2.0 * pi;
            else                       endValue += 2.0 * pi;
        }

        updateStandard(property, startValue, endValue);
    }
	
    public function getEndValue(property:String):Float
    {
        var index:Int = mProperties.indexOf(property);
        if (index == -1) {
			trace("The property '" + property + "' is not animated");
			return 0;
        } else return mEndValues[index];
    }
	
    public var isComplete(get, never):Bool;
    private function get_isComplete():Bool 
    { 
        return mCurrentTime >= mTotalTime && mRepeatCount == 1; 
    }
	
    public var target(get, never):Dynamic;
    private function get_target():Dynamic { return mTarget; }
	
    public var transition(get, set):String;
    private function get_transition():String { return mTransitionName; }
    private function set_transition(value:String):String 
    { 
        mTransitionName = value;
        mTransitionFunc = Transitions.getTransition(value);
        
        if (mTransitionFunc == null)
            trace("Invalid transiton: " + value);
        return mTransitionName;
    }
	
    public var transitionFunc(get, set):Float->Float;
    private function get_transitionFunc():Float->Float { return mTransitionFunc; }
    private function set_transitionFunc(value:Float->Float):Float->Float
    {
        mTransitionName = "custom";
        mTransitionFunc = value;
        return value;
    }
    
    public var totalTime(get, never):Float;
    private function get_totalTime():Float { return mTotalTime; }
	
    public var currentTime(get, never):Float;
    private function get_currentTime():Float { return mCurrentTime; }
	
    public var progress(get, never):Float;
    private function get_progress():Float { return mProgress; }
	
    public var delay(get, set):Float;
    private function get_delay():Float { return mDelay; }
    private function set_delay(value:Float):Float 
    { 
        mCurrentTime = mCurrentTime + mDelay - value;
        mDelay = value;
        return mDelay;
    }
	
    public var repeatCount(get, set):Int;
    private function get_repeatCount():Int { return mRepeatCount; }
    private function set_repeatCount(value:Int):Int { return mRepeatCount = value; }
	
    public var repeatDelay(get, set):Float;
    private function get_repeatDelay():Float { return mRepeatDelay; }
    private function set_repeatDelay(value:Float):Float { return mRepeatDelay = value; }
	
    public var reverse(get, set):Bool;
    private function get_reverse():Bool { return mReverse; }
    private function set_reverse(value:Bool):Bool { return mReverse = value; }
	
    public var roundToInt(get, set):Bool;
    private function get_roundToInt():Bool { return mRoundToInt; }
    private function set_roundToInt(value:Bool):Bool { return mRoundToInt = value; }        
	
    public var onStart(get, set):Function;
    private function get_onStart():Function { return mOnStart; }
    private function set_onStart(value:Function):Function { return mOnStart = value; }
	
    public var onUpdate(get, set):Function;
    private function get_onUpdate():Function { return mOnUpdate; }
    private function set_onUpdate(value:Function):Function { return mOnUpdate = value; }
	
    public var onRepeat(get, set):Function;
    private function get_onRepeat():Function { return mOnRepeat; }
    private function set_onRepeat(value:Function):Function { return mOnRepeat = value; }
    
    public var onComplete(get, set):Function;
    private function get_onComplete():Function { return mOnComplete; }
    private function set_onComplete(value:Function):Function { return mOnComplete = value; }
    
    public var onStartArgs(get, set):Array<Dynamic>;
    private function get_onStartArgs():Array<Dynamic> { return mOnStartArgs; }
    private function set_onStartArgs(value:Array<Dynamic>):Array<Dynamic> { return mOnStartArgs = value; }
    
    public var onUpdateArgs:Array<Dynamic>;
    private function get_onUpdateArgs():Array<Dynamic> { return mOnUpdateArgs; }
    private function set_onUpdateArgs(value:Array<Dynamic>):Void { mOnUpdateArgs = value; }
    
    public var onRepeatArgs(get, set):Array<Dynamic>;
    private function get_onRepeatArgs():Array<Dynamic> { return mOnRepeatArgs; }
    private function set_onRepeatArgs(value:Array<Dynamic>):Array<Dynamic> { return mOnRepeatArgs = value; }
    
    public var onCompleteArgs(get, set):Array<Dynamic>;
    private function get_onCompleteArgs():Array<Dynamic> { return mOnCompleteArgs; }
    private function set_onCompleteArgs(value:Array<Dynamic>):Array<Dynamic> { return mOnCompleteArgs = value; }
    
    public var nextTween(get, set):Tween;
    private function get_nextTween():Tween { return mNextTween; }
    private function set_nextTween(value:Tween):Tween { return mNextTween = value; }
    
    private static var sTweenPool:Array<Tween> = new Array<Tween>();
    
    private static function fromPool(target:Dynamic, time:Float, transition:Dynamic="linear"):Tween
    {
        if (sTweenPool.length != 0) return sTweenPool.pop().reset(target, time, transition);
        else return new Tween(target, time, transition);
    }
    
    private static function toPool(tween:Tween):Void
    {
        tween.mOnStart = tween.mOnUpdate = tween.mOnRepeat = tween.mOnComplete = null;
        tween.mOnStartArgs = tween.mOnUpdateArgs = tween.mOnRepeatArgs = tween.mOnCompleteArgs = null;
        tween.mTarget = null;
        tween.mTransitionFunc = null;
        tween.removeEventListeners();
        sTweenPool.push(tween);
    }
}
