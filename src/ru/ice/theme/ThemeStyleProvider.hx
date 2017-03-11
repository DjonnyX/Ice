package ru.ice.theme;

import haxe.Constraints.Function;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class ThemeStyleProvider 
{
	private static var _styleFactoryList:Map<String, Map<String, Function>> = new Map<String, Map<String, Function>>();
	
	public static function setStyleFactory<T>(type:T, name:String, func:Function) : Void {
		var cname:String = Type.getClassName(cast type);
		if (_styleFactoryList[cname] == null)
			_styleFactoryList[cname] = new Map<String, Function>();
		var subMap:Map<String, Function> = _styleFactoryList[cname];
		subMap.set(name, func);
	}
	
	public static function getStyleFactoryFor<T>(instance:T, name:String) : Function {
		var cname:String = Type.getClassName(Type.getClass(instance));
		if (_styleFactoryList[cname] == null) {
			#if debug
				trace('Style is not defined.');
			#end
			return null;
		}
		if (!_styleFactoryList[cname].exists(name)) {
			#if debug
				trace('Style is not defined.');
			#end
			return null;
		}
		return _styleFactoryList[cname].get(name);
	}
}