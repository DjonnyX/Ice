package com.flicker.motion;

import com.flicker.controls.ScreenNavigator;
import com.flicker.display.DisplayObject;
import com.flicker.animation.Tween;
import com.flicker.core.Flicker;

/**
 * ...
 * @author e.grebennikov
 */
class SlideTween extends Tween
{
	private var _navigator:DisplayObject;
	private var _otherTarget:DisplayObject;
	private var _onCompleteCallback:Dynamic;
	private var _xOffset:Float = 0;
	private var _yOffset:Float = 0;
	
	public function new(target:DisplayObject, otherTarget:DisplayObject,
		xOffset:Float, yOffset:Float, duration:Float, ease:String,
		onCompleteCallback:Dynamic, tweenProperties:Dynamic)
	{
		super(target, duration, ease);
		if(xOffset != 0) {
			_xOffset = xOffset;
			animate("x", target.x + xOffset);
		}
		if(yOffset != 0) {
			_yOffset = yOffset;
			animate("y", target.y + yOffset);
		}
		if(tweenProperties != null) {
			for(propertyName in Reflect.fields(tweenProperties)) {
				Reflect.setProperty(this, propertyName, Reflect.field(tweenProperties, propertyName));
			}
		}
		_navigator = target.parent;
		if(otherTarget != null) {
			_otherTarget = otherTarget;
			onUpdate = updateOtherTarget;
		}
		_onCompleteCallback = onCompleteCallback;
		onComplete = cleanupTween;
		Flicker.animator.add(this);
	}

	private function updateOtherTarget():Void
	{
		var newScreen:DisplayObject = cast(target, DisplayObject);
		if(_xOffset < 0) {
			_otherTarget.x = newScreen.x - _navigator.width;
		}
		else if(_xOffset > 0) {
			_otherTarget.x = newScreen.x + newScreen.width;
		}
		if(_yOffset < 0) {
			_otherTarget.y = newScreen.y - _navigator.height;
		}
		else if (_yOffset > 0) {
			_otherTarget.y = newScreen.y + newScreen.height;
		}
	}

	private function cleanupTween():Void
	{
		target.x = 0;
		target.y = 0;
		if(_otherTarget != null) {
			_otherTarget.x = 0;
			_otherTarget.y = 0;
		}
		if(_onCompleteCallback != null)
			_onCompleteCallback();
	}
}