package ru.ice.layout;

import ru.ice.display.DisplayObject;
import ru.ice.layout.BaseLayout;
import ru.ice.layout.ILayout;
import ru.ice.math.Rectangle;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class TiledRowsLayout extends BaseLayout
{
	public static inline var HORIZONTAL_ALIGN_LEFT:String = 'left';
	public static inline var HORIZONTAL_ALIGN_CENTER:String = 'center';
	public static inline var HORIZONTAL_ALIGN_RIGHT:String = 'right';
	public static inline var VERTICAL_ALIGN_TOP:String = 'top';
	public static inline var VERTICAL_ALIGN_MIDDLE:String = 'middle';
	public static inline var VERTICAL_ALIGN_BOTTOM:String = 'bottom';
	
	public var distributeWidth:Bool = false;
	public var fitToStageHeight:Bool = false;
	public var horizontalAlign:String = HORIZONTAL_ALIGN_LEFT;
	public var verticalAlign:String = VERTICAL_ALIGN_TOP;
	
	public function new() {
		super();
	}
	
	public override function update() : Rectangle
	{
		if (_owner == null || !_owner.isInitialized)
			return _bound;
		
		if (_needSort)
			sort();
		
		_needResize = false;
		
		var fullWidth:Float = 0, fullHeight:Float = 0, x:Float = 0, y:Float = 0, itemHeight:Float = 0;
		if (fitToStageHeight)
			itemHeight = (_owner.parent.contentHeight - (paddingTop + paddingBottom) - (_objects.length - 1) * gap) / _objects.length;
		
		var i:Int = 0;
		for (child in _objects) {
			if (distributeWidth)
				child.width = _owner.parent.contentWidth - paddingLeft - paddingRight;
			if (fitToStageHeight)
				child.height = itemHeight;
			
			fullWidth = Math.max(fullWidth, child.contentWidth);
			fullHeight += child.contentHeight + (i < _objects.length - 1 ? gap : 0);
			i ++;
		}
		
		if (verticalAlign == VERTICAL_ALIGN_MIDDLE)
			y = (_owner.parent.contentHeight - fullHeight) * .5;
		else if (verticalAlign == VERTICAL_ALIGN_BOTTOM)
			y = _owner.parent.contentHeight - fullHeight;
		else
			y = paddingTop;
		
		if (horizontalAlign == HORIZONTAL_ALIGN_CENTER)
			x = (_owner.parent.contentWidth - fullWidth) * .5;
		else if (horizontalAlign == HORIZONTAL_ALIGN_RIGHT)
			x = _owner.parent.contentWidth - fullWidth;
		else
			x = paddingTop;
		
		for (child in _objects) {
			child.y = y;
			child.x = x;
			y += child.contentHeight + gap;
		}
		_bound.setSize(distributeWidth ? fullWidth : fullWidth + paddingLeft + paddingRight, fitToStageHeight ? _owner.parent.contentHeight : fullHeight + paddingTop + paddingBottom);
		_owner.setSize(_bound.width, _bound.height);
		return _bound;
	}
}