package ru.ice.app.controls;

import haxe.Constraints.Function;
import ru.ice.controls.super.BaseListItemControl;
import ru.ice.controls.super.BaseStatesControl;
import ru.ice.data.ElementData;

import ru.ice.controls.super.IceControl;
import ru.ice.controls.TabBar;
import ru.ice.events.Event;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class MenuPanel extends BaseStatesControl
{
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
	
	public function new() {
		super(new ElementData({'name':'mp', 'useTouchableClass':false}));
		_tabBar = new TabBar();
		addChild(_tabBar);
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