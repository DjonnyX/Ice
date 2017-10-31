package com.flicker.controls;

import haxe.Constraints.Function;

import com.flicker.controls.SimplePreloader;
import com.flicker.controls.super.FlickerControl;
import com.flicker.app.events.EventTypes;
import com.flicker.display.DisplayObject;
import com.flicker.data.ElementData;
import com.flicker.controls.Image;
import com.flicker.events.Event;
import com.flicker.core.Flicker;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class ResourceBox extends FlickerControl
{
	public static inline var DEFAULT_STYLE:String = 'default-resource-box-style';
	
	private var _preloaderHRatio : Float = 1;
	public var preloaderHRatio(get, set) : Float;
	private function get_preloaderHRatio() : Float {
		return _preloaderHRatio;
	}
	private function set_preloaderHRatio(v:Float) : Float {
		if (_preloaderHRatio != v) {
			_preloaderHRatio = v;
			/*if (_image != null)
				_image.preloaderHRatio = _preloaderHRatio;*/
		}
		return get_preloaderHRatio();
	}
	
	private var _preloaderVRatio : Float = 1;
	public var preloaderVRatio(get, set) : Float;
	private function get_preloaderVRatio() : Float {
		return _preloaderVRatio;
	}
	private function set_preloaderVRatio(v:Float) : Float {
		if (_preloaderVRatio != v) {
			_preloaderVRatio = v;
			/*if (_image != null)
				_image.preloaderHRatio = _preloaderHRatio;*/
		}
		return get_preloaderVRatio();
	}
	/*
	private override function get_width() : Float {
		return _image == null || !_image.isLoaded ? super.height * _preloaderHRatio : super.height;
	}
	
	private override function get_height() : Float {
		return _image == null || !_image.isLoaded ? super.width * _preloaderVRatio : super.width;
	}*/
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'pre-img', 'interactive':false});
		super(elementData);
		snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_SELF);
		styleName = DEFAULT_STYLE;
	}
	
	public override function initialize() : Void {
		super.initialize();
		showPreloader();
		/*if (_image != null)
			showPreloader();*/
		//this.dispatchEventWith(Event.RESIZE, true);
	}
	
	private function showPreloader() : Void {
		if (_preloader == null) {
			_preloader = new SimplePreloader();
			_preloader.styleFactory = _preloaderStyleFactory;
			addChild(_preloader);
			_preloader.snapTo(_image, _image);
		}
	}
	
	private function hidePreloader() : Void {
		//removePreloader();
	}
	
	private function removePreloader() : Void {
		if (_preloader != null) {
			_preloader.removeEventListeners();
			_preloader.removeFromParent(true);
			_preloader = null;
		}
		//needResize = true;
	}
	
	/*public override function snapTo(?width:Dynamic, ?height:Dynamic) : Void {
		if (super.width != null) {
			if (Std.is(super.width, String)) {
				_snapWidth = super.width;
			} else if (Std.is(super.width, DisplayObject)) {
				_snapWidthObject = cast super.width;
				_snapWidth = IceControl.SNAP_TO_CUSTOM_OBJECT;
			}
		}
	}*/
	
	private function resetImage(src:String) : Void {
		if (_image != null) {
			if (_image.src == src)
				return;
			removeImage();
		}
		
		_image = new Image();
		_image.addEventListener(Event.LOADED, onLoadImage);
		_image._styleFactory = _imageStyleFactory;
		//_image.setSize(super.width, super.height);
		_image.src = src;
		addChildAt(_image, 0);
	}
	
	private function removeImage() : Void {
		if (_image != null) {
			snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_SELF);
			_image.removeEventListeners();
			_image.removeFromParent(true);
			_image = null;
		}
	}
	
	private function onLoadImage() : Void {
		dispatchEventWith(Event.SCREEN_LOADED, true);
		_image.removeEventListener(Event.LOADED, onLoadImage);
		hidePreloader();
	}
	
	private override function _resizeHandler(event:Event, ?data:Dynamic) : Void {
		super._resizeHandler(event, data);
	}
	
	public override function dispose() : Void {
		_preloaderStyleFactory = null;
		_imageStyleFactory = null;
		removePreloader();
		removeImage();
		super.dispose();
	}
}