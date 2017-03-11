package ru.ice.display;

import ru.ice.display.DisplayObject;
import ru.ice.data.ElementData;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Sprite extends DisplayObject
{
	public function new(?elementData:ElementData, ?initial:Bool = false) 
	{
		if (!initial) {
			if (elementData == null) {
				elementData = new ElementData(
				{
					'name':'sprite',
					'style':{
						'position': 'absolute',
						'transform-origin': 'left top'
					}
				});
			} else {
				elementData.setStyle(
				{
					'position': 'absolute',
					'transform-origin': 'left top'
				});
			}
		}
		super(elementData);
	}
}