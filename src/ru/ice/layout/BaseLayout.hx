package ru.ice.layout;

import ru.ice.controls.super.IceControl;
import ru.ice.layout.params.ILayoutParams;
import ru.ice.events.EventDispatcher;
import ru.ice.display.DisplayObject;
import ru.ice.data.ElementData;
import ru.ice.layout.ILayout;
import ru.ice.math.Rectangle;
import ru.ice.display.Stage;
import ru.ice.events.Event;
/**
 * ...
 * @author Evgenii Grebennikov
 */
class BaseLayout extends EventDispatcher implements ILayout
{
	/**
	 * Включает округление координат и размеров
	 */
	private var _roundToInt:Bool = true;
	public var roundToInt(get, set):Bool;
	private function get_roundToInt() : Bool {
		return _roundToInt;
	}
	private function set_roundToInt(v:Bool) : Bool {
		if (_roundToInt != v) {
			_roundToInt = v;
			if (_owner != null)
				update();
		}
		return _roundToInt;
	}
	
	/**
	 * Указывает является ли данный лэйаут, пост-лэйаутом
	 */
	private var _isPost:Bool = false;
	
	/**
	 * Список объектов обработки лэйатуа
	 */
	public var objects(get, never) : Array<DisplayObject>;
	private var _objects:Array<DisplayObject>;
	private function get_objects() : Array<DisplayObject> {
		return _objects;
	}
	
	/**
	 * Лэйауи-предок текущего луйаута
	 */
	public var ownerLayout(get, set) : BaseLayout;
	private var _ownerLayout:BaseLayout;
	private function get_ownerLayout() : BaseLayout {
		return _ownerLayout;
	}
	private function set_ownerLayout(v:BaseLayout) : BaseLayout {
		if (_ownerLayout != v) {
			_ownerLayout = v;
			if (_ownerLayout != null) {
				_isPost = true;
				_owner = _ownerLayout.owner;
				if (_owner != null)
					_objects = _ownerLayout.objects;
			} else
				_isPost = false;
		}
		return _ownerLayout;
	}
	
	/**
	 * Носитель лэйаута
	 */
	public var owner(get, set) : IceControl;
	private var _owner:IceControl;
	private function get_owner() : IceControl {
		return _owner;
	}
	private function set_owner(v:IceControl) : IceControl {
		if (_owner != v) {
			if (_owner != null) {
				_owner.removeEventListener(Event.CHILD_ADDED, childAddedHandler);
				_owner.removeEventListener(Event.CHILD_REMOVED, childRemovedHandler);
				//_owner.removeEventListener(Event.RESIZE, resizeHandler);
				_owner.removeEventListener(Event.ADDED_TO_STAGE, addChildToStageHandler);
				_owner.removeEventListener(Event.REMOVED_FROM_STAGE, removeChildFromStageHandler);
				_owner = null;
				_objects = null;
			}
			_owner = v;
			if (_owner != null) {
				// Если лэйаут добавили к контролу, то он не является пост-лэйаутом
				_isPost = false;
				
				_owner.addEventListener(Event.CHILD_ADDED, childAddedHandler);
				_owner.addEventListener(Event.CHILD_REMOVED, childRemovedHandler);
				//_owner.addEventListener(Event.RESIZE, resizeHandler);
				_owner.addEventListener(Event.ADDED_TO_STAGE, addChildToStageHandler);
				_owner.addEventListener(Event.REMOVED_FROM_STAGE, removeChildFromStageHandler);
				updateObjects();
			}
		}
		return get_owner();
	}
	
	private function updateObjects() : Void {
		_objects = [];
		for (child in _owner.children) {
			var iceObj:IceControl = cast child;
			if (iceObj != null) {
				if (iceObj.includeInLayout) {
					_objects.push(iceObj);
					needChange();
				}
			} else {
				// Добавляются все DisplayObject
				_objects.push(child);
				needChange();
			}
		}
	}
	
	/*private function addObject(obj:DisplayObject) : Void {
		var ind:Int = _objects.indexOf(obj);
		if (ind == -1) {
			_objects.
		}
		for (child in _owner.children) {
			var iceObj:IceControl = cast child;
			if (iceObj != null) {
				if (iceObj.includeInLayout) {
					_objects.push(iceObj);
					needChange();
				}
			} else {
				// Добавляются все DisplayObject
				_objects.push(child);
				needChange();
			}
		}
	}
	
	private function removeObject(obj:DisplayObject) : Void {
		_objects = [];
		for (child in _owner.children) {
			var iceObj:IceControl = cast child;
			if (iceObj != null) {
				if (iceObj.includeInLayout) {
					_objects.push(iceObj);
					needChange();
				}
			} else {
				// Добавляются все DisplayObject
				_objects.push(child);
				needChange();
			}
		}
	}*/
	
	/**
	 * Сортирует элементы в том же порядке что у родителя
	 */
	public function sort() : Void {
		_needSort = false;
		var l:Int = _objects.length;
		if (l > 0) {
			if (_owner != null && _objects != null) {
				var index:Int = 0;
				for (child in _owner.children) {
					var i:Int = _objects.indexOf(child);
					if (i != -1) {
						var c:DisplayObject = _objects[i];
						_objects.remove(c);
						_objects.insert(index, c);
						index ++;
					}
				}
			}
			_objects.slice(l - 1);
		}
	}
	
	/**
	 * Включает объект в списк обработки лэйаутом
	 */
	public function include(obj:DisplayObject) : Void {
		var child:DisplayObject = obj;
		if (_owner.getChildIndex(child) == -1)
			return;
		if (_objects.indexOf(child) == -1) {
			_objects.push(child);
			needChange();
		}
	}
	
	/**
	 * Исключает объект из списка обработки лэйаутом
	 */
	public function exclude(obj:DisplayObject) : Void {
		var child:DisplayObject = obj;
		if (_owner.getChildIndex(child) == -1)
			return;
		var index:Int = _objects.indexOf(child);
		if (index != -1) {
			_objects.remove(child);
			needChange();
		}
	}
	
	/**
	 * private
	 */
	private function addChildToStageHandler(e:Event) : Void {
		var child:DisplayObject = cast e.target;
		if (_owner.getChildIndex(child) == -1)
			return;
		if (_objects.indexOf(child) == -1) {
			var iceObj:IceControl = cast child;
			if (iceObj != null) {
				if (iceObj.includeInLayout) {
					_objects.push(child);
					needChange();
				}
			} else {
				_objects.push(child);
				needChange();
			}
		}
	}
	
	/**
	 * private
	 */
	private function removeChildFromStageHandler(e:Event) : Void {
		var child:DisplayObject = cast e.target;
		if (_owner.getChildIndex(child) == -1)
			return;
		var index:Int = _objects.indexOf(child);
		if (index != -1) {
			_objects.remove(child);
			needChange();
		}
	}
	
	/**
	 * Устанавливает флаги необходимости обновления лэйаута и сортировки элементов
	 * в списке обработки.
	 */
	private function needChange() : Void {
		_needSort = true;
		_needResize = true;
	}
	
	/**
	 * Задается лэйаут в качестве пост-обработчика.
	 * Т.е. сначала отработает родительский далее по цепи пост-лэйауты.
	 */
	public var postLayout(get, set) : ILayout;
	private var _postLayout:ILayout;
	private function get_postLayout() : ILayout {
		return _postLayout;
	}
	private function set_postLayout(v:ILayout) : ILayout {
		if (_postLayout != v) {
			if (v == null) {
				_postLayout.dispose();
				_postLayout = null;
			} else {
				_postLayout = v;
				_postLayout.ownerLayout = this;
			}
		}
		return get_postLayout();
	}
	
	/**
	 * Флаг указывающий на необходимость обновления лэйаута
	 */
	public var needResize(get, never) : Bool;
	private var _needResize:Bool = false;
	private function get_needResize() : Bool {
		return _needResize;
	}
	
	public var needCalcParams(get, never) : Bool;
	private var _needCalcParams:Bool = false;
	private function get_needCalcParams() : Bool {
		return _needCalcParams;
	}
	
	/**
	 * Флаг указывающий на необходимость сортировки списка обработки
	 */
	public var needSort(get, never) : Bool;
	private var _needSort:Bool = false;
	private function get_needSort() : Bool {
		return _needSort;
	}
	
	/**
	 * Регионы лэйаута
	 */
	public var bound(get, never) : Rectangle;
	private var _bound:Rectangle;
	private function get_bound() : Rectangle {
		return _bound;
	}
	
	/**
	 * Ссылка на объект stage
	 */
	public var stage(get, never):Stage;
	private function get_stage():Stage {
		return Stage.current;
	}
	
	/**
	 * Высота
	 */
	public var width(get, set) : Float;
	private var _width:Float = 0;
	private function get_width() : Float {
		return _width;
	}
	private function set_width(v:Float) : Float {
		if (_width != v)
			_width = v;
		return _width;
	}
	
	/**
	 * Ширина
	 */
	private var _height:Float = 0;
	public var height(get, set) : Float;
	private function get_height() : Float {
		return _height;
	}
	private function set_height(v:Float) : Float {
		if (_height != v)
			_height = v;
		return _height;
	}
	
	private var _postLayoutPaddingLeft:Float = 0;
	private var _postLayoutPaddingRight:Float = 0;
	private var _postLayoutPaddingTop:Float = 0;
	private var _postLayoutPaddingBottom:Float = 0;
	
	/**
	 * Суммарный отступ слева
	 */
	private var _commonPaddingLeft:Float = 0;
	public var commonPaddingLeft(get, never) : Float;
	private function get_commonPaddingLeft() : Float {
		return _commonPaddingLeft;
	}
	
	/**
	 * Суммарный отступ справа
	 */
	private var _commonPaddingRight:Float = 0;
	public var commonPaddingRight(get, never) : Float;
	private function get_commonPaddingRight() : Float {
		return _commonPaddingRight;
	}
	
	/**
	 * Суммарный отступ сверху
	 */
	private var _commonPaddingTop:Float = 0;
	public var commonPaddingTop(get, never) : Float;
	private function get_commonPaddingTop() : Float {
		return _commonPaddingTop;
	}
	
	/**
	 * Суммарный отступ снизу
	 */
	private var _commonPaddingBottom:Float = 0;
	public var commonPaddingBottom(get, never) : Float;
	private function get_commonPaddingBottom() : Float {
		return _commonPaddingBottom;
	}
	
	/**
	 * Устанавливает все отступы равными заданному значению
	 */
	public var padding(get, set) : Float;
	private var _padding:Float = 0;
	private function get_padding() : Float {
		return _padding;
	}
	private function set_padding(v:Float) : Float {
		_padding = _paddingLeft = _paddingRight = _paddingTop = _paddingBottom = v;
		_commonPaddingLeft = _paddingLeft + _postLayoutPaddingLeft;
		_commonPaddingRight = _paddingRight + _postLayoutPaddingRight;
		_commonPaddingTop = _paddingTop + _postLayoutPaddingTop;
		_commonPaddingBottom = _paddingBottom + _postLayoutPaddingBottom;
		updateParams();
		return _padding;
	}
	
	/**
	 * Отступ слева
	 */
	public var paddingLeft(get, set) : Float;
	private var _paddingLeft:Float = 0;
	private function get_paddingLeft() : Float {
		return _paddingLeft;
	}
	private function set_paddingLeft(v:Float) : Float {
		if (_paddingLeft != v) {
			_paddingLeft = v;
			_commonPaddingLeft = v + _postLayoutPaddingLeft;
			updateParams();
		}
		return _paddingLeft;
	}
	
	/**
	 * Отступ справа
	 */
	public var paddingRight(get, set) : Float;
	private var _paddingRight:Float = 0;
	private function get_paddingRight() : Float {
		return _paddingRight;
	}
	private function set_paddingRight(v:Float) : Float {
		if (_paddingRight != v) {
			_paddingRight = v;
			_commonPaddingRight = v + _postLayoutPaddingRight;
			updateParams();
		}
		return _paddingRight;
	}
	
	/**
	 * Отступ сверху
	 */
	public var paddingTop(get, set) : Float;
	private var _paddingTop:Float = 0;
	private function get_paddingTop() : Float {
		return _paddingTop;
	}
	private function set_paddingTop(v:Float) : Float {
		if (_paddingTop != v) {
			_paddingTop = v;
			_commonPaddingTop = v + _postLayoutPaddingTop;
			updateParams();
		}
		return _paddingTop;
	}
	
	/**
	 * Отступ снизу
	 */
	public var paddingBottom(get, set) : Float;
	private var _paddingBottom:Float = 0;
	private function get_paddingBottom() : Float {
		return _paddingBottom;
	}
	private function set_paddingBottom(v:Float) : Float {
		if (_paddingBottom != v) {
			_paddingBottom = v;
			_commonPaddingBottom = v + _postLayoutPaddingBottom;
			updateParams();
		}
		return _paddingBottom;
	}
	
	/**
	 * Устанавливает горизонтальный и вертикальный отступы между объектами
	 * равные заданному значению
	 */
	public var gap(never, set) : Float;
	private function set_gap(v:Float) : Float {
		_horizontalGap = v;
		_verticalGap = v;
		updateParams();
		return v;
	}
	
	private function updateParams() : Void {
		_needResize = true;
		_needCalcParams = true;
	}
	
	/**
	 * Горизонтальный отступ между объектами
	 */
	public var horizontalGap(get, set) : Float;
	private var _horizontalGap:Float = 0;
	private function get_horizontalGap() : Float {
		return _horizontalGap;
	}
	private function set_horizontalGap(v:Float) : Float {
		if (_horizontalGap != v) {
			_horizontalGap = v;
			updateParams();
		}
		return _horizontalGap;
	}
	
	/**
	 * Вуртикальный отступ между объектами
	 */
	public var verticalGap(get, set) : Float;
	private var _verticalGap:Float = 0;
	private function get_verticalGap() : Float {
		return _verticalGap;
	}
	private function set_verticalGap(v:Float) : Float {
		if (_verticalGap != v) {
			_verticalGap = v;
			updateParams();
		}
		return _verticalGap;
	}
	
	/**
	 * Конструктор
	 */
	public function new() {
		super();
		_bound = new Rectangle();
	}
	
	/*private function resizeHandler(e:Event) : Void {
		if (e.target != _owner)
			_needResize = true;
	}*/
	
	private function childAddedHandler(e:Event) : Void {
		e.stopImmediatePropagation();
		updateObjects();
	}
	
	private function childRemovedHandler(e:Event) : Void {
		e.stopImmediatePropagation();
		updateObjects();
	}
	
	/**
	 * Устанавливает размеры лэйаута
	 */
	public function setSize(w:Float, h:Float) : Void {
		_width = w;
		_height = h;
	}
	
	/**
	 * Обновление лэйаута
	 */
	public function update() : Rectangle {
		return null;
	}
	
	/**
	 * Деструктор
	 */
	public function dispose() : Void {
		if (_postLayout != null) {
			//_postLayout.removeEventListener(Event.CHANGE_PARAMS, changeParamsHandler);
			_postLayout.dispose();
			_postLayout = null;
		}
		if (_owner != null) {
			_owner.removeEventListener(Event.CHILD_ADDED, childAddedHandler);
			_owner.removeEventListener(Event.CHILD_REMOVED, childRemovedHandler);
			//_owner.removeEventListener(Event.RESIZE, resizeHandler);
			_owner.removeEventListener(Event.ADDED_TO_STAGE, addChildToStageHandler);
			_owner.removeEventListener(Event.REMOVED_FROM_STAGE, removeChildFromStageHandler);
			for (child in _owner.children) {
				var c:IceControl = cast child;
				if (c != null) {
					var p:ILayoutParams = cast c.layoutParams;
					if (p != null) {
						p.dispose();
						p = null;
					}
				}
			}
			_owner = null;
		}
		_objects = null;
		_bound = null;
	}
}