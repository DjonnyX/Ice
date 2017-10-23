package ru.ice.core;

import haxe.io.Error;

import js.Browser;
import js.html.Element;
import js.html.CSSStyleDeclaration;
/**
 * ...
 * @author Evgenii Grebennikov
 */
class Capabilities 
{
	public static var TRANSFORM_METHODS:Array<String> = [
		"-webkit-transform",
		"-moz-transform",
		"-ms-transform",
		"-o-transform",
		"transform"
	];
	
	public static var transformMethod:String;
	
	public static function initialize() 
	{
		var e:Element = Browser.document.body;
		var st:CSSStyleDeclaration = Reflect.hasField(Browser.window, 'getComputedStyle') ? Browser.window.getComputedStyle(e, null) : e.style;
		for (method in Capabilities.TRANSFORM_METHODS) {
			if (Reflect.hasField(st, method)) {
				Capabilities.transformMethod = method;
				break;
			}
		}
		if (Capabilities.transformMethod == null) {
			#if debug
				trace("Transform method cannot be detected.");
			#end
			Capabilities.transformMethod = "transform";
		}
	}
	
}