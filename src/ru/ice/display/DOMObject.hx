package ru.ice.display;

import js.html.IFrameElement;
import js.html.Element;
import js.html.Node;
import js.Browser;

import ru.ice.events.EventDispatcher;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class DOMObject extends EventDispatcher
{
	private var _classes:Array<String> = [];
	
	private var _element:Element;
	public var element(get, null):Element;
	private function get_element():Element {
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
		return get_style();
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
				_element = Browser.document.createElement(_elementName);
			}
		}
		return get_elementName();
	}
	
	public function new() {
		super();
	}
	
	public function setID(v:String) : Void {
		if (_element != null)
			_element.id = v;
	}
	
	public function hasClass(args:Array<String>) : Bool {
		if (_classes == null)
			return false;
		for (className in args) {
			var c:String = cast className;
			if (_classes.indexOf(c) > -1)
				continue;
			return false;
		}
		return true;
	}
	
	public function addClass(args:Array<String>) : Void {
		if (_classes == null)
			_classes = [];
		if (args.length == 1 && Std.is(args[0], Array)) {
			var a:Array<Dynamic> = cast args[0];
			for (className in a) {
				var c:String = cast className;
				if (_classes.indexOf(c) < 0) {
					_classes.push(c);
					_element.classList.add(c);
				}
			}
		} else {
			for (className in args) {
				var c:String = cast className;
				if (_classes.indexOf(c) < 0) {
					_classes.push(c);
					_element.classList.add(c);
				}
			}
		}
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
	}
	
	public static function createElement(name:String) : Element {
		return Browser.document.createElement(name);
	}
	
	public static function createIFrameElement() : IFrameElement {
		return Browser.document.createIFrameElement();
	}
	
	public function addNode(node:Node) : Node {
		return _element.appendChild(node);
	}
	
	public function removeNode(node:Node) : Node {
		return _element.removeChild(node);
	}
	
	public function dispose() : Void
	{
		_classes = null;
		_style = null;
		_element = null;
	}
}