package ru.ice.display;

import haxe.Constraints.Function;

import js.Browser;
import js.html.Image;
import js.html.Element;
import js.html.MouseEvent;
import js.html.TouchEvent;
import js.html.WheelEvent;
import js.html.EventTarget;
import js.html.TransitionEvent;

//import ru.ice.events.CSSTransitionEventType;
import ru.ice.events.WheelScrollEvent;
import ru.ice.events.FingerEvent;
import ru.ice.display.DOMObject;
import ru.ice.core.Capabilities;
import ru.ice.data.ElementData;
import ru.ice.math.Rectangle;
import ru.ice.events.Event;
import ru.ice.math.Point;
import ru.ice.core.Ice;

/**
 * ...
 * @author Evgenii Grebennikov
 * !При применении вращения, область объекта не корректно вычисляется.
 */
class DisplayObject extends DOMObject
{
	private static inline var _DEFAULT_NAME:String = 'div';
	
	private var _isStage:Bool = false;
	
	private var _isClipped:Bool = false;
	public var isClipped(get, set):Bool;
	private function get_isClipped() : Bool {
		return _isClipped;
	}
	private function set_isClipped(v:Bool) : Bool {
		_isClipped = v;
		style = v ? { 'overflow': 'hidden' } : { 'overflow': 'initial' };
		return get_isClipped();
	}
	
	private var _visible:Bool = true;
	public var visible(get, set):Bool;
	private function get_visible() : Bool {
		return _visible;
	}
	private function set_visible(v:Bool) : Bool {
		_visible = v;
		style = v ? { 'visibility': 'visible' } : { 'visibility': 'hidden' };
		return get_visible();
	}
	
	private var _parent:DisplayObject = null;
	public var parent(get, never):DisplayObject;
	private function get_parent() : DisplayObject {
		return _parent;
	}
	
	private var _children:Array<DisplayObject> = new Array<DisplayObject>();
	public var children(get, never):Array<DisplayObject>;
	private function get_children() : Array<DisplayObject> {
		return _children;
	}
	
	private var _x:Float;
	public var x(get, set):Float;
	private function get_x() : Float {
		return Math.isNaN(_x) ? 0 : _x;
	}
	private function set_x(v:Float) : Float {
		if (_x != v) {
			_x = v;
			_element.style.left = _x + 'px';
		}
		return get_x();
	}
	
	private var _y:Float = 0;
	public var y(get, set):Float;
	private function get_y() : Float {
		return Math.isNaN(_y) ? 0 : _y;
	}
	private function set_y(v:Float) : Float {
		if (_y != v) {
			_y = v;
			_element.style.top = _y + 'px';
		}
		return get_y();
	}
	
	private var _scaleX:Float = 1;
	public var scaleX(get, set):Float;
	private function get_scaleX() : Float {
		return _scaleX;
	}
	private function set_scaleX(v:Float) : Float {
		if (_scaleX != v) {
			_scaleX = v;
			resetTransformation(_scaleX, _scaleY, _rotate);
		}
		return get_scaleX();
	}
	
	private var _scaleY:Float = 1;
	public var scaleY(get, set):Float;
	private function get_scaleY() : Float {
		return _scaleY;
	}
	private function set_scaleY(v:Float) : Float {
		if (_scaleY != v) {
			_scaleY = v;
			resetTransformation(_scaleX, _scaleY, _rotate);
		}
		return get_scaleY();
	}
	
	private var _rotate:Float = 0;
	public var rotate(get, set):Float;
	private function get_rotate() : Float {
		return _rotate;
	}
	private function set_rotate(v:Float) : Float {
		if (_rotate != v) {
			_rotate = v;
			resetTransformation(_scaleX, _scaleY, _rotate);
		}
		return get_rotate();
	}
	
	private function resetTransformation(sx:Float, sy:Float, r:Float) : Void
	{
		if (_element != null) 
			Reflect.setField(_element.style, Capabilities.transformMethod, "scale(" + sx + ", " + sy + ") rotate(" + r + "deg)");
	}
	
	private var _bound:Rectangle = new Rectangle();
	public var bound(get, never) : Rectangle;
	public function get_bound() : Rectangle {
		var x:Float = 0, y:Float = 0, w:Float = 0, h:Float = 0;
		for (child in _children) {
			if (child.style.overflow != 'hidden') {
				x = Math.min(x, child.x);
				y = Math.min(y, child.y);
				w = Math.max(w, child.x + child.contentWidth);
				h = Math.max(h, child.y + child.contentHeight);
			}
		}
		_bound.move(x, y);
		_bound.setSize(w, h);
		return _bound;
	}
	
	public var totalContentWidth(get, never) : Float;
	public function get_totalContentWidth() : Float {
		var w:Float = 0;
		for (child in _children) {
			if (child.style.overflow != 'hidden')
				w = Math.max(w, child.x + child.contentWidth);
		}
		return w;
	}
	
	public var totalContentHeight(get, never) : Float;
	public function get_totalContentHeight() : Float {
		var h:Float = 0;
		for (child in _children) {
			if (child.style.overflow != 'hidden')
				h = Math.max(h, child.y + child.contentHeight);
		}
		return h;
	}
	
	public var contentWidth(get, never):Float;
	private function get_contentWidth() : Float {
		return width * _scaleX;
	}
	
	public var contentHeight(get, never):Float;
	private function get_contentHeight() : Float {
		return height * _scaleY;
	}
	
	public var width(get, set):Float;
	private function get_width() : Float {
		return _element.offsetWidth;
	}
	private function set_width(v:Float) : Float {
		if (_element.offsetWidth != v)
			_element.style.width = v + 'px';
		return get_width();
	}
	
	public var height(get, set):Float;
	private function get_height() : Float {
		return _element.offsetHeight;
	}
	private function set_height(v:Float) : Float {
		if (_element.offsetHeight != v)
			_element.style.height = v + 'px';
		return get_height();
	}
	
	private override function set_elementName(v:String):String {
		if (_elementName != v) {
			if (v == null) {
				if (_element != null) {
					if (_parent != null) {
						if (_parent.element.contains(this._element))
							_parent.element.removeChild(this._element);
					}
					_element = null;
				}
			} else {
				_elementName = v;
				_element = Browser.document.createElement(_elementName);
			}
		}
		return get_elementName();
	}
	
	public var displayState(get, never):String;
	private function get_displayState():String {
		return _element != null ? _element.style.display : '';
	}
	
	public var stage(get, never):Stage;
	private function get_stage():Stage {
		return Stage.current;
	}
	
	private var _touchX:Float = 0;
	public var touchX(get, set):Float;
	private function get_touchX() : Float {
		return _touchX;
	}
	private function set_touchX(v:Float) : Float {
		_touchX = v;
		return get_touchX();
	}
	
	private var _touchY:Float = 0;
	public var touchY(get, set):Float;
	private function get_touchY() : Float {
		return _touchY;
	}
	private function set_touchY(v:Float) : Float {
		_touchY = v;
		return get_touchY();
	}
	
	private var _touchable:Bool = true;
	public var touchable(get, set):Bool;
	private function get_touchable() : Bool {
		return _touchable;
	}
	private function set_touchable(v:Bool) : Bool {
		if (_touchable != v) {
			_touchable = v;
			if (_touchable)
				element_addTouchListeners();
			else
				element_removeTouchListeners();
		}
		return get_touchable();
	}
	
	private var _hasCssOnTransitionCompleteListeners:Bool = false;
	
	/*private var _onCssTransitionComplete:Function;
	public var onCssTransitionComplete(get, set):Function;
	private function get_onCssTransitionComplete() : Function {
		return _onCssTransitionComplete;
	}
	private function set_onCssTransitionComplete(v:Function) : Function {
		if (_onCssTransitionComplete != v) {
			_onCssTransitionComplete = v;
			var l:Int = CSSTransitionEventType.CSS_TRANSITION_EVENTS.length;
			if (v == null) {
				if (_hasCssOnTransitionCompleteListeners) {
					for (i in 0...l) {
						trace('removett l');
						this._element.removeEventListener(CSSTransitionEventType.CSS_TRANSITION_EVENTS[i], cssTransitionCompleteHandler);
					}
					_hasCssOnTransitionCompleteListeners = false;
				}
			} else {
				if (!_hasCssOnTransitionCompleteListeners) {
					for (j in 0...l) {
						trace('addtt l');
						_element.addEventListener(CSSTransitionEventType.CSS_TRANSITION_EVENTS[j], cssTransitionCompleteHandler, false);
					}
					_hasCssOnTransitionCompleteListeners = true;
				}
			}
		}
		return get_onCssTransitionComplete();
	}
	
	
	private function cssTransitionCompleteHandler(e:TransitionEvent) : Void {
		trace('css transition');
		if (_onCssTransitionComplete != null)
			_onCssTransitionComplete();
	}*/
	
	public function new(?elementData:ElementData, ?initial:Bool = false) 
	{
		super();
		_isStage = Std.is(this, Stage);
		if (elementData != null) {
			elementName = elementData.name != null ? elementData.name : _DEFAULT_NAME;
			style = elementData.style;
			_touchable = elementData.touchable;
			if (_touchable)
				element_addTouchListeners();
			else
				element_removeTouchListeners();
			if (elementData.id != null)
				setID(elementData.id);
			if (elementData.classes != null)
				addClass(elementData.classes);
		} else
			elementName = _DEFAULT_NAME;
	}
	
	private function element_addTouchListeners() : Void
	{
		var eTarget:EventTarget = _isStage ? Browser.window : element;
		eTarget.addEventListener('mousemove', _mouseMoveHandler);
		eTarget.addEventListener('touchstart', _touchStartHandler);
		eTarget.addEventListener('touchend', _touchEndHandler);
		eTarget.addEventListener('touchmove', _touchMoveHandler);
		eTarget.addEventListener('mouseup', _mouseUpHandler);
		eTarget.addEventListener('mousedown', _mouseDownHandler);
		eTarget.addEventListener('wheel', _wheelScrollHandler);
	}
	
	private function element_removeTouchListeners() : Void
	{
		var eTarget:EventTarget = _isStage ? Browser.window : element;
		eTarget.removeEventListener('mousemove', _mouseMoveHandler);
		eTarget.removeEventListener('touchstart', _touchStartHandler);
		eTarget.removeEventListener('touchend', _touchEndHandler);
		eTarget.removeEventListener('touchmove', _touchMoveHandler);
		eTarget.removeEventListener('mouseup', _mouseUpHandler);
		eTarget.removeEventListener('mousedown', _mouseDownHandler);
		eTarget.removeEventListener('wheel', _wheelScrollHandler);
	}
	
	private function _touchStartHandler(e:js.html.TouchEvent) : Void {
		e.cancelBubble = true;
		e.preventDefault();
		e.stopImmediatePropagation();
		
		var event:FingerEvent = FingerEvent.fromDomEvent(FingerEvent.DOWN, e, true);
		
		dispatchEvent(event, this);
	}
	
	private function _mouseMoveHandler(e:js.html.MouseEvent) : Void {
		e.cancelBubble = true;
		e.preventDefault();
		e.stopImmediatePropagation();
		
		var event1:FingerEvent = FingerEvent.fromDomEvent(FingerEvent.MOVE, e, false);
		event1.setTarget(this);
		
		var event:FingerEvent = FingerEvent.fromDomEvent(FingerEvent.MOVE, e, false);
		event.setTarget(this);
		// Для восходящего улавливания
		stage.sMove(event1);
		
		if (_isStage)
			dispatchEvent(event, this);
		else
			stage.dispatchEvent(event, this);
	}
	
	private function _touchEndHandler(e:js.html.TouchEvent) : Void {
		e.cancelBubble = true;
		e.preventDefault();
		e.stopImmediatePropagation();
		
		Ice.isDragging = false;
		
		var event:FingerEvent = FingerEvent.fromDomEvent(FingerEvent.UP, e, true);
		
		dispatchEvent(event, this);
	}
	
	private function _touchMoveHandler(e:js.html.TouchEvent) : Void {
		e.cancelBubble = true;
		e.stopImmediatePropagation();
		
		var event:FingerEvent = FingerEvent.fromDomEvent(FingerEvent.MOVE, e, true);
		
		dispatchEvent(event, this);
	}
	
	private function _mouseUpHandler(e:js.html.MouseEvent) : Void {
		e.cancelBubble = true;
		e.preventDefault();
		e.stopImmediatePropagation();
		
		Ice.isDragging = false;
		
		var event:FingerEvent = FingerEvent.fromDomEvent(FingerEvent.UP, e, true);
		
		dispatchEvent(event, this);
	}
	
	private function _mouseDownHandler(e:js.html.MouseEvent) : Void {
		e.cancelBubble = true;
		e.preventDefault();
		e.stopImmediatePropagation();
		
		var event:FingerEvent = FingerEvent.fromDomEvent(FingerEvent.DOWN, e, true);
		
		dispatchEvent(event, this);
	}
	
	private function _wheelScrollHandler(e:js.html.WheelEvent) : Void {
		e.cancelBubble = true;
		e.preventDefault();
		e.stopImmediatePropagation();
		//trace(e.altKey, e.button, e.buttons, e.ctrlKey, e.deltaMode, e.deltaX, e.deltaY, e.deltaZ, e.detail, e.isChar, e.isTrusted, e.movementX, e.movementY, e.metaKey, e.layerX, e.layerY, e.offsetY, e.offsetX, e.pageX, e.pageY, e.rangeOffset, e.type, e.view, e.which);
		var event:WheelScrollEvent = WheelScrollEvent.fromDomEvent(WheelScrollEvent.SCROLL, e, true);
		
		dispatchEvent(event, this);
	}
	
	public function containsInChain(child:DisplayObject) : Bool {
		if (child == this)
			return true;
		if (_children.indexOf(child) > -1)
			return true;
		for (c in _children) {
			var contains:Bool = c.containsInChain(child);
			if (contains)
				return true;
		}
		return false;
	}
	
	public function contains(child:DisplayObject) : Bool {
		return _children.indexOf(child) > -1;
	}
	
	private function addedToStage() : Void {}
	
	private function removeFromStage() : Void {}
	
	public function addChild(child:DisplayObject) : DisplayObject {
		if (child == null) {
			#if debug
				throw "Parameter 'child' must be non null.";
			#end
			return null;
		}
		_children.push(child);
		var childNode:Element = child.element;
		_element.appendChild(childNode);
		child._parent = this;
		element.appendChild(child.element);
		child.addedToStage();
		return child;
	}
	
	public function removeChild(child:DisplayObject) : DisplayObject {
		if (child == null) {
			#if debug
				throw "Parameter 'child' must be non null.";
			#end
			return null;
		}
		var index:Int = getChildIndex(child);
		if (index < 0) {
			#if debug
				throw "Child not found.";
			#end
			return null;
		}
		_children.splice(index, 1);
		_element.removeChild(child.element);
		child._parent = null;
		child.removeFromStage();
		return child;
	}
	
	public function getChildIndex(child:DisplayObject) : Int {
		return _children.indexOf(child);
	}
	
	public function getAbsolutePosition() : Point {
		var parent:DisplayObject = parent;
		var offsetX:Float = x, offsetY:Float = y;
		while (parent != null) {
			offsetX += parent.x;
			offsetY += parent.y;
			parent = parent.parent;
		}
		return new Point(offsetX, offsetY);
	}
	
	public var position(get, never):Point;
	private function get_position() : Point {
		return new Point(x, y);
	}
	
	public function localToGlobal(point:Point) : Point {
		return getAbsolutePosition().add(point);
	}
	
	public function globalToLocal(point:Point) : Point {
		if (point == null) {
			#if debug
				throw 'Parameter "point" is not defined.';
			#end
			return null;
		}
		return point.deduct(getAbsolutePosition());
	}
	
	public function removeFromParent(dispose:Bool = false) : DisplayObject {
		if (parent != null) {
			if (parent.contains(this))
				parent.removeChild(this);
		}
		if (dispose)
			this.dispose();
		return this;
	}
	
	public function setSize(width:Float, height:Float) : Void
	{
		this.width = width;
		this.height = height;
	}
	
	public function move(x:Float, y:Float) : Void
	{
		this.x = x;
		this.y = y;
		resetTransformation(_scaleX, _scaleY, _rotate);
	}
	
	public function update() : Void {}
	
	@:allow(ru.ice.display.Stage)
	private function mouseMove(e:FingerEvent) : Void {}
	
	private function chainToString() : String
	{
		var mParent:DisplayObject = parent;
		var str:String = _elementName;
		if (mParent == null)
			return str + ':disposed parent';
		str += '->' + mParent.elementName;
		while (mParent.parent != null) {
			str += '->' + mParent.parent.elementName;
			mParent = mParent.parent;
		}
		return str;
	}
	
	public override function dispose() : Void
	{
		//onCssTransitionComplete = null;
		
		if (_touchable)
			removeEventListeners();
		
		Ice.animator.removeTweens(this);
		while (_children.length > 0) {
			var child:DisplayObject = _children.shift();
			child.removeFromParent(true);
			child = null;
		}
		while (_element.children.length > 0) {
			var eChild:Element = _element.children.item(_element.children.length - 1);
			eChild.remove();
			eChild = null;
		}
		elementName = null;
		super.dispose();
	}
}