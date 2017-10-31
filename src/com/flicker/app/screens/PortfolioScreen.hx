package com.flicker.app.screens;

import com.flicker.app.App;
import haxe.Json;
import haxe.Constraints.Function;

import com.flicker.app.data.ScreenTypes;
import com.flicker.controls.ScreenNavigatorItem;
import com.flicker.core.Router;
import com.flicker.core.Router.Route;
import com.flicker.controls.ScreenNavigator;
import com.flicker.app.controls.gallery.RockGalleryItemRenderer;
import com.flicker.motion.transitionManager.TransitionManager;
import com.flicker.layout.params.RockLayoutParams;
import com.flicker.controls.super.FlickerControl;
import com.flicker.app.events.EventTypes;
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
class PortfolioScreen extends Screen
{
	public static inline var DEFAULT_STYLE:String = 'default-portfolio-screen-style';
	
	private var _navigator:ScreenNavigator;
	private var _requestedScreen:String;
	private var _transitionManager:TransitionManager;
	
	private var _navigatorStyleFactory:Function;
	public var navigatorStyleFactory(get, set) : Function;
	private function set_navigatorStyleFactory(v:Function) : Function {
		if (_navigatorStyleFactory != v) {
			_navigatorStyleFactory = v;
			if (_navigator != null)
				_navigator.styleFactory = v;
		}
		return get_navigatorStyleFactory();
	}
	private function get_navigatorStyleFactory() : Function {
		return _navigatorStyleFactory;
	}
	
	public function new() 
	{
		super(new ElementData({'name':'Portfolio'}));
	}
	
	override public function initialize() : Void 
	{
		_navigator = new ScreenNavigator();
		_navigator.name = 'portf';
		_navigator.styleFactory = _navigatorStyleFactory;
		
		_transitionManager = new TransitionManager(_navigator);
		
		var galleryScreenItem:ScreenNavigatorItem = new ScreenNavigatorItem(PortfolioGalleryScreen, null, {data: cast(App.portfolioData, Array<Dynamic>)}, new Route(this, ScreenTypes.PORTFOLIO_GALLERY));
		_navigator.addScreen(ScreenTypes.PORTFOLIO_GALLERY, galleryScreenItem);
		
		for (i in App.portfolioData) {
			var screenName:String = cast i.screenName;
			var route:Route = new Route(this, screenName);
			var screenItem:ScreenNavigatorItem = new ScreenNavigatorItem(PortfolioProjectScreen, null, {data:i.description}, route);
			_navigator.addScreen(screenName, screenItem);
		}
		
		addChild(_navigator);
		
		_navigator.showScreen(_requestedScreen != null ? _requestedScreen : ScreenTypes.PORTFOLIO_GALLERY);
		
		styleName = DEFAULT_STYLE;
		super.initialize();
	}
	
	public override function deactive() : Void {
		if (_navigator != null)
			_navigator.deactive();
	}
	
	public override function dispose() : Void {
		_navigatorStyleFactory = null;
		if (_transitionManager != null) {
			_transitionManager.dispose();
			_transitionManager = null;
		}
		if (_navigator != null) {
			_navigator.removeFromParent(true);
			_navigator = null;
		}
		super.dispose();
	}
}