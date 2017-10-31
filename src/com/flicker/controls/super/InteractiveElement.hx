package com.flicker.controls.super;

import js.html.Element;

import com.flicker.controls.super.FlickerControl;
import com.flicker.data.ElementData;
import com.flicker.display.DisplayObject;
import com.flicker.events.Event;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class InteractiveElement
{
	public static function resetState(e:Element) : Void {
		upState(e);
	}
	
	public static function upState(e:Element) : Void {
		e.removeClass('state-down', 'state-hover');
		e.classList.add('state-up');
	}
	
	public static function downState(e:Element) : Void {
		e.removeClass('state-up', 'state-hover');
		e.classList.add('state-down');
	}
	
	public static function hoverState(e:Element) : Void {
		e.removeClass('state-down', 'state-hover');
		e.classList.add('state-up');
	}
}