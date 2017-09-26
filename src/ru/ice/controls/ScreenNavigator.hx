package ru.ice.controls;

import haxe.Constraints.Function;

import ru.ice.controls.super.InteractiveControl;
import ru.ice.controls.super.IceControl;
import ru.ice.controls.ScreenNavigatorItem;
import ru.ice.controls.Screen;
import ru.ice.data.ElementData;
import ru.ice.events.Event;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class ScreenNavigator extends IceControl
{
	public var name:String = '';
	
	private var _onScreenLoaded:Function;
	private var _screens:Dynamic = {};
	private var _oldScreen:Screen;
	private var _newScreen:Screen;
	private var _preScreen:Screen;
	private var _events:Dynamic = {};
	private var index:Int = 0;
	
	private var _activeScreen:Screen;
	public var activeScreen(get, null):Screen;
	private function get_activeScreen():Screen {
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
			elementData = new ElementData({'name':'nav', 'interactive':false});
		super(elementData);
		_screens = {};
	}
	
	public function addScreen(id:String, screen:ScreenNavigatorItem) : Void
	{
		screen.screenNavigator = this;
		screen.addEventListener(Event.CHANGE_ROUTE, changeRouteHandler);
		screen.index = index;
		screen.id = id;
		Reflect.setField(_screens, id, screen);
		index ++;
	}
	
	private function changeRouteHandler(event:Event, data:Dynamic) : Void {
		var isEnd:Bool = cast data.isEnd;
		var address:String = cast data.address;
		trace('change('+name, address, isEnd +')');
		showScreen(address);
		dispatchEventWith(Event.CHANGE, false, data);
	}
	
	public function showScreen(screenName:String, pre:Bool = false, onScreenLoaded:Function = null) : Screen
	{
		if (_activeScreen != null) {
			if (_activeScreen.id == screenName)
				return _activeScreen;
		}
		_lastScreenName = _activeScreen != null ? _activeScreen.id : null;
		var newScreen:Screen = _createScreenByName(screenName);
		
		if (pre) {
			_onScreenLoaded = onScreenLoaded;
			_preScreen = newScreen;
			if (_preScreen != null)
				_preScreen.addEventListener(Event.SCREEN_LOADED, screenLoadedHandler);
			return _preScreen;
		}
		
		return show(newScreen);
	}
	
	private function screenLoadedHandler(e:Event) : Void {
		e.stopImmediatePropagation();
		if (_preScreen != null) {
			if (_onScreenLoaded != null)
				_onScreenLoaded(_preScreen);
			show(_preScreen);
		}
	}
	
	private function show(newScreen:Screen) : Screen {
		if (newScreen == null)
			return _oldScreen;
		
		newScreen.setSize(_width, _height);
		
		if (_oldScreen != null && _oldScreen != _newScreen) {
			_oldScreen.dispatchEventWith(Event.TRANSITION_OUT_START, true);
			_oldScreen.dispatchEventWith(Event.TRANSITION_OUT_COMPLETE, true);
			_oldScreen.removeFromParent(true);
			_oldScreen = null;
		}
		_oldScreen = _newScreen;
		_newScreen = newScreen;
		_activeScreen = _newScreen;
		if (_transition == null) {
			if (_oldScreen != _newScreen) {
				addChild(_newScreen);
				_newScreen.dispatchEventWith(Event.TRANSITION_IN_START, true);
				_newScreen.dispatchEventWith(Event.TRANSITION_IN_COMPLETE, true);
			}
		} else {
			addChild(_newScreen);
			_transition(_oldScreen, _newScreen, _transitionComplete);
		}
		return _newScreen;
	}
	
	public function hasScreen(screenName:String) : Bool
	{
		return Reflect.hasField(_screens, screenName);
	}
	
	/*private function existsScreen(screenName:String) : Bool
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
	}*/
	
	private function _createScreenByName(screenName:String) : Screen
	{
		//var isExists:Bool = existsScreen(screenName);
		//if (!isExists) {
			var screenItem:ScreenNavigatorItem = Reflect.getProperty(_screens, screenName);
			if (screenItem == null)
				return null;
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
		//}
		//return null;
	}
	
	private function _transitionComplete() : Void
	{
		_disposeScreen(_oldScreen);
		_oldScreen = null;
	}
	
	private function _disposeScreen(screen:Screen) : Void
	{
		if (screen != null) {
			#if debug
				trace('disposeScreen ' + _oldScreen.elementName);
			#end
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
		} else {
			#if debug
				trace('screen is empty');
			#end
		}
	}
	
	public function deactive() : Void {
		removeItems();
	}
	
	private function removeItems() : Void {
		if (_screens != null) {
			for (s in Reflect.fields(_screens)) {
				var screenItem:ScreenNavigatorItem = cast Reflect.getProperty(_screens, s);
				if (screenItem != null) {
					screenItem.removeEventListener(Event.CHANGE_ROUTE, changeRouteHandler);
					screenItem.dispose();
					screenItem = null;
				}
			}
			_screens = null;
		}
	}
	
	public override function dispose() : Void
	{
		if (_onScreenLoaded != null)
			_onScreenLoaded = null;
		for (eventType in Reflect.fields(_events)) {
			var handler:Event->Void;
			handler = Reflect.getProperty(_events, eventType);
			this.removeEventListener(eventType, handler);
		}
		removeItems();
		if (_oldScreen != null) {
			_oldScreen.removeEventListeners();
			_oldScreen.removeFromParent(true);
			_oldScreen = null;
		}
		if (_newScreen != null) {
			_newScreen.removeEventListeners();
			_newScreen.removeFromParent(true);
			_newScreen = null;
		}
		if (_preScreen != null) {
			_preScreen.removeEventListener(Event.SCREEN_LOADED, screenLoadedHandler);
			_preScreen.removeFromParent(true);
			_preScreen = null;
		}
		_activeScreen = null;
		_transition = null;
		_screens = null;
		_events = null;
		
		super.dispose();
	}
}
