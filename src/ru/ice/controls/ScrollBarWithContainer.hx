package ru.ice.controls;

import haxe.Constraints.Function;

import ru.ice.controls.super.BaseStatesControl;
import ru.ice.controls.super.IceControl;
import ru.ice.events.WheelScrollEvent;
import ru.ice.events.FingerEvent;
import ru.ice.display.DisplayObject;
import ru.ice.controls.IScrollBar;
import ru.ice.controls.ScrollBar;
import ru.ice.data.ElementData;
import ru.ice.events.Event;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class ScrollBarWithContainer extends BaseStatesControl implements IScrollBar {
	
	private override function set_isHover(v:Bool) : Bool {
		var val:Bool = super.set_isHover(v);
		_scrollBar.isHover = val;
		return get_isHover();
	}
	
	private var _scrollBar:ScrollBar;
	public var scrollBar(get, never):ScrollBar;
	private function get_scrollBar():ScrollBar{
		return _scrollBar;
	}
	
	/**
	 * Scroller implements
	 */
	public var isDraggingHorizontally(get, never) : Bool;
	private function get_isDraggingHorizontally() : Bool {
		return _scrollBar.isDraggingHorizontally;
	}
	
	public var isDraggingVertically(get, never) : Bool;
	private function get_isDraggingVertically() : Bool {
		return _scrollBar.isDraggingVertically;
	}
	
	public var isDragging(get, never) : Bool;
	private function get_isDragging() : Bool {
		return _scrollBar.isDragging;
	}
	
	public var snapToPages(get, set):Bool;
	private function get_snapToPages():Bool {
		return _scrollBar.snapToPages;
	}
	private function set_snapToPages(v:Bool):Bool {
		return _scrollBar.snapToPages = v;
	}
	
	public var paggination(get, set):String;
	private function get_paggination() : String {
		return _scrollBar.paggination;
	}
	private function set_paggination(v:String) : String {
		return _scrollBar.paggination = v;
	}
	
	public var horizontalPages(get, never):Int;
	private function get_horizontalPages():Int {
		return _scrollBar.horizontalPages;
	}
	
	public var verticalPages(get, never):Int;
	private function get_verticalPages():Int {
		return _scrollBar.verticalPages;
	}
	
	public var maxScrollX(get, never):Float;
	private function get_maxScrollX():Float {
		return _scrollBar.maxScrollX;
	}
	
	public var maxScrollY(get, never):Float;
	private function get_maxScrollY():Float {
		return _scrollBar.maxScrollY;
	}
	
	public var horizontalScrollPosition(get, set) : Float;
	private function get_horizontalScrollPosition() : Float {
		return _scrollBar.horizontalScrollPosition;
	}
	private function set_horizontalScrollPosition(v:Float) : Float {
		return _scrollBar.horizontalScrollPosition = v;
	}
	
	public var verticalScrollPosition(get, set) : Float;
	private function get_verticalScrollPosition() : Float {
		return _scrollBar.verticalScrollPosition;
	}
	private function set_verticalScrollPosition(v:Float) : Float {
		return _scrollBar.verticalScrollPosition = v;
	}
	
	public var contentStyleFactory(never, set) : Function;
	private function set_contentStyleFactory(v:Function) : Function {
		return _scrollBar.contentStyleFactory = v;
	}
	
	// НЕ ИСПОЛЬЗУЕТСЯ
	public function resizeContent(?data:ResizeData) : Void {}
	
	public function contentChildren() : Array<DisplayObject> {
		return _scrollBar.contentChildren();
	}
	
	public function contentContains(child:DisplayObject) : Bool {
		return _scrollBar.contains(child);
	}
	
	public function addItem(child:DisplayObject) : DisplayObject {
		return _scrollBar.addChild(child);
	}
	
	public function removeItem(child:DisplayObject) : DisplayObject {
		return _scrollBar.removeChild(child);
	}
	
	public function getContentChildIndex(child:DisplayObject) : Int {
		return _scrollBar.getChildIndex(child);
	}
	
	/**
	 * ScrollBar implements
	 */
	public var ratio(get, set):Float;
	private function get_ratio():Float {
		return _scrollBar.ratio;
	}
	private function set_ratio(v:Float):Float {
		return _scrollBar.ratio = v;
	}
	
	public var direction(get, set):String;
	private function get_direction():String {
		return _scrollBar.direction;
	}
	private function set_direction(v:String):String {
		return _scrollBar.direction = v;
	}
	
	public var isOutScrollPosition(get, never) : Bool;
	private function get_isOutScrollPosition() : Bool {
		return _scrollBar.isOutScrollPosition;
	}
	
	public var thumb(get, never) : ScrollBarThumb;
	private function get_thumb() : ScrollBarThumb {
		return _scrollBar.thumb;
	}
	
	public var thumbStyleFactory(never, set):Function;
	private function set_thumbStyleFactory(v:Function):Function {
		return _scrollBar.thumbStyleFactory = v;
	}
	
	public var offsetRatioFunction(get, set):Float->Float->Float->Float;
	private function get_offsetRatioFunction() : Float->Float->Float->Float {
		return _scrollBar.offsetRatioFunction;
	}
	private function set_offsetRatioFunction(v:Float->Float->Float->Float) : Float->Float->Float->Float {
		return _scrollBar.offsetRatioFunction = v;
	}
	
	public var minThumbSize(get, set) : Float;
	public function get_minThumbSize() : Float {
		return _scrollBar.minThumbSize;
	}
	public function set_minThumbSize(v:Float) : Float {
		return _scrollBar.minThumbSize = v;
	}
	
	public function setScrollPosition(ratio:Float) : Void {
		_scrollBar.setScrollPosition(ratio);
	}
	
	private function setScrollParams(?os:Float, ?ocs:Float) : Void {
		_scrollBar.setScrollParams(os, ocs);
	}
	
	public function new(namePrefix:String, classPrefix:String, nameSBPrefix:String, direction:String = 'horizontal') {
		super();
		addClass([classPrefix + direction + '-container']);
		_scrollBar = new ScrollBar(new ElementData({'name':'sb', 'interactive':false}), new ElementData({'name':'tmb', 'interactive':false}), 'direction-' + direction);
		_scrollBar.addEventListener(Event.SCROLL, scrollHandler);
		addChild(_scrollBar);
		addEventListener(WheelScrollEvent.SCROLL, wheelScrollHandler);
	}
	
	private function scrollHandler(e:Event, ?data:Dynamic) : Void {
		dispatchEventWith(e.type, false, data);
	}
	
	private function wheelScrollHandler(e:WheelScrollEvent) : Void
	{
		_scrollBar.simWheelScroll(e);
	}
	
	private override function stageMoveHandler(e:FingerEvent) : Void
	{
		_scrollBar.simFingerStageMove(e);
	}
	
	private override function stageUpHandler(e:FingerEvent) : Void
	{
		_scrollBar.simFingerStageUp(e);
	}
	
	private override function upHandler(e:FingerEvent) : Void
	{
		_scrollBar.simFingerUp(e);
	}
	
	private override function downHandler(e:FingerEvent) : Void
	{
		_scrollBar.simFingerDown(e);
	}
	
	public override function dispose() : Void {
		removeEventListener(WheelScrollEvent.SCROLL, wheelScrollHandler);
		if (_scrollBar != null) {
			_scrollBar.removeEventListener(Event.SCROLL, scrollHandler);
			_scrollBar.removeEventListeners();
			_scrollBar.removeFromParent(true);
			_scrollBar = null;
		}
		super.dispose();
	}
}