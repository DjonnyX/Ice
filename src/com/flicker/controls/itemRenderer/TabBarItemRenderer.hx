package com.flicker.controls.itemRenderer;

import haxe.Constraints.Function;
import com.flicker.controls.super.BaseStatesControl;
import com.flicker.events.FingerEvent;

import com.flicker.controls.Button;
import com.flicker.controls.super.IBaseListItemControl;
import com.flicker.controls.super.FlickerControl;
import com.flicker.data.ElementData;
import com.flicker.events.Event;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class TabBarItemRenderer extends Button implements IBaseListItemControl {
	
	public static inline var DEFAULT_STYLE:String = 'default-tabbar-item-renderer-style';
	
	private var _index:Int;
	public var index(get, set) : Int;
	private function set_index(v:Int) : Int {
		if (_index != v) {
			_index = v;
		}
		return get_index();
	}
	private function get_index() : Int {
		return _index;
	}
	
	public var data(get, set) : Dynamic;
	private var _data:Dynamic;
	private function set_data(v:Dynamic) : Dynamic {
		if (_data != v) {
			_data = v;
			label = _data.label;
			icon = _data.icon;
		}
		return get_data();
	}
	private function get_data() : Dynamic {
		return _data;
	}
	
	public var selected(get, set) : Bool;
	private var _selected:Bool = false;
	private function set_selected(v:Bool) : Bool {
		if (_selected != v) {
			_selected = v;
			isSelect = _selected;
			state = _selected ? Button.STATE_SELECT : Button.STATE_UP;
			interactive = !_selected;
		}
		return get_selected();
	}
	private function get_selected() : Bool {
		return _selected;
	}
	
	public function select() : Void {
		selected = true;
		dispatchEventWith(Event.CHANGE, true);
	}
	
	public function deselect() : Void {
		selected = false;
		dispatchEventWith(Event.CHANGE, true);
	}
	
	private var _button:Button;
	
	public function new(?elementData:ElementData)
	{
		if (elementData == null)
			elementData = new ElementData({'name':'li'});
		super(elementData);
		allowDeselect = false;
		isToggle = true;
		isSelect = _selected;
		styleName = DEFAULT_STYLE;
	}
	
	private override function upHandler(e:FingerEvent) : Void {
		if (_useTouchableClass)
			addClass(['i-touchable']);
		stage.removeEventListener(FingerEvent.MOVE, stageMoveHandler);
		if (e.isMouse && e.key != FingerEvent.KEY_LEFT)
			return;
		if (_isPress) {
			_isPress = false;
			if (_isToggle)
				_isSelect = !_isSelect;
			state = _isSelect ? BaseStatesControl.STATE_SELECT : BaseStatesControl.STATE_UP;
			selected = isSelect;
			dispatchEventWith(Event.CHANGE, true, this);
		} else
			state = BaseStatesControl.STATE_UP;
	}
	
	public override function dispose() : Void {
		super.dispose();
	}
}