package ru.ice.animation;

import haxe.Constraints.Function;

import ru.ice.events.Event;
import ru.ice.events.EventDispatcher;
/**
 * ...
 * @author Evgenii Grebennikov
 */
class Delayer extends EventDispatcher implements IAnimatable
{
    private var mCurrentTime:Float;
    private var mTotalTime:Float;
    private var mCall:Function;
    private var mArgs:Array<Dynamic>;
    private var mRepeatCount:Int;
    
    public function new(call:Function, delay:Float, args:Array<Dynamic>=null)
    {
        super();
        reset(call, delay, args);
    }
    
    public function reset(call:Function, delay:Float, args:Array<Dynamic>=null):Delayer
    {
        mCurrentTime = 0;
        mTotalTime = Math.max(delay, 0.0001);
        mCall = call;
        mArgs = args;
        mRepeatCount = 1;
        
        return this;
    }
    
    public function update(time:Float):Void
    {
        var previousTime:Float = mCurrentTime;
        mCurrentTime += time;

        if (mCurrentTime > mTotalTime)
            mCurrentTime = mTotalTime;
        
        if (previousTime < mTotalTime && mCurrentTime >= mTotalTime)
        {                
            if (mRepeatCount == 0 || mRepeatCount > 1)
            {
                Reflect.callMethod(mCall, mCall, mArgs);
                
                if (mRepeatCount > 0) mRepeatCount -= 1;
                mCurrentTime = 0;
                update((previousTime + time) - mTotalTime);
            }
            else
            {
                var call:Function = mCall;
                var args:Array<Dynamic> = mArgs;
                
                dispatchEventWith(Event.REMOVE_FROM_ANIMATOR);
                Reflect.callMethod(call, call, args);
            }
        }
    }
	
    public function complete():Void
    {
        var restTime:Float = mTotalTime - mCurrentTime;
        if (restTime > 0) update(restTime);
    }
    
    public var isComplete(get, never):Bool;
    private function get_isComplete():Bool 
    { 
        return mRepeatCount == 1 && mCurrentTime >= mTotalTime; 
    }
    
    public var totalTime(get, never):Float;
    private function get_totalTime():Float { return mTotalTime; }
    
    public var currentTime(get, never):Float;
    private function get_currentTime():Float { return mCurrentTime; }
    
    public var repeatCount(get, set):Int;
    private function get_repeatCount():Int { return mRepeatCount; }
    private function set_repeatCount(value:Int):Int { return mRepeatCount = value; }
    
    private static var sPool:Array<Delayer> = new Array<Delayer>();
    
    private static function fromPool(call:Function, delay:Float, 
                                               args:Array<Dynamic>=null):Delayer
    {
        if (sPool.length != 0) return sPool.pop().reset(call, delay, args);
        else return new Delayer(call, delay, args);
    }
    
    public static function toPool(delayedCall:Delayer):Void
    {
        delayedCall.mCall = null;
        delayedCall.mArgs = null;
        delayedCall.removeEventListeners();
        sPool.push(delayedCall);
    }
}