package ru.ice.controls;

import js.Browser;
import js.html.Node;
import js.html.Element;
import js.html.IFrameElement;

import ru.ice.events.Event;
import ru.ice.data.ElementData;
import ru.ice.controls.super.IceControl;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class HTMLElement extends IceControl
{
	public static function createElement(name:String) : Element {
		return Browser.document.createElement(name);
	}
	
	public static function createIFrame(name:String) : Element {
		return Browser.document.createIFrameElement();
	}
	
	public static function createIFrameElement() : IFrameElement {
		return Browser.document.createIFrameElement();
	}
	
	public function addIFrame(src:String) : Void {
		var e = createIFrameElement();
		e.src = src;
		_element.appendChild(cast e);
	}
	
	public function new(?elementData:ElementData, ?initial:Bool = false) 
	{
		if (!initial) {
			if (elementData == null)
				elementData = new ElementData({'name':'div'});
			else
				elementData.setStyle({'name': 'div'});
		}
		super(elementData);
		autosize = IceControl.AUTO_SIZE_CONTENT;
	}
	
	public override function dispose() : Void
	{
		for (child in _element.children) {
			_element.removeChild(child);
		}
		super.dispose();
	}
}