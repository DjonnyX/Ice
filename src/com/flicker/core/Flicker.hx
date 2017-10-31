package com.flicker.core;

import js.Browser;

import com.flicker.controls.super.BaseStatesControl;
import com.flicker.controls.super.FlickerControl;
import com.flicker.data.ElementData;
import com.flicker.display.DisplayObject;
import com.flicker.display.Stage;
import com.flicker.controls.super.InteractiveControl;
import com.flicker.animation.Animator;
import com.flicker.core.Capabilities;
import com.flicker.display.Stage;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Flicker
{
	public static inline var VERSION : String = '0.4.0';
	
	public static var isDragging:Bool = false;
	
	public static var globalPressed:Bool = false;
	
	public static var screenWidth(get, never):Float;
	private static function get_screenWidth():Float {
		return Browser.window.innerWidth;
	}
	
	public static var screenHeight(get, never):Float;
	private static function get_screenHeight():Float {
		return Browser.window.innerHeight;
	}
	
	private static var _serializer:Serializer;
	public static var serializer(get, never):Serializer;
	private static function get_serializer():Serializer {
		return _serializer;
	}
	
	private static var _focusObjects:Array<DisplayObject> = [];
	public static var focusObjects(get, set):Array<DisplayObject>;
	private static function set_focusObjects(v:Array<DisplayObject>):Array<DisplayObject>
	{
		if (_focusObjects != v) {
			if (v == null)
				v = [];
			var lastFocusObjects:Array<DisplayObject> = _focusObjects;
			var removedObjects:Array<DisplayObject> = [];
			for (o in lastFocusObjects) {
				if (v.indexOf(o) == -1)
					o.isHover = false;
			}
			for (o in v) {
				o.isHover = true;
			}
			_focusObjects = v;
		}
		return get_focusObjects();
	}
	private static function get_focusObjects():Array<DisplayObject> {
		return _focusObjects;
	}
	
	public static var animator(get, never):Animator;
	private static function get_animator():Animator {
		return Stage.animator;
	}
	
	private var _useStats:Bool = false;
	public var useStats(get, set) : Bool;
	private function set_useStats(v:Bool):Bool
	{
		if (v != _useStats) {
			_useStats = v;
			stage.useStats = v;
		}
		return get_useStats();
	}
	private function get_useStats():Bool {
		return _useStats;
	}
	
	public var stage:Stage;
	
	public function new(main:FlickerControl, ?name:String='stage', ?style:Dynamic, ?serializer:Serializer) 
	{
		_serializer = serializer != null ? serializer : new Serializer();
		Capabilities.initialize();
		stage = new Stage(new ElementData({name:name, style:Dynamic}));
		stage.fps = 60;
		stage.add(main);
	}
	
	public static function isInteractiveObject(object:DisplayObject) : Bool {
		return Std.is(object, InteractiveControl);
	}
}