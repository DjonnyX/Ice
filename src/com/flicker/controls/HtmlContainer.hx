package com.flicker.controls;

import com.flicker.controls.super.FlickerControl;
import com.flicker.data.ElementData;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class HtmlContainer extends FlickerControl
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
		snapTo(FlickerControl.SNAP_TO_HTML_CONTENT, FlickerControl.SNAP_TO_HTML_CONTENT);
		styleName = DEFAULT_STYLE;
	}
}