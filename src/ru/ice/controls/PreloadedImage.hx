package ru.ice.controls;

import haxe.Constraints.Function;

import ru.ice.controls.SimplePreloader;
import ru.ice.controls.super.IceControl;
import ru.ice.app.events.EventTypes;
import ru.ice.display.DisplayObject;
import ru.ice.data.ElementData;
import ru.ice.controls.Image;
import ru.ice.events.Event;
import ru.ice.core.Ice;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class PreloadedImage extends IceControl
{
	public static inline var DEFAULT_STYLE:String = 'default-preloaded-image-style';
	
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
			elementData = new ElementData({'name':'pre-img', 'interactive':false});
		super(elementData);
		snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_SELF);
		styleName = DEFAULT_STYLE;
	}
	
	public override function initialize() : Void {
		super.initialize();
		if (_image != null)
			showPreloader();
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
		
		if (_isInitialized)
			showPreloader();
	}
	
	private function removeImage() : Void {
		if (_image != null) {
			snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_SELF);
			_image.removeEventListeners();
			_image.removeFromParent(true);
			_image = null;
		}
	}
	
	private function onLoadImage() : Void {
		trace('cupture loaded');
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