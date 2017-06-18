package ru.ice.data.accessories;

import haxe.Json;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class AccessoryJSONData
{
	private var _items:Array<Dynamic>;
	public var items(get, never) : Array<Dynamic>;
	private function setItems(v:Array<Dynamic>) : Array<Dynamic> {
		if (v != null) {
			items = v;
		}
		return get_items();
	}
	private function get_items() : Array<Dynamic> {
		return _items;
	}
	
	public function new(data:Dynamic) 
	{
		if (Std.is(data, String)) {
			setItems(cast Json.parse(cast data));
		} else if (Std.is(data, Array<Dynamic>)) {
			setItems(cast data);
		}
	}
	
	public function dispose() : Void {
		
	}
}