package ru.ice.controls;

import js.html.Image;
import ru.ice.events.LayoutEvent;

import ru.ice.events.Event;
import ru.ice.data.ElementData;
import ru.ice.controls.super.BaseIceObject;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Image extends BaseIceObject
{
	private var _imageElement:js.html.Image;
	
	private var _imageStyle:Dynamic;
	public var imageStyle(get, set):Dynamic;
	private function get_imageStyle():Dynamic {
		return _imageStyle;
	}
	private function set_imageStyle(v:Dynamic):Dynamic {
		if (v != null) {
			_imageStyle = v;
			for (s in Reflect.fields(v)) {
				Reflect.setProperty(_imageElement.style, s, Reflect.getProperty(v, s));
			}
		}
		return get_imageStyle();
	}
	
	private var _proportional:Bool = true;
	public var proportional(get, set):Bool;
	private function get_proportional() : Bool {
		return _proportional;
	}
	private function set_proportional(v:Bool) : Bool {
		if (_proportional != v) {
			_proportional = v;
			resizeImage();
		}
		return get_proportional();
	}
	
	private var _src:String;
	public var src(get, set):String;
	private function get_src() : String {
		return _src;
	}
	private function set_src(v:String) : String {
		if (_src != v) {
			_src = v;
			_imageElement.src = v;
		}
		return get_src();
	}
	
	private override function set_width(v:Float) : Float {
		if (_element.offsetWidth != v) {
			var f:String = v + 'px';
			if (_imageElement != null)
				_imageElement.style.width = f;
			_element.style.width = f;
		}
		return get_width();
	}
	
	private override function set_height(v:Float) : Float {
		if (_element.offsetHeight != v) {
			var f:String = v + 'px';
			if (_imageElement != null)
				_imageElement.style.height = f;
			_element.style.height = f;
		}
		return get_height();
	}
	
    public var originalWidth(get, never):Float;
	private function get_originalWidth() : Float {
		return _imageElement != null ? _imageElement.naturalWidth : 0;
	}
	
    public var originalHeight(get, never):Float;
	private function get_originalHeight() : Float {
		return _imageElement != null ? _imageElement.naturalHeight : 0;
	}
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null) {
			elementData = new ElementData(
			{
				'name':'image',
				'image-rendering': 'auto'
			});
		} else {
			elementData.setStyle(
			{
				'name': 'image',
				'image-rendering': 'auto'
			});
		}
		super(elementData);
		autosize = BaseIceObject.AUTO_SIZE_CONTENT;
		_imageElement = new js.html.Image();
		_imageElement.onload = loadImage;
		element.appendChild(_imageElement);
	}
	
	private override function invalidSizeHandler(e:LayoutEvent, data:Dynamic) : Void
	{
		if (e.target == this)
			resizeImage();
		super.invalidSizeHandler(e, data);
	}
	
	/*public override function renderDraft(isParent:Bool = true) : Void {
		super.renderDraft();
		trace('renderDraft');
		imageStyle = {
			'image-rendering': 'optimizeSpeed'
		}
	}
	
	public override function renderNormal(isParent:Bool = true) : Void {
		super.renderNormal();
		trace('renderNormal');
		imageStyle = {
			'image-rendering': 'optimizeQuality'
		}
	}*/
	
	private function resizeImage() : Void
	{
		if (originalWidth == 0 && originalHeight == 0)
			return;
		if (_proportional && width > 0 && height > 0) {
			var ratio:Float = Math.min(width / originalWidth, height / originalHeight);
			setSize(originalWidth * ratio, originalHeight * ratio);
		} else {
			setSize(width, height);
		}
	}
	
	private function loadImage() : Void
	{
		resizeImage();
	}
	
	public override function dispose() : Void
	{
		if (_imageElement != null) {
			element.removeChild(_imageElement);
			_imageElement.src = null;
			_imageElement = null;
		}
		super.dispose();
	}
}