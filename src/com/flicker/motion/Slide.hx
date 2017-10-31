package com.flicker.motion;

import com.flicker.animation.Transitions;
import com.flicker.display.DisplayObject;
import com.flicker.motion.SlideTween;
import com.flicker.animation.Tween;
import com.flicker.controls.Screen;
/**
 * ...
 * @author e.grebennikov
 */
class Slide 
{
	public function new()  {}
	
	public static function createSlideLeftTransition(duration:Float = .5, ease:String = null, tweenProperties:Dynamic = null):DisplayObject->DisplayObject->Dynamic->Tween
	{
		if (ease == null)
			ease = Transitions.EASE_OUT;
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Dynamic):Tween
		{
			#if debug
				if(oldScreen == null && newScreen == null)
					trace('Must be one screen is defined.');
			#end
			if(newScreen != null) {
				if(oldScreen != null) {
					oldScreen.x = 0;
					oldScreen.y = 0;
				}
				newScreen.x = newScreen.width;
				newScreen.y = 0;
				return new SlideTween(newScreen, oldScreen, -newScreen.width, 0, duration, ease, onComplete, tweenProperties);
			} else {
				oldScreen.x = 0;
				oldScreen.y = 0;
				return new SlideTween(oldScreen, null, -oldScreen.width, 0, duration, ease, onComplete, tweenProperties);
			}
			return null;
		}
	}
	
	public static function createSlideRightTransition(duration:Float = 0.5, ease:String = null, tweenProperties:Dynamic = null):DisplayObject->DisplayObject->Dynamic->Tween
	{
		if (ease == null)
			ease = Transitions.EASE_OUT;
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Dynamic):Tween
		{
			#if debug
				if(oldScreen == null && newScreen == null)
					trace('Must be one screen is defined.');
			#end
			if(newScreen != null) {
				if(oldScreen != null) {
					oldScreen.x = 0;
					oldScreen.y = 0;
				}
				newScreen.x = -newScreen.width;
				newScreen.y = 0;
				return new SlideTween(newScreen, oldScreen, newScreen.width, 0, duration, ease, onComplete, tweenProperties);
			} else {
				oldScreen.x = 0;
				oldScreen.y = 0;
				return new SlideTween(oldScreen, null, oldScreen.width, 0, duration, ease, onComplete, tweenProperties);
			}
			return null;
		}
	}
	
	public static function createSlideUpTransition(duration:Float = 0.5, ease:String = null, tweenProperties:Dynamic = null):DisplayObject->DisplayObject->Dynamic->Tween
	{
		if (ease == null)
			ease = Transitions.EASE_OUT;
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Dynamic):Tween
		{
			#if debug
				if(oldScreen == null && newScreen == null)
					trace('Must be one screen is defined.');
			#end
			if(newScreen != null) {
				if(oldScreen != null) {
					oldScreen.x = 0;
					oldScreen.y = 0;
				}
				newScreen.x = 0;
				newScreen.y = newScreen.height;
				return new SlideTween(newScreen, oldScreen, 0, -newScreen.height, duration, ease, onComplete, tweenProperties);
			} else {
				oldScreen.x = 0;
				oldScreen.y = 0;
				return new SlideTween(oldScreen, null, 0, -oldScreen.height, duration, ease, onComplete, tweenProperties);
			}
			return null;
		}
	}
	
	public static function createSlideDownTransition(duration:Float = 0.5, ease:String = null, tweenProperties:Dynamic = null):Screen->Screen->Dynamic->Tween
	{
		if (ease == null)
			ease = Transitions.EASE_OUT;
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Dynamic):Tween
		{
			#if debug
				if(oldScreen == null && newScreen == null)
					trace('Must be one screen is defined.');
			#end
			if(newScreen != null) {
				if(oldScreen != null) {
					oldScreen.x = 0;
					oldScreen.y = 0;
				}
				newScreen.x = 0;
				newScreen.y = -newScreen.height;
				return new SlideTween(newScreen, oldScreen, 0, newScreen.height, duration, ease, onComplete, tweenProperties);
			} else {
				oldScreen.x = 0;
				oldScreen.y = 0;
				return new SlideTween(oldScreen, null, 0, oldScreen.height, duration, ease, onComplete, tweenProperties);
			}
			return null;
		}
	}
}
