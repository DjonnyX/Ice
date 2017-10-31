package com.flicker.controls.super;

import com.flicker.controls.super.FlickerControl;
import com.flicker.data.ElementData;
import com.flicker.display.DisplayObject;
import com.flicker.events.Event;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class InteractiveControl extends FlickerControl
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