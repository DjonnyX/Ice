package ru.ice.controls.super;

import haxe.Constraints.Function;

import ru.ice.layout.params.ILayoutParams;
import ru.ice.controls.super.IceControl;
import ru.ice.display.IDisplayObject;
import ru.ice.display.DisplayObject;
import ru.ice.layout.ILayout;
import ru.ice.math.Rectangle;
import ru.ice.display.Stage;
import ru.ice.events.Event;
import ru.ice.events.FingerEvent;
import ru.ice.core.Ice;

/**
 * @author Evgenii Grebennikov
 */
interface IBaseStatesControl extends IIceControl
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