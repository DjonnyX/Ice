package com.flicker.app.screens;

import com.flicker.app.App;
import haxe.Json;
import haxe.Constraints.Function;
import com.flicker.app.controls.MenuPanel;

import com.flicker.controls.FilterGroup;
import com.flicker.controls.ScreenNavigator;
import com.flicker.app.controls.gallery.RockGalleryItemRenderer;
import com.flicker.layout.params.RockLayoutParams;
import com.flicker.controls.super.FlickerControl;
import com.flicker.display.DisplayObject;
import com.flicker.layout.VerticalLayout;
import com.flicker.animation.Transitions;
import com.flicker.controls.ScrollPlane;
import com.flicker.display.DOMExpress;
import com.flicker.data.ElementData;
import com.flicker.controls.Screen;
import com.flicker.controls.Button;
import com.flicker.controls.Image;
import com.flicker.display.Sprite;
import com.flicker.events.Event;
import com.flicker.data.Loader;
import com.flicker.core.Flicker;


/**
 * ...
 * @author Evgenii Grebennikov
 */
class PortfolioGalleryScreen extends Screen
{
	public static inline var DEFAULT_STYLE:String = 'default-portfolio-gallery-screen-style';
	
	public static var selectedFilters:Array<String> = [];
	
	private var _filterGroup:FilterGroup;
	private var _plane:ScrollPlane;
	private var _overlay:FlickerControl;
	private var _planeGroups:Array<FlickerControl> = [];
	
	private var _filterGroupStyleFactory:Function;
	public var filterGroupStyleFactory(get, set) : Function;
	private function set_filterGroupStyleFactory(v:Function) : Function {
		if (_filterGroupStyleFactory != v) {
			_filterGroupStyleFactory = v;
			if (_filterGroup != null)
				_filterGroup.styleFactory = v;
		}
		return get_filterGroupStyleFactory();
	}
	private function get_filterGroupStyleFactory() : Function {
		return _filterGroupStyleFactory;
	}
	
	private var _planeStyleFactory:Function;
	public var planeStyleFactory(get, set) : Function;
	private function set_planeStyleFactory(v:Function) : Function {
		if (_planeStyleFactory != v) {
			_planeStyleFactory = v;
			if (_plane != null)
				_plane.styleFactory = v;
		}
		return get_planeStyleFactory();
	}
	private function get_planeStyleFactory() : Function {
		return _planeStyleFactory;
	}
	
	private var _planeGroupStyleFactory:Function;
	public var planeGroupStyleFactory(get, set) : Function;
	private function set_planeGroupStyleFactory(v:Function) : Function {
		if (_planeGroupStyleFactory != v) {
			_planeGroupStyleFactory = v;
			if (_planeGroups.length > 0) {
				for (item in _planeGroups) {
					item.styleFactory = v;
				}
			}
		}
		return get_planeGroupStyleFactory();
	}
	private function get_planeGroupStyleFactory() : Function {
		return _planeGroupStyleFactory;
	}
	
	private var _minLeftOffset:Float = 0;
	public var minLeftOffset(get, set) : Float;
	private function set_minLeftOffset(v:Float) : Float {
		if (_minLeftOffset != v) {
			_minLeftOffset = v;
			
		}
		return get_minLeftOffset();
	}
	private function get_minLeftOffset() : Float {
		return _minLeftOffset;
	}
	
	private var _maxLeftOffset:Float = 0;
	public var maxLeftOffset(get, set) : Float;
	private function set_maxLeftOffset(v:Float) : Float {
		if (_maxLeftOffset != v) {
			_maxLeftOffset = v;
			
		}
		return get_maxLeftOffset();
	}
	private function get_maxLeftOffset() : Float {
		return _maxLeftOffset;
	}
	
	private var _minRightOffset:Float = 0;
	public var minRightOffset(get, set) : Float;
	private function set_minRightOffset(v:Float) : Float {
		if (_minRightOffset != v) {
			_minRightOffset = v;
			
		}
		return get_minRightOffset();
	}
	private function get_minRightOffset() : Float {
		return _minRightOffset;
	}
	
	private var _maxRightOffset:Float = 0;
	public var maxRightOffset(get, set) : Float;
	private function set_maxRightOffset(v:Float) : Float {
		if (_maxRightOffset != v) {
			_maxRightOffset = v;
			
		}
		return get_maxRightOffset();
	}
	private function get_maxRightOffset() : Float {
		return _maxRightOffset;
	}
	
	public var data:Array<Dynamic>;
	
	private var _items:Array<RockGalleryItemRenderer> = [];
	public var items(get, never) : Array<RockGalleryItemRenderer>;
	private function get_items() : Array<RockGalleryItemRenderer> {
		return _items;
	}
	
	public function new() {
		super();
		this.styleName = DEFAULT_STYLE;
		MenuPanel.current.addEventListener(Event.OPEN, menuPanelOpenHandler);
		MenuPanel.current.addEventListener(Event.CLOSE, menuPanelCloseHandler);
	}
	
	override public function initialize() : Void {
		_plane = new ScrollPlane();
		_plane.styleFactory = _planeStyleFactory;
		addChild(_plane);
		
		_plane.style = {'z-index':10};
		for (i in data) {
			var factory:Function = function() : DisplayObject {
				var item:RockGalleryItemRenderer = new RockGalleryItemRenderer();
				item.data = i;
				_items.push(item);
				var rLayoutParams:RockLayoutParams = new RockLayoutParams();
				rLayoutParams.horizontalRatio = cast i.ratio;
				rLayoutParams.verticalRatio = cast i.ratio;
				item.layoutParams = rLayoutParams;
				return _plane.addItem(item);
			}
			_plane.addDelayedItemFactory(factory);
		}
		
		addEventListener(Event.SCROLLBAR_MINIMIZE, scrollBarMinimizeHandler);
		addEventListener(Event.SCROLLBAR_MAXIMIZE, scrollBarMaximizeHandler);
		
		_filterGroup = new FilterGroup();
		_filterGroup.emitResizeEvents = false;
		_filterGroup.styleFactory = _filterGroupStyleFactory;
		_filterGroup.addEventListener(Event.CHANGE, changeFilterGroupHandler);
		_filterGroup.accessoryItems = App.portfolioFilters;
		addChild(_filterGroup);
		
		super.initialize();
	}
	
	public function excludeAll() : Void {
		if (_plane != null) {
			for (item in _items) {
				if (_plane.contentContains(item))
					_plane.removeItem(item);
			}
		}
	}
	
	public function include(item:RockGalleryItemRenderer) : Void {
		if (_plane != null) _plane.addItem(item);
	}
	
	private function changeFilterGroupHandler(e:Event, data:Dynamic) : Void {
		e.stopImmediatePropagation();
		var tags:Array<String> = cast data;
		if (tags != null) {
			excludeAll();
			for (item in _items) {
				var enabled:Bool = false;
				for (selectedTag in tags) {
					if (item.tags != null && item.tags.indexOf(selectedTag) >= 0) {
						enabled = true;
						break;
					}
				}
				if (enabled) include(item);
			}
		}
	}
	
	private function menuPanelOpenHandler() : Void {
		_filterGroup.leftOffset = _maxLeftOffset;
	}
	
	private function menuPanelCloseHandler() : Void {
		_filterGroup.leftOffset = _minLeftOffset;
	}
	
	private function scrollBarMinimizeHandler(e:Event) : Void {
		_filterGroup.rightOffset = _minRightOffset;
	}
	
	private function scrollBarMaximizeHandler(e:Event) : Void {
		_filterGroup.rightOffset = _maxRightOffset;
	}
	
	private override function transitionOutStart(e:Event) : Void {
		super.transitionOutStart(e);
		if (_plane != null)
			_plane.hideScrollBars();
	}
	
	public override function dispose() : Void {
		_items = null;
		MenuPanel.current.removeEventListener(Event.OPEN, menuPanelOpenHandler);
		MenuPanel.current.removeEventListener(Event.CLOSE, menuPanelCloseHandler);
		removeEventListener(Event.SCROLLBAR_MINIMIZE, scrollBarMinimizeHandler);
		removeEventListener(Event.SCROLLBAR_MAXIMIZE, scrollBarMaximizeHandler);
		if (_filterGroup != null) {
			_filterGroup.removeEventListener(Event.CHANGE, changeFilterGroupHandler);
			_filterGroup.removeFromParent(true);
			_filterGroup = null;
		}
		_planeStyleFactory = null;
		_planeGroupStyleFactory = null;
		while (_planeGroups.length > 0) {
			var item:FlickerControl = _planeGroups.pop();
			item.removeFromParent(true);
			item = null;
		}
		if (_plane != null) {
			_plane.removeFromParent(true);
			_plane = null;
		}
		super.dispose();
	}
}