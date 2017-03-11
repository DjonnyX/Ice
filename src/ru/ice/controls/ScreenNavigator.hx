package ru.ice.controls;

import ru.ice.controls.super.InteractiveObject;
import ru.ice.controls.super.BaseIceObject;
import ru.ice.controls.ScreenNavigatorItem;
import ru.ice.controls.Screen;
import ru.ice.data.ElementData;
import ru.ice.events.Event;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class ScreenNavigator extends BaseIceObject
{
	private var _screens:Dynamic = {};
	private var _oldScreen:Screen;
	private var _newScreen:Screen;
	private var _events:Dynamic = {};
	private var index:Int = 0;
	
	private var _activeScreen:Screen;
	public var activeScreen(get, null):Screen;
	private function get_activeScreen():Screen
	{
		return _activeScreen;
	}
	
	private var _lastScreenName:String = '';
	public var lastScreenName(get, never):String;
	private function get_lastScreenName():String {
		return _lastScreenName == null ? '' : _lastScreenName;
	}
	
	public var activeScreenName(get, never):String;
	private function get_activeScreenName():String {
		return _activeScreen == null ? '' : _activeScreen.id;
	}
	
	private var _transition:Screen->Screen->Dynamic->Void;
	
	public var transition(default,set):Screen->Screen->Dynamic->Void;
	private function set_transition(value:Screen->Screen->Dynamic->Void) : Screen->Screen->Dynamic->Void {
		_transition = value;
		return _transition;
	}
	
	public function new(?elementData:ElementData)
	{
		if (elementData == null)
			elementData = new ElementData({'name':'navigator'});
		super(elementData);
		autosize = BaseIceObject.AUTO_SIZE_STAGE;
		_screens = {};
	}
	
	public function addScreen(id:String, screen:ScreenNavigatorItem) : Void
	{
		screen.screenNavigator = this;
		screen.index = index;
		screen.id = id;
		Reflect.setField(_screens, id, screen);
		index ++;
	}
	
	public function showScreen(screenName:String) : Void
	{
		if (_activeScreen != null) {
			if (_activeScreen.id == screenName)
				return;
		}
		_lastScreenName = _activeScreen != null ? _activeScreen.id : null;
		var newScreen:Screen = _createScreenByName(screenName);
		newScreen.setSize(width, height);
		if (newScreen != null) {
			_oldScreen = _newScreen;
			_newScreen = newScreen;
			_activeScreen = _newScreen;
			if (_transition == null) {
				if (_oldScreen != _newScreen) {
					addChild(_newScreen);
					_oldScreen.dispatchEventWith(Event.TRANSITION_OUT_START, true);
					_oldScreen.dispatchEventWith(Event.TRANSITION_OUT_COMPLETE, true);
					_newScreen.dispatchEventWith(Event.TRANSITION_IN_START, true);
					_newScreen.dispatchEventWith(Event.TRANSITION_IN_COMPLETE, true);
					_oldScreen.removeFromParent(true);
					_oldScreen = null;
				}
			} else {
				addChild(_newScreen);
				_transition(_oldScreen, _newScreen, _transitionComplete);
			}
		}
	}
	
	public function hasScreen(screenName:String) : Bool
	{
		return Reflect.hasField(_screens, screenName);
	}
	
	private function existsScreen(screenName:String) : Bool
	{
		var isExists:Bool = false;
		if (_oldScreen != null) {
			if (_oldScreen.id == screenName)
				isExists = true;
		} else if (_newScreen != null) {
			if (_newScreen.id == screenName)
				isExists = true;
		}
		return isExists;
	}
	
	private function _createScreenByName(screenName:String) : Screen
	{
		var isExists:Bool = existsScreen(screenName);
		if (!isExists) {
			var screenItem:ScreenNavigatorItem = Reflect.getProperty(_screens, screenName);
			var screen:Screen = screenItem.getScreen();
			var events:Dynamic = screenItem.events;
			for (eventType in Reflect.fields(events)) {
				var __transition:Event->Void = 
					function(event:Event) : Void {
						var action:Dynamic = Reflect.getProperty(events, eventType);
						if (Std.is(action, String)) {
							if (hasScreen(action))
								showScreen(action);
						} else {
							if (action != null)
								action();
						}
					}
				Reflect.setField(_events, eventType, __transition);
				screen.addEventListener(eventType, __transition);
			}
			return screen;
		}
		return null;
	}
	
	public override function resize(data:Dynamic = null) : Void
	{
		if (_oldScreen != null)
			_oldScreen.setSize(width, height);
		if (_newScreen != null)
			_newScreen.setSize(width, height);
			super.resize(data);
	}
	
	private function _transitionComplete() : Void
	{
		_disposeScreen(_oldScreen);
		_oldScreen = null;
	}
	
	private function _disposeScreen(screen:Screen) : Void
	{
		if (screen != null) {
			var screenItem:ScreenNavigatorItem = Reflect.getProperty(_screens, screen.id);
			if (screenItem != null) {
				var events:Dynamic = screenItem.events;
				for (eventType in Reflect.fields(events)) {
					var __transition:Event->Void = null;
					if (Reflect.hasField(_events, eventType)) {
						__transition = Reflect.getProperty(_events, eventType);
						screen.removeEventListener(eventType, __transition);
					}
				}
			}
			screen.removeFromParent(true);
			screen = null;
		}
	}
	
	public override function dispose() : Void
	{
		for (eventType in Reflect.fields(_events)) {
			var handler:Event->Void;
			handler = Reflect.getProperty(_events, eventType);
			this.removeEventListener(eventType, handler);
		}
		if (_oldScreen != null) {
			_oldScreen.removeFromParent(true);
			_oldScreen = null;
		}
		if (_newScreen != null) {
			_newScreen.removeFromParent(true);
			_newScreen = null;
		}
		_activeScreen = null;
		_transition = null;
		_screens = null;
		_events = null;
		
		super.dispose();
	}
}
