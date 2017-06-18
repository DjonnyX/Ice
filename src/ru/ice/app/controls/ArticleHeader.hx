package ru.ice.app.controls;

import haxe.Constraints.Function;

import ru.ice.controls.super.IceControl;
import ru.ice.controls.Label;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class ArticleHeader extends IceControl
{
	public static inline var DEFAULT_STYLE:String = 'default-article-header-style';
	
	private var _background:IceControl;
	private var _label:Label;
	
	private var _backgroundOffsetLeft:Float;
	public var backgroundOffsetLeft(get, set) : Float;
	private function set_backgroundOffsetLeft(v:Float) : Float {
		if (_backgroundOffsetLeft != v) {
			_backgroundOffsetLeft = v;
			labelResize();
		}
		return get_backgroundOffsetLeft();
	}
	private function get_backgroundOffsetLeft() : Float {
		return _backgroundOffsetLeft;
	}
	
	private var _backgroundOffsetRight:Float;
	public var backgroundOffsetRight(get, set) : Float;
	private function set_backgroundOffsetRight(v:Float) : Float {
		if (_backgroundOffsetRight != v) {
			_backgroundOffsetRight = v;
			labelResize();
		}
		return get_backgroundOffsetRight();
	}
	private function get_backgroundOffsetRight() : Float {
		return _backgroundOffsetRight;
	}
	
	private var _backgroundOffsetTop:Float;
	public var backgroundOffsetTop(get, set) : Float;
	private function set_backgroundOffsetTop(v:Float) : Float {
		if (_backgroundOffsetTop != v) {
			_backgroundOffsetTop = v;
			labelResize();
		}
		return get_backgroundOffsetTop();
	}
	private function get_backgroundOffsetTop() : Float {
		return _backgroundOffsetTop;
	}
	
	private var _backgroundOffsetBottom:Float;
	public var backgroundOffsetBottom(get, set) : Float;
	private function set_backgroundOffsetBottom(v:Float) : Float {
		if (_backgroundOffsetBottom != v) {
			_backgroundOffsetBottom = v;
			labelResize();
		}
		return get_backgroundOffsetBottom();
	}
	private function get_backgroundOffsetBottom() : Float {
		return _backgroundOffsetBottom;
	}
	
	private var _backgroundStyleFactory:Function;
	public var backgroundStyleFactory(get, set) : Function;
	private function set_backgroundStyleFactory(v:Function) : Function {
		if (_backgroundStyleFactory != v) {
			_backgroundStyleFactory = v;
			if (_background != null)
				_background.styleFactory = v;
		}
		return get_backgroundStyleFactory();
	}
	private function get_backgroundStyleFactory() : Function {
		return _backgroundStyleFactory;
	}
	
	private var _labelStyleFactory:Function;
	public var labelStyleFactory(get, set) : Function;
	private function set_labelStyleFactory(v:Function) : Function {
		if (_labelStyleFactory != v) {
			_labelStyleFactory = v;
			if (_label != null)
				_label.styleFactory = v;
		}
		return get_labelStyleFactory();
	}
	private function get_labelStyleFactory() : Function {
		return _labelStyleFactory;
	}
	
	private var _src:Dynamic;
	public var src(get, set) : Dynamic;
	private function get_src() : Dynamic {
		return _src;
	}
	private function set_src(v:Dynamic) : Dynamic {
		if (_src != v) {
			_src = v;
			if (_src) {
				if (_src.text != null) {
					_label.text = _src.text;
				} else
					_label.text = '';
			} else
				_label.text = '';
		}
		return get_src();
	}
	
	public function new() 
	{
		super();
		_background = new IceControl();
		addChild(_background);
		_label = new Label();
		_label.onResize = labelResize;
		addChild(_label);
		styleName = DEFAULT_STYLE;
	}
	
	public function labelResize(?data:Dynamic) : Void {
		_background.x = _backgroundOffsetLeft + _label.x;
		_background.y = _backgroundOffsetTop + _label.y;
		_background.setSize(_label.width - _backgroundOffsetLeft + _backgroundOffsetRight, _label.height - backgroundOffsetTop + backgroundOffsetBottom);
	}
	
	override public function dispose():Void 
	{
		_src = null;
		_backgroundStyleFactory = null;
		_labelStyleFactory = null;
		super.dispose();
	}
}