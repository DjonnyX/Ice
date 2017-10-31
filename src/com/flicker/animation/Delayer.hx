package com.flicker.animation;

import haxe.Constraints.Function;

import com.flicker.events.Event;
import com.flicker.events.EventDispatcher;
/**
 * ...
 * @author Evgenii Grebennikov
 */
class Delayer extends EventDispatcher implements IAnimatable
{
    private var _currentTime:Float;
    private var _totalTime:Float;
    private var _call:Function;
    private var _args:Array<Dynamic>;
    private var _repeatCount:Int;
    
    public function new(call:Function, delay:Float, args:Array<Dynamic>=null)
    {
        super();
        reset(call, delay, args);
    }
    
    public function reset(call:Function, delay:Float, args:Array<Dynamic>=null):Delayer
    {
        _currentTime = 0;
        _totalTime = Math.max(delay, 0.0001);
        _call = call;
        _args = args;
        _repeatCount = 1;
        
        return this;
    }
    
    public function update(time:Float):Void
    {
        var previousTime:Float = _currentTime;
        _currentTime += time;

        if (_currentTime > _totalTime)
            _currentTime = _totalTime;
        
        if (previousTime < _totalTime && _currentTime >= _totalTime)
        {                
            if (_repeatCount == 0 || _repeatCount > 1)
            {
                Reflect.callMethod(_call, _call, _args);
                
                if (_repeatCount > 0) _repeatCount -= 1;
                _currentTime = 0;
                update((previousTime + time) - _totalTime);
            }
            else
            {
                var call:Function = _call;
                var args:Array<Dynamic> = _args;
                
                dispatchEventWith(Event.REMOVE_FROM_ANIMATOR);
                Reflect.callMethod(call, call, args);
            }
        }
    }
	
    public function complete():Void
    {
        var restTime:Float = _totalTime - _currentTime;
        if (restTime > 0) update(restTime);
    }
    
    public var isComplete(get, never):Bool;
    private function get_isComplete():Bool 
    { 
        return _repeatCount == 1 && _currentTime >= _totalTime; 
    }
    
    public var totalTime(get, never):Float;
    private function get_totalTime():Float { return _totalTime; }
    
    public var currentTime(get, never):Float;
    private function get_currentTime():Float { return _currentTime; }
    
    public var repeatCount(get, set):Int;
    private function get_repeatCount():Int { return _repeatCount; }
    private function set_repeatCount(value:Int):Int { return _repeatCount = value; }
    
    private static var sPool:Array<Delayer> = new Array<Delayer>();
    
    private static function fromPool(call:Function, delay:Float, 
                                               args:Array<Dynamic>=null):Delayer
    {
        if (sPool.length != 0) return sPool.pop().reset(call, delay, args);
        else return new Delayer(call, delay, args);
    }
    
    public static function toPool(delayedCall:Delayer):Void
    {
        delayedCall._call = null;
        delayedCall._args = null;
        delayedCall.removeEventListeners();
        sPool.push(delayedCall);
    }
}