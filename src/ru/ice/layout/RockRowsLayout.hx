package ru.ice.layout;

import haxe.Constraints.Function;

import js.html.DOMElement;

import ru.ice.layout.params.RockLayoutParams;
import ru.ice.controls.super.IceControl;
import ru.ice.display.DisplayObject;
import ru.ice.layout.BaseLayout;
import ru.ice.layout.ILayout;
import ru.ice.math.Rectangle;
import ru.ice.math.Point;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class RockRowsLayout extends BaseLayout
{
	public static inline var PAGGINATION_HORIZONTAL:String = 'paggination-horizontal';
	public static inline var PAGGINATION_VERTICAL:String = 'paggination-vertical';
	
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
	
	private var _emptyItemFactory:Function;
	public var emptyItemFactory(get, set):Function;
	private function get_emptyItemFactory() : Function {
		return _emptyItemFactory;
	}
	private function set_emptyItemFactory(v:Function) : Function {
		if (_emptyItemFactory != v) {
			_emptyItemFactory = v;
			if (_owner != null)
				update();
		}
		return get_emptyItemFactory();
	}
	
	private var _paggination:String = PAGGINATION_HORIZONTAL;
	public var paggination(get, set):String;
	private function get_paggination() : String {
		return _paggination;
	}
	private function set_paggination(v:String) : String {
		if (_paggination != v) {
			_paggination = v;
			if (_owner != null)
				update();
		}
		return get_paggination();
	}
	
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
		return get_horizontalAlign();
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
		return get_verticalAlign();
	}
	
	private var _defaultHorizontalRatio:Float = 1;
	public var defaultHorizontalRatio(get, set):Float;
	private function get_defaultHorizontalRatio() : Float {
		return _defaultHorizontalRatio;
	}
	private function set_defaultHorizontalRatio(v:Float) : Float {
		if (_defaultHorizontalRatio != v) {
			_defaultHorizontalRatio = v;
			if (_owner != null)
				update();
		}
		return get_defaultHorizontalRatio();
	}
	
	private var _defaultVerticalRatio:Float = 1;
	public var defaultVerticalRatio(get, set):Float;
	private function get_defaultVerticalRatio() : Float {
		return _defaultVerticalRatio;
	}
	private function set_defaultVerticalRatio(v:Float) : Float {
		if (_defaultVerticalRatio != v) {
			_defaultVerticalRatio = v;
			if (_owner != null)
				update();
		}
		return get_defaultVerticalRatio();
	}
	
	private var _uniscale:Bool = false;
	public var uniscale(get, set):Bool;
	private function get_uniscale() : Bool {
		return _uniscale;
	}
	private function set_uniscale(v:Bool) : Bool {
		if (_uniscale != v) {
			_uniscale = v;
			if (_owner != null)
				update();
		}
		return get_uniscale();
	}
	
	/**
	 * Структура разметки по-умолчанию
	 */
	private static var _defaultColumnsCountFactory:Function = function(width:Int, height:Int) : Int {
		if (width < 500) {
			return 1;
		} else if (width < 900) {
			return 4;
		} else if (width < 1200) {
			return 5;
		} else if (width < 1500) {
			return 6;
		} else if (width < 1900) {
			return 7;
		} else if (width < 2300) {
			return 8;
		} else if (width < 2600) {
			return 9;
		}
		return 10;
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
	
	/**
	 * Задает пользовательскую разметку
	 * Используется в IceSerializer
	 * @param	data
	 */
	public function setColumnsCountFactory(data:Array<Dynamic>) : Void {
		columnsCountFactory = function(width:Int, height:Int) : Int {
			for (i in data) {
				var w:Int = cast i.width;
				var h:Int = cast i.height;
				var c:Int = cast i.columns;
				if ((w > 0 && width < w) || (h > 0 && height < h)) {
					return c;
				}
			}
			return 1;
		}
	}
	
	private var _emptyItems:Array<IceControl> = [];
	
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
		var e:DOMElement = _owner.element;
		
		var w:Float = _owner._width;
		var h:Float = _owner._height;
		
		#if debug
			trace('update layout', _owner.element, w, _owner.height);
		#end
		
		_bound.setSize(w, h);
		
		var stageWidth:Float = w - (_paddingLeft + _paddingRight),
		stageHeight:Float = h - (_paddingTop + _paddingBottom),
		fullWidth:Float = 0, fullHeight:Float = 0, x:Float = paddingLeft, y:Float = paddingTop, itemWidth:Float = 0;
		var columnLength:Int = _columnsCountFactory(w, h);
		fullWidth = w - (_paddingLeft + _paddingRight);
		itemWidth = (fullWidth - (columnLength - 1) * _horizontalGap) / columnLength;
		
		var places:Array<Array<Bool>> = [];
		var grid:Array<Array<Float>> = [];
		var columnCount:Int = 0;
		var rowIndex:Int = 0;
		
		var fillColumnsIfNeeded:Function = function(row:Array<Bool>) : Array<Bool> {
			while (row.length < columnLength) {
				row.push(true);
			}
			return row;
		}
		
		var fillRowsIfNeeded:Function = function(length:Int) : Array<Array<Bool>> {
			while (places.length < length) {
				places.push([]);
				fillColumnsIfNeeded(places[places.length - 1]);
			}
			return places;
		}
		
		var layoutChild:Function = function(child:DisplayObject, hRatio:Float, vRatio:Float) : Void {
			var endIndex:Int = places.length;
			var w:Int = Math.ceil(hRatio);
			var h:Int = Math.ceil(vRatio);
			var cx:Float = 0, cy:Float = 0;
			for (ri in 0...places.length) {
				var columns:Array<Bool> = places[ri];
				for (ci in 0...columns.length) {
					var val:Bool = columns[ci];
					var cellXL:Int = ci + w;
					var cellYL:Int = ri + h;
					if (val && cellXL <= columns.length) {
						var isEmpty:Bool = true;
						fillRowsIfNeeded(cellYL);
						for (hi in ri...cellYL) {
							if (!isEmpty)
								break;
							for (wi in ci...cellXL) {
								if (!places[hi][wi]) {
									isEmpty = false;
									break;
								}
							}
						}
						if (isEmpty) {
							for (hi in ri...cellYL) {
								for (wi in ci...cellXL) {
									places[hi][wi] = false;
								}
							}
							cx = _paddingLeft + (ci * itemWidth) + (ci * _horizontalGap);
							cy = _paddingTop + (ri * (_uniscale ? hRatio : 1) * itemWidth) + (ri * _verticalGap);
							child.x = cx;
							child.y = cy;
							child.setSize(vRatio * itemWidth + ((hRatio - 1) * _horizontalGap), hRatio * itemWidth + ((vRatio - 1) * _verticalGap));
							fullHeight = Math.max(fullHeight, cy + child.height);
							return;
						}
					}
				}
			}
			var pl:Int = endIndex + h;
			fillRowsIfNeeded(pl);
			for (ar in endIndex...pl) {
				for (ac in 0...columnLength) {
					places[ar][ac] = !(ac < w && ar < pl);
				}
			}
			cx = _paddingLeft;
			cy = _paddingTop + (endIndex * itemWidth) + (endIndex * _verticalGap);
			child.x = cx;
			child.y = cy;
			child.setSize(vRatio * itemWidth + ((hRatio - 1) * _horizontalGap), hRatio * itemWidth + ((vRatio - 1) * _verticalGap)); //hr hr vr vr
			fullHeight = Math.max(fullHeight, cy + child.height);
		}
		
		fillRowsIfNeeded(1);
		
		for (child in _objects) {
			if (!child.enabled)
				break;
			
			var hRatio:Float = _defaultHorizontalRatio, vRatio:Float = _defaultVerticalRatio;
			var c:IceControl = cast child;
			if (c != null) {
				var p:RockLayoutParams = cast c.layoutParams;
				if (p != null) {
					hRatio = p.horizontalRatio;
					vRatio = p.verticalRatio;
				}
			}
			if (hRatio > columnLength)
				hRatio = columnLength;
			
			if (vRatio > columnLength)
				vRatio = columnLength;
			
			if (columnCount >= columnLength) {
				rowIndex ++;
				columnCount = 0;
				fillRowsIfNeeded(rowIndex + 1);
			}
			
			layoutChild(child, hRatio, vRatio);
			
			columnCount ++;
		}
		
		if (fullHeight > 0)
			fullHeight -= paddingTop;
		
		if (_owner.snapWidth == IceControl.SNAP_TO_PARENT || _owner.snapWidth == IceControl.SNAP_TO_CUSTOM_OBJECT || snapToStageWidth)
			fullWidth = stageWidth;
		
		if (_owner.snapHeight == IceControl.SNAP_TO_PARENT || _owner.snapHeight == IceControl.SNAP_TO_CUSTOM_OBJECT || snapToStageHeight)
			fullHeight = stageHeight;
		
		_bound.setSize(fullWidth + _paddingLeft + _paddingRight, fullHeight + paddingTop + paddingBottom);
		_owner.setSize(_bound.width, _bound.height);
		
		if (_postLayout != null) {
			_bound = _postLayout.update();
			_owner.setSize(_bound.width, _bound.height);
		}
		return _bound;
	}
	
	override public function dispose() : Void {
		_columnsCountFactory = null;
		super.dispose();
	}
}