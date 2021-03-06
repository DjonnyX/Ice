package com.flicker.motion.transitionManager;

import haxe.Constraints.Function;

import com.flicker.animation.Tween;
import com.flicker.controls.TabBar;
import com.flicker.display.DisplayObject;
import com.flicker.controls.itemRenderer.TabBarItemRenderer;
import com.flicker.controls.ScreenNavigator;
import com.flicker.animation.Transitions;
import com.flicker.controls.Screen;
import com.flicker.controls.TabBar;
import com.flicker.motion.Slide;
import com.flicker.events.Event;
import com.flicker.core.Flicker;

/**
 * ...
 * @author e.grebennikov
 */
class TransitionManager 
{
	private var _transition:Dynamic;
	
	private var _screenNavigator:ScreenNavigator;
	
	public var onTransitionComplete:Function;
	
	private var _onComplete:Void->Void;
	
	private var _oldScreen:Screen;
	
	private var _newScreen:Screen;
	
	private var _isFromLeft:Bool = true;
	
	public var skipNextTransition:Bool = false;
	
	public var invertNext:Bool = false;
	
	public var isInvert:Bool = false;
	
	private var _normalTransition:DisplayObject->DisplayObject->Dynamic->Tween;
	
	private var _invertTransition:DisplayObject->DisplayObject->Dynamic->Tween;
	
	public function new(screenNavigator:ScreenNavigator, transition:Dynamic = null) 
	{
		_screenNavigator = screenNavigator;
		_screenNavigator.transition = onTransition;
		_transition = transition;
	}
	
	private function onTransition(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Dynamic) : Void {
		this.onComplete(false);
		_onComplete = onComplete;
		_newScreen = cast newScreen;
		_oldScreen = cast oldScreen;
		if (skipNextTransition || _newScreen == null || _oldScreen == null) {
			skipNextTransition = false;
			if (_oldScreen != null)
				_oldScreen.dispatchEventWith(Event.TRANSITION_OUT_START, true);
			if (_newScreen != null)
				_newScreen.dispatchEventWith(Event.TRANSITION_IN_START, true);
			onComplete();
			return;
		}
		_oldScreen.deactive();
		_isFromLeft = _newScreen.index > _oldScreen.index;
		if (invertNext) {
			_isFromLeft = false;
			invertNext = false;
		}
		if (isInvert)
			_isFromLeft = !_isFromLeft;
		if (_isFromLeft) {
			if (_normalTransition == null) {
				Flicker.animator.removeTweens(_oldScreen);
				Flicker.animator.removeTweens(_newScreen);
				_normalTransition = Slide.createSlideLeftTransition(.5, null, {delay:.05, onStart:this.onStart, transition:Transitions.EASE_OUT});
				_normalTransition(_oldScreen, _newScreen, this.onComplete);
			}
		} else {
			if (_invertTransition == null) {
				Flicker.animator.removeTweens(_oldScreen);
				Flicker.animator.removeTweens(_newScreen);
				_invertTransition = Slide.createSlideRightTransition(.5, null, {delay:.05, onStart:this.onStart, transition:Transitions.EASE_OUT});
				_invertTransition(_oldScreen, _newScreen, this.onComplete);
			}
		}
	}
	
	private function onStart() : Void {
		_oldScreen.dispatchEventWith(Event.TRANSITION_OUT_START, true);
		_newScreen.dispatchEventWith(Event.TRANSITION_IN_START, true);
	}
	
	private function onComplete(e:Bool = true) : Void {
		if (_oldScreen != null) {
			_oldScreen.dispatchEventWith(Event.TRANSITION_OUT_COMPLETE, true);
			Flicker.animator.removeTweens(_oldScreen);
			_oldScreen = null;
		}
		if (_newScreen != null) {
			_newScreen.dispatchEventWith(Event.TRANSITION_IN_COMPLETE, true);
			Flicker.animator.removeTweens(_newScreen);
			_newScreen = null;
		}
		if (e && _onComplete != null) {
			_onComplete();
			_onComplete = null;
		}
		if (_normalTransition != null)
			_normalTransition = null;
		if (_invertTransition != null)
			_invertTransition = null;
	}
	
	public function dispose() : Void {
		onComplete();
		if (_screenNavigator != null) {
			_screenNavigator.transition = null;
			_screenNavigator = null;
		}
	}
}
