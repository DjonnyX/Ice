package ru.ice.core;

import haxe.Constraints.Function;
import haxe.Json;
import haxe.io.Error;
import ru.ice.controls.Label;

import ru.ice.controls.Image;
import ru.ice.controls.VideoPlayer;
import ru.ice.controls.PreloadedImage;
import ru.ice.controls.super.IceControl;

/**
 * @author Evgenii Grebennikov
 */
class IceSerializer 
{
	public static inline var DISPLAY_OBJECT:String = 'displayobject';
	public static inline var SPRITE:String = 'sprite';
	public static inline var IMAGE:String = 'image';
	public static inline var ICE_CONTROL:String = 'icecontrol';
	public static inline var VIDEO_PLAYER:String = 'videoplayer';
	public static inline var LABEL:String = 'label';
	public static inline var PRELOADED_IMAGE:String = 'preloadedimage';
	
	public function new() {}
	
	public function serialize(data:String) : Array<IceControl> 
	{
		var items:Array<IceControl> = [];
		var xmlData:Xml;
		try {
			xmlData = Xml.parse(data);
			var elements:Iterator<Xml> = xmlData.elements();
			for (element in elements) {
				var control:IceControl = parseXmlData(element);
				if (control != null)
					items.push(control);
			}
		} catch (e:Dynamic) {
			throw "Bad data.";
		}
		return items;
	}
	
	private function parseXmlData(data:Xml) : IceControl {
		var control:IceControl = parseXmlElement(data);
		if (control != null) {
			var elements:Iterator<Xml> = data.elements();
			var children:Array<IceControl> = [];
			for (element in elements) {
				children.push(parseXmlData(element));
			}
			for (child in children) {
				control.addChild(child);
			}
		}
		return control;
	}
	
	private function parseXmlElement(data:Xml) : IceControl {
		var element:Xml = data;
		var name:String = data.nodeName.toLowerCase();
		var control:IceControl = null;
		switch (name) {
			case ICE_CONTROL: {
				control = createIceControl(data);
			}
			case VIDEO_PLAYER: {
				control = createVideoControl(data);
			}
			case IMAGE: {
				control = createImage(data);
			}
			case LABEL: {
				control = createLabel(data);
			}
			case PRELOADED_IMAGE: {
				control = createPreloadedImage(data);
			}
		}
		return control;
	}
	
	private function createPreloadedImage(data:Xml) : PreloadedImage {
		var renderer:PreloadedImage = new PreloadedImage();
		applyIceProps(renderer, data);
		var setProps:Function = function(prop:String, propValue:Any) : Void {
			switch(prop) {
				case 'src': {
					renderer.src = cast propValue;
				}
				case 'preloaderHRatio': {
					//renderer.preloaderHRatio = Std.parseFloat(propValue);
				}
				case 'preloaderVRatio': {
					//renderer.preloaderVRatio = Std.parseFloat(propValue);
				}
			}
		}
		var attrs:Iterator<String> = data.attributes();
		for (a in attrs) {
			setProps(a, data.get(a));
		}
		return renderer;
	}
	
	private function createIceControl(data:Xml) : IceControl {
		var renderer:IceControl = new IceControl();
		applyIceProps(renderer, data);
		return renderer;
	}
	
	private function createImage(data:Xml) : Image {
		var renderer:Image = new Image();
		applyIceProps(renderer, data);
		var setProps:Function = function(prop:String, propValue:Any) : Void {
			switch(prop) {
				case 'src': {
					renderer.src = cast propValue;
				}
			}
		}
		var attrs:Iterator<String> = data.attributes();
		for (a in attrs) {
			setProps(a, data.get(a));
		}
		return renderer;
	}
	
	private function createVideoControl(data:Xml) : VideoPlayer {
		var renderer:VideoPlayer = new VideoPlayer();
		applyIceProps(renderer, data);
		var setProps:Function = function(prop:String, propValue:Any) : Void {
			switch(prop) {
				case 'src': {
					renderer.src = cast propValue;
				}
			}
		}
		var attrs:Iterator<String> = data.attributes();
		for (a in attrs) {
			setProps(a, data.get(a));
		}
		return renderer;
	}
	
	private function createLabel(data:Xml) : Label {
		var renderer:Label = new Label();
		applyIceProps(renderer, data, false);
		
		var text:String = null;
		var child = data.firstChild();
		if (child != null && (child.nodeType == Xml.PCData || child.nodeType == Xml.CData)) {
			text = child.nodeValue;
		}
		if (text != null && text != '')
			renderer.text = text;
		
		return renderer;
	}
	
	private function applyIceProps(renderer:IceControl, data:Xml, fillInnerHTML:Bool = true ) : Any {
		if (fillInnerHTML) {
			var text:String = null;
			var child = data.firstChild();
			if (child != null && (child.nodeType == Xml.PCData || child.nodeType == Xml.CData)) {
				text = child.nodeValue;
				trace(data, text);
			}
			if (text != null)
				renderer.innerHTML = text;
		}
		var setProps:Function = function(prop:String, propValue:Any) : Void {
			switch(prop) {
				case 'x': {
					renderer.x = cast propValue;
				}
				case 'y': {
					renderer.y = cast propValue;
				}
				case 'styleName': {
					renderer.styleName = propValue;
				}
				case 'visible': {
					renderer.visible = stringToBool(propValue);
				}
				case 'class': {
					renderer.addClass(stringToArrayString(propValue));
				}
				case 'style': {
					renderer.style = stringToArrayDynamic(propValue);
				}
			}
		}
		var attrs:Iterator<String> = data.attributes();
		for (a in attrs) {
			setProps(a, data.get(a));
		}
		return renderer;
	}
	
	private function getFields(obj:Dynamic) : Array<String> {
		return Type.getInstanceFields(Type.getClass(obj));
	}
	
	private function hasPropery(obj:Dynamic, propery:String, fields:Array<String> = null) : Bool {
		var f:Array<String> = fields != null ? fields : getFields(obj);
		return f.indexOf(propery) != -1 || f.indexOf('set_' + propery) != -1;
	}
	
	private function stringToLoverString(v:String) : String {
		if (v == null)
			return null;
		return v.toLowerCase();
	}
	
	private function stringToBool(v:String) : Bool {
		if (v == null)
			return false;
		return v == '1' || v.toLowerCase() == 'true';
	}
	
	private function stringToArrayString(v:String) : Array<String> {
		var a:Array<String> = [];
		if (v != null) {
			while(v.indexOf(' ') > -1) v = StringTools.replace(v, ' ', '');
			v += ',';
			while(v.indexOf(',') > -1) {
				var s:String = v.substring(0, v.indexOf(','));
				v = StringTools.replace(v, s, '');
				v = StringTools.replace(v, ',', '');
				a.push(s);
			}
		}
		return a;
	}
	
	private function stringToArrayDynamic(v:String) : Json {
		var a:Json = null;
		if (v != null) {
			try {
				a = Json.parse(v);
			} catch (e:Dynamic) {
				throw 'Bad data.';
			}
		}
		return a;
	}
}