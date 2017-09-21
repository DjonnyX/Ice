package ru.ice.controls;

import haxe.Constraints.Function;
import ru.ice.events.Event;

import ru.ice.controls.super.BaseListItemControl;
import ru.ice.controls.super.IceControl;
import ru.ice.display.DisplayObject;
import ru.ice.data.ElementData;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class TabBar extends IceControl
{
	public static inline var DEFAULT_STYLE:String = 'default-tabbar-style';
	
	private var _itemFactory:Function;
	/**
	 * public
	 * Фабрика для элемета(таба)
	 * @return Function
	 */
	public var itemFactory(get, set) : Function;
	private function set_itemFactory(v:Function) : Function {
		if (_itemFactory != v) {
			removeItems();
			_itemFactory = v;
			createItems();
		}
		return get_itemFactory();
	}
	private function get_itemFactory() : Function {
		return _itemFactory;
	}
	
	private var _items:Array<BaseListItemControl>;
	
	private var _accessoryItems:Array<Dynamic>;
	public var accessoryItems(get, set):Array<Dynamic>;
	private function set_accessoryItems(v:Array<Dynamic>) : Array<Dynamic> {
		if (_accessoryItems != v) {
			_accessoryItems = v;
			removeItems();
			createItems();
		}
		return get_accessoryItems();
	}
	private function get_accessoryItems() : Array<Dynamic> {
		return _accessoryItems;
	}
	
	/**
	 * public
	 * get/set
	 * Возвращает/устанавливает текущий выбранный элемент(таб) по индексу
	 * @return Int
	 */
	public var selectedIndex(get, set) : Int;
	private var _selectedIndex:Int = -1;
	private function set_selectedIndex(v:Int) : Int {
		if (_selectedIndex != v) {
			_selectedIndex = v;
			if (_items != null) {
				var index:Int = 0;
				for (item in _items) {
					if (index == _selectedIndex) {
						item.select();
						return get_selectedIndex();
					}
					index ++;
				}
			}
		}
		return get_selectedIndex();
	}
	private function get_selectedIndex() : Int {
		return _selectedIndex;
	}
	
	/**
	 * public
	 * get/set
	 * Возвращает/устанавливает текущий выбранный элемент(таб) 
	 * @return BaseListItemControl
	 */
	private var _selectedItem:BaseListItemControl;
	public var selectedItem(get, set) : BaseListItemControl;
	private function set_selectedItem(v:BaseListItemControl) : BaseListItemControl {
		if (_selectedItem != v) {
			_selectedItem = v;
			if (_items != null) {
				var index:Int = 0;
				for (item in _items) {
					if (item == _selectedItem) {
						item.selected = true;
						_selectedIndex = index;
					} else {
						item.selected = false;
					}
					index ++;
				}
			}
			if (_selectedItem == null)
				_selectedIndex = -1;
			else
				dispatchEventWith(Event.SELECT, true);
		}
		return get_selectedItem();
	}
	private function get_selectedItem() : BaseListItemControl {
		return _selectedItem;
	}
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'tb'});
		else
			elementData.name = 'tabbar';
		super(elementData);
		styleName = DEFAULT_STYLE;
	}
	
	private function removeItems() : Void {
		if (_items != null) {
			while (_items.length > 0) {
				var item:BaseListItemControl = _items.pop();
				item.removeEventListener(Event.CHANGE, itemTriggeredHandler);
				item.removeEventListeners();
				item.removeFromParent(true);
				item = null;
			}
		}
		_items = null;
	}
	
	private function createItems() : Void {
		if (_itemFactory != null && _accessoryItems != null) {
			var index:Int = 0;
			_items = new Array<BaseListItemControl>();
			for (accessoryItem in _accessoryItems) {
				var item:BaseListItemControl = cast _itemFactory(accessoryItem);
				item.index = index;
				item.addEventListener(Event.CHANGE, itemTriggeredHandler);
				addChild(item);
				index ++;
				_items.push(item);
			}
		}
	}
	
	private function itemTriggeredHandler(e:Event, data:Dynamic) : Void {
		var item:BaseListItemControl = cast e.target;
		selectedItem = item;
	}
	
	public override function dispose() : Void {
		removeItems();
		_itemFactory = null;
		_accessoryItems = null;
		super.dispose();
	}
}