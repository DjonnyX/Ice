package ru.ice.display;

import js.html.DOMElement;
import js.html.IFrameElement;
import js.html.Node;
import js.Browser;
import js.html.svg.SVGElement;

import ru.ice.events.EventDispatcher;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class DOMExpress extends EventDispatcher
{
	private var _classes:Array<String> = [];
	
	private var _element:DOMElement;
	public var element(get, null):DOMElement;
	private function get_element():DOMElement {
		return _element;
	}
	
	private var _style:Dynamic;
	public var style(get, set):Dynamic;
	private function get_style():Dynamic {
		return _style;
	}
	private function set_style(v:Dynamic):Dynamic {
		if (v != null) {
			_style = v;
			for (s in Reflect.fields(v)) {
				Reflect.setProperty(_element.style, s, Reflect.getProperty(v, s));
			}
		}
		return _style;
	}
	
	private var _elementName:String;
	public var elementName(get, set):String;
	private function get_elementName():String {
		return _elementName;
	}
	private function set_elementName(v:String):String {
		if (_elementName != v) {
			if (v == null) {
				Browser.document.removeChild(_element);
			    _element = null;
			} else {
				_elementName = v;
				if (_isSvg) {
					_element = cast createSvg();
					_element.setAttributeNS("http://www.w3.org/2000/xmlns/", "xmlns:xlink", "http://www.w3.org/1999/xlink");
					_svg = cast _element;
				} else {
					_element = Browser.document.createElement(_elementName);
				}
			}
		}
		return _elementName;
	}
	
	private var _isSvg:Bool = false;
	public var isSvg(get, never):Bool;
	private function get_isSvg() : Bool {
		return _isSvg;
	}
	
	private var _svg:SVGElement;
	public var svg(get, never):SVGElement;
	private function get_svg():SVGElement {
		return _svg;
	}
	
	private function createSvg(name:String = 'svg', ?params:Dynamic) : SVGElement {
		var svg:SVGElement = cast Browser.document.createElementNS('http://www.w3.org/2000/svg', name);
		if (params != null)
			setSvgParams(svg, params);
		return svg;
	}
	
	private function setSvgParams(svg:SVGElement, params:Dynamic) : SVGElement {
		if (svg != null && params != null) {
			var i:Array<String> = Reflect.fields(params);
			for (p in i) {
				svg.setAttributeNS(null, p, Reflect.getProperty(params, p));
			}
		}
		return svg;
	}
	
	public function new(isSvg:Bool = false ) {
		super();
		_isSvg = isSvg;
	}
	
	public function insertElementAt(element:DOMElement, index:Int = 0) : Void {
		if (index >= _element.children.length)
			_element.appendChild(element)
		else
			_element.insertBefore(element, _element.children[index]);
	}
	
	public function setID(v:String) : Void {
		if (_element != null)
			_element.id = v;
		updateCSSStyles();
	}
	
	public function hasClass(args:Array<String>) : Bool {
		if (_classes != null) {
			for (className in args) {
				var c:String = cast className;
				if (_classes.indexOf(c) > -1)
					continue;
				return false;
			}
			return true;
		}
		return false;
	}
	
	public function addClass(args:Array<String>) : Void {
		if (_classes == null)
			return;
		if (args.length == 1 && Std.is(args[0], Array)) {
			var a:Array<Dynamic> = cast args[0];
			for (className in a) {
				var c:String = cast className;
				if (_classes.indexOf(c) == -1) {
					_classes.push(c);
					_element.classList.add(c);
				}
			}
		} else {
			for (className in args) {
				var c:String = cast className;
				if (_classes.indexOf(c) == -1) {
					_classes.push(c);
					_element.classList.add(c);
				}
			}
		}
		updateCSSStyles();
	}
	
	public function removeClass(args:Array<String>) : Void {
		if (_classes == null)
			return;
		for (arg in args) {
			var index = _classes.indexOf(cast arg);
			if (index > -1) {
				_classes.splice(index, 1);
				_element.classList.remove(cast arg);
			}
		}
		updateCSSStyles();
	}
	
	private function updateCSSStyles() : Void {}
	
	public static function createElement(name:String) : DOMElement {
		return cast Browser.document.createElement(name);
	}
	
	public static function createIFrameElement() : IFrameElement {
		return Browser.document.createIFrameElement();
	}
	
	public function addNode(node:Node) : Node {
		return _element.appendChild(node);
	}
	
	public var innerHTML(never, set):Dynamic;
	private function set_innerHTML(v:Dynamic) : Dynamic {
		_element.innerHTML = v;
		return v;
	}
	
	public function removeNode(node:Node) : Node {
		return _element.removeChild(node);
	}
	
	private var _isDisposed: Bool = false;
	public var isDisposed(get, never) : Bool;
	private function get_isDisposed() : Bool {
		return _isDisposed;
	}
	
	public function dispose() : Void
	{
		_isDisposed = true;
		_classes = null;
		_style = null;
		_element = null;
	}
}