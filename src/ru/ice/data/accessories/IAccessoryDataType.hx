package ru.ice.data.accessories;

import haxe.Constraints.Function;

import ru.ice.events.EventDispatcher;
import ru.ice.events.Event;

/**
 * @author Evgenii Grebennikov
 */
interface IAccessoryDataType
{
	public var type(get, set):String;
	public function addEventListener(type:String, listener:Function):Void;
	public function removeEventListener(type:String, listener:Function):Void;
	public function removeEventListeners(type:String = null):Void;
    public function dispatchEvent(event:Event, ?customTarget:EventDispatcher):Void;
	public function dispatchEventWith(type:String, bubbles:Bool = false, data:Dynamic = null):Void;
    public function hasEventListener(type:String):Bool;
}