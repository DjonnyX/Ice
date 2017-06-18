package ru.ice.layout;

import ru.ice.layout.params.AnchorLayoutParams;
import ru.ice.controls.super.IceControl;
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
		if (!(_owner != null && _owner.isInitialized))
			return _bound;
		
		if (_needSort)
			sort();
		
		_needResize = false;
		
		#if debug
			trace('update layout');
		#end
		
		_bound.setSize(_owner.width, _owner.height);
		
		var fullWidth:Float = _owner.width;
		var fullHeight:Float = _owner.height;
		var boundWidth:Float = fullWidth - _paddingLeft - _paddingRight;
		var boundHeight:Float = fullHeight - _paddingTop - _paddingBottom;
		for (child in _objects) {
			var c:IceControl = cast child;
			if (c != null) {
				var p:AnchorLayoutParams = cast c.layoutParams;
				if (p != null) {
					if (c.width > boundWidth) {
						c.width = boundWidth;
					}
					if (c.height > boundHeight) {
						c.height = boundHeight;
					}
					c.move(_paddingLeft + (fullWidth - c.width) * p.horizontalPersent, _paddingTop + (fullHeight - c.height) * p.verticalPersent);
				}
			}
		}
		_bound.setSize(fullWidth, fullHeight);
		
		if (_postLayout != null) {
			_bound = _postLayout.update();
			_owner.setSize(_bound.width, _bound.height);
		}
		return _bound;
	}
}