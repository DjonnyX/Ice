package com.flicker.controls.super;

import haxe.Constraints.Function;

import com.flicker.controls.super.FlickerControl;
import com.flicker.data.ElementData;
import com.flicker.events.Event;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class BaseListItemControl extends FlickerControl
{
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
	
	private var _selected:Bool = false;
	public var selected(get, set) : Bool;
	private function set_selected(v:Bool) : Bool {
		if (_selected != v) {
			_selected = v;
		}
		return get_selected();
	}
	private function get_selected() : Bool {
		return _selected;
	}
	
	private var _data:Dynamic;
	public var data(get, set) : Dynamic;
	private function set_data(v:Dynamic) : Dynamic {
		if (_data != v) {
			_data = v;
		}
		return get_data();
	}
	private function get_data() : Dynamic {
		return _data;
	}
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'li'});
		super(elementData);
	}
	
	public function select() : Void {
		_selected = true;
		dispatchEventWith(Event.CHANGE, true);
		return;
	}
	
	public function deselect() : Void {
		_selected = false;
		dispatchEventWith(Event.CHANGE, true);
		return;
	}
	
	public override function dispose() : Void {
		super.dispose();
	}
}