package ru.ice.events;

import haxe.Constraints.Function;

/**
 * @author Evgenii Grebennikov
 */
interface IEventDispatcher
{
	public function addEventListener(type:String, listener:Function):Void;
	#if debug
		private function traceNumListeners() : Void;
	#end
	#if debug
		private function traceBubleChains() : Void;
	#end
    public function removeEventListener(type:String, listener:Function):Void;
    public function removeEventListeners(type:String = null):Void;
    public function dispatchEvent(event:Event, ?customTarget:EventDispatcher):Void;
    private function invokeEvent(event:Event):Bool;
    private function bubbleEvent(event:Event, ?customTarget:EventDispatcher):Void;
    public function dispatchEventWith(type:String, bubbles:Bool = false, data:Dynamic = null):Void;
    public function hasEventListener(type:String):Bool;
}