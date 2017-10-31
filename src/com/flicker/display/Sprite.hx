package com.flicker.display;

import com.flicker.display.DisplayObject;
import com.flicker.data.ElementData;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Sprite extends DisplayObject
{
	public function new(?elementData:ElementData, ?initial:Bool = false) 
	{
		if (!initial) {
			if (elementData == null)
				elementData = new ElementData({'name':'div'});
		}
		super(elementData);
	}
}