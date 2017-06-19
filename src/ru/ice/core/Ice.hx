package ru.ice.core;

import ru.ice.controls.super.BaseStatesControl;
import ru.ice.controls.super.IceControl;
import ru.ice.data.ElementData;
import ru.ice.display.DisplayObject;
import ru.ice.display.Stage;
import ru.ice.controls.super.InteractiveControl;
import ru.ice.animation.Animator;
import ru.ice.core.Capabilities;
import ru.ice.display.Stage;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Ice
{
	public static inline var VERSION : String = '0.3.1';
	
	public static var isDragging:Bool = false;
	
	public static var globalPressed:Bool = false;
	
	
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
	
	public function new(main:IceControl, ?name:String='stage', ?style:Dynamic) 
	{
		Capabilities.initialize();
		stage = new Stage(new ElementData({name:name, style:Dynamic}));
		stage.fps = 100;
		stage.add(main);
	}
	
	public static function isInteractiveObject(object:DisplayObject) : Bool {
		return Std.is(object, InteractiveControl);
	}
}