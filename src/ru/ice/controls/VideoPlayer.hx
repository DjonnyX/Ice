package ru.ice.controls;

import haxe.Constraints.Function;
import js.html.Element;

import js.html.MediaElement;
import js.html.VideoElement;
import js.html.SourceElement;
import js.Browser;

import ru.ice.controls.super.IceControl;
import ru.ice.data.ElementData;
import ru.ice.events.Event;
import ru.ice.utils.MathUtil;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class VideoPlayer extends IceControl
{
	public static inline var DEFAULT_STYLE:String = 'default-video-player-style';
	
	private var _videoElement:VideoElement;
	
	private var _videoContainer:IceControl;
	
	private var _posterImg:PreloadedImage;
	
	private var _poster:String;
	public var poster(get, set) : String;
	private function set_poster(v:String) : String {
		if (_poster != v) {
			_poster = v;
			deletePosterImage();
			if (v != null) {
				_posterImg = new PreloadedImage();
				_posterImg.preloaderHRatio = _posterHRatio;
				_posterImg.preloaderVRatio = _posterVRatio;
				_posterImg.styleFactory = _posterStyleFactory;
				_posterImg.src = v;
				addChild(_posterImg);
			}
		}
		return get_poster();
	}
	private function get_poster() : String {
		return _poster;
	}
	private function deletePosterImage() : Void {
		if (_posterImg != null) {
			_posterImg.removeFromParent(true);
			_posterImg = null;
		}
	}
	
	private var _posterHRatio : Float = MathUtil.INT_MIN_VALUE;
	public var posterHRatio(get, set) : Float;
	private function get_posterHRatio() : Float {
		return _posterHRatio;
	}
	private function set_posterHRatio(v:Float) : Float {
		if (_posterHRatio != v) {
			_posterHRatio = v;
			if (_posterImg != null)
				_posterImg.preloaderHRatio = v;
		}
		return get_posterHRatio();
	}
	
	private var _posterVRatio : Float = MathUtil.INT_MIN_VALUE;
	public var posterVRatio(get, set) : Float;
	private function get_posterVRatio() : Float {
		return _posterVRatio;
	}
	private function set_posterVRatio(v:Float) : Float {
		if (_posterVRatio != v) {
			_posterVRatio = v;
			if (_posterImg != null)
				_posterImg.preloaderVRatio = v;
		}
		return get_posterVRatio();
	}
	
	private var _posterStyleFactory:Function;
	public var posterStyleFactory(get, set) : Function;
	private function set_posterStyleFactory(v:Function) : Function {
		if (_posterStyleFactory != v) {
			_posterStyleFactory = v;
			if (_posterImg != null)
				_posterImg.styleFactory = v;
		}
		return get_posterStyleFactory();
	}
	private function get_posterStyleFactory() : Function {
		return _posterStyleFactory;
	}
	
	private var _videoContainerStyleFactory:Function;
	public var videoContainerStyleFactory(get, set) : Function;
	private function set_videoContainerStyleFactory(v:Function) : Function {
		if (_videoContainerStyleFactory != v) {
			_videoContainerStyleFactory = v;
			if (_videoContainer != null)
				_videoContainer.styleFactory = v;
		}
		return get_videoContainerStyleFactory();
	}
	private function get_videoContainerStyleFactory() : Function {
		return _videoContainerStyleFactory;
	}
	
	private var _screenToggleButton:Button;
	
	private var _screenToggleButtonStyleFactory:Function;
	public var screenToggleButtonStyleFactory(get, set) : Function;
	private function set_screenToggleButtonStyleFactory(v:Function) : Function {
		if (_screenToggleButtonStyleFactory != v) {
			_screenToggleButtonStyleFactory = v;
			if (_screenToggleButton != null)
				_screenToggleButton.styleFactory = v;
		}
		return get_screenToggleButtonStyleFactory();
	}
	private function get_screenToggleButtonStyleFactory() : Function {
		return _screenToggleButtonStyleFactory;
	}
	
	private var _controlPanel:IceControl;
	
	private var _useCache:Bool = false;
	
	public var src(never, set):String;
	
	private function set_src(v:String) : String {
		var sourceElement:SourceElement = addSource(v + (_useCache ? '' : '?n=' + Date.now().getTime()), "video/mp4");
		_videoElement.appendChild(sourceElement);
		_videoElement.play();
		return v;
	}
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'vp'});
		super(elementData);
		_videoContainer = new IceControl(new ElementData({name:'vpc'}));
		_videoContainer.styleFactory = _videoContainerStyleFactory;
		addChild(_videoContainer);
		
		_videoElement = Browser.document.createVideoElement();
		_videoElement.addEventListener('pause', videoElement_pauseHandler, false);
		_videoElement.addEventListener('play', videoElement_playHandler, false);
		_videoElement.addEventListener('ended', videoElement_endedHandler, false);
		_videoElement.addEventListener('timeupdate', videoElement_progressHandler, false);
		
		_videoElement.style.width = '100%';
		_videoElement.style.height = 'auto';
		
		_videoContainer.element.appendChild(_videoElement);
		/*_screenToggleButton = new Button();
		_screenToggleButton.addEventListener(Event.TRIGGERED, buttonTriggeredHandler);
		_screenToggleButton.styleFactory = _screenToggleButtonStyleFactory;
		addChild(_screenToggleButton);*/
		
		styleName = DEFAULT_STYLE;
	}
	
	private function addSource(src, type) : SourceElement {
		var source:SourceElement = cast Browser.document.createElement('source');
		source.src = src;
		source.type = type;
		_videoElement.appendChild(source);
		return source;
	}
	
	private function buttonTriggeredHandler() : Void {
		
	}
	
	private function videoElement_pauseHandler() : Void {
		//_screenToggleButton.isSelect = false;
	}
	
	private function videoElement_playHandler() : Void {
		//_screenToggleButton.isSelect = true;
	}
	
	private function videoElement_endedHandler() : Void {
		
	}
	
	private function videoElement_progressHandler() : Void {
		
	}
	
	function toggle() {
		if (_videoElement.paused || _videoElement.ended) {
			_screenToggleButton.isSelect = false;
			_videoElement.play();
		} else {
			_screenToggleButton.isSelect = true;
			_videoElement.pause();
		}
	}
	
	public function stop() : Void {
		_videoElement.pause();
		_videoElement.currentTime = 0;
	}
	
	public override function dispose() : Void {
		deletePosterImage();
		if (_posterStyleFactory != null)
			_posterStyleFactory = null;
		if (_videoContainerStyleFactory != null)
			_videoContainerStyleFactory = null;
		if (_screenToggleButtonStyleFactory != null)
			_screenToggleButtonStyleFactory = null;
		if (_videoContainer != null) {
			_videoContainer.removeFromParent(true);
			_videoContainer = null;
		}
		if (_screenToggleButton != null) {
			_screenToggleButton.removeFromParent(true);
			_screenToggleButton = null;
		}
		if (_videoElement != null) {
			_videoElement = null;
		}
		super.dispose();
	}
}