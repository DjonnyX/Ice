package com.flicker.controls.super;

import haxe.Constraints.Function;

import com.flicker.layout.params.ILayoutParams;
import com.flicker.controls.super.FlickerControl;
import com.flicker.display.IDisplayObject;
import com.flicker.display.DisplayObject;
import com.flicker.layout.ILayout;
import com.flicker.math.Rectangle;
import com.flicker.display.Stage;
import com.flicker.events.Event;
import com.flicker.events.FingerEvent;
import com.flicker.core.Flicker;

/**
 * @author Evgenii Grebennikov
 */
interface IBaseStatesControl extends IFlickerControl
{
	public var allowDeselect(get, set) : Bool;
	public var isToggle(get, set) : Bool;
	public var isSelect(get, set) : Bool;
	public var upStyleFactory(get, set) : Function;
	public var downStyleFactory(get, set) : Function;
	public var downSelectStyleFactory(get, set) : Function;
	public var hoverStyleFactory(get, set) : Function;
	public var hoverSelectStyleFactory(get, set) : Function;
	public var selectStyleFactory(get, set) : Function;
	public var disabledStyleFactory(get, set) : Function;
	public var disabledSelectStyleFactory(get, set) : Function;
	public var state(get, set) : String;
	public var isHover(get, set) : Bool;
	private function updateState() : Void;
	private function upHandler(e:FingerEvent) : Void;
	private function downHandler(e:FingerEvent) : Void;
	private function stageMoveHandler(e:FingerEvent) : Void;
	private function stageUpHandler(e:FingerEvent) : Void;
}