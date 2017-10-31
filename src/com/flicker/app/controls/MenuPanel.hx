package com.flicker.app.controls;

import haxe.Constraints.Function;
import com.flicker.controls.super.BaseListItemControl;
import com.flicker.controls.super.BaseStatesControl;
import com.flicker.data.ElementData;
import com.flicker.events.FingerEvent;

import com.flicker.controls.super.FlickerControl;
import com.flicker.controls.TabBar;
import com.flicker.events.Event;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class MenuPanel extends BaseStatesControl
{
	private static var _current:MenuPanel;
	public static var current(get, never):MenuPanel;
	private static function get_current() : MenuPanel {
		return _current;
	}
	
	public static inline var DEFAULT_STYLE:String = 'default-menu-panel-style';
	
	private var _requestedSelectedIndex:Int = -1;
	
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
	
	private var _data:Dynamic;
	public var data(get, set):Dynamic;
	private function set_data(v:Dynamic) : Dynamic {
		if (_data != v) {
			_data = v;
			if (v != null)
				accessoryItems = v;
		}
		return get_data();
	}
	private function get_data() : Dynamic {
		return _data;
	}
	
	public var accessoryItems(get, set):Array<Dynamic>;
	private function set_accessoryItems(v:Array<Dynamic>) : Array<Dynamic> {
		if (_tabBar != null)
			_tabBar.accessoryItems = v;
		return get_accessoryItems();
	}
	private function get_accessoryItems() : Array<Dynamic> {
		if (_tabBar == null)
			return null;
		return _tabBar.accessoryItems;
	}
	
	public var selectedIndex(get, set) : Int;
	private function set_selectedIndex(v:Int) : Int {
		_requestedSelectedIndex = v;
		if (_isInitialized) {
			if (_tabBar != null)
				_tabBar.selectedIndex = v;
		}
		return get_selectedIndex();
	}
	private function get_selectedIndex() : Int {
		if (_tabBar == null)
			return -1;
		return _tabBar.selectedIndex;
	}
	
	public var selectedItem(get, set) : BaseListItemControl;
	private function set_selectedItem(v:BaseListItemControl) : BaseListItemControl {
		if (_tabBar != null)
			_tabBar.selectedItem = v;
		return get_selectedItem();
	}
	private function get_selectedItem() : BaseListItemControl {
		if (_tabBar == null)
			return null;
		return _tabBar.selectedItem;
	}
	
	private var _tabBar:TabBar;
	
	override private function set_isHover(v:Bool) : Bool {
		if (_isHover != v) {
			_isHover = v;
			dispatchEventWith(v||_isPress?Event.OPEN:Event.CLOSE);
			updateState();
		}
		return get_isHover();
	}
	
	public function new() {
		super(new ElementData({'useTouchableClass':false}));
		emitResizeEvents = false;
		_tabBar = new TabBar();
		_tabBar.emitResizeEvents = false;
		addChild(_tabBar);
		_current = this;
	}
	
	private override function stageUpHandler(e:FingerEvent) : Void
	{
		super.stageUpHandler(e);
		if (!_isHover) dispatchEventWith(Event.CLOSE, true);
	}
	
	public function hilight(index:Int) : Void {
		_tabBar.hilight(index);
	}
	
	override public function initialize() : Void {
		_tabBar.styleFactory = _tabBarStyleFactory;
		styleName = DEFAULT_STYLE;
		super.initialize();
		_tabBar.selectedIndex = _requestedSelectedIndex;
	}
	
	public override function dispose() : Void {
		_data = null;
		if (_tabBar != null) {
			_tabBar.removeFromParent(true);
			_tabBar = null;
		}
		super.dispose();
	}
}