package ru.ice.core;

import haxe.Constraints.Function;
import haxe.Json;
import haxe.io.Error;
import ru.ice.controls.HtmlContainer;

import ru.ice.layout.AnchorLayout;
import ru.ice.layout.BaseLayout;
import ru.ice.layout.HorizontalLayout;
import ru.ice.layout.RockRowsLayout;
import ru.ice.layout.VerticalLayout;

import ru.ice.controls.Image;
import ru.ice.controls.VideoPlayer;
import ru.ice.controls.PreloadedImage;
import ru.ice.controls.super.IceControl;

/**
 * @author Evgenii Grebennikov
 */
class IceSerializer 
{
	private static inline var HTML_TAG:String = 'html';
	public static inline var DISPLAY_OBJECT:String = 'displayobject';
	public static inline var SPRITE:String = 'sprite';
	public static inline var IMAGE:String = 'image';
	public static inline var ICE_CONTROL:String = 'icecontrol';
	public static inline var VIDEO_PLAYER:String = 'videoplayer';
	public static inline var PRELOADED_IMAGE:String = 'preloadedimage';
	public static inline var ANCHOR_LAYOUT:String = 'anchorlayout';
	public static inline var VERTICAL_LAYOUT:String = 'verticallayout';
	public static inline var HORIZONTAL_LAYOUT:String = 'horizontallayout';
	public static inline var ROCK_ROWS_LAYOUT:String = 'rockrowslayout';
	
	public function new() {}
	
	public function serialize(data:String) : Array<IceControl> 
	{
		if (data == null)
			return [];
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
		var name:String = data.nodeName.toLowerCase();
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
			case HTML_TAG: {
				control = createIceHtmlControl(data);
			}
			case ICE_CONTROL: {
				control = createIceControl(data);
			}
			case VIDEO_PLAYER: {
				control = createVideoControl(data);
			}
			case IMAGE: {
				control = createImage(data);
			}
			case PRELOADED_IMAGE: {
				control = createPreloadedImage(data);
			}
			case ANCHOR_LAYOUT: {
				control = createAnchorLayout(data);
			}
			case VERTICAL_LAYOUT: {
				control = createVerticalLayout(data);
			}
			case HORIZONTAL_LAYOUT: {
				control = createHorizontalLayout(data);
			}
			case ROCK_ROWS_LAYOUT: {
				control = createRockRowsLayout(data);
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
					renderer.preloaderHRatio = Std.parseFloat(propValue);
				}
				case 'preloaderVRatio': {
					renderer.preloaderVRatio = Std.parseFloat(propValue);
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
	
	private function createIceHtmlControl(data:Xml) : IceControl {
		var renderer:HtmlContainer = new HtmlContainer();
		applyIceProps(renderer, data);
		
		var text:String = null;
		var child = data.firstChild();
		if (child != null && (child.nodeType == Xml.PCData || child.nodeType == Xml.CData)) {
			text = child.nodeValue;
		}
		if (text != null && text != '')
			renderer.innerHTML = text;
		
		return renderer;
	}
	
	private function createAnchorLayout(data:Xml) : IceControl {
		var renderer:IceControl = new IceControl();
		applyIceProps(renderer, data);
		var layout:AnchorLayout = new AnchorLayout();
		applyLayoutProps(layout, data);
		renderer.layout = layout;
		return renderer;
	}
	
	private function createHorizontalLayout(data:Xml) : IceControl {
		var renderer:IceControl = new IceControl();
		applyIceProps(renderer, data);
		var layout:HorizontalLayout = new HorizontalLayout();
		applyLayoutProps(layout, data);
		var setProps:Function = function(prop:String, propValue:Any) : Void {
			switch(prop) {
				case 'horizontalAlign': {
					layout.horizontalAlign = cast propValue;
				}
				case 'verticalAlign': {
					layout.horizontalAlign = cast propValue;
				}
				case 'snapToStageWidth': {
					layout.snapToStageWidth = propValue == 'true';
				}
				case 'snapToStageHeight': {
					layout.snapToStageHeight = propValue == 'true';
				}
				case 'ignoreX': {
					layout.ignoreX = stringToBool(propValue);
				}
				case 'ignoreY': {
					layout.ignoreY = stringToBool(propValue);
				}
			}
		}
		renderer.layout = layout;
		var attrs:Iterator<String> = data.attributes();
		for (a in attrs) {
			setProps(a, data.get(a));
		}
		return renderer;
	}
	
	private function createVerticalLayout(data:Xml) : IceControl {
		var renderer:IceControl = new IceControl();
		applyIceProps(renderer, data);
		var layout:VerticalLayout = new VerticalLayout();
		applyLayoutProps(layout, data);
		var setProps:Function = function(prop:String, propValue:Any) : Void {
			switch(prop) {
				case 'horizontalAlign': {
					layout.horizontalAlign = cast propValue;
				}
				case 'verticalAlign': {
					layout.horizontalAlign = cast propValue;
				}
				case 'snapToStageWidth': {
					layout.snapToStageWidth = propValue == 'true';
				}
				case 'snapToStageHeight': {
					layout.snapToStageHeight = propValue == 'true';
				}
				case 'ignoreX': {
					layout.ignoreX = stringToBool(propValue);
				}
				case 'ignoreY': {
					layout.ignoreY = stringToBool(propValue);
				}
			}
		}
		renderer.layout = layout;
		var attrs:Iterator<String> = data.attributes();
		for (a in attrs) {
			setProps(a, data.get(a));
		}
		return renderer;
	}
	
	private function createRockRowsLayout(data:Xml) : IceControl {
		var renderer:IceControl = new IceControl();
		applyIceProps(renderer, data);
		var layout:RockRowsLayout = new RockRowsLayout();
		applyLayoutProps(layout, data);
		var setProps:Function = function(prop:String, propValue:Any) : Void {
			switch(prop) {
				case 'countFactory': {
					var cData:Array<Dynamic> = null;
					try {
						cData = Json.parse(propValue);
					} catch (e:Error) {
						cData = null;
						#if debug
							throw 'Parameter "countFactory" is not Array<Dynamic>.';
						#end
					}
					if (cData != null)
						layout.setColumnsCountFactory(cast cData);
				}
				case 'paggination': {
					layout.paggination = cast propValue;
				}
				case 'horizontalAlign': {
					layout.horizontalAlign = cast propValue;
				}
				case 'verticalAlign': {
					layout.horizontalAlign = cast propValue;
				}
				case 'defaultHorizontalRatio': {
					layout.defaultHorizontalRatio = cast Std.parseFloat(propValue);
				}
				case 'defaultVerticalRatio': {
					layout.defaultVerticalRatio = cast Std.parseFloat(propValue);
				}
				case 'uniscale': {
					layout.uniscale = stringToBool(propValue);
				}
			}
		}
		renderer.layout = layout;
		var attrs:Iterator<String> = data.attributes();
		for (a in attrs) {
			setProps(a, data.get(a));
		}
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
				case 'poster': {
					renderer.poster = cast propValue;
				}
				case 'posterHRatio': {
					renderer.posterHRatio = Std.parseFloat(propValue);
				}
				case 'posterVRatio': {
					renderer.posterVRatio = Std.parseFloat(propValue);
				}
			}
		}
		var attrs:Iterator<String> = data.attributes();
		for (a in attrs) {
			setProps(a, data.get(a));
		}
		return renderer;
	}
	
	private function applyIceProps(renderer:IceControl, data:Xml, fillInnerHTML:Bool = true ) : Any {
		if (fillInnerHTML) {
			var text:String = null;
			var child = data.firstChild();
			if (child != null && (child.nodeType == Xml.PCData || child.nodeType == Xml.CData)) {
				text = child.nodeValue;
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
	
	private function applyLayoutProps(renderer:BaseLayout, data:Xml ) : Any {
		var setProps:Function = function(prop:String, propValue:Any) : Void {
			switch(prop) {
				case 'paddingLeft': {
					renderer.paddingLeft = Std.parseInt(propValue);
				}
				case 'paddingRight': {
					renderer.paddingRight = Std.parseInt(propValue);
				}
				case 'paddingTop': {
					renderer.paddingTop = Std.parseInt(propValue);
				}
				case 'paddingBottom': {
					renderer.paddingBottom = Std.parseInt(propValue);
				}
				case 'padding': {
					renderer.padding = Std.parseInt(propValue);
				}
				case 'gap': {
					renderer.gap = Std.parseInt(propValue);
				}
				case 'verticalGap': {
					renderer.verticalGap = Std.parseInt(propValue);
				}
				case 'horizontalGap': {
					renderer.horizontalGap = Std.parseInt(propValue);
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
		v = v.toLowerCase();
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