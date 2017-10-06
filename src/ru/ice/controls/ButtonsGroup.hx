package ru.ice.controls;

import haxe.Constraints.Function;

import ru.ice.controls.super.BaseListItemControl;
import ru.ice.controls.super.IceControl;
import ru.ice.events.Event;
import ru.ice.display.DisplayObject;
import ru.ice.data.ElementData;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class ButtonsGroup extends IceControl
{
	public static inline var DEFAULT_STYLE:String = 'default-button-group-style';
	
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
	public var selectedIndexes(get, set) : Array<Int>;
	private var _selectedIndexes:Array<Int> = [];
	private function set_selectedIndexes(v:Array<Int>) : Array<Int> {
		if (_selectedIndexes != v) {
			_selectedIndexes = v;
			if (_items != null) {
				var index:Int = 0;
				for (item in _items) {
					if (v.indexOf(index) >= 0)
						item.select();
					else
						item.deselect();
					index ++;
				}
			}
		}
		return get_selectedIndexes();
	}
	private function get_selectedIndexes() : Array<Int> {
		return _selectedIndexes;
	}
	
	public var selectedItems(get, never):Array<BaseListItemControl>;
	private function get_selectedItems() : Array<BaseListItemControl> {
		var result:Array<BaseListItemControl> = [];
		for (ind in _selectedIndexes) {
			var item:BaseListItemControl = _items[ind];
			result.push(item);
		}
		return result;
	}
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'ul'});
		else
			elementData.name = 'ul';
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
		var index:Int = item.index;
		if (_selectedIndexes.length > index) {
			if (item.selected) {
				if (_selectedIndexes.indexOf(item.index) == -1)
					_selectedIndexes.push(item.index);
			} else {
				if (_selectedIndexes.indexOf(item.index) >= 0)
					_selectedIndexes.splice(item.index, 1);
			}
		}
	}
	
	public override function dispose() : Void {
		removeItems();
		_itemFactory = null;
		_accessoryItems = null;
		super.dispose();
	}
}