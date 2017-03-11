package ru.ice.layout;

import ru.ice.controls.super.BaseIceObject;
import ru.ice.layout.params.ILayoutParams;
import ru.ice.events.EventDispatcher;
import ru.ice.display.DisplayObject;
import ru.ice.events.LayoutEvent;
import ru.ice.data.ElementData;
import ru.ice.layout.ILayout;
import ru.ice.math.Rectangle;
import ru.ice.display.Stage;
import ru.ice.events.Event;
/**
 * ...
 * @author Evgenii Grebennikov
 */
class BaseLayout extends EventDispatcher implements ILayout
{
	private var _objects:Array<DisplayObject>;
	
	private var _owner:BaseIceObject;
	public var owner(get, set) : BaseIceObject;
	public function get_owner() : BaseIceObject {
		return _owner;
	}
	private function set_owner(v:BaseIceObject) : BaseIceObject {
		if (owner != v) {
			if (_owner != null) {
				_owner.removeEventListener(Event.RESIZE, resizeHandler);
				_owner = null;
				_objects = null;
			}
			_owner = v;
			if (_owner != null) {
				_owner.addEventListener(Event.RESIZE, resizeHandler);
				_objects = _owner.children;
			}
		}
		return get_owner();
	}
	
	/*private var _velociteX:Float = 0;
	public var velociteX(get,set):Float;
	private function get_velociteX():Float {
		return _velociteX;
	}
	private function set_velociteX(v:Float):Float {
		if (_velociteX != v) {
			_velociteX = v;
			//update();
		}
		return get_velociteX();
	}
	
	private var _velociteY:Float = 0;
	public var velociteY(get,set):Float;
	private function get_velociteY():Float {
		return _velociteY;
	}
	private function set_velociteY(v:Float):Float {
		if (_velociteY != v) {
			_velociteY = v;
			//update();
		}
		return get_velociteY();
	}
	
	public function setVelocites(vx:Float, vy:Float) : Void
	{
		if (_velociteX != vx && _velociteY != vy) {
			_velociteX = vx;
			_velociteY = vy;
			update();
		}
	}*/
	
	private var _bound:Rectangle;
	public var bound(get, never) : Rectangle;
	public function get_bound() : Rectangle {
		return _bound;
	}
	
	public var stage(get, never):Stage;
	private function get_stage():Stage {
		return Stage.current;
	}
	
	private var _width:Float = 0;
	public var width(get, set) : Float;
	private function get_width() : Float {
		return _width;
	}
	private function set_width(v:Float) : Float {
		if (Math.isNaN(v))
			v = 0;
		if (width != v)
			_width = v;
		return get_width();
	}
	
	private var _height:Float = 0;
	public var height(get, set) : Float;
	private function get_height() : Float {
		return _height;
	}
	private function set_height(v:Float) : Float {
		if (Math.isNaN(v))
			v = 0;
		if (height != v)
			_height = v;
		return get_height();
	}
	
	private var _paddingLeft:Float = 0;
	public var paddingLeft(get, set) : Float;
	private function get_paddingLeft() : Float {
		return _paddingLeft;
	}
	private function set_paddingLeft(v:Float) : Float {
		if (Math.isNaN(v))
			v = 0;
		if (paddingLeft != v)
			_paddingLeft = v;
		return get_paddingLeft();
	}
	
	private var _paddingRight:Float = 0;
	public var paddingRight(get, set) : Float;
	private function get_paddingRight() : Float {
		return _paddingRight;
	}
	private function set_paddingRight(v:Float) : Float {
		if (Math.isNaN(v))
			v = 0;
		if (paddingRight != v)
			_paddingRight = v;
		return get_paddingRight();
	}
	
	private var _paddingTop:Float = 0;
	public var paddingTop(get, set) : Float;
	private function get_paddingTop() : Float {
		return _paddingTop;
	}
	private function set_paddingTop(v:Float) : Float {
		if (Math.isNaN(v))
			v = 0;
		if (paddingTop != v)
			_paddingTop = v;
		return get_paddingTop();
	}
	
	private var _paddingBottom:Float = 0;
	public var paddingBottom(get, set) : Float;
	private function get_paddingBottom() : Float {
		return _paddingBottom;
	}
	private function set_paddingBottom(v:Float) : Float {
		if (Math.isNaN(v))
			v = 0;
		if (paddingBottom != v)
			_paddingBottom = v;
		return get_paddingBottom();
	}
	
	private var _gap:Float = 0;
	public var gap(get, set) : Float;
	private function get_gap() : Float {
		return _gap;
	}
	private function set_gap(v:Float) : Float {
		if (Math.isNaN(v))
			v = 0;
		if (gap != v)
			_gap = v;
		return get_gap();
	}
	
	public function new() {
		super();
		_bound = new Rectangle();
	}
	
	private function resizeHandler(e:Event) : Void {
		update();
	}
	
	public function setSize(w:Float, h:Float) : Void {
		_width = w;
		_height = h;
	}
	
	public function update() : Rectangle {
		return null;
	}
	
	public function dispose() : Void {
		if (_owner != null) {
			for (child in _owner.children) {
				var c:BaseIceObject = cast child;
				if (c != null) {
					var p:ILayoutParams = cast c.layoutParams;
					if (p != null) {
						p.dispose();
						p = null;
					}
				}
			}
			_owner = null;
		}
		_objects = null;
		_bound = null;
	}
}