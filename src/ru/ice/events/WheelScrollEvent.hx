package ru.ice.events;

import js.html.WheelEvent;

import ru.ice.events.Event;
/**
 * ...
 * @author Evgenii Grebennikov
 */
class WheelScrollEvent extends Event
{
	public static inline var SCROLL:String = 'wheel-scroll';
	
	public var deltaX:Float = 0;
	public var deltaY:Float = 0;
	public var ctrlKey:Bool = false;
	public var shiftKey:Bool = false;
	
	public function new(type:String, bubbles:Bool = false, data:Dynamic = null) 
	{
		super(type, bubbles, data);
	}
	
	public static function fromDomEvent<T>(type:String, event:T, bubbles:Bool = false, data:Dynamic = null) : WheelScrollEvent {
		var evt:WheelScrollEvent = new WheelScrollEvent(type, bubbles, data);
		if (event != null) {
			var e:Dynamic = cast event;
			evt.ctrlKey = e.ctrlKey;
			evt.shiftKey = e.shiftKey;
			if (Std.is(event, WheelEvent)) {
				evt.deltaX = e.deltaX;
				evt.deltaY = e.deltaY;
			} else {
				evt.deltaX = e.wheelDeltaX;
				evt.deltaY = e.wheelDeltaY;
			}
		}
		return evt;
	}
	
	private override function reset(type:String, bubbles:Bool=false, data:Dynamic=null) : Event
    {
		deltaX = deltaY = 0;
		shiftKey = ctrlKey = false;
		return super.reset(type, bubbles, data);
	}
}