package ru.ice.motion;

import ru.ice.animation.Transitions;
import ru.ice.display.DisplayObject;
import ru.ice.motion.SlideTween;
import ru.ice.controls.Screen;
/**
 * ...
 * @author e.grebennikov
 */
class Slide 
{
	public function new()  {}
	
	public static function createSlideLeftTransition(duration:Float = .5, ease:String = null, tweenProperties:Dynamic = null):DisplayObject->DisplayObject->Dynamic->Void
	{
		if (ease == null)
			ease = Transitions.EASE_OUT;
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Dynamic):Void
		{
			if(oldScreen == null && newScreen == null) {
				trace('Must be one screen is defined.');
			}
			if(newScreen != null) {
				if(oldScreen != null) {
					oldScreen.x = 0;
					oldScreen.y = 0;
				}
				newScreen.x = newScreen.contentWidth;
				newScreen.y = 0;
				new SlideTween(newScreen, oldScreen, -newScreen.contentWidth, 0, duration, ease, onComplete, tweenProperties);
			} else {
				oldScreen.x = 0;
				oldScreen.y = 0;
				new SlideTween(oldScreen, null, -oldScreen.contentWidth, 0, duration, ease, onComplete, tweenProperties);
			}
		}
	}
	
	public static function createSlideRightTransition(duration:Float = 0.5, ease:String = null, tweenProperties:Dynamic = null):DisplayObject->DisplayObject->Dynamic->Void
	{
		if (ease == null)
			ease = Transitions.EASE_OUT;
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Dynamic):Void
		{
			if(oldScreen == null && newScreen == null) {
				trace('Must be one screen is defined.');
			}
			if(newScreen != null) {
				if(oldScreen != null) {
					oldScreen.x = 0;
					oldScreen.y = 0;
				}
				newScreen.x = -newScreen.contentWidth;
				newScreen.y = 0;
				new SlideTween(newScreen, oldScreen, newScreen.contentWidth, 0, duration, ease, onComplete, tweenProperties);
			} else {
				oldScreen.x = 0;
				oldScreen.y = 0;
				new SlideTween(oldScreen, null, oldScreen.contentWidth, 0, duration, ease, onComplete, tweenProperties);
			}
		}
	}
	
	public static function createSlideUpTransition(duration:Float = 0.5, ease:String = null, tweenProperties:Dynamic = null):DisplayObject->DisplayObject->Dynamic->Void
	{
		if (ease == null)
			ease = Transitions.EASE_OUT;
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Dynamic):Void
		{
			if(oldScreen == null && newScreen == null) {
				trace('Must be one screen is defined.');
			}
			if(newScreen != null) {
				if(oldScreen != null) {
					oldScreen.x = 0;
					oldScreen.y = 0;
				}
				newScreen.x = 0;
				newScreen.y = newScreen.contentHeight;
				new SlideTween(newScreen, oldScreen, 0, -newScreen.contentHeight, duration, ease, onComplete, tweenProperties);
			} else {
				oldScreen.x = 0;
				oldScreen.y = 0;
				new SlideTween(oldScreen, null, 0, -oldScreen.contentHeight, duration, ease, onComplete, tweenProperties);
			}
		}
	}
	
	public static function createSlideDownTransition(duration:Float = 0.5, ease:String = null, tweenProperties:Dynamic = null):Screen->Screen->Dynamic->Void
	{
		if (ease == null)
			ease = Transitions.EASE_OUT;
		return function(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Dynamic):Void
		{
			if(oldScreen == null && newScreen == null) {
				trace('Must be one screen is defined.');
			}
			if(newScreen != null) {
				if(oldScreen != null) {
					oldScreen.x = 0;
					oldScreen.y = 0;
				}
				newScreen.x = 0;
				newScreen.y = -newScreen.contentHeight;
				new SlideTween(newScreen, oldScreen, 0, newScreen.contentHeight, duration, ease, onComplete, tweenProperties);
			} else {
				oldScreen.x = 0;
				oldScreen.y = 0;
				new SlideTween(oldScreen, null, 0, oldScreen.contentHeight, duration, ease, onComplete, tweenProperties);
			}
		}
	}
}
