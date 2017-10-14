package ru.ice.controls.super;

import haxe.Constraints.Function;

import ru.ice.layout.params.ILayoutParams;
import ru.ice.controls.super.IceControl;
import ru.ice.display.IDisplayObject;
import ru.ice.display.DisplayObject;
import ru.ice.layout.ILayout;
import ru.ice.math.Rectangle;
import ru.ice.display.Stage;
import ru.ice.core.Ice;

/**
 * @author Evgenii Grebennikov
 */
interface IIceControl extends IDisplayObject
{
	public var includeInLayout(get, set) : Bool;
	public var onReposition(get, set):Function;
	public var snapWidth(get, never) : Dynamic;
	public var snapHeight(get, never) : Dynamic;
	private var _snapWidthObject:DisplayObject;
	private var _snapHeightObject:DisplayObject;
	public function snapTo(?width:Dynamic, ?height:Dynamic) : Void;
	public var emitResizeEvents:Bool;
	public var onResize:ResizeData->Void;
	private var _lastStyleName:String;
	private var _styleName:String;
	public var styleName(get, set) : String;
	private var _lastStyleFactory:Function;
	public var styleFactory(get, set) : Function;
	private function applyStylesIfNeeded() : Void;
	private function updateStyleFactory() : Void;
	public var layout(get,set):ILayout;
	public var layoutParams(get,set):ILayoutParams;
	public var isComplexControl(get, set):Bool;
	private var _propertiesProxy:PropertiesProxy;
	private function getInvalidData() : Dynamic;
	private var _layoutRegion:Rectangle;
	public function resize(?data:ResizeData) : Void;
	private function createDelayedBuilder(owner:IceControl, content:IceControl) : Void;
	public function addDelayedItemFactory(factory:Function, ?owner:IceControl, ?content:IceControl) : Void;
	private function updateLayout() : Void;
}