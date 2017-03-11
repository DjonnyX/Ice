package ru.ice.controls;

import haxe.Constraints.Function;

import ru.ice.animation.IAnimatable;
import ru.ice.animation.Tween;
import ru.ice.animation.Transitions;
import ru.ice.core.Ice;
import ru.ice.controls.super.BaseIceObject;
import ru.ice.data.ElementData;
import ru.ice.events.Event;
import ru.ice.events.FingerEvent;
import ru.ice.events.WheelScrollEvent;
import ru.ice.display.DisplayObject;
import ru.ice.math.Point;
import ru.ice.math.Rectangle;
import ru.ice.utils.FloatUtil;
import ru.ice.layout.ILayout;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class ScrollPlane extends Scroller
{
	public static inline var DEFAULT_SCROLLPLANE_STYLE:String = 'default-scrollplane-style';
	
	public static inline var SCROLL_POLICY_AUTO:String = 'auto';
	public static inline var SCROLL_POLICY_ON:String = 'on';
	public static inline var SCROLL_POLICY_OFF:String = 'of';
	
	private var _horizontalScrollbar:ScrollBar;
	private var _verticalScrollbar:ScrollBar;
	
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
					if (maxScrollX > 0)
						createScrollBarHorizontally();
					else
						removeScrollBarHorizontally();
				}
				case SCROLL_POLICY_ON:
				{
					createScrollBarHorizontally();
				}
				case SCROLL_POLICY_OFF:
				{
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
					if (maxScrollY > 0)
						createScrollBarVertically();
					else
						removeScrollBarVertically();
				}
				case SCROLL_POLICY_ON:
				{
					createScrollBarVertically();
				}
				case SCROLL_POLICY_OFF:
				{
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
			elementData = new ElementData({'name':'scrollplane'});
		super(elementData);
		isClipped = true;
		horizontalScrollPolicy = SCROLL_POLICY_AUTO;
		verticalScrollPolicy = SCROLL_POLICY_AUTO;
		styleName = DEFAULT_SCROLLPLANE_STYLE;
	}
	
	@:allow(ru.ice.core.Ice)
	private override function initialize() : Void {
		super.initialize();
		if (_horizontalScrollbar != null)
			_horizontalScrollbar.initialize();
		if (_verticalScrollbar != null)
			_verticalScrollbar.initialize();
	}
	
	private override function calculateViewportOffset() : Void
	{
		super.calculateViewportOffset();
		
		switch(_horizontalScrollPolicy) {
			case SCROLL_POLICY_AUTO:
			{
				if (maxScrollX < 0) {
					createScrollBarHorizontally();
					updateScrollBarHorizontally();
				} else
					removeScrollBarHorizontally();
			}
		}
		switch(_verticalScrollPolicy) {
			case SCROLL_POLICY_AUTO:
			{
				if (maxScrollY < 0) {
					createScrollBarVertically();
					updateScrollBarVertically();
				} else
					removeScrollBarVertically();
			}
		}
	}
	
	private function updateScrollBarHorizontally() : Void
	{
		_horizontalScrollbar.setScrollParams(contentWidth, _content.contentWidth);
	}
	
	private function updateScrollBarVertically() : Void
	{
		_verticalScrollbar.setScrollParams(contentHeight, _content.contentHeight);
	}
	
	private function createScrollBarHorizontally() : Void {
		if (_horizontalScrollbar == null) {
			_horizontalScrollbar = new ScrollBar(new ElementData({'name':'scrollbar-horizontal'}));
			//_horizontalScrollbar.addEventListener(Event.RESIZE, onResizeHorizontalScrollBar);
			_horizontalScrollbar.initializedParent = this;
			_horizontalScrollbar.addEventListener(Event.SCROLL, horizontalScrollHandler);
			_horizontalScrollbar.styleFactory = _horizontalScrollBarStyleFactory;
			_forelayer.addChild(_horizontalScrollbar);
			resizeHorizontalScrollBar();
		}
	}
	
	/*private function onResizeHorizontalScrollBar(e:Event, data:Dynamic) : Void {
		if (_horizontalScrollbar != null) {
			_horizontalScrollbar.width = width;
			_horizontalScrollbar.y = height - _horizontalScrollbar.height;
		}
	}*/
	
	private function horizontalScrollHandler(e:Event) : Void
	{
		horizontalScrollPosition = _horizontalScrollbar.horizontalScrollPosition;
	}
	
	private function removeScrollBarHorizontally() : Void {
		if (_horizontalScrollbar != null) {
			//_horizontalScrollbar.removeEventListener(Event.RESIZE, onResizeHorizontalScrollBar);
			_horizontalScrollbar.removeEventListener(Event.SCROLL, horizontalScrollHandler);
			_horizontalScrollbar.removeFromParent(true);
			_horizontalScrollbar = null;
		}
	}
	
	private function createScrollBarVertically() : Void {
		if (_verticalScrollbar == null) {
			_verticalScrollbar = new ScrollBar(new ElementData({'name':'scrollbar-vertical'}), null, ScrollBar.DIRECTION_VERTICAL);
			//_verticalScrollbar.addEventListener(Event.RESIZE, onResizeVerticalScrollBar);
			_verticalScrollbar.initializedParent = this;
			_verticalScrollbar.addEventListener(Event.SCROLL, verticalScrollHandler);
			_verticalScrollbar.styleFactory = _verticalScrollBarStyleFactory;
			_forelayer.addChild(_verticalScrollbar);
			resizeVerticalScrollBar();
		}
	}
	
	/*private function onResizeVerticalScrollBar(e:Event, data:Dynamic) : Void {
		if (_verticalScrollbar != null) {
			_verticalScrollbar.height = height;
			_verticalScrollbar.x = width - _verticalScrollbar.width;
		}
	}*/
	
	private function verticalScrollHandler(e:Event) : Void
	{
		verticalScrollPosition = _verticalScrollbar.verticalScrollPosition;
	}
	
	private function removeScrollBarVertically() : Void {
		if (_verticalScrollbar != null) {
			//_verticalScrollbar.removeEventListener(Event.RESIZE, onResizeVerticalScrollBar);
			_verticalScrollbar.removeEventListener(Event.SCROLL, verticalScrollHandler);
			_verticalScrollbar.removeFromParent(true);
			_verticalScrollbar = null;
		}
	}
	
	public override function resize(?data:Dynamic) : Void
	{
		super.resize(data);
		if (data.invalidateSize)
			resizeScrollBars(data.isSizeChanged);
	}
	
	private function resizeScrollBars(resetPos:Bool = true) : Void
	{
		resizeHorizontalScrollBar(resetPos);
		resizeVerticalScrollBar(resetPos);
	}
	
	private function resizeHorizontalScrollBar(resetPos:Bool = true) : Void
	{
		if (_horizontalScrollbar != null) {
			_horizontalScrollbar.width = width;
			_horizontalScrollbar.y = height - _horizontalScrollbar.height;
			if (resetPos)
				_horizontalScrollbar.setScrollPosition(horizontalScrollPosition);
		}
	}
	
	private function resizeVerticalScrollBar(resetPos:Bool = true) : Void
	{
		if (_verticalScrollbar != null) {
			_verticalScrollbar.height = height;
			_verticalScrollbar.x = width - _verticalScrollbar.width;
			if (resetPos)
				_verticalScrollbar.setScrollPosition(verticalScrollPosition);
		}
	}
	
	private override function scrollX() : Void {
		if (_horizontalScrollbar != null) {
			_horizontalScrollbar.setScrollPosition(horizontalScrollPosition);
		}
		super.scrollX();
	}
	
	private override function scrollY() : Void {
		if (_verticalScrollbar != null) {
			_verticalScrollbar.setScrollPosition(verticalScrollPosition);
		}
		super.scrollY();
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