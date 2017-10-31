package com.flicker.controls.itemRenderer;

import haxe.Constraints.Function;

import com.flicker.controls.itemRenderer.ToggleItemRenderer;
import com.flicker.data.ElementData;
import com.flicker.controls.Button;
import com.flicker.events.Event;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class FilterItemRenderer extends ToggleItemRenderer {
	
	public static inline var DEFAULT_STYLE:String = 'default-toggle-item-renderer-style';
	
	public var tag:String = '';
	
	private override function set_data(v:Dynamic) : Dynamic {
		if (_data != v) {
			super.set_data(v);
			if (v.tag != null)
				tag = v.tag;
			if (v.selected == true) {
				selected = true;
				dispatchEventWith(Event.CHANGE, true);
			}
		}
		return get_data();
	}
	
	private override function set_selected(v:Bool) : Bool {
		if (_selected != v) {
			_selected = v;
			isSelect = _selected;
			state = _selected ? Button.STATE_SELECT : Button.STATE_UP;
			updateState();
		}
		return get_selected();
	}
	
	public function new(?elementData:ElementData)
	{
		if (elementData == null)
			elementData = new ElementData({'name':'li'});
		super(elementData);
	}
}