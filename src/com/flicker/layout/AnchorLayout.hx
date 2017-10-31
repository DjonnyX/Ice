package com.flicker.layout;

import com.flicker.layout.params.AnchorLayoutParams;
import com.flicker.controls.super.FlickerControl;
import com.flicker.display.DisplayObject;
import com.flicker.layout.BaseLayout;
import com.flicker.layout.ILayout;
import com.flicker.math.Rectangle;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class AnchorLayout extends BaseLayout
{
	public function new() {
		super();
	}
	
	public override function update(width:Float = 0, height:Float = 0) : Rectangle
	{
		if (_owner == null || !_owner.isInitialized)
			return _bound;
		
		if (_needSort)
			sort();
		
		var w:Float = width > 0 ? width : _owner._width;
		var h:Float = height > 0 ? height : _owner._height;
		
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
			var c:FlickerControl = cast child;
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
		if (_owner._width != _bound.width || _owner._height != _bound.height)
			_owner.setSize(_bound.width, _bound.height);
		
		if (_postLayout != null) {
			_bound = _postLayout.update();
			_owner.setSize(_bound.width, _bound.height);
		}
		return _bound;
	}
}