package ru.ice.controls;

import haxe.Constraints.Function;

import ru.ice.controls.super.IceControl;
import ru.ice.data.ElementData;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Header extends IceControl
{
	public static inline var DEFAULT_STYLE:String = 'default-header-style';
	
	private var _titleField:IceControl;
	private var _container:IceControl;
	
	private var _titleStyleFactory:Function;
	public var titleStyleFactory(get, set) : Function;
	private function set_titleStyleFactory(v:Function) : Function {
		if (_titleStyleFactory != v) {
			_titleStyleFactory = v;
			if (_titleField != null)
				_titleField.styleFactory = v;
		}
		return get_titleStyleFactory();
	}
	private function get_titleStyleFactory() : Function {
		return _titleStyleFactory;
	}
	
	private var _containerStyleFactory:Function;
	public var containerStyleFactory(get, set) : Function;
	private function set_containerStyleFactory(v:Function) : Function {
		if (_containerStyleFactory != v) {
			_containerStyleFactory = v;
			if (_container != null)
				_container.styleFactory = v;
		}
		return get_containerStyleFactory();
	}
	private function get_containerStyleFactory() : Function {
		return _containerStyleFactory;
	}
	
	private var _title:Dynamic;
	public var title(get, set) : Dynamic;
	private function set_title(v:Dynamic) : Dynamic {
		if (_title != v) {
			_title = v;
			if (_title == null) {
				if (_titleField != null) {
					_titleField.removeFromParent(true);
					_titleField = null;
				}
			} else {
				if (_titleField == null) {
					_titleField = new IceControl(new ElementData({'name':'t'}));
					_titleField.styleFactory = _titleStyleFactory;
					_container.addChild(_titleField);
					_titleField.innerHTML = v;
				} else
					_titleField.innerHTML = v;
			}
		}
		return get_title();
	}
	private function get_title() : Dynamic {
		return _title;
	}
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'hdr', 'interactive':false});
		super(elementData);
		_container = new IceControl(new ElementData({'name':'c'}));
		addChild(_container);
		styleName = DEFAULT_STYLE;
	}
	
	public override function dispose() : Void {
		_containerStyleFactory = null;
		_titleStyleFactory = null;
		if (_titleField != null) {
			_titleField.removeFromParent(true);
			_titleField = null;
		}
		if (_container != null) {
			_container.removeFromParent(true);
			_container = null;
		}
		super.dispose();
	}
}