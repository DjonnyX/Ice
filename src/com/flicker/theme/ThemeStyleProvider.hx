package com.flicker.theme;

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
		_styleFactoryList[cname][name] = func;
	}
	
	public static function getStyleFactoryFor<T>(instance:T, styleName:String) : Function {
		var _class_:Class<T> = Type.getClass(instance);
		var _className_:String = null;
		var factory:Function = getStyleFactoryByName(_className_, styleName);
		while (_class_ != null && factory == null) {
			_className_ = Type.getClassName(_class_);
			_class_ = cast Type.getSuperClass(_class_);
			factory = getStyleFactoryByName(_className_, styleName);
		}
		#if debug
			if (factory == null)
				trace('Style is not defined.', styleName);
		#end
		return factory; 
	}
	
	private static function getStyleFactoryByName(className:String, styleName:String) : Function {
		if (_styleFactoryList[className] == null)
			return null;
		if (!_styleFactoryList[className].exists(styleName))
			return null;
		return _styleFactoryList[className].get(styleName);
	}
}