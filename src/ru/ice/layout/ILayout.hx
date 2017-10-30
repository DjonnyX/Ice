package ru.ice.layout;

import ru.ice.controls.super.IceControl;
import ru.ice.display.DisplayObject;
import ru.ice.events.IEventDispatcher;
import ru.ice.math.Rectangle;
import ru.ice.display.Stage;

/**
 * @author Evgenii Grebennikov
 */
interface ILayout extends IEventDispatcher
{
	public var roundToInt(get, set):Bool;
	public function include(obj:DisplayObject) : Void;
	public function exclude(obj:DisplayObject) : Void;
	public var objects(get, never) : Array<DisplayObject>;
	public var ownerLayout(get, set) : BaseLayout;
	private var _isPost:Bool;
	private var _objects:Array<DisplayObject>;
	public var stage(get, never):Stage;
	public var owner(get, set) : IceControl;
	public var bound(get, never) : Rectangle;
	public var needResize(get, never) : Bool;
	public var needCalcParams(get, never) : Bool;
	public var maxWidth(get, never) : Float;
	public var maxHeight(get, never) : Float;
	public var commonPaddingLeft(get, never) : Float;
	public var commonPaddingRight(get, never) : Float;
	public var commonPaddingTop(get, never) : Float;
	public var commonPaddingBottom(get, never) : Float;
	public var paddingLeft(get, set):Float;
	public var paddingRight(get, set):Float;
	public var paddingTop(get, set):Float;
	public var paddingBottom(get, set):Float;
	public var gap(never, set):Float;
	public var verticalGap(never, set):Float;
	public var horizontalGap(never, set):Float;
	public var postLayout(get, set):ILayout;
	public function update(width:Float = 0, height:Float = 0):Rectangle;
	//public function setSize(w:Float, h:Float):Void;
	public function dispose():Void;
}