package ru.ice.controls;

import ru.ice.controls.Screen;
import ru.ice.controls.super.IceControl;
import ru.ice.core.Router.Route;
import ru.ice.events.EventDispatcher;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class ScreenNavigatorItem extends EventDispatcher
{
	private static var _items:Array<ScreenNavigatorItem> = [];

	public static function addScreenToPool(item:ScreenNavigatorItem) : Void
	{
		if (_items.indexOf(item) == -1)
			_items.push(item);
	}

	public static function removeScreenFromPool(item:ScreenNavigatorItem) : Void
	{
		var ind:Int = _items.indexOf(item);
		if (ind > -1)
			_items.splice(ind, 0);
	}

	public static function getScreenFromPool(item:ScreenNavigatorItem) : ScreenNavigatorItem
	{
		var ind:Int = _items.indexOf(item);
		if (ind > -1)
			return _items[ind];
		return null;
	}

	public static function getScreenByAddress(address:String) : ScreenNavigatorItem
	{
		for (item in _items)
		{
			if (item.route != null)
			{
				if (item.route.address.origin == address)
					return item;
			}
		}
		return null;
	}
	
	private var _route:Route;
	public var route(get, never):Route;
	private function get_route():Route {
		return _route;
	}
	
	public var id:String;
	public var index:Int;
	public var screenNavigator:ScreenNavigator;

	public function new(screen:Dynamic = null, events:Dynamic= null, properties:Dynamic = null, route:Route = null)
	{
		super();
		_route = route;
		_screen = screen;
		_events = events ? events : {};
		_properties = properties ? properties : {};
		addScreenToPool(this);
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
		if (value == null)
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
		if (Std.is(_screen, Class))
		{
			var screenType:Class<Dynamic> = cast _screen;
			screenInstance = Type.createInstance(screenType, []);
		}
		#if debug
		if (!Std.is(screenInstance, Screen))
			throw "ScreenNavigatorItem \"getScreen()\" must return a Starling display object.";
		#end
		if (_properties != null)
		{
			for (propertyName in Reflect.fields(_properties))
			{
				Reflect.setProperty(screenInstance, propertyName, Reflect.field(_properties, propertyName));
			}
		}
		screenInstance.setId(id);
		screenInstance.setIndex(index);
		return screenInstance;
	}
	
	public function dispose() : Void {
		if (_route != null)
			_route = null;
		removeScreenFromPool(this);
		removeEventListeners();
	}
}