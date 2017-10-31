package com.flicker.app.core;

import haxe.Constraints.Function;
import haxe.Json;
import haxe.io.Error;
import com.flicker.controls.super.FlickerControl;
import com.flicker.core.Serializer;
import com.flicker.controls.VideoPlayer;
import com.flicker.controls.Image;

/**
 * @author Evgenii Grebennikov
 */
class AppSerializer extends Serializer
{
	//public static inline var PRELOADED_IMAGE:String = 'preloadedimage';
	
	public function new() {
		super();
	}
	
	/*private override function parseXmlElement(data:Xml) : IceControl {
		var element:Xml = data;
		var name:String = data.nodeName.toLowerCase();
		var control:IceControl = super.parseXmlElement(data);
		switch (name) {
			case PRELOADED_IMAGE: {
				control = createPreloadedImage(data);
			}
		}
		return control;
	}*/
	
	/*private function createPreloadedImage(data:Xml) : PreloadedImage {
		var renderer:PreloadedImage = new PreloadedImage();
		applyIceProps(renderer, data);
		var setProps:Function = function(prop:String, propValue:Any) : Void {
			switch(prop) {
				case 'src': {
					renderer.src = cast propValue;
				}
				case 'preloaderRatio': {
					renderer.preloaderRatio = Std.parseFloat(prop);
				}
			}
		}
		var attrs:Iterator<String> = data.attributes();
		for (a in attrs) {
			setProps(a, data.get(a));
		}
		return renderer;
	}*/
}