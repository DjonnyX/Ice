package com.flicker.layout.params;

import com.flicker.controls.super.FlickerControl;
import com.flicker.layout.AnchorLayout;
import com.flicker.layout.ILayout;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class AnchorLayoutParams implements ILayoutParams
{
	private var _horizontalPersent:Float = 0;
	/**
	 * Устанавливает точку опоры по горизонтали, указанную процентах
	 * от ширины региона родительского объекта
	 */
	public var horizontalPersent(get, set):Float;
	private function get_horizontalPersent() : Float {
		return _horizontalPersent;
	}
	private function set_horizontalPersent(v:Float) : Float {
		if (_horizontalPersent != v) {
			_horizontalPersent = v;
			update();
		}
		return get_horizontalPersent();
	}
	
	private var _verticalPersent:Float = 0;
	
	/**
	 * Устанавливает точку опоры по вертикали, указанную процентах
	 * от высоты региона родительского объекта
	 */
	public var verticalPersent(get, set):Float;
	private function get_verticalPersent() : Float {
		return _verticalPersent;
	}
	private function set_verticalPersent(v:Float) : Float {
		if (_verticalPersent != v) {
			_verticalPersent = v;
			update();
		}
		return get_verticalPersent();
	}
	
	private var _layout:ILayout;
	public var layout(get, set):ILayout;
	private function get_layout() : ILayout {
		return _layout;
	}
	private function set_layout(v:ILayout) : ILayout {
		if (_layout != v) {
			_layout = v;
		}
		return get_layout();
	}
	
	/**
	 * Выставляет точку привязки в центр региона родительского объекта
	 */
	public var isCenter(get, set):Bool;
	private function get_isCenter() : Bool {
		return _horizontalPersent == .5 && _verticalPersent == .5;
	}
	private function set_isCenter(v:Bool) : Bool {
		if (isCenter != v) {
			_verticalPersent = .5;
			_horizontalPersent = .5;
			update();
		}
		return get_isCenter();
	}
	
	private var _notLeaveBoundaries:Bool = false;
	/**
	 * Указывает, может ли объект иметь размеры большие чем у региона
	 * родительского объекта (false) или нет (true) 
	 */
	public var notLeaveBoundaries(get, set):Bool;
	private function get_notLeaveBoundaries() : Bool {
		return _notLeaveBoundaries;
	}
	private function set_notLeaveBoundaries(v:Bool) : Bool {
		if (_notLeaveBoundaries != v) {
			_notLeaveBoundaries = true;
			update();
		}
		return get_notLeaveBoundaries();
	}
	
	public function new() {}
	
	private function update() : Void {
		if (_layout != null)
			_layout.update();
	}
	
	public function dispose() : Void {
		_layout = null;
	}
}