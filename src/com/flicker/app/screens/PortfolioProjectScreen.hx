package com.flicker.app.screens;

import haxe.Constraints.Function;
import com.flicker.controls.Button;
import com.flicker.core.Router;
import com.flicker.events.Event;

import com.flicker.display.DisplayObject;

import com.flicker.controls.super.FlickerControl;
import com.flicker.controls.ScrollPlane;
import com.flicker.data.ElementData;
import com.flicker.controls.Screen;
import com.flicker.app.events.EventTypes;
import com.flicker.app.data.ScreenTypes;
import com.flicker.core.Serializer;
import com.flicker.core.Flicker;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class PortfolioProjectScreen extends Screen
{
	public static inline var DEFAULT_STYLE:String = 'default-portfolio-project-screen-style';
	
	private var _plane:ScrollPlane;
	private var _backButton:Button;
	private var _content:FlickerControl;
	
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
	
	private var _backButtonStyleFactory:Function;
	public var backButtonStyleFactory(get, set) : Function;
	private function set_backButtonStyleFactory(v:Function) : Function {
		if (_backButtonStyleFactory != v) {
			_backButtonStyleFactory = v;
			if (_backButton != null)
				_backButton.styleFactory = v;
		}
		return get_backButtonStyleFactory();
	}
	private function get_backButtonStyleFactory() : Function {
		return _backButtonStyleFactory;
	}
	
	private var _contentStyleFactory:Function;
	public var contentStyleFactory(get, set) : Function;
	private function set_contentStyleFactory(v:Function) : Function {
		if (_contentStyleFactory != v) {
			_contentStyleFactory = v;
			if (_content != null)
				_content.styleFactory = v;
		}
		return get_contentStyleFactory();
	}
	private function get_contentStyleFactory() : Function {
		return _contentStyleFactory;
	}
	
	private var _isHeaderShowed:Bool = false;
	
	public var data:Dynamic;
	
	public function new() 
	{
		super(new ElementData({'name':'Portfolio'}));
	}
	
	public override function initialize() : Void {
		_plane = new ScrollPlane();
		_plane.addEventListener(Event.SCROLL, planeScrollHandler);
		
		
		var str:String = data.content;
		var items:Array<FlickerControl> = Flicker.serializer.serialize(str);
		for (item in items) {
			//_plane.addDelayedItemFactory(function() : DisplayObject {
				/*return */_plane.addItem(item);
			//});
		}
		addChild(_plane);
		
		_backButton = new Button();
		_backButton.styleFactory = _backButtonStyleFactory;
		_backButton.addEventListener(Event.TRIGGERED, backButtonTriggeredHandler);
		addChild(_backButton);
		
		styleName = DEFAULT_STYLE;
		super.initialize();
	}
	
	private function planeScrollHandler(e:Event) : Void {
		//_backButton.visible = _plane.verticalScrollPosition > 0;
	}
	
	private function backButtonTriggeredHandler(e:Event) : Void {
		Router.current.change('#/portfolio/gallery');
	}
	
	public override function dispose() : Void {
		data = null;
		_contentStyleFactory = null;
		_backButtonStyleFactory = null;
		_planeStyleFactory = null;
		if (_backButton != null) {
			_backButton.removeFromParent(true);
			_backButton = null;
		}
		if (_content != null) {
			_content.removeFromParent(true);
			_content = null;
		}
		if (_plane != null) {
			_plane.removeEventListener(Event.SCROLL, planeScrollHandler);
			_plane.removeFromParent(true);
			_plane = null;
		}
		super.dispose();
	}
}