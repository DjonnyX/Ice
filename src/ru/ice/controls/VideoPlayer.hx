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

/**
 * ...
 * @author Evgenii Grebennikov
 */
class VideoPlayer extends IceControl
{
	public static inline var DEFAULT_STYLE:String = 'default-video-player-style';
	
	private var _videoElement:VideoElement;
	
	private var _videoContainer:IceControl;
	
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