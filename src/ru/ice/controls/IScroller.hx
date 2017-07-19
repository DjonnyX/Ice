package ru.ice.controls;

import haxe.Constraints.Function;

import ru.ice.controls.super.IceControl;
import ru.ice.controls.super.IIceControl;
import ru.ice.controls.super.IBaseStatesControl;
import ru.ice.display.DisplayObject;
import ru.ice.math.Rectangle;
import ru.ice.display.Stage;

/**
 * @author Evgenii Grebennikov
 */
interface IScroller extends IBaseStatesControl 
{
	public var isDraggingHorizontally(get, never) : Bool;
	public var isDraggingVertically(get, never) : Bool;
	public var isDragging(get, never) : Bool;
	public var snapToPages(get, set):Bool;
	public var paggination(get, set):String;
	public var horizontalPages(get, never):Int;
	public var verticalPages(get, never):Int;
	public var maxScrollX(get, never):Float;
	public var maxScrollY(get, never):Float;
	public var horizontalScrollPosition(get, set) : Float;
	public var verticalScrollPosition(get, set) : Float;
	public var contentStyleFactory(never, set) : Function;
	public function resizeContent(?data:ResizeData) : Void;
	/*private function resetScrollParams() : Void;
	private function throwWheel(spinX:Float, spinY:Float, withoutAnimation:Bool = false) : Void;
	private function calculateViewportOffset() : Void;
	private function calculateViewportBound() : Void;
	private function clearAnimations() : Void;
	private function scrollX() : Void;
	private function scrollY() : Void;
	private function throwScroll(checkNullVelocity:Bool) : Void;
	private function throwScrollInertialForceX(distance:Float = null, withoutAnimation:Bool = false) : Void;
	private function throwScrollInertialForceY(distance:Float = null, withoutAnimation:Bool = false) : Void;
	private function calculateDynamicThrowDurationByDistance(distance:Float) : Float;
	private function calculateSpringOffset(distance:Float) : Float;
	private function calculateSpringDistance(distance:Float) : Float;
	private function calculateThrowDistance(pixelsPerMS:Float) : Float;
	private function calculateDynamicThrowDuration(pixelsPerMS:Float) : Float;
	private function calculatePPMS(velocity:Float, scopeVelocity:Array<Float>) : Float;
	private function calculateVelocity() : Void;
	private function stopScrolling() : Void;*/
	public function contentChildren() : Array<DisplayObject>;
	public function contentContains(child:DisplayObject) : Bool;
	public function addItem(child:DisplayObject) : DisplayObject;
	public function removeItem(child:DisplayObject) : DisplayObject;
	public function getContentChildIndex(child:DisplayObject) : Int;
}