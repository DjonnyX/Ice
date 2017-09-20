package ru.ice.events;

//import ru.ice.utils.StringUtil;
/**
 * ...
 * @author Evgenii Grebennikov
 */
class Event
{
    private static var __eventPool:Array<Event> = new Array<Event>();
    
    public function new(type:String, bubbles:Bool=false, data:Dynamic=null)
    {
        this.type = type;
        this.bubbles = bubbles;
        this.data = data;
    }
    
    public function stopPropagation():Void
    {
        this.stopsPropagation = true;            
    }
    
    public function stopImmediatePropagation():Void
    {
        this.stopsPropagation = this.stopsImmediatePropagation = true;
    }
    
    public function toString():String
    {
        return '';/* StringUtil.formatString("[{0} type=\"{1}\" bubbles={2}]", 
            [Type.getClassName(Type.getClass(this)).split("::").pop(), type, bubbles]);*/
    }
	
	public var isStopedPropagation(get, never) : Bool; 
	
	private function get_isStopedPropagation() : Bool {
		return stopsPropagation || stopsImmediatePropagation;
	}
    
    public var bubbles(default, null):Bool;
    
    public var target(default, null):EventDispatcher;
    
    public var currentTarget(default, null):EventDispatcher;
    
    public var type(default, null):String;
    
    public var data(default, null):Dynamic;
    
	@:allow(ru.ice.display.DisplayObject)
    private function setTarget(value:EventDispatcher):Void { target = value; }
    
	@:allow(ru.ice.display.DisplayObject)
    private function setCurrentTarget(value:EventDispatcher):Void { currentTarget = value; } 
    
	@:allow(ru.ice.display.DisplayObject)
    private function setData(value:Dynamic):Void { data = value; }
    
    private var stopsPropagation(default, null):Bool;
    
    private var stopsImmediatePropagation(default, null):Bool;
    
    private static function fromPool(type:String, bubbles:Bool=false, data:Dynamic=null):Event
    {
        if (__eventPool.length != 0) return __eventPool.pop().reset(type, bubbles, data);
        else return new Event(type, bubbles, data);
    }
	
    private static function toPool(event:Event):Void
    {
        event.data = event.target = event.currentTarget = null;
        __eventPool[__eventPool.length] = event;
    }
    
    private function reset(type:String, bubbles:Bool=false, data:Dynamic=null):Event
    {
        this.type = type;
        this.bubbles = bubbles;
        this.data = data;
        this.target = this.currentTarget = null;
        this.stopsPropagation = this.stopsImmediatePropagation = false;
        return this;
    }
	
    public static inline var WIN_MOUSE_LEAVE:String = "windowMouseLeave";
    public static inline var WIN_MOUSE_ENTER:String = "windowMouseEnter";
	
    public static inline var TRANSITION_IN_START:String = "transitionInStart";
    public static inline var TRANSITION_IN_COMPLETE:String = "transitionInComplete";
    public static inline var TRANSITION_OUT_START:String = "transitionOutStart";
    public static inline var TRANSITION_OUT_COMPLETE:String = "transitionOutComplete";
	
    public static inline var CHANGE_ROUTE:String = "change-route";
    public static inline var INITIALIZE:String = "initialize";
    public static inline var UPDATE_LAYOUT:String = "update-layout";
    public static inline var LOADED:String = "loaded";
    public static inline var ADDED:String = "added";
    public static inline var ADDED_TO_STAGE:String = "addedToStage";
    public static inline var REMOVED:String = "removed";
    public static inline var REMOVED_FROM_STAGE:String = "removedFromStage";
    public static inline var TRIGGERED:String = "triggered";
    public static inline var RESIZE:String = "resize";
    public static inline var COMPLETE:String = "complete";
    public static inline var RENDER:String = "render";
    public static inline var REMOVE_FROM_ANIMATOR:String = "removeFromAnimator";
    public static inline var IO_ERROR:String = "ioError";
    public static inline var SECURITY_ERROR:String = "securityError";
    public static inline var PARSE_ERROR:String = "parseError";
    public static inline var FATAL_ERROR:String = "fatalError";
	
    public static inline var CHANGE:String = "change";
    public static inline var CANCEL:String = "cancel";
    public static inline var SCROLL:String = "scroll";
    public static inline var OPEN:String = "open";
    public static inline var CLOSE:String = "close";
    public static inline var SELECT:String = "select";
    public static inline var READY:String = "ready";
    public static inline var RESET_STATE:String = "resetState";
    public static inline var REPOSITION:String = "reposition";
	
    public static inline var INCLUDE_IN_LAYOUT:String = "includeInLayout";
    public static inline var EXCLUDE_FROM_LAYOUT:String = "excludeFromLayout";
	
    public static inline var SCREEN_LOADED:String = "screenLoaded";
    public static inline var HOVER:String = "hoverForChain";
}