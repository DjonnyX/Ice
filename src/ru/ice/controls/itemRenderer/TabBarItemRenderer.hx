package ru.ice.controls.itemRenderer;

import haxe.Constraints.Function;

import ru.ice.controls.super.BaseListItemControl;
import ru.ice.controls.super.IceControl;
import ru.ice.data.ElementData;
import ru.ice.events.Event;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class TabBarItemRenderer extends BaseListItemControl {
	
	public static inline var DEFAULT_STYLE:String = 'default-tabbar-item-renderer-style';
	
	private var _buttonFactory:Function;
	public var buttonFactory(get, set) : Function;
	private function set_buttonFactory(v:Function) : Function {
		if (_buttonFactory != v) {
			_buttonFactory = v;
			if (_button != null)
				_button.styleFactory = _buttonFactory;
		}
		return get_buttonFactory();
	}
	private function get_buttonFactory() : Function {
		return _buttonFactory;
	}
	
	private override function set_data(v:Dynamic) : Dynamic {
		if (_data != v) {
			_data = v;
			_button.label = _data.label;
			_button.icon = _data.icon;
		}
		return get_data();
	}
	
	private override function set_selected(v:Bool) : Bool {
		if (_selected != v) {
			_selected = v;
			if (_button != null) {
				_button.isSelect = _selected;
				_button.state = _selected ? Button.STATE_SELECT : Button.STATE_UP;
				_button.interactive = !_selected;
			}
		}
		return get_selected();
	}
	
	public override function select() : Void {
		selected = true;
		super.select();
	}
	
	public override function deselect() : Void {
		selected = false;
		super.deselect();
	}
	
	private var _button:Button;
	
	public function new(?elementData:ElementData)
	{
		if (elementData == null)
			elementData = new ElementData({'name':'li'});
		super(elementData);
		_button = new Button();
		_button.allowDeselect = false;
		_button.isToggle = true;
		_button.isSelect = _selected;
		_button.addEventListener(Event.TRIGGERED, buttonTriggeredHandler);
		styleName = DEFAULT_STYLE;
		addChild(_button);
	}
	
	private function buttonTriggeredHandler(e:Event) : Void {
		e.stopImmediatePropagation();
		selected = _button.isSelect;
		dispatchEventWith(Event.CHANGE, true, this);
	}
	
	public override function dispose() : Void {
		_buttonFactory = null;
		if (_button != null) {
			_button.removeEventListener(Event.TRIGGERED, buttonTriggeredHandler);
			_button.removeEventListeners();
			_button.removeFromParent(true);
			_button = null;
		}
		super.dispose();
	}
}