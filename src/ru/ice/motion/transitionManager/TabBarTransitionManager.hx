package ru.ice.motion.transitionManager;

import haxe.Constraints.Function;
import ru.ice.controls.TabBar;
import ru.ice.display.DisplayObject;

import ru.ice.controls.itemRenderer.TabBarItemRenderer;
import ru.ice.controls.ScreenNavigator;
import ru.ice.animation.Transitions;
import ru.ice.controls.Screen;
import ru.ice.controls.TabBar;
import ru.ice.motion.Slide;
import ru.ice.events.Event;
import ru.ice.core.Ice;

/**
 * ...
 * @author e.grebennikov
 */
class TabBarTransitionManager 
{
	private var _transition:Dynamic;
	
	private var _screenNavigator:ScreenNavigator;
	
	public var onTransitionComplete:Function;
	
	private var _onComplete:Void->Void;
	
	private var _oldScreen:Screen;
	
	private var _newScreen:Screen;
	
	//private var _tabBar:TabBar;
	
	private var _isFromLeft:Bool = true;
	
	public var delay:Float = .135;
	
	public var skipNextTransition:Bool = false;
	
	public var invertNext:Bool = false;
	
	private var _normalTransition:DisplayObject->DisplayObject->Dynamic->Void;
	
	private var _invertTransition:DisplayObject->DisplayObject->Dynamic->Void;
	
	public function new(screenNavigator:ScreenNavigator/*, tabBar:TabBar*/, transition:Dynamic = null) 
	{
		//_tabBar = tabBar;
		_screenNavigator = screenNavigator;
		_screenNavigator.transition = onTransition;
		_transition = transition;
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
		_isFromLeft = _newScreen.index > _oldScreen.index;
		if (invertNext) {
			_isFromLeft = false;
			invertNext = false;
		}
		if (_isFromLeft) {
			if (_normalTransition == null) {
				_normalTransition = Slide.createSlideLeftTransition(.5, null, {onStart:this.onStart});
				_normalTransition(_oldScreen, _newScreen, this.onComplete);
			}
		} else {
			if (_invertTransition == null) {
				_invertTransition = Slide.createSlideRightTransition(.5, null, {onStart:this.onStart});
				_invertTransition(_oldScreen, _newScreen, this.onComplete);
			}
		}
	}
	
	private function onStart() : Void {
		_oldScreen.dispatchEventWith(Event.TRANSITION_OUT_START, true);
		_newScreen.dispatchEventWith(Event.TRANSITION_IN_START, true);
	}
	
	private function onComplete() : Void {
		if (_oldScreen != null) {
			_oldScreen.dispatchEventWith(Event.TRANSITION_OUT_COMPLETE, true);
			Ice.animator.removeTweens(_oldScreen);
			_oldScreen = null;
		}
		if (_newScreen != null) {
			_newScreen.dispatchEventWith(Event.TRANSITION_IN_COMPLETE, true);
			Ice.animator.removeTweens(_newScreen);
			_newScreen = null;
		}
		if (_onComplete != null) {
			_onComplete();
			_onComplete = null;
		}
		if (_normalTransition != null)
			_normalTransition = null;
		if (_invertTransition != null)
			_invertTransition = null;
		/*if (_tabBar != null) {
			var item:TabBarItemRenderer = cast _tabBar.selectedItem;
			if (item == null)
				return;
			var screenName:String = item.data.screenName;
			if (_screenNavigator.activeScreenName != screenName)
				_screenNavigator.showScreen(screenName);
		}*/
	}
	
	public function dispose() : Void {
		onComplete();
		/*if (_tabBar != null)
			_tabBar = null;*/
		if (_screenNavigator != null) {
			_screenNavigator.transition = null;
			_screenNavigator = null;
		}
	}
}
