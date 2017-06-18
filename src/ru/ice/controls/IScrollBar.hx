package ru.ice.controls;

import haxe.Constraints.Function;

import ru.ice.display.DisplayObject;
import ru.ice.controls.ScrollBar;
import ru.ice.controls.IScroller;
import ru.ice.math.Rectangle;
import ru.ice.display.Stage;

/**
 * @author Evgenii Grebennikov
 */
interface IScrollBar extends IScroller 
{
	public var ratio(get, set):Float;
	public var direction(get, set):String;
	public var isOutScrollPosition(get, never) : Bool;
	public var thumb(get, never) : ScrollBarThumb;
	public var thumbStyleFactory(never, set):Function;
	public var offsetRatioFunction(get, set):Float->Float->Float->Float;
	public var minThumbSize(get, set) : Float;
	@:allow(ru.ice.controls)
	private function setScrollParams(?os:Float, ?ocs:Float) : Void;
	/*private var _ownerSize(default, null):Float;
	private var _ownerContentSize(default, null):Float;
	private function getThumbSize() : Float;
	private function getThumbActualSize(size:Float) : Float;
	private function setElasticThumbWidth(distance:Float): Void;
	private function setElasticThumbHeight(distance:Float): Void;*/
	public function setScrollPosition(ratio:Float) : Void;
	/*private function getThumbParamsByRatio(ratio:Float) : Dynamic;
	private function updateThumbSize() : Void;*/
}