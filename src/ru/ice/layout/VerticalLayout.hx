package ru.ice.layout;

import ru.ice.layout.params.VerticalLayoutParams;
import ru.ice.controls.super.IceControl;
import ru.ice.display.DisplayObject;
import ru.ice.layout.BaseLayout;
import ru.ice.utils.MathUtil;
import ru.ice.layout.ILayout;
import ru.ice.math.Rectangle;
/**
 * ...
 * @author Evgenii Grebennikov
 */
class VerticalLayout extends BaseLayout
{
	public static inline var HORIZONTAL_ALIGN_LEFT:String = 'horizontal-align-left';
	public static inline var HORIZONTAL_ALIGN_CENTER:String = 'horizontal-align-center';
	public static inline var HORIZONTAL_ALIGN_RIGHT:String = 'horizontal-align-right';
	public static inline var HORIZONTAL_ALIGN_JUSTIFY:String = 'horizontal-align-justify';
	public static inline var VERTICAL_ALIGN_TOP:String = 'vertical-align-top';
	public static inline var VERTICAL_ALIGN_MIDDLE:String = 'vertical-align-middle';
	public static inline var VERTICAL_ALIGN_BOTTOM:String = 'vertical-align-bottom';
	public static inline var VERTICAL_ALIGN_JUSTIFY:String = 'vertical-align-justify';
	public static inline var VERTICAL_ALIGN_FIT:String = 'vertical-align-fit';
	
	public var snapToStageWidth:Bool = false;
	public var snapToStageHeight:Bool = false;
	
	public var ignoreX:Bool = false;
	public var ignoreY:Bool = false;
	
	private var _horizontalAlign:String = HORIZONTAL_ALIGN_LEFT;
	public var horizontalAlign(get, set):String;
	private function get_horizontalAlign() : String {
		return _horizontalAlign;
	}
	private function set_horizontalAlign(v:String) : String {
		if (_horizontalAlign != v) {
			_horizontalAlign = v;
			if (_owner != null)
				update();
		}
		return _horizontalAlign;
	}
	
	private var _verticalAlign:String = VERTICAL_ALIGN_TOP;
	public var verticalAlign(get, set):String;
	private function get_verticalAlign() : String {
		return _verticalAlign;
	}
	private function set_verticalAlign(v:String) : String {
		if (_verticalAlign != v) {
			_verticalAlign = v;
			if (_owner != null)
				update();
		}
		return _verticalAlign;
	}
	
	public function new() {
		super();
	}
	
	public override function update() : Rectangle
	{
		if (!(_owner != null && _owner.isInitialized))
			return _bound;
		
		if (_needSort)
			sort();
		
		#if debug
			trace('update layout', _owner.elementName, _owner.width, _owner.height, _paddingLeft, _paddingRight);
		#end
		
		_needResize = false;
		_bound.setSize(_owner.width, _owner.height);
		
		var stageWidth:Float = _owner.width - (_paddingLeft + _paddingRight),
		stageHeight:Float = _owner.height - (_paddingTop + _paddingBottom),
		fullWidth:Float = 0, fullHeight:Float = 0, y:Float = null, itemHeight:Float = 0;
		
		var heights:Array<Float> = [];
		if (_verticalAlign == VERTICAL_ALIGN_JUSTIFY)
			itemHeight = stageHeight;
		else if (_verticalAlign == VERTICAL_ALIGN_FIT) {
			snapToStageHeight = true;
			var fixedL:Int = 0;
			var fixedHeights:Float = 0;
			var ol:Int = _objects.length;
			for (i in 0...ol) {
				var isNoFit:Bool = false;
				var c:IceControl = cast _objects[i];
				if (c != null) {
					var p:VerticalLayoutParams = cast c.layoutParams;
					if (p != null && p.fitHeight == VerticalLayoutParams.NO_FIT) {
						isNoFit = true;
						var ch:Float = c.height;
						heights.push(ch);
						fixedHeights += ch + (i < ol - 1 ? _verticalGap : 0);
						fixedL ++;
					}
				}
				if (!isNoFit)
					heights.push(MathUtil.MAX_VALUE);
			}
			var nfl:Float = ol - fixedL - 1;
			if (nfl < 0)
				nfl = 0;
			itemHeight = (stageHeight - fixedHeights - (nfl * _verticalGap)) / (ol - fixedL);
		}
		var i:Int = 0;
		
		for (child in _objects) {
			if (_horizontalAlign == HORIZONTAL_ALIGN_JUSTIFY)
				child.width = stageWidth;
			
			if (_verticalAlign == VERTICAL_ALIGN_JUSTIFY)
				child.height = itemHeight;
			else if (_verticalAlign == VERTICAL_ALIGN_FIT)
				child.height = heights[i] == MathUtil.MAX_VALUE ? itemHeight : heights[i];
			
			if (_verticalAlign == VERTICAL_ALIGN_JUSTIFY)
				fullHeight += stageHeight + (i < _objects.length - 1 ? _paddingTop + _paddingBottom : 0);
			else 
				fullHeight += child.height + (i < _objects.length - 1 ? _verticalGap : 0);
			
			/*if (child.elementName == 'pre-img') {
				trace('repos', 'pre-img', child.width, child.height);
			}*/
			
			fullWidth = Math.max(fullWidth, child.width);
			i ++;
		}
		
		if (!ignoreY) {
			if (_verticalAlign == VERTICAL_ALIGN_MIDDLE)
				y = _paddingTop + (stageHeight - fullHeight) * .5;
			else if (_verticalAlign == VERTICAL_ALIGN_BOTTOM)
				y = stageHeight + _paddingTop + _paddingBottom - fullHeight;
			else
				y = _paddingTop;
		}
		
		for (child in _objects) {
			if (!ignoreX) {
				if (_horizontalAlign == HORIZONTAL_ALIGN_CENTER) {
					child.x = _paddingLeft + (stageWidth - child.width) * .5;
				}
				else if (_horizontalAlign == HORIZONTAL_ALIGN_RIGHT)
					child.x = stageWidth + _paddingLeft - child.width;
				else
					child.x = _paddingLeft;
			}
			if (!ignoreY) {
				child.y = y;
				y += child.height + (_verticalAlign == VERTICAL_ALIGN_JUSTIFY ? _paddingTop + _paddingBottom : _verticalGap);
			}
		}
		
		if (_owner.snapWidth == IceControl.SNAP_TO_PARENT || _owner.snapWidth == IceControl.SNAP_TO_CUSTOM_OBJECT || snapToStageWidth)
			fullWidth = stageWidth;
		
		if (_owner.snapHeight == IceControl.SNAP_TO_PARENT || _owner.snapHeight == IceControl.SNAP_TO_CUSTOM_OBJECT || snapToStageHeight)
			fullHeight = stageHeight;
		
		_bound.setSize(fullWidth + _paddingLeft + _paddingRight,
					   fullHeight + _paddingTop + _paddingBottom);
		_owner.setSize(_bound.width, _bound.height);
		
		if (_postLayout != null) {
			_bound = _postLayout.update();
			_owner.setSize(_bound.width, _bound.height);
		}
		return _bound;
	}
}