package ru.ice.core;

import ru.ice.controls.super.BaseIceObject;
import ru.ice.data.ElementData;
import ru.ice.display.DisplayObject;
import ru.ice.display.Stage;
import ru.ice.controls.super.InteractiveObject;
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
	
	public function new(main:BaseIceObject, ?name:String='stage', ?style:Dynamic) 
	{
		Capabilities.initialize();
		stage = new Stage(new ElementData({name:name, style:Dynamic}));
		stage.add(main);
		main.initialize();
	}
	
	public static function isInteractiveObject(object:DisplayObject) : Bool {
		return Std.is(object, InteractiveObject);
	}
}