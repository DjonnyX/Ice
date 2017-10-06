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
class ToggleItemRenderer extends TabBarItemRenderer {
	
	public static inline var DEFAULT_STYLE:String = 'default-toggle-item-renderer-style';
	
	private override function set_selected(v:Bool) : Bool {
		if (_selected != v) {
			_selected = v;
			if (_button != null) {
				_button.isSelect = _selected;
				_button.state = _selected ? Button.STATE_SELECT : Button.STATE_UP;
			}
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