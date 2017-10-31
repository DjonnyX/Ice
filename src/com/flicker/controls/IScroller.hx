package com.flicker.controls;

import haxe.Constraints.Function;

import com.flicker.controls.super.FlickerControl;
import com.flicker.controls.super.IFlickerControl;
import com.flicker.controls.super.IBaseStatesControl;
import com.flicker.display.DisplayObject;
import com.flicker.math.Rectangle;
import com.flicker.display.Stage;

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
	public function contentChildren() : Array<DisplayObject>;
	public function contentContains(child:DisplayObject) : Bool;
	public function addItem(child:DisplayObject) : DisplayObject;
	public function removeItem(child:DisplayObject) : DisplayObject;
	public function getContentChildIndex(child:DisplayObject) : Int;
}