package com.flicker.app;

import js.Browser;
import js.html.DOMElement;
import js.html.Element;
import com.flicker.animation.IAnimatable;
import com.flicker.animation.Transitions;
import com.flicker.controls.FilterGroup;
import com.flicker.controls.HtmlContainer;
import com.flicker.controls.RootScreen;
import com.flicker.core.Router;
import com.flicker.display.DOMExpress;

import haxe.Constraints.Function;

import com.flicker.motion.transitionManager.TransitionManager;
import com.flicker.controls.itemRenderer.TabBarItemRenderer;
import com.flicker.controls.ScreenNavigatorItem;
import com.flicker.app.screens.PortfolioScreen;
import com.flicker.controls.super.FlickerControl;
import com.flicker.app.screens.AboutMeScreen;
import com.flicker.app.screens.ContactsScreen;
import com.flicker.controls.ScreenNavigator;
import com.flicker.app.controls.MenuPanel;
import com.flicker.layout.VerticalLayout;
import com.flicker.app.events.EventTypes;
import com.flicker.app.data.ScreenTypes;
import com.flicker.app.theme.AppTheme;
import com.flicker.data.ElementData;
import com.flicker.controls.Screen;
import com.flicker.controls.TabBar;
import com.flicker.utils.MathUtil;
import com.flicker.math.Rectangle;
import com.flicker.events.Event;
import com.flicker.data.QueueLoader;
import com.flicker.data.Loader;
import com.flicker.core.Flicker;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class App extends RootScreen
{
	public static inline var DEFAULT_STYLE:String = 'app-default-style';
	
	public static var portfolioData:Array<Dynamic>;
	public static var portfolioFilters:Array<{name:String, tag:String, selected:Bool}>;
	public static var aboutMeData:Dynamic;
	public static var mainData:Dynamic;
	
	private var _menuPanelStyleFactory:Function;
	public var menuPanelStyleFactory(get, set) : Function;
	private function set_menuPanelStyleFactory(v:Function) : Function {
		if (_menuPanelStyleFactory != v) {
			_menuPanelStyleFactory = v;
			if (_menuPanel != null)
				_menuPanel.styleFactory = v;
		}
		return get_menuPanelStyleFactory();
	}
	private function get_menuPanelStyleFactory() : Function {
		return _menuPanelStyleFactory;
	}
	
	private var _contentContainerStyleFactory:Function;
	public var contentContainerStyleFactory(get, set) : Function;
	private function set_contentContainerStyleFactory(v:Function) : Function {
		if (_contentContainerStyleFactory != v) {
			_contentContainerStyleFactory = v;
			if (_contentContainer != null)
				_contentContainer.styleFactory = v;
		}
		return get_contentContainerStyleFactory();
	}
	private function get_contentContainerStyleFactory() : Function {
		return _contentContainerStyleFactory;
	}
	
	private var _menuContainerStyleFactory:Function;
	public var menuContainerStyleFactory(get, set) : Function;
	private function set_menuContainerStyleFactory(v:Function) : Function {
		if (_menuContainerStyleFactory != v) {
			_menuContainerStyleFactory = v;
			if (_menuContainer != null)
				_menuContainer.styleFactory = v;
		}
		return get_menuContainerStyleFactory();
	}
	private function get_menuContainerStyleFactory() : Function {
		return _menuContainerStyleFactory;
	}
	
	private var _tabBarStyleFactory:Function;
	public var tabBarStyleFactory(get, set) : Function;
	private function set_tabBarStyleFactory(v:Function) : Function {
		if (_tabBarStyleFactory != v) {
			_tabBarStyleFactory = v;
			if (_tabBar != null)
				_tabBar.styleFactory = v;
		}
		return get_tabBarStyleFactory();
	}
	private function get_tabBarStyleFactory() : Function {
		return _tabBarStyleFactory;
	}
	
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
	
	/*private var _footerStyleFactory:Function;
	public var footerStyleFactory(get, set) : Function;
	private function set_footerStyleFactory(v:Function) : Function {
		if (_footerStyleFactory != v) {
			_footerStyleFactory = v;
			if (_footer != null)
				_footer.styleFactory = v;
		}
		return get_footerStyleFactory();
	}
	private function get_footerStyleFactory() : Function {
		return _footerStyleFactory;
	}*/
	
	private var _menuStubStyleFactory:Function;
	public var menuStubStyleFactory(get, set) : Function;
	private function set_menuStubStyleFactory(v:Function) : Function {
		if (_menuStubStyleFactory != v) {
			_menuStubStyleFactory = v;
			if (_menuStub != null)
				_menuStub.styleFactory = v;
		}
		return get_menuStubStyleFactory();
	}
	private function get_menuStubStyleFactory() : Function {
		return _menuStubStyleFactory;
	}
	
	private var _maxWidthForCompact:Float;
	public var maxWidthForCompact(get, set) : Float;
	private function set_maxWidthForCompact(v:Float) : Float {
		if (_maxWidthForCompact != v)
			_maxWidthForCompact = v;
		return get_maxWidthForCompact();
	}
	private function get_maxWidthForCompact() : Float {
		return _maxWidthForCompact;
	}
	
	private var _tabBar:TabBar;
	private var _menuStub:FlickerControl;
	private var _menuPanel:MenuPanel;
	private var _contentContainer:FlickerControl;
	private var _menuContainer:FlickerControl;
	//private var _footer:HtmlContainer;
	private var _requestedScreen:String;
	private var _navigator:ScreenNavigator;
	private var _transitionManager:TransitionManager;
	
	public function new() {
		super(new ElementData({'name':'portfolio', 'isInteractive':false}));
		Router.defaultLinks([
			{address:'#/portfolio', def:'#/portfolio/gallery'}
		]);
	}
	
	override public function initialize():Void 
	{
		new AppTheme();
		
		var loader:Loader = new Loader('../assets/main.json', {onComplete:function(response:String) : Void {
				mainData = cast haxe.Json.parse(response);
				loadingAboutMe();
			}
		});
		loader.load();
	}
	
	private function loadingAboutMe() : Void {
		var loader:Loader = null;
		loader = new Loader('../assets/aboutme.json', {
			onComplete:function(response:String) : Void {
				aboutMeData = cast haxe.Json.parse(response);
				var queueLoader:QueueLoader = null;
				queueLoader = new QueueLoader({
					onComplete:function() {
						var topUrl:String = cast aboutMeData.topUrl;
						aboutMeData.topContent = queueLoader.getResource(topUrl);
						loadingPortfolio();
						queueLoader.dispose();
						queueLoader = null;
					}
				});
				var t:String = cast Date.now().getTime();
				var topUrl:String = cast aboutMeData.topUrl;
				queueLoader.addResource(topUrl, '../' + topUrl + '?n=' + t);
				queueLoader.load();
				
				loader.dispose();
				loader = null;
			}
		});
		loader.load();
	}
	
	private function loadingPortfolio() : Void {
		var loader:Loader = null;
		loader = new Loader('../assets/portfolio.json', {
			onComplete:function(response:String) : Void {
				portfolioData = cast haxe.Json.parse(response).gallery;
				portfolioFilters = cast haxe.Json.parse(response).filters;
				var queueLoader:QueueLoader = null;
				queueLoader = new QueueLoader({
					onComplete:function() {
						for (i in portfolioData) {
							var description:Dynamic = i.description;
							var contentUrl:String = cast description.contentUrl;
							description.content = queueLoader.getResource(contentUrl);
						}
						Flicker.animator.delayCall(onLoadData, .5);
						queueLoader.dispose();
						queueLoader = null;
					}
				});
				var t:String = cast Date.now().getTime();
				for (i in portfolioData) {
					var description:Dynamic = i.description;
					var contentUrl:String = cast description.contentUrl;
					queueLoader.addResource(contentUrl, '../' + contentUrl + '?n=' + t);
				}
				queueLoader.load();
				
				loader.dispose();
				loader = null;
			}
		});
		loader.load();
	}
	
	private var _isLoadedData:Bool = false;
	
	private function onLoadData() : Void {
		if (_isLoadedData)
			return;
		_isLoadedData = true;
		
		_menuContainer = new FlickerControl();
		_menuContainer.styleFactory = _menuContainerStyleFactory;
		addChild(_menuContainer);
		
		/*_footer = new HtmlContainer();
		_footer.styleFactory = _footerStyleFactory;
		_footer.innerHTML = mainData.footer;
		addChild(_footer);*/
		
		_contentContainer = new FlickerControl();
		_contentContainer.styleFactory = _contentContainerStyleFactory;
		_menuContainer.addChild(_contentContainer);
		
		_menuStub = new FlickerControl();
		_menuStub.styleFactory = _menuStubStyleFactory;
		
		_menuPanel = new MenuPanel();
		_menuPanel.styleFactory = _menuPanelStyleFactory;
		_menuPanel.accessoryItems = mainData.tabbar.advanced;
		_menuPanel.addEventListener(Event.CHANGE, changeTabHandler);
		_menuPanel.addEventListener(Event.OPEN, menuPanelOpenHandler);
		_menuPanel.addEventListener(Event.CLOSE, menuPanelCloseHandler);
		_menuPanel.initialize();
		
		_tabBar = new TabBar();
		_tabBar.styleFactory = _tabBarStyleFactory;
		_tabBar.accessoryItems = mainData.tabbar.compact;
		_tabBar.addEventListener(Event.CHANGE, changeTabHandler);
		_tabBar.initialize();
		
		checkSizeForSwapTabBars();
		
		_navigator = new ScreenNavigator();
		_navigator.addEventListener(Event.CHANGE, changeNavigatorHandler);
		_navigator.styleFactory = _navigatorStyleFactory;
		_navigator.isClipped = true;
		_contentContainer.addChild(_navigator);
		
		var aboutMeScreenItem:ScreenNavigatorItem = new ScreenNavigatorItem(AboutMeScreen, null, {data:aboutMeData}, new Route(this, ScreenTypes.ABOUT_ME));
		aboutMeScreenItem.setScreenIDForEvent(ScreenTypes.PORTFOLIO, ScreenTypes.PORTFOLIO);
		aboutMeScreenItem.setScreenIDForEvent(ScreenTypes.CONTACTS, ScreenTypes.CONTACTS);
		_navigator.addScreen(ScreenTypes.ABOUT_ME, aboutMeScreenItem);
		
		var portfolioScreenItem:ScreenNavigatorItem = new ScreenNavigatorItem(PortfolioScreen, null, null, new Route(this, ScreenTypes.PORTFOLIO));
		portfolioScreenItem.setScreenIDForEvent(ScreenTypes.ABOUT_ME, ScreenTypes.ABOUT_ME);
		portfolioScreenItem.setScreenIDForEvent(ScreenTypes.CONTACTS, ScreenTypes.CONTACTS);
		_navigator.addScreen(ScreenTypes.PORTFOLIO, portfolioScreenItem);
		
		var contactsScreenItem:ScreenNavigatorItem = new ScreenNavigatorItem(ContactsScreen, null, {data:null}, new Route(this, ScreenTypes.CONTACTS));
		aboutMeScreenItem.setScreenIDForEvent(ScreenTypes.PORTFOLIO, ScreenTypes.PORTFOLIO);
		portfolioScreenItem.setScreenIDForEvent(ScreenTypes.ABOUT_ME, ScreenTypes.ABOUT_ME);
		_navigator.addScreen(ScreenTypes.CONTACTS, contactsScreenItem);
		
		_transitionManager = new TransitionManager(_navigator);
		
		styleName = DEFAULT_STYLE;
		
		hidePreloader();
		
		super.initialize();
		
		createWaterMark();
		
		router.start('#/portfolio');
	}
	
	/**
	 * Добавляет "водяной знак"
	 */
	private function createWaterMark() : Void {
		var e:Element = cast DOMExpress.createElement('div');
		var t:Array<Int> = [50, 48, 49, 55, 32, 71, 114, 101, 98, 101, 110, 110, 105, 107, 111, 118, 32, 69, 118, 103, 101, 110, 121];
		var s:String = '';
		while (t.length > 0) {
			s += String.fromCharCode(t[0]);
			t.shift();
		}
		DOMExpress.setStyle(e, {
			'position': 'absolute',
			'color': '#000',
			'fontSize': '12px',
			'fontFamily': 'Roboto Regular',
			'bottom': '20px',
			'right': '30px',
			'pointer-events': 'none'
		});
		e.innerHTML = s;
		_element.appendChild(e);
	}
	
	private function menuPanelOpenHandler() : Void {
		slideNavigator(true);
	}
	
	private function menuPanelCloseHandler() : Void {
		slideNavigator(false);
	}
	
	private var _navigatorTween:IAnimatable;
	
	private function slideNavigator(open:Bool) : Void {
		if (_navigatorTween != null) Flicker.animator.remove(_navigatorTween);
			
		if (open) {
			_navigator.addClass(['fade']);
			_menuPanel.addClass(['focused']);
		} else {
			_navigator.removeClass(['fade']);
			_menuPanel.removeClass(['focused']);
		}
		_navigatorTween = Flicker.animator.tween(_navigator, open ? .32 : .28, {x:open ? 140 : 0, transition:Transitions.EASE_OUT, onComplete:slideNavigatorComplete});
	}
	
	private function slideNavigatorComplete() : Void {
		
	}
	
	private function changeNavigatorHandler(e:Event, data:Dynamic) : Void {
		var screenName:String = cast data.address;
		var index:Int = getTabIndexByScreenName(screenName);
		_tabBar.hilight(index);
		_menuPanel.hilight(index);
	}
	
	private function changeTabHandler(e:Event) : Void {
		var item:TabBarItemRenderer = cast e.target;
		var screenName:String = item.data.screenName;
		router.change('#/' + screenName);
	}
	
	private function getTabIndexByScreenName(name:String) : Int {
		if (name == ScreenTypes.ABOUT_ME)
			return 0;
		if (name == ScreenTypes.PORTFOLIO)
			return 1;
		if (name == ScreenTypes.CONTACTS)
			return 2;
		return -1;
	}
	
	public override function resize(?data:ResizeData) : Void {
		super.resize(data);
		checkSizeForSwapTabBars();
	}
	
	/**
	 * Проверка ширины для определения какую навигацию по меню использовать.
	 * Компактную или расширенную.
	 */
	private function checkSizeForSwapTabBars() : Void {
		if (width > _maxWidthForCompact) {
			if (_contentContainer.contains(_tabBar)) {
				_tabBar.removeEventListener(Event.CHANGE, changeTabHandler);
				_tabBar.includeInLayout = false;
				_tabBar.removeFromParent(false);
			}
			if (!_menuContainer.contains(_menuStub)) {
				_menuStub.includeInLayout = true;
				_menuContainer.addChildAt(_menuStub, 0);
			}
			if (!_menuContainer.contains(_menuPanel)) {
				_menuPanel.addEventListener(Event.CHANGE, changeTabHandler);
				_contentContainer.addChild(_menuPanel);
			}
		} else {
			if (!_contentContainer.contains(_tabBar)) {
				_tabBar.addEventListener(Event.CHANGE, changeTabHandler);
				_tabBar.includeInLayout = true;
				_contentContainer.addChildAt(_tabBar, 0);
			}
			if (_menuContainer.contains(_menuStub)) {
				_menuStub.includeInLayout = false;
				_menuStub.removeFromParent(false);
			}
			if (_menuContainer.contains(_menuPanel)) {
				_menuPanel.removeEventListener(Event.CHANGE, changeTabHandler);
				_menuPanel.removeFromParent(false);
			}
		}
	}
	
	public static function hidePreloader() : Void {
		var e:DOMElement = Browser.document.getElementById('preloader');
		if (e != null) {
			Flicker.animator.delayCall(function() {
				e.classList.add('hide-preloader');
				e.addEventListener('transitionend', function() {
					e.parentNode.removeChild(e);
					e = null;
				}, false);
			}, 1);
		}
	}
	
	public override function dispose() : Void {
		//_footerStyleFactory = null;
		_tabBarStyleFactory = null;
		_menuStubStyleFactory = null;
		_menuPanelStyleFactory = null;
		_navigatorStyleFactory = null;
		_menuContainerStyleFactory = null;
		_contentContainerStyleFactory = null;
		if (_transitionManager != null) {
			_transitionManager.dispose();
			_transitionManager = null;
		}
		if (_menuStub != null) {
			_menuStub.removeFromParent(true);
			_menuStub = null;
		}
		/*if (_footer != null) {
			_footer.removeFromParent(true);
			_footer = null;
		}*/
		if (_navigator != null) {
			_navigator.removeFromParent(true);
			_navigator = null;
		}
		if (_tabBar != null) {
			_tabBar.removeEventListener(Event.CHANGE, changeTabHandler);
			_tabBar.removeFromParent(true);
			_tabBar = null;
		}
		super.dispose();
	}
}