package com.flicker.utils;

import js.html.Element;
import js.html.MouseEvent;
import js.html.MouseEventInit;
import js.html.TouchEvent;
import js.Browser;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class DomUtils 
{
	public static function resetButtonState(target:Element, isMouse:Bool = true) : Void
	{
		simulateEvent(Browser.window, {type:'mouseleave'});
	}
	
	public static function simulateEvent(target:Dynamic, ?options:Dynamic) {
		target = target.parentElement;
	  var event:Dynamic = target.ownerDocument.createEvent('MouseEvents'),
		  options = options == null ? {} : options,
		  opts = { // These are the default values, set up for un-modified left clicks
			type: 'click',
			canBubble: true,
			cancelable: true,
			view: target.ownerDocument.defaultView,
			detail: 1,
			screenX: 999999, //The coordinates within the entire page
			screenY: 999999,
			clientX: 999999, //The coordinates within the viewport
			clientY: 999999,
			ctrlKey: false,
			altKey: false,
			shiftKey: false,
			metaKey: false, //I *think* 'meta' is 'Cmd/Apple' on Mac, and 'Windows key' on Win. Not sure, though!
			button: 0, //0 = left, 1 = middle, 2 = right
			relatedTarget: target.parentElement,
		  };

	  //Merge the options with the defaults
	  for (key in Reflect.fields(options)) {
		if (Reflect.hasField(opts,key)) {
		  Reflect.setField(opts, key, Reflect.getProperty(options, key));
		}
	  }

	  //Pass in the options
	  event.initMouseEvent(
		  opts.type,
		  opts.canBubble,
		  opts.cancelable,
		  opts.view,
		  opts.detail,
		  opts.screenX,
		  opts.screenY,
		  opts.clientX,
		  opts.clientY,
		  opts.ctrlKey,
		  opts.altKey,
		  opts.shiftKey,
		  opts.metaKey,
		  opts.button,
		  opts.relatedTarget
	  );

	  //Fire the event
	  target.dispatchEvent(event);
	}
}