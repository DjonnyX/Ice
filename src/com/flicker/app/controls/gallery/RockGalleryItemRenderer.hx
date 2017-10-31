package com.flicker.app.controls.gallery;

import com.flicker.controls.super.FlickerControl;
import haxe.Constraints.Function;
import com.flicker.animation.IAnimatable;
import com.flicker.animation.Transitions;
import com.flicker.controls.HtmlContainer;
import com.flicker.core.Router;

import com.flicker.controls.SimplePreloader;
//import ru.ice.controls.Preloader;
import com.flicker.app.motion.transitionManager.RandomTransitionManager;
import com.flicker.controls.PreloadedImage;
import com.flicker.controls.super.FlickerControl.ResizeData;
import com.flicker.controls.super.BaseStatesControl;
import com.flicker.controls.ScreenNavigatorItem;
import com.flicker.controls.ScreenNavigator;
import com.flicker.app.events.EventTypes;
import com.flicker.animation.Delayer;
import com.flicker.data.ElementData;
import com.flicker.controls.Screen;
import com.flicker.controls.Image;
import com.flicker.events.Event;
import com.flicker.core.Flicker;

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
	public var navigator(get, never):ScreenNavigator;
	private function get_navigator():ScreenNavigator {
		return _navigator;
	}
	private var _navigatorScreenKeys:Array<String> = [];
	private var _currentScreenIndex:Int = 0;
	private var _delayer:Delayer;
	private var _header:HtmlContainer;
	
	private var _tags:Array<String> = [];
	public var tags(get, never) : Array<String>;
	private function get_tags() : Array<String> {
		return _tags;
	}
	
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
	
	private var _firstUpdated:Bool = false;
	
	private var _firstUpdateFactory:Function;
	public var firstUpdateFactory(get, set) : Function;
	private function set_firstUpdateFactory(v:Function) : Function {
		if (_firstUpdateFactory != v) {
			_firstUpdateFactory = v;
			if (_firstUpdated && _firstUpdateFactory != null)
				_firstUpdateFactory(this);
		}
		return get_firstUpdateFactory();
	}
	private function get_firstUpdateFactory() : Function {
		return _firstUpdateFactory;
	}
	
	override public function update(emitResize:Bool = true):ResizeData 
	{
		var data:ResizeData = super.update(emitResize);
		if (data != null && !_firstUpdated) {
			_firstUpdated = true;
			_firstUpdateFactory(this);
		}
		return data;
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
	
	private override function set_isHover(v:Bool) : Bool {
		if (_isHover != v) {
			_isHover = v;
			updateState();
			hilightContent(v);
		}
		return get_isHover();
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
			_header = new HtmlContainer();
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
			
			_tags = cast _data.tags;
			
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
				_currentScreenIndex = Math.round(Math.random() * (_navigatorScreenKeys.length - 1));
				var startScreenId:String = cast _currentScreenIndex;
				_navigator.showScreen( startScreenId );
				_delayer = cast Flicker.animator.delayCall(showNext, 5 + Math.random() * 5);
			}
		}
	}
	
	private var _navigatorTween:IAnimatable;
	
	private function hilightContent(v:Bool) : Void {
		if (v) {
			if (_navigatorTween != null) {
				Flicker.animator.remove(_navigatorTween);
				_navigatorTween = null;
			}
			_navigatorTween = Flicker.animator.tween(_navigator, 3.45, {scale:1.4, transition: Transitions.EASE_OUT, onComplete:navigatorHilight});
			if (_header != null)
				_header.addClass(['hilight']);
		} else {
			if (_navigatorTween != null) {
				Flicker.animator.remove(_navigatorTween);
				_navigatorTween = null;
			}
			_navigatorTween = Flicker.animator.tween(_navigator, 3.45, {scale:1, transition: Transitions.EASE_OUT, onComplete:navigatorDehilight});
			if (_header != null)
				_header.removeClass(['hilight']);
		}
	}
	
	private function navigatorHilight() : Void {
		_navigator.scale = 1.4;
	}
	
	private function navigatorDehilight() : Void {
		_navigator.scale = 1;
	}
	
	private function triggeredHandler(e:Event) : Void {
		Router.current.change('#/portfolio/'+_data.screenName);
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
		_delayer = cast Flicker.animator.delayCall(showNext, 5 + Math.random() * 5);
	}
	
	public function new(?elementData:ElementData) 
	{
		super();
		isClipped = true;
		styleName = DEFAULT_STYLE;
		state = STATE_UP;
		addEventListener(Event.TRIGGERED, triggeredHandler);
	}
	
	public override function initialize() : Void {
		super.initialize();
		this.dispatchEventWith(Event.RESIZE, true);
	}
	
	override public function dispose() : Void {
		_firstUpdateFactory = null;
		if (_navigatorTween != null) {
			Flicker.animator.remove(_navigatorTween);
			_navigatorTween = null;
		}
		removeEventListener(Event.TRIGGERED, triggeredHandler);
		if (_delayer != null) {
			Flicker.animator.remove(_delayer);
			_delayer = null;
		}
		if (_transitionManager != null) {
			_transitionManager.dispose();
			_transitionManager = null;
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
	
	private var _image:PreloadedImage;
	
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
	
	private var _data:Dynamic;
	public var data(get, set):Dynamic;
	private function set_data(v:Dynamic) : Dynamic {
		if (_data != v) {
			_data = v;
			removeImage();
			if (_data != null) {
				var imageSrc:String = cast _data.src;
				if (imageSrc != null) {
					_image = new PreloadedImage();
					_image.styleFactory = _imageStyleFactory;
					_image.src = imageSrc;
					addChild(_image);
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
			_image.removeFromParent(true);
			_image = null;
		}
	}
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null)
			elementData = new ElementData({'disableInput':true,'interactive':false});
		super(elementData);
		styleName = DEFAULT_STYLE;
	}
	
	public override function dispose() : Void {
		_imageStyleFactory = null;
		data = null;
		super.dispose();
	}
}