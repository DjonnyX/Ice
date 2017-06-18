package ru.ice.layout;

import ru.ice.controls.super.IceControl;
import ru.ice.display.DisplayObject;
import ru.ice.layout.BaseLayout;
import ru.ice.layout.ILayout;
import ru.ice.layout.params.HorizontalLayoutParams;
import ru.ice.math.Rectangle;
import ru.ice.utils.MathUtil;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class HorizontalLayout extends BaseLayout
{
	public static inline var HORIZONTAL_ALIGN_LEFT:String = 'horizontal-align-left';
	public static inline var HORIZONTAL_ALIGN_CENTER:String = 'horizontal-align-center';
	public static inline var HORIZONTAL_ALIGN_RIGHT:String = 'horizontal-align-right';
	public static inline var HORIZONTAL_ALIGN_JUSTIFY:String = 'horizontal-align-justify';
	public static inline var HORIZONTAL_ALIGN_FIT:String = 'horizontal-align-fit';
	public static inline var VERTICAL_ALIGN_TOP:String = 'vertical-align-top';
	public static inline var VERTICAL_ALIGN_MIDDLE:String = 'vertical-align-middle';
	public static inline var VERTICAL_ALIGN_BOTTOM:String = 'vertical-align-bottom';
	public static inline var VERTICAL_ALIGN_JUSTIFY:String = 'vertical-align-justify';
	
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
			trace('update layout', _owner.elementName, _owner.width, _owner.height);
		#end
		
		_needResize = false;
		_bound.setSize(_owner.width, _owner.height);
		
		var stageWidth:Float = _owner.width - (_paddingLeft + _paddingRight),
		stageHeight:Float = _owner.height - (_paddingTop + _paddingBottom),
		fullWidth:Float = 0, fullHeight:Float = 0, x:Float = null, itemWidth:Float = 0;
		
		var widths:Array<Float> = [];
		if (_horizontalAlign == HORIZONTAL_ALIGN_JUSTIFY)
			itemWidth = stageWidth;
		else if (_horizontalAlign == HORIZONTAL_ALIGN_FIT) {
			snapToStageWidth = true;
			var fixedL:Int = 0;
			var fixedWidths:Float = 0;
			var ol:Int = _objects.length;
			for (i in 0...ol) {
				var isNoFit:Bool = false;
				var c:IceControl = cast _objects[i];
				if (c != null) {
					var p:HorizontalLayoutParams = cast c.layoutParams;
					if (p != null && p.fitWidth == HorizontalLayoutParams.NO_FIT) {
						isNoFit = true;
						var ch:Float = c.width;
						widths.push(ch);
						fixedWidths += ch + (i < ol - 1 ? _horizontalGap : 0);
						fixedL ++;
					}
				}
				if (!isNoFit)
					widths.push(MathUtil.MAX_VALUE);
			}
			var nfl:Float = ol - fixedL - 1;
			if (nfl < 0)
				nfl = 0;
			itemWidth = (stageWidth - fixedWidths - (nfl * _horizontalGap)) / (ol - fixedL);
		}
		var i:Int = 0;
		
		for (child in _objects) {
			if (_verticalAlign == VERTICAL_ALIGN_JUSTIFY)
				child.height = stageHeight;
			
			if (_horizontalAlign == HORIZONTAL_ALIGN_JUSTIFY)
				child.width = itemWidth;
			else if (_horizontalAlign == HORIZONTAL_ALIGN_FIT)
				child.width = widths[i] == MathUtil.MAX_VALUE ? itemWidth : widths[i];
			
			if (_horizontalAlign == HORIZONTAL_ALIGN_JUSTIFY)
				fullWidth += stageWidth + (i < _objects.length - 1 ? _paddingLeft + _paddingRight : 0);
			else 
				fullWidth += child.width + (i < _objects.length - 1 ? _horizontalGap : 0);
			
			fullHeight = Math.max(fullHeight, child.height);
			i ++;
		}
		
		if (!ignoreX) {
			if (_horizontalAlign == HORIZONTAL_ALIGN_CENTER)
				x = _paddingLeft + (stageWidth - fullWidth) * .5;
			else if (_horizontalAlign == HORIZONTAL_ALIGN_RIGHT)
				x = stageWidth + _paddingLeft + _paddingRight - fullWidth;
			else
				x = _paddingLeft;
		}
		
		for (child in _objects) {
			if (!ignoreY) {
				if (_verticalAlign == VERTICAL_ALIGN_MIDDLE)
					child.y = _paddingTop + (stageHeight - child.height) * .5;
				
				else if (_verticalAlign == VERTICAL_ALIGN_BOTTOM)
					child.y = stageHeight + _paddingTop - child.height;
				else
					child.y = _paddingTop;
			}
			if (!ignoreX) {
				child.x = x;
				x += child.width + (_horizontalAlign == HORIZONTAL_ALIGN_JUSTIFY ? _paddingLeft + _paddingRight : _horizontalGap);
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