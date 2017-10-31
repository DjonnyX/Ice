package com.flicker.events;

import js.html.Element;
import js.html.MouseEvent;
import js.html.TouchEvent;
import js.html.TouchList;
import js.html.Touch;

import com.flicker.math.Point;
import com.flicker.math.Rectangle;
import com.flicker.display.Stage;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class FingerEvent extends Event
{
    private static var __eventPool:Array<FingerEvent> = new Array<FingerEvent>();
	
	private static function fromPool<T>(type:String, event:T, bubbles:Bool = false, data:Dynamic = null):FingerEvent
    {
		var evt:FingerEvent = null;
        if (__eventPool.length != 0) evt = __eventPool.pop().reset(type, bubbles, data);
        else {
			evt = new FingerEvent(type, bubbles, data);
			toPool(evt);
		}
		
		if (event != null) {
			var e:Dynamic = cast event;
			if (!Std.is(event, MouseEvent)) {
				var touches:TouchList = e.touches;
				if (touches != null) {
					if (touches.length > 0) {
						var touch:Touch = touches[touches.length - 1];
						evt.touchPoint.move(touch.clientX, touch.clientY);
					}
				}
			} else {
				evt.isMouse = true;
				evt.touchPoint.move(e.clientX, e.clientY);
				evt.key = e.button;
			}
		}
		return evt;
    }
	
    private static function toPool(event:FingerEvent):Void
    {
        event.data = event.target = event.currentTarget = null;
        __eventPool[__eventPool.length] = event;
    }
	
	public static inline var KEY_LEFT:Float = 0;
	public static inline var KEY_RIGHT:Float = 1;
	public static inline var KEY_MIDDLE:Float = 2;
	
	public static inline var UP = 'touch-up';
	public static inline var DOWN = 'touch-down';
	public static inline var MOVE = 'touch-move';
	public static inline var ENTER = 'touch-enter';
	public static inline var LEAVE = 'touch-leave';
	public static inline var OVER = 'touch-over';
	public static inline var OUT = 'touch-out';
	public static inline var STAGE_TOUCH_DOWN = 'stage-touch-down';
	
	public var isMouse:Bool = false;
	public var touchPoint:Point = new Point();
	public var key:Float = -1;
	
	public function new(type:String, bubbles:Bool = false, data:Dynamic = null) 
	{
		super(type, bubbles, data);
	}
	
	public static function fromDomEvent<T>(type:String, event:T, bubbles:Bool = false, data:Dynamic = null) : FingerEvent {
		return fromPool(type, event, bubbles, data);
	}
	
	private override function reset(type:String, bubbles:Bool=false, data:Dynamic=null) : FingerEvent
    {
		isMouse = false;
		touchPoint.empty();
		key = -1;
		super.reset(type, bubbles, data);
		return this;
	}
}