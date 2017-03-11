package ru.ice.events;
import ru.ice.display.DisplayObject;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class LayoutEvent extends Event
{
	public static inline var INVALIDATE_TRANSFORM:String = 'invalidate-transform';
	public static inline var INVALIDATE_POSITION:String = 'invalidate-position';
	public static inline var INVALIDATE_SIZE:String = 'invalidate-size';
	
	public var targetObject(get, never):DisplayObject;
	private function get_targetObject():DisplayObject {
		return data != null ? data.targetObject : null;
	}
	
	public var invalidateWidth(get, never):Bool;
	private function get_invalidateWidth():Bool {
		return data != null ? data.invalidateWidth == true : false;
	}
	
	public var invalidateHeight(get, never):Bool;
	private function get_invalidateHeight():Bool {
		return data != null ? data.invalidateHeight == true : false;
	}
	
	public var invalidateSize(get, never):Bool;
	private function get_invalidateSize():Bool {
		return data != null ? data.invalidateSize == true : false;
	}
	
	public var invalidatePosition(get, never):Bool;
	private function get_invalidatePosition():Bool {
		return data != null ? data.invalidatePosition == true : false;
	}
	
	public var toStage(get, never):Bool;
	private function get_toStage():Bool {
		return data != null ? data.toStage == true : false;
	}
	
	public function new(type:String, bubbles:Bool=false, data:Dynamic=null)
	{
		super(type, bubbles, data);
	}
	
}