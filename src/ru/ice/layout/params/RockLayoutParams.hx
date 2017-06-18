package ru.ice.layout.params;

import ru.ice.controls.super.IceControl;
import ru.ice.layout.AnchorLayout;
import ru.ice.layout.ILayout;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class RockLayoutParams implements ILayoutParams
{
	private var _horizontalRatio:Float = 1;
	/**
	 * Устанавливает точку опоры по горизонтали, указанную процентах
	 * от ширины региона родительского объекта
	 */
	public var horizontalRatio(get, set):Float;
	private function get_horizontalRatio() : Float {
		return _horizontalRatio;
	}
	private function set_horizontalRatio(v:Float) : Float {
		if (_horizontalRatio != v) {
			_horizontalRatio = v;
			update();
		}
		return get_horizontalRatio();
	}
	
	private var _verticalRatio:Float = 1;
	
	/**
	 * Устанавливает точку опоры по вертикали, указанную процентах
	 * от высоты региона родительского объекта
	 */
	public var verticalRatio(get, set):Float;
	private function get_verticalRatio() : Float {
		return _verticalRatio;
	}
	private function set_verticalRatio(v:Float) : Float {
		if (_verticalRatio != v) {
			_verticalRatio = v;
			update();
		}
		return get_verticalRatio();
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
	
	public function new() {}
	
	private function update() : Void {
		if (_layout != null)
			_layout.update();
	}
	
	public function dispose() : Void {
		_layout = null;
	}
}