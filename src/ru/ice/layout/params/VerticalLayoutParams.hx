package ru.ice.layout.params;

import ru.ice.controls.super.IceControl;
import ru.ice.layout.AnchorLayout;
import ru.ice.layout.ILayout;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class VerticalLayoutParams implements ILayoutParams
{
	public static inline var NO_FIT:String = 'no-fit';
	public static inline var FIT:String = 'fit';
	
	public var ignoreY:Bool = false;
	
	private var _fitHeight:String = FIT;
	/**
	 * Устанавливает точку опоры по вертикали, указанную процентах
	 * от высоты региона родительского объекта
	 */
	public var fitHeight(get, set):String;
	private function get_fitHeight() : String {
		return _fitHeight;
	}
	private function set_fitHeight(v:String) : String {
		if (_fitHeight != v) {
			_fitHeight = v;
			update();
		}
		return get_fitHeight();
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