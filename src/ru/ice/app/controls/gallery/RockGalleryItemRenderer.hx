package ru.ice.app.controls.gallery;

import haxe.Constraints.Function;

import ru.ice.app.controls.SimplePreloader;
//import ru.ice.controls.Preloader;
import ru.ice.app.motion.transitionManager.RandomTransitionManager;
import ru.ice.controls.super.IceControl.ResizeData;
import ru.ice.controls.super.BaseStatesControl;
import ru.ice.controls.ScreenNavigatorItem;
import ru.ice.controls.ScreenNavigator;
import ru.ice.app.events.EventTypes;
import ru.ice.animation.Delayer;
import ru.ice.data.ElementData;
import ru.ice.controls.Header;
import ru.ice.controls.Screen;
import ru.ice.controls.Image;
import ru.ice.events.Event;
import ru.ice.core.Ice;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class RockGalleryItemRenderer extends BaseStatesControl
{
	public static inline var DEFAULT_STYLE:String = 'default-rock-gallery-item-renderer-style';
	
	public static inline var STATE_UP:String = 'up';
	public static inline var STATE_DOWN:String = 'down';
	public static inline var STATE_HOVER:String = 'hover';
	public static inline var STATE_SELECT:String = 'select';
	public static inline var STATE_DISABLED:String = 'disabled';
	
	private var _transitionManager:RandomTransitionManager;
	private var _navigator:ScreenNavigator;
	private var _navigatorScreenKeys:Array<String> = [];
	private var _currentScreenIndex:Int = 0;
	private var _delayer:Delayer;
	private var _header:Header;
	
	private var _headerStyleFactory:Function;
	public var headerStyleFactory(get, set) : Function;
	private function set_headerStyleFactory(v:Function) : Function {
		if (_headerStyleFactory != v) {
			_headerStyleFactory = v;
			if (_header != null)
				_header.styleFactory = v;
		}
		return get_headerStyleFactory();
	}
	private function get_headerStyleFactory() : Function {
		return _headerStyleFactory;
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
	
	private var _data:Dynamic;
	public var data(get, set) : Dynamic;
	private function set_data(v:Dynamic) : Dynamic {
		if (_data != v) {
			_data = v;
			if (_data == null) {
				removeNavigator();
				removeHeader();
			} else {
				createNavigator();
				createHeader();
			}
		}
		return get_data();
	}
	private function get_data() : Array<Dynamic> {
		return _data;
	}
	
	private function removeHeader() : Void {
		if (_header != null) {
			_header.removeEventListeners();
			_header.removeFromParent(true);
			_header = null;
		}
	}
	
	private function createHeader() : Void {
		if (_header == null) {
			_header = new Header();
			_header.interactive = false;
			_header.innerHTML = _data.title;
			_header.styleFactory = _headerStyleFactory;
			addChild(_header);
		}
	}
	
	private function removeNavigator() : Void {
		if (_navigator != null) {
			_navigator.removeEventListeners();
			_navigator.removeFromParent(true);
			_navigator = null;
		}
	}
	
	private function createNavigator() : Void {
		if (_navigator == null) {
			_navigator = new ScreenNavigator();
			_navigator.isClipped = true;
			_navigator.styleFactory = _navigatorStyleFactory;
			_navigator.interactive = false;
			addChild(_navigator);
			
			var collection:Array<Dynamic> = cast _data.collection;
			
			var firstId:String = collection.length > 0 ? collection[0].id : null;
			
			for (i in 0...collection.length) {
				var itemData:Dynamic = collection[i];
				var id:String = cast i;
				itemData.id = id;
				itemData.screenName = _data.screenName;
				itemData.interactive = false;
				var screenNavigatorItem:ScreenNavigatorItem = new ScreenNavigatorItem(RockGalleryIRScreen, null, itemData);
				_navigator.addScreen(itemData.id, screenNavigatorItem);
				_navigatorScreenKeys.push(itemData.id);
			}
			
			if (_isInitialized)
				_navigator.initialize();
			
			_transitionManager = new RandomTransitionManager(_navigator);
			
			if (_navigatorScreenKeys.length > 0) {
				var startScreenId:String = cast Math.round(Math.random() * (_navigatorScreenKeys.length - 1));
				_navigator.showScreen( startScreenId );
				_delayer = cast Ice.animator.delayCall(showNext, 5 + Math.random() * 40);
			}
		}
	}
	
	private function triggeredHandler(e:Event) : Void {
		this.dispatchEventWith(EventTypes.CHANGE_SCREEN, true, {id:_data.screenName});
	}
	
	private function showNext() : Void {
		if (_navigator == null)
			return;
		_currentScreenIndex ++;
		if (_currentScreenIndex >= _navigatorScreenKeys.length)
			_currentScreenIndex = 0;
		var nextId:String = _navigatorScreenKeys[_currentScreenIndex];
		_navigator.showScreen(nextId, true, onScreenLoaded);
	}
	
	private function onScreenLoaded(screen:Screen) : Void {
		_delayer = cast Ice.animator.delayCall(showNext, 5 + Math.random() * 40);
	}
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'rock-gallery-ir', 'interactive':true});
		super(elementData);
		
		styleName = DEFAULT_STYLE;
		state = STATE_UP;
		addEventListener(Event.TRIGGERED, triggeredHandler);
	}
	
	public override function resize(?data:ResizeData) : Void {
		if (_header != null) {
			_header.y = height - _header.height;
		}
		super.resize(data);
	}
	
	public override function initialize() : Void {
		super.initialize();
		this.dispatchEventWith(Event.RESIZE, true);
	}
	
	override public function dispose() : Void {
		removeEventListener(Event.TRIGGERED, triggeredHandler);
		if (_transitionManager != null) {
			_transitionManager.dispose();
			_transitionManager = null;
		}
		if (_delayer != null) {
			Ice.animator.remove(_delayer);
			_delayer = null;
		}
		_navigatorStyleFactory = null;
		_headerStyleFactory = null;
		data = null;
		super.dispose();
	}
}

/**
 * ...
 * @author Evgenii Grebennikov
 */
class RockGalleryIRScreen extends Screen
{
	public static inline var DEFAULT_STYLE:String = 'default-rock-gallery-item-renderer-screen-style';
	
	private var _data:Dynamic;
	public var data(get, set):Dynamic;
	private function set_data(v:Dynamic) : Dynamic {
		if (_data != v) {
			_data = v;
			if (_data != null) {
				var imageSrc:String = cast _data.src;
				if (imageSrc != null) {
					_image = new Image();
					_image.addEventListener(Event.LOADED, onLoadImage);
					_image.src = imageSrc;
					_image.styleFactory = _imageStyleFactory;
					addChildAt(_image, 0);
				} else
					removeImage();
			} else
				removeImage();
		}
		return get_data();
	}
	private function get_data() : Dynamic {
		return _data;
	}
	
	private function removeImage() : Void {
		if (_image != null) {
			_image.removeEventListener(Event.LOADED, onLoadImage);
			_image.removeFromParent(true);
			_image = null;
		}
	}
	
	private var _image:Image;
	
	private var _imageStyleFactory:Function;
	public var imageStyleFactory(get, set) : Function;
	private function set_imageStyleFactory(v:Function) : Function {
		if (_imageStyleFactory != v) {
			_imageStyleFactory = v;
			if (_image != null)
				_image.styleFactory = v;
		}
		return get_imageStyleFactory();
	}
	private function get_imageStyleFactory() : Function {
		return _imageStyleFactory;
	}
	
	private var _preloaderStyleFactory:Function;
	public var preloaderStyleFactory(get, set) : Function;
	private function set_preloaderStyleFactory(v:Function) : Function {
		if (_preloaderStyleFactory != v) {
			_preloaderStyleFactory = v;
			if (_preloader != null)
				_preloader.styleFactory = v;
		}
		return get_preloaderStyleFactory();
	}
	private function get_preloaderStyleFactory() : Function {
		return _preloaderStyleFactory;
	}
	
	private var _preloader:SimplePreloader;
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'rock-gallery-ir-sub', 'interactive':false});
		super(elementData);
		styleName = DEFAULT_STYLE;
		showPreloader();
	}
	
	private function showPreloader() : Void {
		_preloader = new SimplePreloader();
		_preloader.includeInLayout = false;
		addChild(_preloader);
	}
	
	private function hidePreloader() : Void {
		removePreloader();
	}
	
	private function removePreloader() : Void {
		if (_preloader != null) {
			_preloader.removeFromParent(true);
			_preloader = null;
		}
		needResize = true;
	}
	
	private function onLoadImage() : Void {
		dispatchEventWith(Event.SCREEN_LOADED, true);
		if (_image != null)
			_image.removeEventListener(Event.LOADED, onLoadImage);
		hidePreloader();
	}
	
	private override function _resizeHandler(event:Event, ?data:Dynamic) : Void {
		_needResize = true;
		super._resizeHandler(event, data);
	}
	
	public override function initialize() : Void {
		super.initialize();
		this.dispatchEventWith(Event.RESIZE, true);
	}
	
	public override function dispose() : Void {
		_preloaderStyleFactory = null;
		removePreloader();
		_data = null;
		removeImage();
		_imageStyleFactory = null;
		super.dispose();
	}
}