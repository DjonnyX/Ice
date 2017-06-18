package ru.ice.app.controls;

import haxe.Constraints.Function;
import js.html.DOMElement;
import js.html.ImageElement;
import js.Browser;
import ru.ice.data.ElementData;

import ru.ice.controls.super.IceControl;

/**
 * ...
 * @author test
 */
class SimplePreloader extends IceControl
{
	public static inline var DEFAULT_STYLE:String = 'default-simple-preloader-style';
	
	private var _pContainer:DOMElement;
	public var pContainer(get, never):DOMElement;
	private function get_pContainer() : DOMElement {
		return _pContainer;
	}
	
	private var _img:ImageElement;
	public var img(get, never):ImageElement;
	private function get_img() : ImageElement {
		return _img;
	}
	
	public function new() 
	{
		super(new ElementData({'name':'c', 'interactive':false}));
		_pContainer = Browser.document.createElement('div');
		_img = Browser.document.createImageElement();
		_pContainer.appendChild(_img);
		_element.appendChild(_pContainer);
		styleName = DEFAULT_STYLE;
	}
	
	public override function dispose() : Void {
		if (_img != null) {
			if (_pContainer != null) {
				_pContainer.removeChild(_img);
				_img = null;
			}
		}
		if (_pContainer != null) {
			if (_element != null) {
				_element.removeChild(_pContainer);
				_pContainer = null;
			}
		}
		super.dispose();
	}
}