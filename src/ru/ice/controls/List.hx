package ru.ice.controls;

import ru.ice.controls.ScrollPlane;
import ru.ice.controls.ScrollBar;
import ru.ice.data.ElementData;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class List extends ScrollPlane
{
	public static inline var SCROLL_POLICY_AUTO:String = 'auto';
	public static inline var SCROLL_POLICY_ON:String = 'on';
	public static inline var SCROLL_POLICY_OFF:String = 'of';
	
	private var _horizontalScrollbar:ScrollBar;
	private var _verticalScrollbar:ScrollBar;
	
	private var _horizontalScrollBarStyle:Dynamic;
	public var horizontalScrollBarStyle(get, set) : Dynamic;
	private function set_horizontalScrollBarStyle(v:Dynamic) : Dynamic
	{
		if (_horizontalScrollBarStyle != v) {
			_horizontalScrollBarStyle = v;
			if (_horizontalScrollbar != null && v != null) {
				_horizontalScrollbar.style = v.style;
				_horizontalScrollbar.thumbStyle = v.thumbStyle;
			}
		return get_horizontalScrollBarStyle();
	}
	private function get_horizontalScrollBarStyle() : String {
		return _horizontalScrollBarStyle;
	}
	
	private var _verticalScrollBarStyle:Dynamic;
	public var verticalScrollBarStyle(get, set) : Dynamic;
	private function set_verticalScrollBarStyle(v:Dynamic) : Dynamic
	{
		if (_verticalScrollBarStyle != v) {
			_verticalScrollBarStyle = v;
			if (_verticalScrollbar != null && v != null) {
				_verticalScrollbar.style = v.style;
				_verticalScrollbar.thumbStyle = v.thumbStyle;
			}
		return get_verticalScrollBarStyle();
	}
	private function get_verticalScrollBarStyle() : String {
		return _verticalScrollBarStyle;
	}
	
	private var _horizontalScrollPolicy:String = SCROLL_POLICY_AUTO;
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
	
	private var _verticalScrollPolicy:String = SCROLL_POLICY_AUTO;
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
		super(elementData);
	}
	
	private function createScrollBarHorizontally() : Void {
		if (_horizontalScrollbar == null) {
			_horizontalScrollbar = new ScrollBar();
			addToOverlay(_horizontalScrollbar);
		}
	}
	
	private function removeScrollBarHorizontally() : Void {
		if (_horizontalScrollbar != null) {
			_horizontalScrollbar.removeFromParent();
			_horizontalScrollbar = null;
		}
	}
	
	private function createScrollBarVertically() : Void {
		if (_verticalScrollbar == null) {
			_verticalScrollbar = new ScrollBar();
			addToOverlay(_verticalScrollbar);
		}
	}
	
	private function removeScrollBarVertically() : Void {
		if (_verticalScrollbar != null) {
			_verticalScrollbar.removeFromParent();
			_verticalScrollbar = null;
		}
	}
	
	public override function dispose() : Void
	{
		removeScrollBarHorizontally();
		removeScrollBarVertically();
		super.dispose();
	}
}