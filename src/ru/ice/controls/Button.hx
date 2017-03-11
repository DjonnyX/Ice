package ru.ice.controls;

import haxe.Constraints.Function;

import ru.ice.display.DisplayObject;
import ru.ice.events.Event;
import ru.ice.math.Point;
import ru.ice.math.Rectangle;
import ru.ice.controls.super.BaseIceObject;
import ru.ice.controls.super.BaseStatesObject;
import ru.ice.controls.super.InteractiveObject;
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
class Button extends BaseStatesObject
{
	public static inline var DEFAULT_SIMPLE_BUTTON_STYLE:String = 'default-simple-button-style';
	
	public static inline var STATE_UP:String = 'up';
	public static inline var STATE_DOWN:String = 'down';
	public static inline var STATE_HOVER:String = 'hover';
	public static inline var STATE_DISABLED:String = 'disabled';
	
	private var _labelField:Label;
	
	private var _iconField:Image;
	
	private var _contentBox:BaseIceObject;
	
	public var labelStyleFactory(never, set) : Function;
	private function set_labelStyleFactory(v:Function) : Function {
		_labelField.styleFactory = v;
		return null;
	}
	
	public var iconStyleFactory(never, set) : Function;
	private function set_iconStyleFactory(v:Function) : Function {
		_iconField.styleFactory = v;
		return null;
	}
	
	public var contentBoxStyleFactory(never, set) : Function;
	private function set_contentBoxStyleFactory(v:Function) : Function {
		_contentBox.styleFactory = v;
		return null;
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
				_labelField.initializedParent = this;
				_contentBox.addChild(_labelField);
			}
			_labelField.text = _label;
			if (_isInitialized)
				updateState();
		}
		return get_label();
	}
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'btn'});
		super(elementData);
		autosize = BaseIceObject.AUTO_SIZE_NONE;
		_contentBox = new BaseIceObject(new ElementData({'name':'box', 'touchable':false}));
		_contentBox.autosize = BaseIceObject.AUTO_SIZE_CONTENT;
		addChild(_contentBox);
		
		styleName = DEFAULT_SIMPLE_BUTTON_STYLE;
		state = STATE_UP;
	}
	
	@:allow(ru.ice.core.Ice)
	private override function initialize() : Void {
		super.initialize();
		if (_labelField != null)
			_labelField.initialize();
	}
	
	override public function dispose() :Void {
		super.dispose();
	}
}