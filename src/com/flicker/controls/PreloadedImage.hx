package com.flicker.controls;

import haxe.Constraints.Function;

import com.flicker.controls.super.FlickerControl;
import com.flicker.controls.SimplePreloader;
import com.flicker.app.events.EventTypes;
import com.flicker.display.DisplayObject;
import com.flicker.data.ElementData;
import com.flicker.controls.Image;
import com.flicker.events.Event;
import com.flicker.core.Flicker;
import com.flicker.utils.MathUtil;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class PreloadedImage extends FlickerControl
{
	public static inline var DEFAULT_STYLE:String = 'default-preloaded-image-style';
	
	private var _preloaderHRatio : Float = MathUtil.INT_MIN_VALUE;
	public var preloaderHRatio(get, set) : Float;
	private function get_preloaderHRatio() : Float {
		return _preloaderHRatio;
	}
	private function set_preloaderHRatio(v:Float) : Float {
		if (_preloaderHRatio != v) {
			_preloaderHRatio = v;
			this.dispatchEventWith(Event.RESIZE, true);
		}
		return get_preloaderHRatio();
	}
	
	private var _preloaderVRatio : Float = MathUtil.INT_MIN_VALUE;
	public var preloaderVRatio(get, set) : Float;
	private function get_preloaderVRatio() : Float {
		return _preloaderVRatio;
	}
	private function set_preloaderVRatio(v:Float) : Float {
		if (_preloaderVRatio != v) {
			_preloaderVRatio = v;
			this.dispatchEventWith(Event.RESIZE, true);
		}
		return get_preloaderVRatio();
	}
	
	public var src(get, set) : String;
	private function set_src(v:String) : String {
		if (v != null)
			resetImage(v);
		else
			removeImage();
		return get_src();
	}
	private function get_src() : String {
		return _image != null ? _image.src : null;
	}
	
	private var _imageStyleFactory:Function;
	public var imageStyleFactory(get, set) : Function;
	private function set_imageStyleFactory(v:Function) : Function {
		if (_imageStyleFactory != v) {
			_imageStyleFactory = v;
			if (_image != null)
				_image.styleFactory = v;
		}
		return get_imageStyleFactory();
	}
	private function get_imageStyleFactory() : Function {
		return _imageStyleFactory;
	}
	
	private var _image:Image;
	public var image(get, never) : Image;
	private function get_image() : Image {
		return _image;
	}
	
	private var _preloaderStyleFactory:Function;
	public var preloaderStyleFactory(get, set) : Function;
	private function set_preloaderStyleFactory(v:Function) : Function {
		if (_preloaderStyleFactory != v) {
			_preloaderStyleFactory = v;
			if (_preloader != null)
				_preloader.styleFactory = v;
		}
		return get_preloaderStyleFactory();
	}
	private function get_preloaderStyleFactory() : Function {
		return _preloaderStyleFactory;
	}
	
	private var _preloader:SimplePreloader;
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null)
			elementData = new ElementData({'disableInput':true, 'interactive':false});
		super(elementData);
		snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_SELF);
		styleName = DEFAULT_STYLE;
	}
	
	private override function _resizeHandler(event:Event, ?data:Dynamic):Void 
	{
		//if (event.target == this)
			resizeWithRatioIfNeeded();
		super._resizeHandler(event, data);
	}
	
	private function resizeWithRatioIfNeeded() : Void {
		if (_preloaderHRatio != MathUtil.INT_MIN_VALUE)
			this.width = _height * _preloaderHRatio;
		else 
		if (_preloaderVRatio != MathUtil.INT_MIN_VALUE)
			this.height = _width * _preloaderVRatio;
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
		removePreloader();
	}
	
	private function removePreloader() : Void {
		if (_preloader != null) {
			_preloader.removeEventListeners();
			_preloader.removeFromParent();
			_preloader.dispose();
			_preloader = null;
		}
		needResize = true;
	}
	
	private function resetImage(src:String) : Void {
		if (_image != null) {
			if (_image.src == src)
				return;
			removeImage();
		}
		
		showPreloader();
			
		_image = new Image();
		_image.addEventListener(Event.LOADED, onLoadImage);
		_image._styleFactory = _imageStyleFactory;
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
	
	public override function dispose() : Void {
		_preloaderStyleFactory = null;
		_imageStyleFactory = null;
		removePreloader();
		removeImage();
		super.dispose();
	}
}