package com.flicker.display;

import js.html.DOMElement;
import js.html.Node;

import haxe.Constraints.Function;

import com.flicker.layout.params.ILayoutParams;
import com.flicker.controls.super.FlickerControl;
import com.flicker.events.IEventDispatcher;
import com.flicker.display.DisplayObject;
import com.flicker.math.Rectangle;
import com.flicker.display.Stage;
import com.flicker.core.Flicker;

/**
 * @author Evgenii Grebennikov
 */
interface IDOMExpress extends IEventDispatcher
{
	public var element(get, null):DOMElement;
	public var style(get, set):Dynamic;
	public var elementName(get, set):String;
	public function insertElementAt(element:DOMElement, index:Int = 0) : Void;
	public function setID(v:String) : Void;
	public function hasClass(args:Array<String>) : Bool;
	public function addClass(args:Array<String>) : Void;
	public function removeClass(args:Array<String>) : Void;
	public function addNode(node:Node) : Node;
	public function removeNode(node:Node) : Node;
	public function dispose() : Void;
}