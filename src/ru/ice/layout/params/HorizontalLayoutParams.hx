package ru.ice.layout.params;

import ru.ice.controls.super.IceControl;
import ru.ice.layout.AnchorLayout;
import ru.ice.layout.ILayout;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class HorizontalLayoutParams implements ILayoutParams
{
	public static inline var NO_FIT:String = 'no-fit';
	public static inline var FIT:String = 'fit';
	
	public var ignoreX:Bool = false;
	
	private var _fitWidth:String = FIT;
	/**
	 * Устанавливает точку опоры по горизонтали, указанную процентах
	 * от ширины региона родительского объекта
	 */
	public var fitWidth(get, set):String;
	private function get_fitWidth() : String {
		return _fitWidth;
	}
	private function set_fitWidth(v:String) : String {
		if (_fitWidth != v) {
			_fitWidth = v;
			update();
		}
		return get_fitWidth();
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