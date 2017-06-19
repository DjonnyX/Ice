package ru.ice.app;

import js.Browser;
import js.html.DOMElement;

import haxe.Constraints.Function;

import ru.ice.motion.transitionManager.TabBarTransitionManager;
import ru.ice.controls.itemRenderer.TabBarItemRenderer;
import ru.ice.controls.ScreenNavigatorItem;
import ru.ice.app.screens.PortfolioScreen;
import ru.ice.controls.super.IceControl;
import ru.ice.app.screens.AboutMeScreen;
import ru.ice.controls.ScreenNavigator;
import ru.ice.app.controls.MenuPanel;
import ru.ice.layout.VerticalLayout;
import ru.ice.app.events.EventTypes;
import ru.ice.app.data.ScreenTypes;
import ru.ice.app.theme.AppTheme;
import ru.ice.data.ElementData;
import ru.ice.controls.Screen;
import ru.ice.controls.TabBar;
import ru.ice.controls.Header;
import ru.ice.utils.MathUtil;
import ru.ice.math.Rectangle;
import ru.ice.events.Event;
import ru.ice.data.Loader;
import ru.ice.core.Ice;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class App extends Screen
{
	public static inline var DEFAULT_STYLE:String = 'app-default-style';
	
	public static var portfolioData:Array<Dynamic>;
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
	
	private var _footerStyleFactory:Function;
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
	}
	
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
	private var _menuStub:IceControl;
	private var _menuPanel:MenuPanel;
	private var _contentContainer:IceControl;
	private var _menuContainer:IceControl;
	private var _footer:Header;
	private var _requestedScreen:String;
	private var _navigator:ScreenNavigator;
	private var _transitionManager:TabBarTransitionManager;
	
	public function new() {
		super(new ElementData({'name':'app', 'isInteractive':false}));
	}
	
	override public function initialize():Void 
	{
		new AppTheme();
		
		var loader:Loader = new Loader('../assets/main.json', {onComplete:function(response:String) : Void {
				mainData = cast haxe.Json.parse(response);
				loadingPortfolio();
			}
		});
		loader.load();
	}
	
	private function loadingPortfolio() : Void {
		var totalLoadingItems:Int = 0;
		var loadedItemsCount:Int = 0;
		var loader:Loader = new Loader('../assets/portfolio.json', {
			onComplete:function(response:String) : Void {
				portfolioData = cast haxe.Json.parse(response);
				for (i in portfolioData) {
					var gallery:Array<Dynamic> = cast i.gallery;
					for (j in gallery) {
						totalLoadingItems ++;
						var description:Dynamic = j.description;
						var contentUrl:String = cast description.contentUrl;
						var loader1:Loader = new Loader('../' + contentUrl, {
							onComplete:function(response1:String) : Void {
								description.content = response1;
								loadedItemsCount ++;
								if (loadedItemsCount == totalLoadingItems)
									onLoadData();
							}
						});
						loader1.load();
					}
				}
				if (loadedItemsCount == totalLoadingItems)
					onLoadData();
			}
		});
		loader.load();
	}
	
	private function onLoadData() : Void {
		addEventListener(EventTypes.CHANGE_SCREEN, changeScreenHandler);
		
		_menuContainer = new IceControl();
		_menuContainer.styleFactory = _menuContainerStyleFactory;
		addChild(_menuContainer);
		
		_footer = new Header();
		_footer.styleFactory = _footerStyleFactory;
		_footer.title = mainData.footer.text;
		addChild(_footer);
		
		_contentContainer = new IceControl();
		_contentContainer.styleFactory = _contentContainerStyleFactory;
		_menuContainer.addChild(_contentContainer);
		
		_menuStub = new IceControl();
		_menuStub.styleFactory = _menuStubStyleFactory;
		
		_menuPanel = new MenuPanel();
		_menuPanel.styleFactory = _menuPanelStyleFactory;
		_menuPanel.accessoryItems = mainData.tabbar.advanced;
		//_menuPanel.addEventListener(Event.CHANGE, changeTabHandler);
		
		_tabBar = new TabBar();
		_tabBar.styleFactory = _tabBarStyleFactory;
		_tabBar.accessoryItems = mainData.tabbar.compact;
		//_tabBar.addEventListener(Event.CHANGE, changeTabHandler);
		
		checkSizeForSwapTabBars();
		
		_navigator = new ScreenNavigator();
		_navigator.styleFactory = _navigatorStyleFactory;
		_navigator.isClipped = true;
		_contentContainer.addChild(_navigator);
		
		var aboutMeScreenItem:ScreenNavigatorItem = new ScreenNavigatorItem(AboutMeScreen);
		aboutMeScreenItem.setScreenIDForEvent(ScreenTypes.PORTFOLIO, ScreenTypes.PORTFOLIO);
		aboutMeScreenItem.setScreenIDForEvent(ScreenTypes.CONTACTS, ScreenTypes.CONTACTS);
		_navigator.addScreen(ScreenTypes.ABOUT_ME, aboutMeScreenItem);
		
		var portfolioScreenItem:ScreenNavigatorItem = new ScreenNavigatorItem(PortfolioScreen);
		portfolioScreenItem.setScreenIDForEvent(ScreenTypes.ABOUT_ME, ScreenTypes.ABOUT_ME);
		portfolioScreenItem.setScreenIDForEvent(ScreenTypes.CONTACTS, ScreenTypes.CONTACTS);
		_navigator.addScreen(ScreenTypes.PORTFOLIO, portfolioScreenItem);
		
		var contactsScreenItem:ScreenNavigatorItem = new ScreenNavigatorItem(PortfolioScreen);
		aboutMeScreenItem.setScreenIDForEvent(ScreenTypes.PORTFOLIO, ScreenTypes.PORTFOLIO);
		portfolioScreenItem.setScreenIDForEvent(ScreenTypes.ABOUT_ME, ScreenTypes.ABOUT_ME);
		_navigator.addScreen(ScreenTypes.CONTACTS, contactsScreenItem);
		
		_transitionManager = new TabBarTransitionManager(_navigator, _tabBar);
		
		styleName = DEFAULT_STYLE;
		super.initialize();
		
		_menuPanel.selectedIndex = 1;
		_tabBar.selectedIndex = 1;
		
		/**
		 * Парсит хэш в массив, где каждый элемент "каталога" является id экрана.
		 * По цепи идет переход на нужный экран.
		 */
		Browser.window.onhashchange = watchHashChanged;
		
		hidePreloader();
	}
	
	private function watchHashChanged() : Void {
		var hash:String = StringTools.replace(Browser.window.location.hash, '#', '');
		var params:Array<String> = parseHash(hash);
		if (params.length > 0) {
			_requestedScreen = params[0];
			var tabIndex:Int = getTabIndexByScreenName(_requestedScreen);
			if (tabIndex > -1)
				_tabBar.selectedIndex = _menuPanel.selectedIndex = tabIndex;
			if (params.length > 1) {
				var screen:Screen = _navigator.activeScreen;
				if (screen != null)
					screen.dispatchEventWith(EventTypes.CHANGE_SUB_SCREEN, false, {id:params[1]});
			}
		}
	}
	
	private function changeScreenHandler(e:Event, ?data:Dynamic) : Void {
		var screenName:String = _navigator.activeScreenName;
		var hash:String = StringTools.replace(Browser.window.location.hash, '#', '');
		var subScreenName:String = cast data.id;
		var requestedHash:String = subScreenName != null && subScreenName != '' ? screenName + '/' + subScreenName : screenName;
		if (hash != requestedHash) {
			Browser.window.location.hash = '#' + requestedHash;
			watchHashChanged();
		}
	}
	
	/**
	 * Парсит хэш в массив(набор) экранов
	 * @param	hash
	 */
	private function parseHash(hash:String) : Array<String> {
		var result:Array<String> = [];
		while (hash.indexOf('/') > -1) {
			var s:String = hash.substring(0, hash.indexOf('/'));
			hash = StringTools.replace(hash, s, '');
			hash = StringTools.replace(hash, '/', '');
			result.push(s);
		}
		result.push(hash);
		return result;
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
	
	private function changeTabHandler(e:Event) : Void {
		var item:TabBarItemRenderer = cast e.target;
		var screenName:String = item.data.screenName;
		var subScreenName:String = '';
		switch(item.index) {
			case 1:
				subScreenName = ScreenTypes.PORTFOLIO_GALLERY;
		}
		var hash:String = StringTools.replace(Browser.window.location.hash, '#', '');
		var requestedHash:String = subScreenName != null && subScreenName != '' ? screenName + '/' + subScreenName : screenName;
		if (requestedHash != hash)
			Browser.window.location.hash = '#' + requestedHash;
		if (_navigator.hasScreen(screenName)) {
			if (_navigator.activeScreenName != screenName)
				_navigator.showScreen(screenName);
		}
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
			Ice.animator.delayCall(function() {
				e.classList.add('hide-preloader');
				e.addEventListener('transitionend', function() {
					e.parentNode.removeChild(e);
					e = null;
				}, false);
			}, 1);
		}
	}
	
	public override function dispose() : Void {
		removeEventListener(EventTypes.CHANGE_SCREEN, changeScreenHandler);
		_footerStyleFactory = null;
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
		if (_footer != null) {
			_footer.removeFromParent(true);
			_footer = null;
		}
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