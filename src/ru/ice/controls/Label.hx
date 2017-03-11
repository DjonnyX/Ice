package ru.ice.controls;

import ru.ice.controls.super.BaseIceObject;
import ru.ice.data.ElementData;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Label extends BaseIceObject
{
	public static inline var DEFAULT_LABEL_STYLE:String = 'default-label-style';
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'label', 'touchable':false});
		else
			elementData.fromData({'touchable':false});
		super(elementData);
		autosize = BaseIceObject.AUTO_SIZE_CONTENT;
		styleName = DEFAULT_LABEL_STYLE;
	}
	
	private var _text:String;
	public var text(get, set) : String;
	private function get_text() : String {
		return _text;
	}
	private function set_text(v:String) : String {
		if (_text != v) {
			_text = v;
			_element.innerHTML = v;
		}
		return get_text();
	}
}