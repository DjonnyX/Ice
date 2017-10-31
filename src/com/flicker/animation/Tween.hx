package com.flicker.animation;

import haxe.Constraints.Function;
import haxe.io.Error;

import com.flicker.events.Event;
import com.flicker.events.EventDispatcher;
/**
 * ...
 * @author Evgenii Grebennikov
 */
class Tween extends EventDispatcher implements IAnimatable
{
    private static inline var HINT_MARKER:String = '#';

    private var _target:Dynamic;
    private var _transitionFunc:Float->Float;
    private var _transitionName:String;
    
    private var _properties:Array<String>;
    private var _startValues:Array<Float>;
    private var _endValues:Array<Float>;
    private var _updateFuncs:Array<String->Float->Float->Void>;

    private var _onStart:Function;
    private var _onUpdate:Function;
    private var _onRepeat:Function;
    private var _onComplete:Function;  
    
    private var _onStartArgs:Array<Dynamic>;
    private var _onUpdateArgs:Array<Dynamic>;
    private var _onRepeatArgs:Array<Dynamic>;
    private var _onCompleteArgs:Array<Dynamic>;
    
    private var _totalTime:Float;
    private var _currentTime:Float;
    private var _progress:Float;
    private var _delay:Float;
    private var _roundToInt:Bool;
    private var _nextTween:Tween;
    private var _repeatCount:Int;
    private var _repeatDelay:Float;
    private var _reverse:Bool;
    private var _currentCycle:Int;
    
    public function new(target:Dynamic, time:Float, transition:Dynamic="linear")        
    {
         super();
         reset(target, time, transition);
    }
	
    public function reset(target:Dynamic, time:Float, transition:Dynamic="linear"):Tween
    {
        _target = target;
        _currentTime = 0.0;
        _totalTime = Math.max(0.0001, time);
        _progress = 0.0;
        _delay = _repeatDelay = 0.0;
        _onStart = _onUpdate = _onRepeat = _onComplete = null;
        _onStartArgs = _onUpdateArgs = _onRepeatArgs = _onCompleteArgs = null;
        _roundToInt = _reverse = false;
        _repeatCount = 1;
        _currentCycle = -1;
        _nextTween = null;
        
        if (Std.is(transition, String))
            this.transition = cast transition;
        else if (Reflect.isFunction(transition))
            this.transitionFunc = transition;
        else {
			#if debug
				trace("Transition must be either a string or a function");
			#end
		}
        
       _properties  = new Array<String>();
       _startValues = new Array<Float>();
       _endValues   = new Array<Float>();
       _updateFuncs = new Array<String->Float->Float->Void>();
        
        return this;
    }
	
    public function animate(property:String, endValue:Float):Void
    {
        if (_target == null)
			return;

        var pos:Int = _properties.length;
        var updateFunc:String->Float->Float->Void = getUpdateFuncFromProperty(property);

        _properties[pos] = getPropertyName(property);
        _startValues[pos] = Math.NaN;
        _endValues[pos] = endValue;
        _updateFuncs[pos] = updateFunc;
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
        if (time == 0 || (_repeatCount == 1 && _currentTime == _totalTime)) return;
        
        var i:Int;
        var previousTime:Float = _currentTime;
        var restTime:Float = _totalTime - _currentTime;
        var carryOverTime:Float = time > restTime ? time - restTime : 0;
        
        _currentTime += time;
        
        if (_currentTime <= 0) 
            return;
        else if (_currentTime > _totalTime) 
            _currentTime = _totalTime;
        
        if (_currentCycle < 0 && previousTime <= 0 && _currentTime > 0)
        {
            _currentCycle++;
            if (_onStart != null) {
                if (_onStartArgs != null) {
                    _onStart(_onStartArgs);
                } else {
                    _onStart();
                }
            }
        }

        var ratio:Float = _currentTime / _totalTime;
        var reversed:Bool = _reverse && (_currentCycle % 2 == 1);
        var numProperties:Int = _startValues.length;
        _progress = reversed ? _transitionFunc(1.0 - ratio) : _transitionFunc(ratio);

        for (i in 0...numProperties)
        {                
            if (_startValues[i] != _startValues[i])
                _startValues[i] = Reflect.getProperty(_target, _properties[i]);

            var updateFunc:String->Float->Float->Void = _updateFuncs[i];
            updateFunc(_properties[i], _startValues[i], _endValues[i]);
        }

        if (_onUpdate != null) {
            if (_onUpdateArgs != null) {
                _onUpdate(_onUpdateArgs);
            } else {
                _onUpdate();
            }
        }
        
        if (previousTime < _totalTime && _currentTime >= _totalTime)
        {
            if (_repeatCount == 0 || _repeatCount > 1)
            {
                _currentTime = -_repeatDelay;
                _currentCycle++;
                if (_repeatCount > 1)
					_repeatCount--;
                if (_onRepeat != null) {
                    if (_onRepeatArgs != null) {
                        _onRepeat(_onRepeatArgs);
                    } else {
                        _onRepeat();
                    }
                }
            }
            else
            {
                var onComplete_:Function = _onComplete;
                var onCompleteArgs_:Array<Dynamic> = _onCompleteArgs;
                
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
				#if debug
					trace("[Starling] Ignoring unknown property hint: " + hint);
				#end
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
        var newValue:Float = startValue + _progress * (endValue - startValue);
        if (_roundToInt) newValue = Math.round(newValue);
        Reflect.setProperty(_target, property, newValue);
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

        var newA:UInt = Std.int(startA + (endA - startA) * _progress);
        var newR:UInt = Std.int(startR + (endR - startR) * _progress);
        var newG:UInt = Std.int(startG + (endG - startG) * _progress);
        var newB:UInt = Std.int(startB + (endB - startB) * _progress);

        Reflect.setProperty(_target, property, (newA << 24) | (newR << 16) | (newG << 8) | newB);
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
        var index:Int = _properties.indexOf(property);
        if (index == -1) {
			#if debug
				trace("The property '" + property + "' is not animated");
			#end
			return 0;
        } else return _endValues[index];
    }
	
    public var isComplete(get, never):Bool;
    private function get_isComplete():Bool 
    { 
        return _currentTime >= _totalTime && _repeatCount == 1; 
    }
	
    public var target(get, never):Dynamic;
    private function get_target():Dynamic { return _target; }
	
    public var transition(get, set):String;
    private function get_transition():String { return _transitionName; }
    private function set_transition(value:String):String 
    { 
        _transitionName = value;
        _transitionFunc = Transitions.getTransition(value);
        
        if (_transitionFunc == null) {
			#if debug
				trace("Invalid transiton: " + value);
			#end
		}
        return _transitionName;
    }
	
    public var transitionFunc(get, set):Float->Float;
    private function get_transitionFunc():Float->Float { return _transitionFunc; }
    private function set_transitionFunc(value:Float->Float):Float->Float
    {
        _transitionName = "custom";
        _transitionFunc = value;
        return value;
    }
    
    public var totalTime(get, never):Float;
    private function get_totalTime():Float { return _totalTime; }
	
    public var currentTime(get, never):Float;
    private function get_currentTime():Float { return _currentTime; }
	
    public var progress(get, never):Float;
    private function get_progress():Float { return _progress; }
	
    public var delay(get, set):Float;
    private function get_delay():Float { return _delay; }
    private function set_delay(value:Float):Float 
    { 
        _currentTime = _currentTime + _delay - value;
        _delay = value;
        return _delay;
    }
	
    public var repeatCount(get, set):Int;
    private function get_repeatCount():Int { return _repeatCount; }
    private function set_repeatCount(value:Int):Int { return _repeatCount = value; }
	
    public var repeatDelay(get, set):Float;
    private function get_repeatDelay():Float { return _repeatDelay; }
    private function set_repeatDelay(value:Float):Float { return _repeatDelay = value; }
	
    public var reverse(get, set):Bool;
    private function get_reverse():Bool { return _reverse; }
    private function set_reverse(value:Bool):Bool { return _reverse = value; }
	
    public var roundToInt(get, set):Bool;
    private function get_roundToInt():Bool { return _roundToInt; }
    private function set_roundToInt(value:Bool):Bool { return _roundToInt = value; }        
	
    public var onStart(get, set):Function;
    private function get_onStart():Function { return _onStart; }
    private function set_onStart(value:Function):Function { return _onStart = value; }
	
    public var onUpdate(get, set):Function;
    private function get_onUpdate():Function { return _onUpdate; }
    private function set_onUpdate(value:Function):Function { return _onUpdate = value; }
	
    public var onRepeat(get, set):Function;
    private function get_onRepeat():Function { return _onRepeat; }
    private function set_onRepeat(value:Function):Function { return _onRepeat = value; }
    
    public var onComplete(get, set):Function;
    private function get_onComplete():Function { return _onComplete; }
    private function set_onComplete(value:Function):Function { return _onComplete = value; }
    
    public var onStartArgs(get, set):Array<Dynamic>;
    private function get_onStartArgs():Array<Dynamic> { return _onStartArgs; }
    private function set_onStartArgs(value:Array<Dynamic>):Array<Dynamic> { return _onStartArgs = value; }
    
    public var onUpdateArgs:Array<Dynamic>;
    private function get_onUpdateArgs():Array<Dynamic> { return _onUpdateArgs; }
    private function set_onUpdateArgs(value:Array<Dynamic>):Void { _onUpdateArgs = value; }
    
    public var onRepeatArgs(get, set):Array<Dynamic>;
    private function get_onRepeatArgs():Array<Dynamic> { return _onRepeatArgs; }
    private function set_onRepeatArgs(value:Array<Dynamic>):Array<Dynamic> { return _onRepeatArgs = value; }
    
    public var onCompleteArgs(get, set):Array<Dynamic>;
    private function get_onCompleteArgs():Array<Dynamic> { return _onCompleteArgs; }
    private function set_onCompleteArgs(value:Array<Dynamic>):Array<Dynamic> { return _onCompleteArgs = value; }
    
    public var nextTween(get, set):Tween;
    private function get_nextTween():Tween { return _nextTween; }
    private function set_nextTween(value:Tween):Tween { return _nextTween = value; }
    
    private static var sTweenPool:Array<Tween> = new Array<Tween>();
    
    private static function fromPool(target:Dynamic, time:Float, transition:Dynamic="linear"):Tween
    {
        if (sTweenPool.length != 0) return sTweenPool.pop().reset(target, time, transition);
        else return new Tween(target, time, transition);
    }
    
    private static function toPool(tween:Tween):Void
    {
        tween._onStart = tween._onUpdate = tween._onRepeat = tween._onComplete = null;
        tween._onStartArgs = tween._onUpdateArgs = tween._onRepeatArgs = tween._onCompleteArgs = null;
        tween._target = null;
        tween._transitionFunc = null;
        tween.removeEventListeners();
        sTweenPool.push(tween);
    }
}
