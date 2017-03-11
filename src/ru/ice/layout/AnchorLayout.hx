package ru.ice.layout;

import ru.ice.layout.params.AnchorLayoutParams;
import ru.ice.controls.super.BaseIceObject;
import ru.ice.display.DisplayObject;
import ru.ice.layout.BaseLayout;
import ru.ice.layout.ILayout;
import ru.ice.math.Rectangle;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class AnchorLayout extends BaseLayout
{
	public function new() {
		super();
	}
	
	public override function update() : Rectangle
	{
		var fullWidth:Float = _owner.width;
		var fullHeight:Float = _owner.height;
		var boundWidth:Float = fullWidth - _paddingLeft - _paddingRight;
		var boundHeight:Float = fullHeight - _paddingTop - _paddingBottom;
		for (child in _objects) {
			var c:BaseIceObject = cast child;
			if (c != null) {
				var p:AnchorLayoutParams = cast c.layoutParams;
				if (p != null) {
					p._layout = this;
					if (c.width > boundWidth)
						c.width = boundWidth;
					if (c.height > boundHeight)
						c.height = boundHeight;
					c.move((fullWidth - c.width) * p.horizontalPersent, (fullHeight - c .height) * p.verticalPersent);
				}
			}
		}
		_bound.setSize(fullWidth, fullHeight);
		return _bound;
	}
}