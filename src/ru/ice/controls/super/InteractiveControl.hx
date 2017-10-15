package ru.ice.controls.super;

import ru.ice.controls.super.IceControl;
import ru.ice.data.ElementData;
import ru.ice.display.DisplayObject;
import ru.ice.events.Event;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class InteractiveControl extends IceControl
{

	public function new(?elementData:ElementData, ?initial:Bool = false) 
	{
		super(elementData, initial);
		addEventListener(Event.RESET_STATE, resetStateHandler);
	}
	
	private function resetStateHandler(e:Event, data:Dynamic) : Void {
		var target:DisplayObject = cast data.target;
		if (target == this)
			e.stopImmediatePropagation();
	}
	
	@:allow(ru.ice.controls)
	private function resetState(target:DisplayObject) : Void {
		dispatchEventWith(Event.RESET_STATE, true, {tartget:target});
	}
}