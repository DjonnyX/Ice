package com.flicker.controls;

import haxe.Constraints.Function;

import js.html.Element;
import js.html.HTMLCollection;

import com.flicker.display.DOMExpress;
import com.flicker.display.DisplayObject;
import com.flicker.events.Event;
import com.flicker.controls.super.FlickerControl;
import com.flicker.controls.super.BaseStatesControl;
import com.flicker.controls.super.IBaseStatesControl;
import com.flicker.events.FingerEvent;
import com.flicker.data.ElementData;
import com.flicker.core.Flicker;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Button extends BaseStatesControl implements IBaseStatesControl
{
	public static inline var DEFAULT_STYLE:String = 'default-simple-button-style';
	
	public static inline var STATE_UP:String = BaseStatesControl.STATE_UP;
	public static inline var STATE_DOWN:String = BaseStatesControl.STATE_DOWN;
	public static inline var STATE_DOWN_SELECTED:String = BaseStatesControl.STATE_DOWN_SELECTED;
	public static inline var STATE_HOVER:String = BaseStatesControl.STATE_HOVER;
	public static inline var STATE_HOVER_SELECTED:String = BaseStatesControl.STATE_HOVER_SELECTED;
	public static inline var STATE_SELECT:String = BaseStatesControl.STATE_SELECT;
	public static inline var STATE_DISABLED:String = BaseStatesControl.STATE_DISABLED;
	
	private override function get_width() : Float {
		return _element.getBoundingClientRect().width;
	}
	
	private override function get_height() : Float {
		return _element.getBoundingClientRect().height;
	}
	
	private var _labelStyleFactory:Function;
	public var labelStyleFactory(get, set) : Function;
	private function set_labelStyleFactory(v:Function) : Function {
		if (_labelStyleFactory != v) {
			_labelStyleFactory = v;
			if (_labelElement != null)
				_labelStyleFactory(_labelElement);
		}
		return get_labelStyleFactory();
	}
	private function get_labelStyleFactory() : Function {
		return _labelStyleFactory;
	}
	
	private var _iconStyleFactory:Function;
	public var iconStyleFactory(get, set) : Function;
	private function set_iconStyleFactory(v:Function) : Function {
		if (_iconStyleFactory != v) {
			_iconStyleFactory = v;
			if (_iconElement != null)
				_iconStyleFactory(_iconElement);
		}
		return get_iconStyleFactory();
	}
	private function get_iconStyleFactory() : Function {
		return _iconStyleFactory;
	}
	
	/**
	 * Лейбл
	 */
	public var label(get, set) : String;
	private var _label:String;
	private function get_label() : String {
		return _label;
	}
	private function set_label(v:String) : String {
		if (_label != v) {
			_label = v;
			_labelElement.innerHTML = v;
			if (_isInitialized)
				updateState();
		}
		return get_label();
	}
	
	/**
	 * Иконка.
	 * В качестве ресурса указывается класс стиля для глифа.
	 */
	public var icon(get, set) : Array<String>;
	private var _icon:Array<String>;
	private function get_icon() : Array<String> {
		return _icon;
	}
	private function set_icon(v:Array<String>) : Array<String> {
		if (_icon != v) {
			_icon = v;
			for (icon in v) {
				_iconElement.classList.add(icon);
			}
			if (_isInitialized)
				updateState();
		}
		return get_icon();
	}
	
	private var _labelElement:Element;
	public var labelElement(get, never) : Element;
	private function get_labelElement() : Element {
		return _labelElement;
	}
	
	private var _iconElement:Element;
	public var iconElement(get, never) : Element;
	private function get_iconElement() : Element {
		return _iconElement;
	}
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'btn'});
		super(elementData);
		snapTo(FlickerControl.SNAP_TO_HTML_CONTENT, FlickerControl.SNAP_TO_HTML_CONTENT);
		_labelElement = cast DOMExpress.createElement('div');
		_labelElement.classList.add('text-optimizing');
		_element.appendChild(_labelElement);
		_iconElement = cast DOMExpress.createElement('div');
		_element.appendChild(_iconElement);
		styleName = DEFAULT_STYLE;
	}
	
	override public function dispose() : Void {
		_labelStyleFactory = null;
		_iconStyleFactory = null;
		super.dispose();
	}
}