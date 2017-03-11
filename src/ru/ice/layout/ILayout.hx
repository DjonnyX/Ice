package ru.ice.layout;

import ru.ice.controls.super.BaseIceObject;
import ru.ice.display.DisplayObject;
import ru.ice.math.Rectangle;
import ru.ice.display.Stage;

/**
 * @author Evgenii Grebennikov
 */
interface ILayout 
{
	private var _objects:Array<DisplayObject>;
	public var stage(get, never):Stage;
	public var owner(get, set) : BaseIceObject;
	//public var velociteX(get, set):Float;
	//public var velociteY(get, set):Float;
	public var bound(get, never) : Rectangle;
	public var paddingLeft(get, set):Float;
	public var paddingRight(get, set):Float;
	public var paddingTop(get, set):Float;
	public var paddingBottom(get, set):Float;
	public var gap(get, set):Float;
	public function update():Rectangle;
	public function setSize(w:Float, h:Float):Void;
	public function dispose():Void;
}