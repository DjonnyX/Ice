package ru.ice.controls;

import js.Browser;
import ru.ice.controls.super.IceControl.ResizeData;
import ru.ice.controls.ScreenNavigatorItem;
import ru.ice.core.Router.Route;
import ru.ice.data.ElementData;
import ru.ice.events.Event;
import ru.ice.core.Router;

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
		//_navigatorItem.addEventListener(Event.CHANGE_ROUTE, routeChangeHandler);
		_router = new Router(_route, this);
	}
	
	/*private function routeChangeHandler(event:Event, data:Dynamic) : Void {
		routeChange(cast data.address);
	}*/
	
	private function routeChange(address:String) : Void {
		
	}
	
	public override function resize(?data:ResizeData) : Void
	{
		super.resize(data);
	}
	
	public override function dispose() : Void
	{
		super.dispose();
	}
}
