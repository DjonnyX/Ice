package ru.ice.app.screens;

import haxe.Constraints.Function;
import ru.ice.controls.Button;
import ru.ice.events.Event;

import ru.ice.display.DisplayObject;
import ru.ice.controls.Header;

import ru.ice.controls.super.IceControl;
import ru.ice.controls.ScrollPlane;
import ru.ice.data.ElementData;
import ru.ice.controls.Screen;
import ru.ice.app.events.EventTypes;
import ru.ice.app.data.ScreenTypes;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class PortfolioProjectScreen extends Screen
{
	public static inline var DEFAULT_STYLE:String = 'default-portfolio-project-screen-style';
	
	private var _plane:ScrollPlane;
	private var _backButton:Button;
	private var _content:IceControl;
	
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
		//_plane.addEventListener(Event.SCROLL, planeScrollHandler);
		addChild(_plane);
		
		_plane.addDelayedItemFactory(function() : DisplayObject {
			_content = new IceControl();
			_content.styleFactory = _contentStyleFactory;
			_content.innerHTML = data.content;
			return _plane.addItem(_content);
		});
		
		_backButton = new Button();
		_backButton.styleFactory = _backButtonStyleFactory;
		_backButton.addEventListener(Event.TRIGGERED, backButtonTriggeredHandler);
		addChild(_backButton);
		
		styleName = DEFAULT_STYLE;
		super.initialize();
	}
	
	private function backButtonTriggeredHandler(e:Event) : Void {
		this.dispatchEventWith(EventTypes.CHANGE_SCREEN, true, {id:ScreenTypes.PORTFOLIO_GALLERY});
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
			//_plane.removeEventListener(Event.SCROLL, planeScrollHandler);
			_plane.removeFromParent(true);
			_plane = null;
		}
		super.dispose();
	}
}