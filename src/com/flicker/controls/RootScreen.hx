package com.flicker.controls;

import com.flicker.controls.super.FlickerControl;
import js.Browser;
import com.flicker.controls.super.FlickerControl.ResizeData;
import com.flicker.controls.ScreenNavigatorItem;
import com.flicker.core.Router.Route;
import com.flicker.data.ElementData;
import com.flicker.events.Event;
import com.flicker.core.Router;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class RootScreen extends Screen
{
	private var _route:Route;
	private var _navigatorItem:ScreenNavigatorItem;
	
	private var _router:Router;
	public var router(get, never) : Router;
	private function get_router() : Router {
		return _router;
	}
	
	public static inline var DEFAULT_STYLE:String = Screen.DEFAULT_STYLE;
	
	public function new(?elementData:ElementData) 
	{
		super(elementData);
		Browser.window.onreset = function(e:Dynamic) {
			e.stopImmediatePropagation();
		}
		_route = new Route(this, "#");
		_navigatorItem = new ScreenNavigatorItem(null, null, null, _route);
		_navigatorItem.id = '#';
		_router = new Router(_route, this);
	}
	
	public override function initialize() : Void {
		Router.isInitialized = true;
		super.initialize();
	}
	
	private function routeChange(address:String) : Void { }
	
	public override function resize(?data:ResizeData) : Void
	{
		super.resize(data);
	}
	
	public override function dispose() : Void
	{
		super.dispose();
	}
}
