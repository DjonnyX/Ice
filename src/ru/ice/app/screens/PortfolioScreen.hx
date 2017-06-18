package ru.ice.app.screens;

import haxe.Json;
import haxe.Constraints.Function;
import ru.ice.app.data.ScreenTypes;
import ru.ice.controls.ScreenNavigatorItem;

import ru.ice.controls.ScreenNavigator;

import ru.ice.app.controls.gallery.RockGalleryItemRenderer;
import ru.ice.motion.transitionManager.TransitionManager;
import ru.ice.app.controls.gallery.RockGalleryGroup;
import ru.ice.layout.params.RockLayoutParams;
import ru.ice.controls.super.IceControl;
import ru.ice.app.events.EventTypes;
import ru.ice.display.DisplayObject;
import ru.ice.layout.VerticalLayout;
import ru.ice.animation.Transitions;
import ru.ice.controls.ScrollPlane;
import ru.ice.display.DOMExpress;
import ru.ice.data.ElementData;
import ru.ice.controls.Screen;
import ru.ice.controls.Button;
import ru.ice.controls.Image;
import ru.ice.display.Sprite;
import ru.ice.events.Event;
import ru.ice.data.Loader;
import ru.ice.core.Ice;

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
		super();
		addEventListener(EventTypes.CHANGE_SUB_SCREEN, changeScreenHandler);
	}
	
	private function changeScreenHandler(e:Event, ?data:Dynamic) : Void {
		_requestedScreen = data.id;
		if (_navigator != null)
			_navigator.showScreen(_requestedScreen);
	}
	
	override public function initialize():Void 
	{
		if (App.portfolioModel == null) {
			var loader:Loader = new Loader('../assets/portfolio.json', {onComplete:function(response:String):Void {
					App.portfolioModel = cast haxe.Json.parse(response);
					onLoadData();
					App.hidePreloader();
				}
			});
			loader.load();
		} else
			onLoadData();
		styleName = DEFAULT_STYLE;
		super.initialize();
	}
	
	private function onLoadData() : Void {
		_navigator = new ScreenNavigator();
		_navigator.styleFactory = _navigatorStyleFactory;
		addChild(_navigator);
		
		_transitionManager = new TransitionManager(_navigator);
		_transitionManager.isInvert = true;
		
		var galleryScreenItem:ScreenNavigatorItem = new ScreenNavigatorItem(PortfolioGalleryScreen, null, {data: cast(App.portfolioModel, Array<Dynamic>)});
		_navigator.addScreen(ScreenTypes.PORTFOLIO_GALLERY, galleryScreenItem);
		
		for (i in App.portfolioModel) {
			var gallery:Array<Dynamic> = cast i.gallery;
			for (j in gallery) {
				var screenName:String = cast j.screenName;
				var screenItem:ScreenNavigatorItem = new ScreenNavigatorItem(PortfolioProjectScreen, null, {data:j.description});
				_navigator.addScreen(screenName, screenItem);
			}
		}
		
		if (_requestedScreen != null)
			_navigator.showScreen(_requestedScreen);
		else
			_navigator.showScreen(ScreenTypes.PORTFOLIO_GALLERY);
	}
	
	public override function dispose() : Void {
		removeEventListener(EventTypes.CHANGE_SUB_SCREEN, changeScreenHandler);
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