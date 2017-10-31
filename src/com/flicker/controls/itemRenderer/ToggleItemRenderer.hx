package com.flicker.controls.itemRenderer;

import com.flicker.controls.Button;
import haxe.Constraints.Function;

import com.flicker.controls.super.BaseListItemControl;
import com.flicker.controls.super.FlickerControl;
import com.flicker.data.ElementData;
import com.flicker.events.Event;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class ToggleItemRenderer extends TabBarItemRenderer {
	
	public static inline var DEFAULT_STYLE:String = 'default-toggle-item-renderer-style';
	
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