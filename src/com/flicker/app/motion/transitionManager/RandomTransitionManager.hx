package com.flicker.app.motion.transitionManager;

import haxe.Constraints.Function;
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
class RandomTransitionManager 
{
	private var _collection:Dynamic;
	
	private var _screenNavigator:ScreenNavigator;
	
	public var onTransitionComplete:Function;
	
	private var _onComplete:Void->Void;
	
	private var _oldScreen:Screen;
	
	private var _newScreen:Screen;
	
	public var delay:Float = .135;
	
	public var skipNextTransition:Bool = false;
	
	private var _transition:DisplayObject->DisplayObject->Dynamic->Void;
	
	private var _transitions:Array<Function> = [
		Slide.createSlideLeftTransition,
		Slide.createSlideRightTransition,
		Slide.createSlideUpTransition,
		Slide.createSlideDownTransition
	];
	
	public function new(screenNavigator:ScreenNavigator, collection:Dynamic = null) 
	{
		_screenNavigator = screenNavigator;
		_screenNavigator.transition = onTransition;
		_collection = collection;
	}
	
	private function onTransition(oldScreen:DisplayObject, newScreen:DisplayObject, onComplete:Dynamic) : Void {
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
		
		if (_transition == null) {
			var r:Int = Math.round(Math.random() * 3);
			var transition:Function = _transitions[r];
			_transition = transition(1, Transitions.EASE_IN_OUT, {onStart:this.onStart});
			_transition(_oldScreen, _newScreen, this.onComplete);
		}
	}
	
	private function onStart() : Void {
		_oldScreen.dispatchEventWith(Event.TRANSITION_OUT_START, true);
		_newScreen.dispatchEventWith(Event.TRANSITION_IN_START, true);
	}
	
	private function onComplete() : Void {
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
		if (_onComplete != null) {
			_onComplete();
			_onComplete = null;
		}
		if (_transition != null)
			_transition = null;
	}
	
	public function dispose() : Void {
		_collection = null;
		onComplete();
		if (_screenNavigator != null) {
			_screenNavigator.transition = null;
			_screenNavigator = null;
		}
	}
}
