package ru.ice.layout;

import haxe.Constraints.Function;

import ru.ice.controls.super.IceControl;
import ru.ice.display.DisplayObject;
import ru.ice.layout.BaseLayout;
import ru.ice.layout.ILayout;
import ru.ice.math.Rectangle;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class FluidRowsLayout extends BaseLayout
{
	public static inline var HORIZONTAL_ALIGN_LEFT:String = 'horizontal-align-left';
	public static inline var HORIZONTAL_ALIGN_CENTER:String = 'horizontal-align-center';
	public static inline var HORIZONTAL_ALIGN_RIGHT:String = 'horizontal-align-right';
	public static inline var HORIZONTAL_ALIGN_JUSTIFY:String = 'horizontal-align-justify';
	public static inline var VERTICAL_ALIGN_TOP:String = 'vertical-align-top';
	public static inline var VERTICAL_ALIGN_MIDDLE:String = 'vertical-align-middle';
	public static inline var VERTICAL_ALIGN_BOTTOM:String = 'vertical-align-bottom';
	public static inline var VERTICAL_ALIGN_JUSTIFY:String = 'vertical-align-justify';
	
	public var snapToStageWidth:Bool = false;
	public var snapToStageHeight:Bool = false;
	
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
	
	private static var _defaultColumnsCountFactory:Function = function(width:Int, height:Int) : Int {
		if (width < 500) {
			return 1;
		} else if (width < 900) {
			return 2;
		} else if (width < 1200) {
			return 3;
		}
		return 9;
	}
	public static var defaultColumnsCountFactory(get, set) : Function;
	private static function get_defaultColumnsCountFactory() : Function {
		return _defaultColumnsCountFactory;
	}
	private static function set_defaultColumnsCountFactory(v:Function) : Function {
		if (_defaultColumnsCountFactory != v)
			_defaultColumnsCountFactory = v;
		return get_defaultColumnsCountFactory();
	}
	
	private var _columnsCountFactory:Function = _defaultColumnsCountFactory;
	public var columnsCountFactory(get, set) : Function;
	private function get_columnsCountFactory() : Function {
		return _columnsCountFactory;
	}
	private function set_columnsCountFactory(v:Function) : Function {
		if (_columnsCountFactory != v) {
			_columnsCountFactory = v;
			if (_columnsCountFactory != null && _owner != null)
				update();
		}
		return get_columnsCountFactory();
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
		
		_needResize = false;
		
		#if debug
			trace('update layout', _owner.elementName, _owner.width, _owner.height);
		#end
		
		_bound.setSize(_owner.width, _owner.height);
		
		var stageWidth:Float = _owner.width - (_paddingLeft + _paddingRight),
		stageHeight:Float = _owner.height - (_paddingTop + _paddingBottom),
		fullWidth:Float = 0, fullHeight:Float = 0, x:Float = paddingLeft, y:Float = paddingTop, itemWidth:Float = 0;
		var columns:Int = _columnsCountFactory(_owner.width, _owner.height);
		fullWidth = _owner.width - (_paddingLeft + _paddingRight);
		itemWidth = (fullWidth - (columns - 1) * _horizontalGap) / columns;
		var rowsHeight:Array<Float> = [];
		var columnCount:Int = 0;
		var rowIndex:Int = 0;
		var rowHeight:Float = 0;
		
		for (child in _objects) {
			child.width = itemWidth;
			rowHeight = Math.max(rowHeight, child.height);
			if (columnCount >= columns) {
				rowIndex ++;
				columnCount = 0;
				rowsHeight.push(rowHeight);
				rowHeight = 0;
			} else {
				rowsHeight[rowIndex] = rowHeight;
			}
			columnCount ++;
		}
		
		var i:Int = 0;
		for (rowHeight in rowsHeight) {
			fullHeight += rowHeight + (i < rowsHeight.length - 1 ? _horizontalGap : 0);
			i ++;
		}
		
		columnCount = 0;
		rowIndex = 0;
		
		for (child in _objects) {
			rowHeight = rowsHeight[rowIndex];
			var yy:Float = y;
			if (verticalAlign == VERTICAL_ALIGN_MIDDLE)
				yy += (_owner.height - child.height) * .5;
			else if (verticalAlign == VERTICAL_ALIGN_BOTTOM)
				yy += _owner.height - child.height;
			else if (verticalAlign == VERTICAL_ALIGN_JUSTIFY)
				child.height = rowHeight;
			
			var xx:Float = x;
			if (horizontalAlign == HORIZONTAL_ALIGN_CENTER)
				xx += (_owner.width - child.width) * .5;
			else if (horizontalAlign == HORIZONTAL_ALIGN_RIGHT)
				xx += _owner.width - child.width;
			
			child.y = yy;
			child.x = xx;
			
			columnCount ++;
			if (columnCount >= columns) {
				rowIndex ++;
				columnCount = 0;
				rowsHeight.push(rowHeight);
				y += rowHeight + _verticalGap;
				x = _paddingLeft;
				rowHeight = 0;
			} else {
				rowsHeight[rowIndex] = rowHeight;
				x += itemWidth + _horizontalGap;
			}
		}
		
		if (_owner.snapWidth == IceControl.SNAP_TO_PARENT || _owner.snapWidth == IceControl.SNAP_TO_CUSTOM_OBJECT || snapToStageWidth)
			fullWidth = stageWidth;
		
		if (_owner.snapHeight == IceControl.SNAP_TO_PARENT || _owner.snapHeight == IceControl.SNAP_TO_CUSTOM_OBJECT || snapToStageHeight)
			fullHeight = stageHeight;
		
		_bound.setSize(stageWidth + _paddingLeft + _paddingRight, fullHeight + paddingTop + paddingBottom);
		_owner.setSize(_bound.width, _bound.height);
		/*
		trace('>> update layout', _owner.elementName, _owner.width, _owner.height);
		*/
		if (_postLayout != null) {
			_bound = _postLayout.update();
			_owner.setSize(_bound.width, _bound.height);
		}
		return _bound;
	}
	
	override public function dispose():Void 
	{
		_columnsCountFactory = null;
		super.dispose();
	}
}