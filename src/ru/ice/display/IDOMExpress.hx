package ru.ice.display;

import js.html.DOMElement;
import js.html.Node;

import haxe.Constraints.Function;

import ru.ice.layout.params.ILayoutParams;
import ru.ice.controls.super.IceControl;
import ru.ice.events.IEventDispatcher;
import ru.ice.display.DisplayObject;
import ru.ice.math.Rectangle;
import ru.ice.display.Stage;
import ru.ice.core.Ice;

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
	//private function updateCSSStyles() : Void;
	public function addNode(node:Node) : Node;
	public function removeNode(node:Node) : Node;
	public function dispose() : Void;
}