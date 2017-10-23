package ru.ice.controls;

import ru.ice.controls.super.IceControl;
import ru.ice.data.ElementData;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class HtmlContainer extends IceControl
{
	public static inline var DEFAULT_STYLE:String = 'default-html-container-style';
	
	private override function get_width() : Float {
		return _element.getBoundingClientRect().width;
	}
	
	private override function get_height() : Float {
		return _element.getBoundingClientRect().height;
	}
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'div', 'interactive':true});
		else {
			elementData.name = 'div';
			elementData.interactive = true;
		}
		super(elementData);
		snapTo(IceControl.SNAP_TO_HTML_CONTENT, IceControl.SNAP_TO_HTML_CONTENT);
		styleName = DEFAULT_STYLE;
	}
}