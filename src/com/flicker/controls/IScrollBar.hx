package com.flicker.controls;

import haxe.Constraints.Function;

import com.flicker.display.DisplayObject;
import com.flicker.controls.ScrollBar;
import com.flicker.controls.IScroller;
import com.flicker.math.Rectangle;
import com.flicker.display.Stage;

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
	@:allow(com.flicker.controls)
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