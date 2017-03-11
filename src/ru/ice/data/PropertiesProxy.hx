package ru.ice.data;
import ru.ice.display.DisplayObject;

/**
 * ...
 * @author test
 */
class PropertiesProxy 
{
	public var x:Float = 0;
	public var y:Float = 0;
	public var width:Float = 0;
	public var height:Float = 0;
	public var scaleX:Float = 0;
	public var scaleY:Float = 0;
	public var rotate:Float = 0;
	
	public function new(?d:Any) 
	{
		fromObject(d);
	}
	
	public function fromObject(?d:Any) : PropertiesProxy
	{
		if (d != null) {
			for (prop in Reflect.fields(this))
				Reflect.setField(this, prop, Reflect.getProperty(d, prop));
		}
		return this;
	}
	
	public function isInvalidTransform(?d:DisplayObject) : Bool {
		return d != null ? (isInvalidPosition(d) || isInvalidSize(d)) : false;
	}
	
	public function isInvalidSize(?d:DisplayObject) : Bool {
		return d != null ? !(width == d.width && height == d.height && scaleX == d.scaleX && scaleY == d.scaleY  && rotate == d.rotate) : false;
	}
	
	public function isInvalidWidth(?d:DisplayObject) : Bool {
		return d != null ? !(width == d.width && scaleX == d.scaleX) : false;
	}
	
	public function isInvalidHeight(?d:DisplayObject) : Bool {
		return d != null ? !(height == d.height && scaleY == d.scaleY) : false;
	}
	
	public function isInvalidPosition(?d:DisplayObject) : Bool {
		return d != null ? !(x == d.x && y == d.y) : false;
	}	
}