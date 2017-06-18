package ru.ice.data;

import ru.ice.data.accessories.AccessoryXMLData;
import ru.ice.data.accessories.AccessoryJSONData;
import ru.ice.data.accessories.IAccessoryDataType;
import ru.ice.events.Event;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class AccessoryData 
{
	private var _data:IAccessoryDataType;
	public var data(get, set):IAccessoryDataType;
	private function set_data(v:IAccessoryDataType) : IAccessoryDataType {
		if (_data != v) {
			if (_data != null) {
				_data.removeEventListener(Event.CHANGE, changeHandler);
				_data.removeEventListener(Event.ADDED, addedHandler);
				_data.removeEventListener(Event.REMOVED, removedHandler);
				_data = null;
			}
			_data = v;
			_data.addEventListener(Event.CHANGE, changeHandler);
			_data.addEventListener(Event.ADDED, addedHandler);
			_data.addEventListener(Event.REMOVED, removedHandler);
		}
		return get_data();
	}
	private function get_data():IAccessoryDataType {
		return _data;
	}
	
	private function changeHandler(e:Event) : Void {
		
	}
	
	private function addedHandler(e:Event) : Void {
		
	}
	
	private function removedHandler(e:Event) : Void {
		
	}
	
	public function new(data:Dynamic)
	{
		if (Std.is(data, Xml))
			this.data = new AccessoryXMLData(cast data);
		else {
			try {
				this.data = new AccessoryJSONData(data);
			} catch (msg:String) {
				throw msg;
			}
		}
	}
	
	public function dispose() : Void {
		data = null;
	}
}