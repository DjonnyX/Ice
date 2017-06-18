package ru.ice.controls;

import haxe.Constraints.Function;

import ru.ice.animation.IAnimatable;
import ru.ice.animation.Tween;
import ru.ice.animation.Transitions;
import ru.ice.core.Ice;
import ru.ice.controls.super.IceControl;
import ru.ice.controls.IScrollBar;
import ru.ice.data.ElementData;
import ru.ice.events.Event;
import ru.ice.events.FingerEvent;
import ru.ice.events.WheelScrollEvent;
import ru.ice.display.DisplayObject;
import ru.ice.math.Point;
import ru.ice.math.Rectangle;
//import ru.ice.utils.FloatUtil;
import ru.ice.layout.ILayout;
import ru.ice.events.LayoutEvent;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class ScrollPlane extends Scroller
{
	public static inline var DEFAULT_STYLE:String = 'default-scrollplane-style';
	
	public static inline var SCROLL_POLICY_AUTO:String = 'auto';
	public static inline var SCROLL_POLICY_ON:String = 'on';
	public static inline var SCROLL_POLICY_OFF:String = 'off';
	
	public static inline var DIRECTION_VERTICAL:String = 'vertical';
	public static inline var DIRECTION_HORIZONTAL:String = 'horizontal';
	
	private var _horizontalScrollbar:IScrollBar;
	private var _verticalScrollbar:IScrollBar;
	
	private var _horizontalScrollBarFactory : Function;
	public var horizontalScrollBarFactory(get, set) : Function;
	private function get_horizontalScrollBarFactory() : Function {
		return _horizontalScrollBarFactory;
	}
	private function set_horizontalScrollBarFactory(v:Function) : Function
	{
		if (_horizontalScrollBarFactory != v) {
			_horizontalScrollBarFactory = v;
			if (_horizontalScrollbar != null) {
				removeScrollBarHorizontally();
				createScrollBarHorizontally();
			}
		}
		return get_horizontalScrollBarFactory();
	}
	
	private var _verticalScrollBarFactory : Function;
	public var verticalScrollBarFactory(get, set) : Function;
	private function get_verticalScrollBarFactory() : Function {
		return _verticalScrollBarFactory;
	}
	private function set_verticalScrollBarFactory(v:Function) : Function
	{
		if (_verticalScrollBarFactory != v) {
			_verticalScrollBarFactory = v;
			if (_verticalScrollbar != null) {
				removeScrollBarVertically();
				createScrollBarVertically();
			}
		}
		return get_verticalScrollBarFactory();
	}
	
	private var _defaultHorizontalScrollBarFactory : Function = function() : IScrollBar {
		return cast new ScrollBar(new ElementData({'name':'sb'}), null, ScrollBar.DIRECTION_HORIZONTAL);
	}
	
	private var _defaultVerticalScrollBarFactory : Function = function() : IScrollBar {
		return cast new ScrollBar(new ElementData({'name':'sb'}), null, ScrollBar.DIRECTION_VERTICAL);
	}
	
	private var _horizontalScrollBarStyleFactory : Function;
	public var horizontalScrollBarStyleFactory(get, set) : Function;
	private function get_horizontalScrollBarStyleFactory() : Function {
		return _horizontalScrollBarStyleFactory;
	}
	private function set_horizontalScrollBarStyleFactory(v:Function) : Function
	{
		if (_horizontalScrollBarStyleFactory != v) {
			_horizontalScrollBarStyleFactory = v;
			if (_horizontalScrollbar != null)
				_horizontalScrollbar.styleFactory = v;
		}
		return get_horizontalScrollBarStyleFactory();
	}
	
	private var _verticalScrollBarStyleFactory : Function;
	public var verticalScrollBarStyleFactory(get, set) : Function;
	private function get_verticalScrollBarStyleFactory() : Function {
		return _verticalScrollBarStyleFactory;
	}
	private function set_verticalScrollBarStyleFactory(v:Function) : Function
	{
		if (_verticalScrollBarStyleFactory != v) {
			_verticalScrollBarStyleFactory = v;
			if (_verticalScrollbar != null)
				_verticalScrollbar.styleFactory = v;
		}
		return get_verticalScrollBarStyleFactory();
	}
	
	private var _horizontalScrollPolicy:String = SCROLL_POLICY_OFF;
	public var horizontalScrollPolicy(get, set) : String;
	private function set_horizontalScrollPolicy(v:String) : String
	{
		if (_horizontalScrollPolicy != v) {
			_horizontalScrollPolicy = v;
			switch(v) {
				case SCROLL_POLICY_AUTO:
				{
					if (maxScrollX > 0) {
						isDraggingHorizontally = true;
						createScrollBarHorizontally();
					} else {
						isDraggingHorizontally = false;
						removeScrollBarHorizontally();
					}
				}
				case SCROLL_POLICY_ON:
				{
					isDraggingHorizontally = true;
					createScrollBarHorizontally();
				}
				case SCROLL_POLICY_OFF:
				{
					isDraggingHorizontally = false;
					removeScrollBarHorizontally();
				}
			}
		}
		return get_horizontalScrollPolicy();
	}
	private function get_horizontalScrollPolicy() : String {
		return _horizontalScrollPolicy;
	}
	
	private var _verticalScrollPolicy:String = SCROLL_POLICY_OFF;
	public var verticalScrollPolicy(get, set) : String;
	private function set_verticalScrollPolicy(v:String) : String
	{
		if (_verticalScrollPolicy != v) {
			_verticalScrollPolicy = v;
			switch(v) {
				case SCROLL_POLICY_AUTO:
				{
					if (maxScrollY > 0) {
						isDraggingVertically = true;
						createScrollBarVertically();
					} else {
						isDraggingVertically = false;
						removeScrollBarVertically();
					}
				}
				case SCROLL_POLICY_ON:
				{
					isDraggingVertically = true;
					createScrollBarVertically();
				}
				case SCROLL_POLICY_OFF:
				{
					isDraggingVertically = false;
					removeScrollBarVertically();
				}
			}
		}
		return get_verticalScrollPolicy();
	}
	private function get_verticalScrollPolicy() : String {
		return _verticalScrollPolicy;
	}
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'sp'});
		super(elementData);
		isClipped = true;
		horizontalScrollPolicy = SCROLL_POLICY_AUTO;
		verticalScrollPolicy = SCROLL_POLICY_AUTO;
		styleName = DEFAULT_STYLE;
	}
	
	public function hideScrollBars() : Void {
		if (_horizontalScrollbar != null)
			_horizontalScrollbar.visible = false;
		if (_verticalScrollbar != null)
			_verticalScrollbar.visible = false;
	}
	
	private override function calculateViewportOffset() : Void
	{
		super.calculateViewportOffset();
		switch(_horizontalScrollPolicy) {
			case SCROLL_POLICY_AUTO:
			{
				if (maxScrollX < 0) {
					isDraggingHorizontally = true;
					createScrollBarHorizontally();
					updateScrollBarHorizontally();
				} else {
					isDraggingHorizontally = false;
					removeScrollBarHorizontally();
				}
			}
		}
		switch(_verticalScrollPolicy) {
			case SCROLL_POLICY_AUTO:
			{
				if (maxScrollY < 0) {
					isDraggingVertically = true;
					createScrollBarVertically();
					updateScrollBarVertically();
				} else {
					isDraggingVertically = false;
					removeScrollBarVertically();
				}
			}
		}
	}
	
	private function updateScrollBarHorizontally() : Void
	{
		_horizontalScrollbar.setScrollParams(_width, _content.width);
	}
	
	private function updateScrollBarVertically() : Void
	{
		_verticalScrollbar.setScrollParams(_height, _content.height);
	}
	
	private function createScrollBarHorizontally() : Void {
		if (_horizontalScrollbar == null) {
			_horizontalScrollbar = _horizontalScrollBarFactory != null ? _horizontalScrollBarFactory() : _defaultHorizontalScrollBarFactory();
			_horizontalScrollbar.addEventListener(Event.SCROLL, horizontalScrollBarScrollHandler);
			_horizontalScrollbar.addEventListener(Event.RESIZE, horizontalScrollBarResizeHandler);
			_horizontalScrollbar.styleFactory = _horizontalScrollBarStyleFactory;
			_forelayer.addChild(cast _horizontalScrollbar);
			resizeHorizontalScrollBar();
		}
	}
	
	private function horizontalScrollBarResizeHandler(e:Event, ?data:ResizeData) : Void {
		if (_horizontalScrollbar != null) {
			if (data.invalidateHeight)
				_horizontalScrollbar.y = _height - _horizontalScrollbar.height;
		}
	}
	
	private function horizontalScrollBarScrollHandler(e:Event) : Void
	{
		horizontalScrollPosition = _horizontalScrollbar.horizontalScrollPosition;
		updateHorizontalBarriers();
	}
	
	private function removeScrollBarHorizontally() : Void {
		if (_horizontalScrollbar != null) {
			_horizontalScrollbar.removeEventListener(Event.SCROLL, horizontalScrollBarScrollHandler);
			_horizontalScrollbar.removeEventListener(Event.RESIZE, horizontalScrollBarResizeHandler);
			_horizontalScrollbar.removeFromParent(true);
			_horizontalScrollbar = null;
		}
	}
	
	private function createScrollBarVertically() : Void {
		if (_verticalScrollbar == null) {
			_verticalScrollbar = _verticalScrollBarFactory != null ? _verticalScrollBarFactory() : _defaultVerticalScrollBarFactory();
			_verticalScrollbar.addEventListener(Event.SCROLL, verticalScrollBarScrollHandler);
			_verticalScrollbar.addEventListener(Event.RESIZE, verticalScrollBarResizeHandler);
			_verticalScrollbar.styleFactory = _verticalScrollBarStyleFactory;
			_forelayer.addChild(cast _verticalScrollbar);
			resizeVerticalScrollBar();
		}
	}
	
	private function verticalScrollBarResizeHandler(e:Event, ?data:ResizeData) : Void {
		if (_verticalScrollbar != null) {
			if (data.invalidateWidth)
				_verticalScrollbar.x = _width - _verticalScrollbar.width;
		}
	}
	
	private function verticalScrollBarScrollHandler(e:Event) : Void
	{
		verticalScrollPosition = _verticalScrollbar.verticalScrollPosition;
		updateVerticalBarriers();
	}
	
	private function removeScrollBarVertically() : Void {
		if (_verticalScrollbar != null) {
			_verticalScrollbar.removeEventListener(Event.SCROLL, verticalScrollBarScrollHandler);
			_verticalScrollbar.removeEventListener(Event.RESIZE, verticalScrollBarResizeHandler);
			_verticalScrollbar.removeFromParent(true);
			_verticalScrollbar = null;
		}
	}
	
	public override function resize(?data:Dynamic) : Void
	{
		super.resize(data);
		resizeScrollBars();
		if (_horizontalScrollbar != null && !_horizontalScrollbar.isDragging && !_horizontalScrollbar.isOutScrollPosition)
			scrollX();
		if (_verticalScrollbar != null && !_verticalScrollbar.isDragging && !_verticalScrollbar.isOutScrollPosition)
			scrollY();
	}
	
	public override function resizeContent(?data:Dynamic) : Void
	{
		super.resizeContent(data);
		resizeScrollBars();
		if (_horizontalScrollbar != null && !_horizontalScrollbar.isDragging && !_horizontalScrollbar.isOutScrollPosition)
			scrollX();
		if (_verticalScrollbar != null && !_verticalScrollbar.isDragging && !_verticalScrollbar.isOutScrollPosition)
			scrollY();
	}
	
	private function resizeScrollBars() : Void
	{
		resizeHorizontalScrollBar();
		resizeVerticalScrollBar();
	}
	
	private function resizeHorizontalScrollBar() : Void
	{
		if (_horizontalScrollbar != null) {
			_horizontalScrollbar.width = _width;
			_horizontalScrollbar.y = _height - _horizontalScrollbar.height;
		}
	}
	
	private function resizeVerticalScrollBar() : Void
	{
		if (_verticalScrollbar != null) {
			_verticalScrollbar.height = _height;
			_verticalScrollbar.x = _width - _verticalScrollbar.width;
		}
	}
	
	private override function scrollX() : Void {
		if (_horizontalScrollbar != null)
			_horizontalScrollbar.setScrollPosition(horizontalScrollPosition);
		updateHorizontalBarriers();
	}
	
	private override function scrollY() : Void {
		if (_verticalScrollbar != null)
			_verticalScrollbar.setScrollPosition(verticalScrollPosition);
		updateVerticalBarriers();
	}
	
	override public function dispose() : Void
	{
		_horizontalScrollBarStyleFactory = null;
		_verticalScrollBarStyleFactory = null;
		removeScrollBarHorizontally();
		removeScrollBarVertically();
		super.dispose();
	}
}