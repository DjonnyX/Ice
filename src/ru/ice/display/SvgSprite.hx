package ru.ice.display;

import ru.ice.display.DisplayObject;
import ru.ice.data.ElementData;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class SvgSprite extends DisplayObject
{
	public function new(?elementData:ElementData, ?initial:Bool = false) 
	{
		if (!initial) {
			if (elementData == null)
				elementData = new ElementData({'name':'svg'});
		}
		super(elementData);
	}
}