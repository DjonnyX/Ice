package ru.ice.controls;

import ru.ice.controls.Screen;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class ScreenNavigatorItem
{
	public var id:String;
	public var index:Int;
	public var screenNavigator:ScreenNavigator;
	
	public function new(screen:Dynamic = null, events:Dynamic= null, properties:Dynamic = null)
	{
		_screen = screen;
		_events = events ? events : {};
		_properties = properties ? properties : {};
	}
	
	private var _screen:Dynamic;
	
	public var screen(get, set):Dynamic;
	public function get_screen():Dynamic
	{
		return _screen;
	}
	
	public function set_screen(value:Dynamic):Dynamic
	{
		_screen = value;
		return get_screen();
	}
	
	private var _events:Dynamic;
	
	public var events(get, set):Dynamic;
	public function get_events():Dynamic
	{
		return _events;
	}
	public function set_events(value:Dynamic):Dynamic
	{
		if (value == null)
			value = {};
		_events = value;
		return get_events();
	}
	
	private var _properties:Dynamic;
	public var properties(get, set):Dynamic;
	public function get_properties():Dynamic
	{
		return _properties;
	}
	public function set_properties(value:Dynamic):Dynamic
	{
		if(value == null)
			value = {};
		_properties = value;
		return get_properties();
	}
	
	public var canDispose(get, never):Bool;
	public function get_canDispose():Bool
	{
		return !Std.is(_screen, Screen);
	}
	
	public function setFunctionForEvent(eventType:String, action:Dynamic):Void
	{
		Reflect.setField(_events, eventType, action);
	}
	
	public function setScreenIDForEvent(eventType:String, screenID:String):Void
	{
		Reflect.setField(_events, eventType, screenID);
	}
	
	public function clearEvent(eventType:String):Void
	{
		Reflect.deleteField(_events, eventType);
	}
	
	public function getScreen():Screen
	{
		var screenInstance:Screen = null;
		if(Std.is(_screen, Class)) {
			var screenType:Class<Dynamic> = cast _screen;
			screenInstance = Type.createInstance(screenType, []);
		}
		#if debug
			if (!Std.is(screenInstance, Screen))
				throw "ScreenNavigatorItem \"getScreen()\" must return a Starling display object.";
		#end
		
		if (_properties != null) {
			for (propertyName in Reflect.fields(_properties)) {
				Reflect.setProperty(screenInstance, propertyName, Reflect.field(_properties, propertyName));
			}
		}
		screenInstance.setId(id);
		screenInstance.setIndex(index);
		return screenInstance;
	}
}
