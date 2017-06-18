package ru.ice.controls;

import haxe.Constraints.Function;

import ru.ice.display.DisplayObject;
import ru.ice.events.Event;
import ru.ice.math.Point;
import ru.ice.math.Rectangle;
import ru.ice.controls.super.IceControl;
import ru.ice.controls.super.BaseStatesControl;
import ru.ice.controls.super.InteractiveControl;
import ru.ice.events.FingerEvent;
import ru.ice.data.ElementData;
import ru.ice.theme.BaseTheme;
import ru.ice.theme.Theme;
import ru.ice.controls.Label;
import ru.ice.layout.ILayout;
import ru.ice.core.Ice;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Button extends BaseStatesControl
{
	public static inline var DEFAULT_STYLE:String = 'default-simple-button-style';
	
	public static inline var STATE_UP:String = 'up';
	public static inline var STATE_DOWN:String = 'down';
	public static inline var STATE_HOVER:String = 'hover';
	public static inline var STATE_SELECT:String = 'select';
	public static inline var STATE_DISABLED:String = 'disabled';
	
	private var _labelField:Label;
	
	private var _iconField:Label;
	
	private var _contentBox:IceControl;
	
	private var _labelInitializedStyleFactory:Function;
	public var labelInitializedStyleFactory(get, set) : Function;
	private function set_labelInitializedStyleFactory(v:Function) : Function {
		if (_labelInitializedStyleFactory != v) {
			_labelInitializedStyleFactory = v;
			if (_labelField != null && v != null)
				_labelInitializedStyleFactory(_labelField);
		}
		return get_labelInitializedStyleFactory();
	}
	private function get_labelInitializedStyleFactory() : Function {
		return _labelInitializedStyleFactory;
	}
	
	private var _iconInitializedStyleFactory:Function;
	public var iconInitializedStyleFactory(get, set) : Function;
	private function set_iconInitializedStyleFactory(v:Function) : Function {
		if (_iconInitializedStyleFactory != v) {
			_iconInitializedStyleFactory = v;
			if (_iconField != null && v != null)
				_iconInitializedStyleFactory(_iconField);
		}
		return get_iconInitializedStyleFactory();
	}
	private function get_iconInitializedStyleFactory() : Function {
		return _iconInitializedStyleFactory;
	}
	
	private var _labelStyleFactory:Function;
	public var labelStyleFactory(get, set) : Function;
	private function set_labelStyleFactory(v:Function) : Function {
		if (_labelStyleFactory != v) {
			_labelStyleFactory = v;
			if (_labelField != null)
				_labelField.styleFactory = v;
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
			if (_iconField != null)
				_iconField.styleFactory = v;
		}
		return get_iconStyleFactory();
	}
	private function get_iconStyleFactory() : Function {
		return _iconStyleFactory;
	}
	
	private var _contentBoxStyleFactory:Function;
	public var contentBoxStyleFactory(get, set) : Function;
	private function set_contentBoxStyleFactory(v:Function) : Function {
		if (_contentBoxStyleFactory != v) {
			_contentBoxStyleFactory = v;
			if (_contentBox != null)
				_contentBox.styleFactory = v;
		}
		return get_contentBoxStyleFactory();
	}
	private function get_contentBoxStyleFactory() : Function {
		return _contentBoxStyleFactory;
	}
	
	private var _label:String;
	public var label(get, set) : String;
	private function get_label() : String {
		return _label;
	}
	private function set_label(v:String) : String {
		if (_label != v) {
			_label = v;
			if (_labelField == null) {
				_labelField = new Label();
				if (_labelInitializedStyleFactory != null)
					_labelInitializedStyleFactory(_labelField);
				if (_labelStyleFactory != null)
					_labelField.styleFactory = _labelStyleFactory;
				_contentBox.addChild(_labelField);
			}
			_labelField.text = _label;
			if (_isInitialized)
				updateState();
		}
		return get_label();
	}
	
	private var _icon:Array<String>;
	public var icon(get, set) : Array<String>;
	private function get_icon() : Array<String> {
		return _icon;
	}
	private function set_icon(v:Array<String>) : Array<String> {
		if (_icon != v) {
			if (_iconField != null)
				_iconField.removeClass(_icon);
			_icon = v;
			if (_iconField == null) {
				_iconField = new Label();
				if (_iconInitializedStyleFactory != null)
					_iconInitializedStyleFactory(_iconField);
				if (_iconStyleFactory != null)
					_iconField.styleFactory = _iconStyleFactory;
				_contentBox.addChild(_iconField);
			}
			_iconField.addClass(_icon);
			if (_isInitialized)
				updateState();
		}
		return get_icon();
	}
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'btn'});
		super(elementData);
		_contentBox = new IceControl(new ElementData({'name':'c', 'interactive':false}));
		addChild(_contentBox);
		
		styleName = DEFAULT_STYLE;
		state = STATE_UP;
	}
	
	override public function dispose() : Void {
		_icon = null;
		_iconStyleFactory = null;
		_labelStyleFactory = null;
		_contentBoxStyleFactory = null;
		_labelInitializedStyleFactory = null;
		_iconInitializedStyleFactory = null;
		if (_labelField != null) {
			_labelField.removeFromParent(true);
			_labelField = null;
		}
		if (_iconField != null) {
			_iconField.removeFromParent(true);
			_iconField = null;
		}
		if (_contentBox != null) {
			_contentBox.removeFromParent(true);
			_contentBox = null;
		}
		super.dispose();
	}
}