package ru.ice.layout;

import ru.ice.display.DisplayObject;
import ru.ice.layout.BaseLayout;
import ru.ice.layout.ILayout;
import ru.ice.math.Rectangle;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class VerticalLayout extends BaseLayout
{
	/*private override function set_velociteX(v:Float):Float {
		return get_velociteX();
	}
	*/
	public var distributeWidth:Bool = false;
	
	public function new() {
		super();
	}
	
	public override function update() : Rectangle
	{
		var fullWidth:Float = 0;
		var fullHeight:Float = paddingTop;
		var boundHeight:Float = paddingTop;
		var y:Float = paddingTop;
		var i:Int = 0;
		for (child in _objects) {
			i ++;
			if (distributeWidth)
				child.width = _owner.parent.contentWidth - paddingLeft - paddingRight;
			child.y = y;
			child.x = paddingRight;
			y += child.contentHeight + gap;// + Math.abs(_velociteY);
			fullHeight += child.contentHeight + gap;
			fullWidth = Math.max(fullWidth, child.contentWidth);
		}
		if (_objects.length > 0)
			fullHeight -= gap;
		
		_bound.setSize(distributeWidth ? fullWidth : fullWidth + paddingLeft + paddingRight, fullHeight + paddingBottom);
		_owner.setSize(_bound.width, _bound.height);
		return _bound;
	}
}