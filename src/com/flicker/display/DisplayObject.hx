package com.flicker.display;

import com.flicker.controls.super.FlickerControl;
import haxe.Constraints.Function;

import js.Browser;
import js.html.Image;
import js.html.DOMElement;
import js.html.MouseEvent;
import js.html.TouchEvent;
import js.html.WheelEvent;
import js.html.EventTarget;

import com.flicker.controls.super.FlickerControl.ResizeData;
import com.flicker.events.WheelScrollEvent;
import com.flicker.events.FingerEvent;
import com.flicker.display.DOMExpress;
import com.flicker.core.Capabilities;
import com.flicker.data.ElementData;
import com.flicker.math.Rectangle;
import com.flicker.events.Event;
import com.flicker.math.Point;
import com.flicker.core.Flicker;

/**
 * ...
 * @author Evgenii Grebennikov
 * !При применении вращения, область объекта не корректно вычисляется.
 */
class DisplayObject extends DOMExpress
{
	private static inline var DEFAULT_NAME:String = 'div';
	
	private var _isStage:Bool = false;
	
	public var _isHover:Bool = false;
	public var isHover(get, set) : Bool;
	private function get_isHover() : Bool {
		return _isHover;
	}
	private function set_isHover(v:Bool) : Bool {
		if (_isHover != v)
			_isHover = v;
		return get_isHover();
	}
	
	private var _isClipped:Bool = false;
	public var isClipped(get, set):Bool;
	private function get_isClipped() : Bool {
		return _isClipped;
	}
	private function set_isClipped(v:Bool) : Bool {
		if (_isClipped != v) {
			_isClipped = v;
			if (v)
				addClass(['i-clipped']);
			else
				removeClass(['i-clipped']);
		}
		return _isClipped;
	}
	
	private var _enabled:Bool = true;
	public var enabled(get, set):Bool;
	private function get_enabled() : Bool {
		return _enabled;
	}
	private function set_enabled(v:Bool) : Bool {
		if (_enabled != v) {
			_enabled = v;
		}
		return _enabled;
	}
	
	private var _visible:Bool = true;
	public var visible(get, set):Bool;
	private function get_visible() : Bool {
		return _visible;
	}
	private function set_visible(v:Bool) : Bool {
		if (_visible != v) {
			_visible = v;
			if (v)
				removeClass(['i-invisible']);
			else
				addClass(['i-invisible']);
		}
		return _visible;
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
	
	/**
	 * Indicates the x coordinate of the DisplayObject instance relative to the local coordinates of the parent, in pixels
	 */
	public var x(get, set):Float;
	// @:getter(y)
	private function get_x() : Float {
		return _x;
	}
	// @:setter(y)
	private function set_x(v:Float) : Float {
		if (_isSvg) {
			if (_x != v) {
				_x = v;
				setSvgParams(_svg, {x:v});
			}
		} else {
			if (_x != v) {
				_x = v;
				resetTransformation();
			}
		}
		return _x;
	}
	private var _x:Float = 0;
	
	/**
	 * Indicates the y coordinate of the DisplayObject instance relative to the local coordinates of the parent, in pixels
	 */
	public var y(get, set):Float;
	// @:getter(y)
	private function get_y() : Float {
		return _y;
	}
	// @:setter(y)
	private function set_y(v:Float) : Float {
		if (_isSvg) {
			if (_y != v) {
				_y = v;
				setSvgParams(_svg, {y:v});
			}
		} else {
			if (_y != v) {
				_y = v;
				resetTransformation();
			}
		}
		return _y;
	}
	private var _y:Float = 0;
	
	/**
	 * Indicates the z coordinate of the DisplayObject instance relative to the local coordinates of the parent, in pixels
	 */
	public var z(get, set):Float;
	// @:getter(z)
	private function get_z() : Float {
		return _z;
	}
	// @:setter(z)
	private function set_z(v:Float) : Float {
		if (_isSvg) {
			if (_z != v) {
				_z = v;
				setSvgParams(_svg, {z:v});
			}
		} else {
			if (_z != v) {
				_z = v;
				resetTransformation();
			}
		}
		return _x;
	}
	private var _z:Float = 0;
	
	/**
	 * Indicates the horizontal scale of the object as applied from pivot
	 */
	public var scaleX(get, set):Float;
	// @:getter(scaleX)
	private function get_scaleX() : Float {
		return _scaleX;
	}
	// @:setter(scaleX)
	private function set_scaleX(v:Float) : Float {
		if (_scaleX != v) {
			_scaleX = v;
			resetTransformation();
		}
		return _scaleX;
	}
	private var _scaleX:Float = 1;
	
	/**
	 * Indicates the vertical scale of the object as applied from pivot
	 */
	public var scaleY(get, set):Float;
	// @:getter(scaleY)
	private function get_scaleY() : Float {
		return _scaleY;
	}
	// @:setter(scaleY)
	private function set_scaleY(v:Float) : Float {
		if (_scaleY != v) {
			_scaleY = v;
			resetTransformation();
		}
		return _scaleY;
	}
	private var _scaleY:Float = 1;
	
	/**
	 * Indicates the scale of the object as applied from pivot
	 */
	public var scale(get, set):Float;
	// @:getter(scale)
	private function get_scale() : Float {
		return _scale;
	}
	// @:setter(scale)
	private function set_scale(v:Float) : Float {
		if (_scale != v) {
			_scale = _scaleX = _scaleY = v;
			resetTransformation();
		}
		return v;
	}
	private var _scale:Float = 1;
	
	/*private var _rotate:Float = 0;
	public var rotate(get, set):Float;
	private function get_rotate() : Float {
		return _rotate;
	}
	private function set_rotate(v:Float) : Float {
		if (_rotate != v) {
			_rotate = v;
			resetTransformation();
		}
		return _rotate;
	}*/
	
	private function resetTransformation() : Void
	{
		if (_element != null) 
			Reflect.setField(_element.style, 'transform'/*Capabilities.transformMethod*/, "translate3D(" + _x + "px, " + _y + "px, " + _z + "px) scale(" + _scaleX + ", " + _scaleY + ")");// rotate(" + _rotate + "deg)");
	}
	
	/**
	 * The rectangle bounds of the display object
	 */
	public var bound(get, never) : Rectangle;
	// @:getter(bound)
	private function get_bound() : Rectangle {
		var x:Float = 0, y:Float = 0, w:Float = 0, h:Float = 0;
		for (child in _children) {
			//if (child.element.style.overflow != 'hidden') {
				x = Math.min(x, child._x);
				y = Math.min(y, child._y);
				w = Math.max(w, child._x + child._width);
				h = Math.max(h, child._y + child._height);
			//}
		}
		_bound.move(x, y);
		_bound.setSize(w, h);
		return _bound;
	}
	private var _bound:Rectangle = new Rectangle();
	
	/**
	 * Indicates the width of the dysplay objects inside the current dysplay object, in pixels
	 */
	public var totalContentWidth(get, never) : Float;
	private function get_totalContentWidth() : Float {
		var w:Float = 0;
		for (child in _children) {
			//if (child.enabled)
				w = Math.max(w, child._x + child._width);
		}
		return w;
	}
	
	/**
	 * Indicates the height of the dysplay objects inside the current dysplay object, in pixels
	 */
	public var totalContentHeight(get, never) : Float;
	private function get_totalContentHeight() : Float {
		var h:Float = 0;
		for (child in _children) {
			//if (child.enabled)
				h = Math.max(h, child._y + child._height);
		}
		return h;
	}
	
	/**
	 * Indicates the width of the DOM objects inside the current dysplay object, in pixels
	 */
	public var htmlContentWidth(get, never) : Float;
	private function get_htmlContentWidth() : Float {
		var w:Float = 0;
		//if (_enabled) {
			for (e in _element.children) {
				w = Math.max(w, e.offsetLeft + e.offsetWidth);
			}
		//}
		return w;
	}
	
	/**
	 * Indicates the height of the DOM objects inside the current dysplay object, in pixels
	 */
	public var htmlContentHeight(get, never) : Float;
	private function get_htmlContentHeight() : Float {
		var h:Float = 0;
		//if (_enabled) {
			for (e in _element.children) {
				h = Math.max(h, e.offsetTop + e.offsetHeight);
			}
		//}
		return h;
	}
	
	/**
	 * Indicates the width of the display object, in pixels
	 */
	public var width(get, set):Float;
	//@:getter(width)
	private function get_width() : Float {
		return _width;
	}
	//@:setter(width)
	private function set_width(v:Float) : Float {
		if (_isSvg) {
			if (_width != v && v >= 0) {
				_width = v;
				setSvgParams(_svg, {width:v});
			}
		} else {
			if (_width != v) {
				_width = v;
				_element.style.width = v + 'px';
			}
		}
		return _width;
	}
	public var _width:Float = 0;
	
	/**
	 * Indicates the height of the display object, in pixels
	 */
	public var height(get, set):Float;
	//@:getter(height)
	private function get_height() : Float {
		return _height;
	}
	//@:setter(height)
	private function set_height(v:Float) : Float {
		if (_isSvg) {
			if (_height != v && v >= 0) {
				_height = v;
				setSvgParams(_svg, {height:v});
			}
		} else {
			if (_height != v) {
				_height = v;
				_element.style.height = v + 'px';
			}
		}
		return _height;
	}
	public var _height:Float = 0;
	
	//@:override
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
				if (_isSvg) {
					_element = Browser.document.createElementNS('http://www.w3.org/2000/svg', 'svg');
					_element.setAttributeNS("http://www.w3.org/2000/xmlns/", "xmlns:xlink", "http://www.w3.org/1999/xlink");
					_svg = cast _element;
				} else {
					_element = Browser.document.createElement(_elementName);
				}
			}
		}
		return get_elementName();
	}
	
	public var actualWidth(get, never):Float;
	//@:getter(actualWidth)
	private function get_actualWidth() : Float {
		return _width;
	}
	
	public var actualHeight(get, never):Float;
	//@:getter(actualHeight)
	private function get_actualHeight() : Float {
		return _height;
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
		return _touchX;
	}
	
	private var _touchY:Float = 0;
	public var touchY(get, set):Float;
	private function get_touchY() : Float {
		return _touchY;
	}
	private function set_touchY(v:Float) : Float {
		_touchY = v;
		return _touchY;
	}
	
	private var _disableInput:Bool = false;
	public var disableInput(get, set):Bool;
	private function get_disableInput() : Bool {
		return _disableInput;
	}
	private function set_disableInput(v:Bool) : Bool {
		if (_disableInput != v) {
			_disableInput = v;
			if (_interactive)
				removeClass(['not-interactive']);
			else
				addClass(['not-interactive']);
		}
		return _interactive;
	}
	
	private var _interactive:Bool = false;
	public var interactive(get, set):Bool;
	private function get_interactive() : Bool {
		return _interactive;
	}
	private function set_interactive(v:Bool) : Bool {
		if (_interactive != v) {
			_interactive = v;
			if (v) {
				if (_disableInput) removeClass(['not-interactive']);
				listenInteractiveEvents();
			} else {
				if (_disableInput) addClass(['not-interactive']);
				removeListenInteractiveEvents();
			}
		}
		return _interactive;
	}
	
	/**
	 * Returns true if the current object is initialized
	 */
	public var isInitialized(get, never):Bool;
	// @:getter(isInitialized)
	private function get_isInitialized():Bool {
		return _isInitialized;
	}
	private var _isInitialized:Bool = false;
	
	private var _isAddedTouchListeners:Bool = false;
	
	public function initialize() : Void {
		_isInitialized = true;
		for (child in children) {
			child.checkInitialized();
		}
		dispatchEventWith(Event.INITIALIZE);
	}
	
	public function new(?elementData:ElementData, ?initial:Bool = false) 
	{
		var nuc:String = (elementData != null ? elementData.name != null ? elementData.name : DEFAULT_NAME : DEFAULT_NAME).toUpperCase();
		super(nuc == 'SVG');
		_isStage = Std.is(this, Stage);
		if (elementData != null) {
			elementName = elementData.name != null ? elementData.name : DEFAULT_NAME;
			addClass(['ice']); // Базовый s класс
			style = elementData.style;
			_disableInput = elementData.disableInput;
			interactive = elementData.interactive;
			if (elementData.id != null)
				setID(elementData.id);
			if (elementData.classes != null)
				addClass(elementData.classes);
		} else {
			elementName = DEFAULT_NAME;
			addClass(['ice']); // Базовый s класс
			interactive = true;
		}
		
		if (!_interactive && _disableInput)
			addClass(['not-interactive']);
		
		x = _element.offsetLeft;
		y = _element.offsetTop;
	}
	
	public function insertChildAt(child:DisplayObject, index:Int) : Void {
		_children.insert(index, child);
		insertElementAt(child.element, index);
	}
	
	public function setPivot(x:String, y:String) : Void {
		style = {'transform-origin': x + ' ' + y};
	}
	
	public function setPivotToCenter() : Void {
		setPivot('center', 'center');
	}
	
	private var _swapedObject:DisplayObject;
	
	public function swapInteractiveEventsFor(swapedObject:DisplayObject) : Void {
		_swapedObject = swapedObject;
	}
	
	private function listenInteractiveEvents() : Void
	{
		if (!_isAddedTouchListeners) {
			_isAddedTouchListeners = true;
			var eTarget:EventTarget = _isStage ? Browser.window : element;
			eTarget.addEventListener('mousemove', __mouseMoveHandler);
			eTarget.addEventListener('touchstart', __touchStartHandler);
			eTarget.addEventListener('touchend', __touchEndHandler);
			eTarget.addEventListener('touchmove', __touchMoveHandler);
			eTarget.addEventListener('mouseup', __mouseUpHandler);
			eTarget.addEventListener('mousedown', __mouseDownHandler);
			eTarget.addEventListener('wheel', __wheelScrollHandler);
		}
	}
	
	private function removeListenInteractiveEvents() : Void
	{
		if (_isAddedTouchListeners) {
			_isAddedTouchListeners = false;
			var eTarget:EventTarget = _isStage ? Browser.window : element;
			eTarget.removeEventListener('mousemove', __mouseMoveHandler);
			eTarget.removeEventListener('touchstart', __touchStartHandler);
			eTarget.removeEventListener('touchend', __touchEndHandler);
			eTarget.removeEventListener('touchmove', __touchMoveHandler);
			eTarget.removeEventListener('mouseup', __mouseUpHandler);
			eTarget.removeEventListener('mousedown', __mouseDownHandler);
			eTarget.removeEventListener('wheel', __wheelScrollHandler);
		}
	}
	
	private function __touchStartHandler(e:js.html.TouchEvent) : Void {
		if (_swapedObject != null)
			_swapedObject._touchStartHandler(e);
		else
			_touchStartHandler(e);
	}
	
	private function _touchStartHandler(e:js.html.TouchEvent) : Void {
		e.cancelBubble = true;
		e.preventDefault();
		e.stopImmediatePropagation();
		
		var event:FingerEvent = FingerEvent.fromDomEvent(FingerEvent.DOWN, e, true);
		
		dispatchEvent(event, this);
	}
	
	private function __mouseMoveHandler(e:js.html.MouseEvent) : Void {
		if (_swapedObject != null)
			_swapedObject._mouseMoveHandler(e);
		else
			_mouseMoveHandler(e);
	}
	
	private function _mouseMoveHandler(e:js.html.MouseEvent) : Void {
		e.cancelBubble = true;
		e.preventDefault();
		e.stopImmediatePropagation();
		
		var event1:FingerEvent = FingerEvent.fromDomEvent(FingerEvent.MOVE, e, false);
		event1.setTarget(this);
		
		var event:FingerEvent = FingerEvent.fromDomEvent(FingerEvent.MOVE, e, true);
		event.setTarget(this);
		// Для восходящего улавливания
		stage.sMove(event1);
		
		if (_isStage)
			dispatchEvent(event, this);
		else
			stage.dispatchEvent(event, this);
	}
	
	private function __touchEndHandler(e:js.html.TouchEvent) : Void {
		if (_swapedObject != null)
			_swapedObject._touchEndHandler(e);
		else
			_touchEndHandler(e);
	}
	
	private function _touchEndHandler(e:js.html.TouchEvent) : Void {
		e.cancelBubble = true;
		e.preventDefault();
		e.stopImmediatePropagation();
		
		Flicker.isDragging = false;
		
		var event:FingerEvent = FingerEvent.fromDomEvent(FingerEvent.UP, e, true);
		
		dispatchEvent(event, this);
	}
	
	private function __touchMoveHandler(e:js.html.TouchEvent) : Void {
		if (_swapedObject != null)
			_swapedObject._touchMoveHandler(e);
		else
			_touchMoveHandler(e);
	}
	
	private function _touchMoveHandler(e:js.html.TouchEvent) : Void {
		e.cancelBubble = true;
		e.stopImmediatePropagation();
		
		var event:FingerEvent = FingerEvent.fromDomEvent(FingerEvent.MOVE, e, true);
		
		dispatchEvent(event, this);
	}
	
	private function __mouseUpHandler(e:js.html.MouseEvent) : Void {
		if (_swapedObject != null)
			_swapedObject._mouseUpHandler(e);
		else
			_mouseUpHandler(e);
	}
	
	private function _mouseUpHandler(e:js.html.MouseEvent) : Void {
		e.cancelBubble = true;
		e.preventDefault();
		e.stopImmediatePropagation();
		
		Flicker.isDragging = false;
		
		var event:FingerEvent = FingerEvent.fromDomEvent(FingerEvent.UP, e, true);
		
		dispatchEvent(event, this);
	}
	
	private function __mouseDownHandler(e:js.html.MouseEvent) : Void {
		if (_swapedObject != null)
			_swapedObject._mouseDownHandler(e);
		else
			_mouseDownHandler(e);
	}
	
	private function _mouseDownHandler(e:js.html.MouseEvent) : Void {
		e.cancelBubble = true;
		e.preventDefault();
		e.stopImmediatePropagation();
		
		var event:FingerEvent = FingerEvent.fromDomEvent(FingerEvent.DOWN, e, true);
		
		dispatchEvent(event, this);
	}
	
	private function __wheelScrollHandler(e:js.html.WheelEvent) : Void {
		if (_swapedObject != null)
			_swapedObject._wheelScrollHandler(e);
		else
			_wheelScrollHandler(e);
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
	
	/**
	 * @param {DisplayObject} child
	 * @return {Bool}
	 */
	public function contains(child:DisplayObject) : Bool {
		return _children.indexOf(child) > -1;
	}
	
	private function addedToStage() : Void {
		checkInitialized();
		this.dispatchEventWith(Event.ADDED_TO_STAGE, true);
	}
	
	public function checkInitialized() : Void {
		if ((parent != null ? parent.isInitialized : false) || Std.is(this, Stage)) {
			if (!_isInitialized)
				initialize();
		}
	}
	
	private function removeFromStage() : Void {
		this.dispatchEventWith(Event.REMOVED_FROM_STAGE, true);
	}
	
	/**
	 * Add the object to the display list with index
	 * @param {DisplayObject} child
	 * @return {DisplayObject}
	 */
	public function addChildAt(child:DisplayObject, index:Int) : DisplayObject {
		if (child == null) {
			#if debug
				throw "Parameter 'child' must be non null.";
			#end
			return null;
		}
		var childNode:DOMElement = child.element;
		insertChildAt(child, index);
		child._parent = this;
		child.addedToStage();
		return child;
	}
	
	/**
	 * Added the object to the display list
	 * @param {DisplayObject} child
	 * @return {DisplayObject}
	 */
	public function addChild(child:DisplayObject) : DisplayObject {
		if (child == null) {
			#if debug
				throw "Parameter 'child' must be non null.";
			#end
			return null;
		}
		insertChildAt(child, _children.length);
		child._parent = this;
		child.addedToStage();
		dispatchEventWith(Event.CHILD_ADDED);
		return child;
	}
	
	/**
	 * Remove the object from the display list
	 * @param {DisplayObject} child
	 * @return {DisplayObject}
	 */
	public function removeChild(child:DisplayObject) : DisplayObject {
		if (child == null) {
			#if debug
				throw 'Parameter "child" must be non null.';
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
		
		// _element.removeChild(child.element);
		// Тут косяк. Удаляется элемент который не пренадлежит к родителю
		// Т.к. родитель удален, Поэтому используется след. конструкция:
		var p:DOMElement = child.element.parentElement;
		if (p != null)
			p.removeChild(child.element);
		
		_children.splice(index, 1);
		child._parent = null;
		child.removeFromStage();
		dispatchEventWith(Event.CHILD_REMOVED);
		return child;
	}
	
	/**
	 * Returns the index of the specified object
	 * @return {Point}
	 */
	public function getChildIndex(child:DisplayObject) : Int {
		return _children.indexOf(child);
	}
	
	/**
	 * Returns a absolute position
	 * @return {Point}
	 */
	public function getAbsolutePosition() : Point {
		var parent:DisplayObject = parent;
		var offsetX:Float = _x, offsetY:Float = _y;
		while (parent != null) {
			offsetX += parent._x;
			offsetY += parent._y;
			parent = parent.parent;
		}
		return new Point(offsetX, offsetY);
	}
	
	/**
	 * Returns a 2D point corresponding to the current position
	 * @return {Point}
	 */
	public var position(get, never):Point;
	private function get_position() : Point {
		return new Point(_x, _y);
	}
	
	/**
	 * Transforms a 2D point from the global (stage) coordinate system to local coordinates
	 * @param {Point} point
	 * @return {Point}
	 */
	public function localToGlobal(point:Point) : Point {
		return getAbsolutePosition().add(point);
	}
	
	/**
	 * Transforms a 2D point from the local coordinate system to global (stage) coordinates
	 * @param {Point} point
	 * @return {Point}
	 */
	public function globalToLocal(point:Point) : Point {
		if (point == null) {
			#if debug
				throw 'Parameter "point" is not defined.';
			#end
			return null;
		}
		return point.deduct(getAbsolutePosition());
	}
	
	/**
	 * Remove the object from its parent, if it has one, and optionaly disposes it
	 * @param {Bool} dispose
	 * @return {DisplayObject}
	 */
	public function removeFromParent(dispose:Bool = false) : DisplayObject {
		if (parent != null) {
			if (parent.contains(this))
				parent.removeChild(this);
		}
		if (dispose)
			this.dispose();
		return this;
	}
	
	/**
	 * Remove all children of the self
	 * @param {Bool} dispose
	 */
	public function removeAllChildren(dispose:Bool = false) : Void {
		while (_children.length > 0) {
			var child:DisplayObject = _children.shift();
			child.removeFromParent(dispose);
			child = null;
		}
	}
	
	/**
	 * Set the size
	 * @param {Float} width
	 * @param {Float} height
	 */
	public function setSize(width:Float, height:Float) : Void
	{
		this.width = width;
		this.height = height;
	}
	
	/**
	 * Move to the set position
	 * @param {Float} x
	 * @param {Float} y
	 */
	public function move(x:Float, y:Float) : Void
	{
		this.x = x;
		this.y = y;
	}
	
	public function update(emitResize:Bool = true) : ResizeData {
		return null;
	}
	
	@:allow(com.flicker.display.Stage)
	private function mouseMove(e:FingerEvent) : Void {
		if (e.target == this && e.isMouse && !Stage.current.isMouseLeave && !Flicker.globalPressed)
			dispatchEventWith(Event.HOVER, true, {objects:[]});
	}
	
	/**
	 * Returns the chain string
	 * @return {String}
	 */
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
	
	
	/**
	 * Disposes all children of the self and remove all registered event listeners
	 */
	public override function dispose() : Void
	{
		if (_interactive)
			removeEventListeners();
		
		Flicker.animator.removeTweens(this);
		while (_children.length > 0) {
			var child:DisplayObject = _children.shift();
			child.removeFromParent(true);
			child = null;
		}
		if (_element != null) {
			if (_element.children != null) {
				while (_element.children.length > 0) {
					var eChild:DOMElement = _element.children.item(_element.children.length - 1);
					eChild.remove();
					eChild = null;
				}
			}
			elementName = null;
		}
		if (_swapedObject != null)
			_swapedObject = null;
		super.dispose();
	}
}