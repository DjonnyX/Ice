package com.flicker.display;

import js.Browser;
import com.flicker.animation.Delayer;
import com.flicker.controls.super.BaseStatesControl;

import com.flicker.display.DOMExpress;
import com.flicker.events.FingerEvent;
import com.flicker.events.EventDispatcher;
import com.flicker.display.Sprite;
import com.flicker.data.ElementData;
import com.flicker.math.Rectangle;
import com.flicker.animation.Animator;
import com.flicker.core.FpsStats;
import com.flicker.events.Event;
import com.flicker.math.Point;
import com.flicker.core.Flicker;
import com.flicker.utils.MathUtil;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Stage extends Sprite
{
	private var _debugLayer:Sprite;
	
	private var _contentLayer:Sprite;
	
	private var _delayedResize:Delayer;
	
	private var _fpsStats:FpsStats;
	
	/**
	 * Indicates if mouse leave
	 */
	public var isMouseLeave(get, set):Bool;
	// @:getter(isMouseLeave)
	private function set_isMouseLeave(v:Bool):Bool
	{
		if (_isMouseLeave != v) {
			_isMouseLeave = v;
			dispatchEventWith(v ? Event.WIN_MOUSE_LEAVE : Event.WIN_MOUSE_ENTER, false);
		}
		return get_isMouseLeave();
	}
	// @:setter(isMouseLeave)
	private function get_isMouseLeave():Bool {
		return _isMouseLeave;
	}
	private var _isMouseLeave:Bool = false;
	
	/**
	 * Show/hide statistic box (fps)
	 */
	public var useStats(get, set) : Bool;
	// @:getter(useStats)
	private function get_useStats():Bool {
		return _useStats;
	}
	// @:setter(useStats)
	private function set_useStats(v:Bool):Bool
	{
		if (v != _useStats) {
			_useStats = v;
			if (v)
				addStats();
			else
				removeStats();
		}
		return get_useStats();
	}
	private var _useStats:Bool = false;
	
	/**
	 * Ссылка на экземпляр аниматора
	 */
	public static var animator:Animator;
	
	public static var sleep:Int = 0;
	/**
	 * Ссылка на экземпляр стейджа
	 */
	public static var current:Stage;
	
	/**
	 * The minimal frame time
	 */
	public var minPassedTime(get, never):Float;
	private function get_minPassedTime():Float {
		return _minPassedTime;
	}
	private var _minPassedTime:Float = 0;
	
	/**
	 * The real time of updating the current frame
	 * <code>passedTime</code> can not be less that <code>minPassedTime</code>
	 */
	public var realPassedTime(get, never):Float;
	// @:getter(realPassedTime)
	private function get_realPassedTime():Float {
		return _realPassedTime;
	}
	private var _realPassedTime:Float = 0;
	
	/**
	 * Time of updating the current frame
	 */
	public var passedTime(get, never):Float;
	// @:getter(passedTime)
	private function get_passedTime():Float {
		return _passedTime;
	}
	private var _passedTime:Float = 0;
	
	/**
	 * Current framerate
	 */
	public var fps(get, set):Float;
	// @:getter(fps)
	private function get_fps() : Float {
		return _fps;
	}
	// @:setter(fps)
	private function set_fps(v:Float) : Float {
		if (Math.isNaN(v) || v < 1)
			v = 1;
		_fps = v;
		_minPassedTime = 1 / _fps;
		return get_fps();
	}
	private var _fps:Float = 60;
	
	private var _currentTime:Float = 0;
	public var currentTime(get, never):Float;
	private function get_currentTime():Float {
		return _currentTime;
	}
	
	private var _lastFramePassedTime:Float = 0;
	
	public var viewport(get, never):Rectangle;
	private function get_viewport():Rectangle {
		return new Rectangle(0, 0, width, height);
	}
	
	private var _currentTarget:EventDispatcher;
	public var currentTarget(get, set):EventDispatcher;
	private function get_currentTarget():EventDispatcher {
		return _currentTarget;
	}
	private function set_currentTarget(v:EventDispatcher) : EventDispatcher {
		if (_currentTarget != v && v != null)
			_currentTarget = v;
		return get_currentTarget();
	}
	
	public function new(?elementData:ElementData, ?fps:Float) 
	{
		fps = fps != null ? fps : 60;
		animator = new Animator();
		super(elementData);
		Browser.document.body.appendChild(element);
		
		_contentLayer = new Sprite(new ElementData(
				{
					'name':'native',
					'disableInput':false,
					'interactive':false
				}
			)
		);
		super.addChild(_contentLayer);
		
		current = this;
		updateFrame(Date.now().getTime());
		
		Browser.document.body.onmouseleave = mouseLeave;
		Browser.document.body.onmouseenter = mouseEnter;
		Browser.window.onresize = resizeWindow;
		resizeWindow();
		initialize();
		checkInitialized();
		
		Browser.window.document.addEventListener( 'visibilitychange' , function() {
			if (Browser.window.document.hidden)
				_isStopped = true;
			else
				_isStopped = false;
		}, false );
		
		_contentLayer.addEventListener(Event.HOVER, hoverHandler);
	}
	
	private function hoverHandler(e:Event, ?data:Dynamic) : Void {
		Flicker.focusObjects = data.objects;
	}
	
	private function mouseLeave(e:Dynamic) : Void {
		isMouseLeave = true;
		Flicker.focusObjects = null;
	}
	
	private function mouseEnter(e:Dynamic) : Void {
		isMouseLeave = false;
	}
	
	public function add(child:DisplayObject) : DisplayObject {
		return _contentLayer.addChild(child);
	}
	
	public function remove(child:DisplayObject) : DisplayObject {
		return _contentLayer.removeChild(child);
	}
	
	private function resizeWindow() : Void
	{
		Flicker.animator.remove(_delayedResize);
		Flicker.animator.delayCall(setSize, .1, [Browser.window.innerWidth, Browser.window.innerHeight]);
	}
	
	/**
	 * Add statistic box (with fps)
	 */
	private function addStats() : Void
	{
		if (_debugLayer == null) {
			_debugLayer = new Sprite(new ElementData(
				{
					'name':'overlay',
					'interactive':false,
						'style':{
							'position':'absolute'
						}
						
					}
				)
			);
			super.addChild(_debugLayer);
		}
		if (_fpsStats == null) {
			_fpsStats = new FpsStats();
			_debugLayer.addChild(_fpsStats);
		}
	}
	
	private function removeStats() : Void
	{
		if (_fpsStats != null) {
			_fpsStats.removeFromParent(true);
			_fpsStats = null;
		}
	}
	
	private var _mouseEvent:FingerEvent;
	
	@:allow(com.flicker.display.DisplayObject)
	private function sMove(e:FingerEvent) : Void {
		_mouseEvent = e;
	}
	
	/**
	 * Calls <code>render()</code> (with the time that has passed since the last frame)
	 * @param {Float} t
	 */
	private function updateFrame(?t:Float) : Void
	{
		_currentTime = Date.now().getTime();
		if (sleep == 0) {
			var now:Float = t / 1000;
			_passedTime = now - _lastFramePassedTime;
			_realPassedTime = _passedTime;
			_lastFramePassedTime = now;
			if (_passedTime < _minPassedTime)
				_passedTime = _minPassedTime;
			render();
		} else
			sleep --;
		Browser.window.requestAnimationFrame(updateFrame);
	}
	
	/**
	 * Set stage size
	 * @param (Float) width
	 * @param (Float) height
	 */
	public override function setSize(width:Float, height:Float) : Void
	{
		if (_contentLayer != null)
			_contentLayer.setSize(width, height);
		this.width = width;
		this.height = height;
		dispatchEventWith(Event.RESIZE, true);
	}
	
	/**
	 * Render the current stage
	 */
	public function render() : Void
	{
		if (_isStopped)
			return;
		animator.update(_passedTime);
		updateChildren(this);
	}
	
	private var _isStopped:Bool = false;
	
	/**
	 * Update states
	 * @param {DisplayObject} obj
	 */
	private function updateChildren(obj:DisplayObject) : Void
	{
		if (_isStopped)
			return;
		var m:FingerEvent = null;
		if (_mouseEvent != null) {
			if (_mouseEvent.isStopedPropagation)
				_mouseEvent = null;
			m = _mouseEvent;
			if (!obj.interactive)
				m = null;
		}
		if (obj != null) {
			if (m != null)
				obj.mouseMove(m);
			for (child in obj.children) {
				updateChildren(child);
			}
			obj.update();
		}
		if (obj == this)
			_mouseEvent = null;
	}
	
	/**
	 * Disposes all children of the stage and remove all registered event listeners
	 */
	public override function dispose() : Void
	{
		removeStats();
		
		removeEventListener(Event.HOVER, hoverHandler);
		
		_currentTarget = null;
		
		if (_contentLayer != null) {
			_contentLayer.removeFromParent(true);
			_contentLayer = null;
		}
		if (_debugLayer != null) {
			_debugLayer.removeFromParent(true);
			_debugLayer = null;
		}
		super.dispose();
	}
}
