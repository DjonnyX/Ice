package ru.ice.display;

import haxe.Constraints.Function;

import ru.ice.layout.params.ILayoutParams;
import ru.ice.controls.super.IceControl;
import ru.ice.display.DisplayObject;
import ru.ice.display.IDOMExpress;
import ru.ice.math.Rectangle;
import ru.ice.display.Stage;
import ru.ice.math.Point;
import ru.ice.core.Ice;

/**
 * @author Evgenii Grebennikov
 */
interface IDisplayObject extends IDOMExpress
{
	public var actualWidth(get, never):Float;
	public var actualHeight(get, never):Float;
	public var enabled(get, set):Bool;
	private var _isStage:Bool = false;
	public var isClipped(get, set):Bool;
	public var visible(get, set):Bool;
	public var parent(get, never):DisplayObject;
	public var children(get, never):Array<DisplayObject>;
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;
	public var rotate(get, set):Float;
	private function resetTransformation() : Void;
	public var bound(get, never) : Rectangle;
	public var totalContentWidth(get, never) : Float;
	public var totalContentHeight(get, never) : Float;
	public var width(get, set):Float;
	public var height(get, set):Float;
	public var displayState(get, never):String;
	public var stage(get, never):Stage;
	public var touchX(get, set):Float;
	public var touchY(get, set):Float;
	public var interactive(get, set):Bool;
	public function insertChildAt(child:DisplayObject, index:Int) : Void;
	public function setPivot(x:String, y:String) : Void;
	public function setPivotToCenter() : Void;
	public function containsInChain(child:DisplayObject) : Bool;
	public function contains(child:DisplayObject) : Bool;
	private function addedToStage() : Void;
	private function removeFromStage() : Void;
	public function addChild(child:DisplayObject) : DisplayObject;
	public function removeChild(child:DisplayObject) : DisplayObject;
	public function removeAllChildren(dispose:Bool = false) : Void;
	public function getChildIndex(child:DisplayObject) : Int;
	public function getAbsolutePosition() : Point;
	public var position(get, never):Point;
	public function localToGlobal(point:Point) : Point;
	public function globalToLocal(point:Point) : Point;
	public function removeFromParent(dispose:Bool = false) : DisplayObject;
	public function setSize(width:Float, height:Float) : Void;
	public function move(x:Float, y:Float) : Void;
	public function update(emitResize:Bool = true) : ResizeData;
	public var isInitialized(get, never):Bool;
	public function initialize() : Void;
	@:allow(ru.ice.display.Stage)
	private function chainToString() : String;
}