package ru.ice.events;

import haxe.Constraints.Function;

import ru.ice.display.DisplayObject;
//import ru.ice.utils.ArrayUtil;

@:access(ru.ice.events.Event)
/**
 * ...
 * @author Evgenii Grebennikov
 */
class EventDispatcher
{
    private var _eventListeners:Map<String, Array<Function>>;
    
    private static var __bubbleChains:Array<Array<EventDispatcher>> = new Array<Array<EventDispatcher>>();
    
    public function new() {  }
    
    public function addEventListener(type:String, listener:Function):Void
    {
        if (_eventListeners == null)
            _eventListeners = new Map<String, Array<Function>>();
        
        var listeners:Array<Function> = _eventListeners[type];
        if (listeners == null)
        {
            _eventListeners[type] = new Array<Function>();
            _eventListeners[type].push(listener);
        }
        else
        {
            for (i in 0...listeners.length)
            {
                if (Reflect.compareMethods(listeners[i], listener))
                    return;
            }
            listeners[listeners.length] = listener;
        }
    }
	
	#if debug
		private function traceNumListeners() : Void
		{
			var ecount:Int = 0;
			if (_eventListeners != null) {
				for (k in _eventListeners.keys()) {
					ecount += _eventListeners[k].length;
				}
				trace('num listeners = ' + ecount);
			}
		}
	#end
	
	#if debug
		private function traceBubleChains() : Void
		{
			var ecount:Int = 0;
			if (__bubbleChains != null) {
				for (k in __bubbleChains) {
					ecount += k.length;
				}
				trace('num bubble chains = ' + ecount);
			}
		}
	#end
    
    public function removeEventListener(type:String, listener:Function):Void
    {
        if (_eventListeners != null)
        {
            var listeners:Array<Function> = _eventListeners[type];
            var numListeners:Int = listeners != null ? listeners.length : 0;

            if (numListeners > 0)
            {
                var index:Int = listeners.indexOf(listener);

                if (index != -1)
                {
                    var restListeners:Array<Function> = listeners.slice(0, index);
					
                    for (i in index + 1...numListeners)
                        restListeners[i - 1] = listeners[i];
						
                    _eventListeners[type] = restListeners;
                }
            }
        }
    }
    
    public function removeEventListeners(type:String=null):Void
    {
        if (type != null && _eventListeners != null)
            _eventListeners.remove(type);
        else
            _eventListeners = null;
    }
    
    public function dispatchEvent(event:Event, ?customTarget:EventDispatcher):Void
    {
        var bubbles:Bool = event.bubbles;
        
        if (!bubbles && (_eventListeners == null || !(_eventListeners.exists(event.type))))
            return;
		
        var previousTarget:EventDispatcher = event.target;
        event.setTarget(customTarget != null ? customTarget : this);
        
        if (bubbles && Std.is(this, DisplayObject)) bubbleEvent(event);
        else                                  invokeEvent(event);
        
        if (previousTarget != null) event.setTarget(previousTarget);
		
		#if debug
			traceNumListeners();
		#end
    }
    
    private function invokeEvent(event:Event):Bool
    {
        var listeners:Array<Function> = _eventListeners != null ? _eventListeners[event.type] : null;
        var numListeners:Int = listeners == null ? 0 : listeners.length;
        
        if (numListeners != 0)
        {
            event.setCurrentTarget(this);
            
            for (i in 0...numListeners)
            {
                var listener:Function = listeners[i];
                if (listener == null)
					continue;
                var numArgs:Int = 2;
                if (numArgs == 0)
					listener();
                else if (numArgs == 1)
					listener(event);
                else
					listener(event, event.data);
                
                if (event.stopsImmediatePropagation)
                    return true;
            }
            
            return event.stopsPropagation;
        }
        else
        {
            return false;
        }
    }
    
    private function bubbleEvent(event:Event, ?customTarget:EventDispatcher):Void
    {
        var chain:Array<EventDispatcher>;
        var element:DisplayObject = cast(this, DisplayObject);
        var length:Int = 1;
        
        if (__bubbleChains.length > 0) { chain = __bubbleChains.pop(); chain[0] = element; }
        else chain = [cast element];
        
        while ((element = element.parent) != null)
            chain[length++] = element;

        for (i in 0...length)
        {
            if (chain[i] == null) continue;
            var stopPropagation:Bool = chain[i].invokeEvent(event);
            if (stopPropagation) break;
        }
		while (chain.length > 0) {
			chain.pop();
		}
        __bubbleChains[__bubbleChains.length] = chain;
		
		#if debug
			traceBubleChains();
		#end
    }
    
    public function dispatchEventWith(type:String, bubbles:Bool=false, data:Dynamic=null):Void
    {
        if (bubbles || hasEventListener(type)) 
        {
            var event:Event = Event.fromPool(type, bubbles, data);
            dispatchEvent(event);
            Event.toPool(event);
        }
    }
    
    public function hasEventListener(type:String):Bool
    {
        var listeners:Array<Function> = _eventListeners != null ? _eventListeners[type] : null;
        return listeners != null ? listeners.length != 0 : false;
    }
}