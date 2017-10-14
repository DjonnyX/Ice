package ru.ice.controls;

import js.html.Image;

import ru.ice.events.Event;
import ru.ice.data.ElementData;
import ru.ice.events.LayoutEvent;
import ru.ice.controls.super.IceControl;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Image extends IceControl
{
	public static inline var FROM_MAX_RECT:String = 'from-max-rect';
	public static inline var FROM_MIN_RECT:String = 'from-min-rect';
	public static inline var FIT_TO_CONTAINER_SIZE:String = 'fit-to-container-size';
	
	private static var __imgPool:Array<Image> = [];
	
	public static var nextLoadImage(get, never) : Image;
	private static function get_nextLoadImage() : Image {
		for (img in __imgPool) {
			if (img != null && !img._isLoaded) {
				return img;
			}
		}
		return null;
	}
	
	public static function loadNextImageIfNeeded() : Void {
		var img:Image = nextLoadImage;
		if (img != null)
			img.load();
	}
	
	public static function removeFromPool(img:Image) : Void {
		if (img == null)
			return;
		
		var ind:Int = __imgPool.indexOf(img);
		if (ind >= 0)
			__imgPool.splice(ind, 1);
	}
	
	private var _isLoaded:Bool = false;
	
	private var _loadingFromChain:Bool = false;
	
	private var _imageElement:Dynamic;
	
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
	
	private var _useCache:Bool = true;
	
	private var _stretchType:String = FROM_MAX_RECT;
	public var stretchType(get, set):String;
	private function get_stretchType() : String {
		return _stretchType;
	}
	private function set_stretchType(v:String) : String {
		if (_stretchType != v) {
			_stretchType = v;
			resizeImage();
		}
		return get_stretchType();
	}
	
	private var _alignCenter:Bool = false;
	public var alignCenter(get, set):Bool;
	private function get_alignCenter() : Bool {
		return _alignCenter;
	}
	private function set_alignCenter(v:Bool) : Bool {
		if (_alignCenter != v) {
			_alignCenter = v;
			resizeImage();
		}
		return get_alignCenter();
	}
	
	private var _src:String;
	public var src(get, set):String;
	private function get_src() : String {
		return _src;
	}
	private function set_src(v:String) : String {
		if (_src != v) {
			_src = v;
			if (_loadingFromChain) {
				if (nextLoadImage == this)
					_imageElement.src = formatSrc(v);
			} else
				_imageElement.src = formatSrc(v);
		}
		return get_src();
	}
	private function formatSrc(v:String) : String {
		return v + (_useCache ? '' : '?n=' + Date.now().getTime());
	}
	
	public function load() : Void {
		_imageElement.src = formatSrc(_src);
	}
	
	private var ratio(get, never) : Float;
	private function get_ratio() : Float {
		return originalWidth / originalHeight;
	}
	
    public var originalWidth(get, never):Float;
	private function get_originalWidth() : Float {
		return _imageElement.naturalWidth;
	}
	
    public var originalHeight(get, never):Float;
	private function get_originalHeight() : Float {
		return _imageElement.naturalHeight;
	}
	
	private var _isFirstResizedImg:Bool = false;
	private var _lastOriginalWidth:Float = 0;
	private var _lastOriginalHeight:Float = 0;
	private var _lastRequestedWidth:Float = 0;
	private var _lastRequestedHeight:Float = 0;
	
	public function new(?elementData:ElementData, useCache:Bool = true) 
	{
		__imgPool.push(this);
		_useCache = useCache;
		if (elementData == null) {
			elementData = new ElementData({
				'name':'img',
				'classes':['i-img'],
				'interactive': false
			});
		} else {
			elementData.name = 'img';
			elementData.classes = ['i-img'];
			elementData.interactive = false;
		}
		super(elementData);
		_imageElement = cast _element;
		visible = false;
		_element.onload = __onLoadHandler;
		_element.onerror = __onLoadHandler;
		snapTo(IceControl.SNAP_TO_CONTENT, IceControl.SNAP_TO_CONTENT);
	}
	
	private override function applyStylesIfNeeded() : Void {
		super.applyStylesIfNeeded();
		needResize = true;
	}
	
	private function __onLoadHandler() : Void {
		removeFromPool(this);
		visible = true;
		_isLoaded = true;
		this.dispatchEventWith(Event.LOADED, false);
		
		if (_loadingFromChain)
			loadNextImageIfNeeded();
	}
	
	private override function _resizeHandler(event:Event, ?data:Dynamic):Void 
	{
		if (event.target == this)
			resizeImage();
		super._resizeHandler(event, data);
	}
	
	private function resizeImage() : Void
	{
		if (!_isLoaded)
			return;
		if (originalWidth == 0 && originalHeight == 0)
			return;
		
		_lastRequestedWidth = _width;
		_lastRequestedHeight = _height;
		_lastOriginalWidth = originalWidth;
		_lastOriginalHeight = originalHeight;
		
		if (_proportional) {
			var ratioX:Float = 0, ratioY:Float = 0, r:Float = 0, w:Float = 0, h:Float = 0;
			if (_stretchType == FROM_MAX_RECT) {
				ratioX = _lastRequestedWidth / _lastOriginalWidth;
				ratioY = _lastRequestedHeight / _lastOriginalHeight;
				if (ratioX > ratioY) {
					removeClass(['i-fit-to-viewport', 'i-fit-to-height', 'i-fit-to-container-size']);
					addClass(['i-fit-to-width']);
				} else {
					removeClass(['i-fit-to-width', 'i-fit-to-viewport', 'i-fit-to-container-size']);
					addClass(['i-fit-to-height']);
				}
			} else if (_stretchType == FROM_MIN_RECT) {
				removeClass(['i-fit-to-width', 'i-fit-to-height', 'i-fit-to-container-size']);
				addClass(['i-fit-to-viewport']);
			} else {
				removeClass(['i-fit-to-width', 'i-fit-to-height', 'i-fit-to-viewport']);
				addClass(['i-fit-to-container-size']);
			}
		} else {
			if (_element.offsetWidth != _lastRequestedWidth)
				_element.style.width = _lastRequestedWidth + 'px';
			if (_element.offsetHeight != _lastRequestedHeight)
				_element.style.height = _lastRequestedHeight + 'px';
		}
		_width = _element.offsetWidth;
		_height = _element.offsetHeight;
		if (_alignCenter) {
			x = (_lastRequestedWidth - _width) * .5;
			y = (_lastRequestedHeight - _height) * .5;
		}
	}
	
	public override function dispose() : Void
	{
		_element.onload = null;
		_element.onerror = null;
		removeFromPool(this);
		super.dispose();
		_imageElement = null;
	}
}