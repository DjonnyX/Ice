package ru.ice.controls;

import haxe.Constraints.Function;

import ru.ice.controls.super.IceControl;
import ru.ice.theme.ThemeStyleProvider;
import ru.ice.animation.Delayer;
import ru.ice.display.DisplayObject;
import ru.ice.core.Ice;

/**
 * Предоставляет отложенную инициализацию детей.
 * @author Evgenii Grebennikov
 */
class DelayedBuilder
{
	public static inline var DEFAULT_STYLE:String = 'default-delayed-renderer-style';
	
	public var delay:Float = .1;
	
	private var _isStarted:Bool = false;
	
	private var _delayedCall:Delayer;
	private var _owner:IceControl;
	private var _content:DisplayObject;
	private var _factories:Array<Function> = new Array<Function>();
	
	private var _lastStyleName:String;
	
	private var _styleName:String;
	public var styleName(get, set) : String;
	private function get_styleName() : String {
		return _styleName;
	}
	private function set_styleName(v:String) : String {
		if (_styleName != v) {
			_styleName = v;
			if (_owner.isInitialized)
				applyStylesIfNeeded();
		}
		return get_styleName();
	}
	
	private var _lastStyleFactory : Function;
	
	private var _styleFactory : Function;
	public var styleFactory(never, set) : Function;
	private function set_styleFactory(v:Function) : Function {
		if (_styleFactory != v) {
			_styleFactory = v;
			if (_owner.isInitialized)
				applyStylesIfNeeded();
		}
		return null;
	}
	
	private var _lastpostFactory : Function;
	
	private var _postFactory : Function;
	public var postFactory(get, set) : Function;
	private function set_postFactory(v:Function) : Function {
		if (_postFactory != v)
			_postFactory = v;
		return get_postFactory();
	}
	private function get_postFactory() : Function {
		return _postFactory;
	}
	
	public function new(owner:IceControl, content:IceControl) {
		_owner = owner;
		_content = content;
		styleName = DEFAULT_STYLE;
	}
	
	public function applyStylesIfNeeded() : Void {
		if (_styleFactory != null && _styleFactory != _lastStyleFactory) {
			_styleFactory(this);
			_lastStyleFactory = _styleFactory;
			return;
		}
		if (_lastStyleName != _styleName && _styleName != null) {
			var styleProviderFactory:Function = ThemeStyleProvider.getStyleFactoryFor(this, _styleName);
			if (styleProviderFactory != null) {
				styleProviderFactory(this);
				_lastStyleName = _styleName;
			} else {
				#if debug
					trace('Style is not regitred in the styleProvider.');
				#end
			}
		}
	}
	
	public function add(factory:Function) : Function {
		_factories.push(factory);
		if ((_isStarted && _delayedCall.isComplete) || (_owner.isInitialized && !_isStarted))
			start();
		return factory;
	}
	
	public function remove(factory:Function) : Function {
		var index:Int = _factories.indexOf(factory);
		var f:Function = null;
		if (index > -1) {
			f = _factories[index];
			_factories.slice(index, index + 1);
		}
		return f;
	}
	
	public function removeAll() : Void {
		while (_factories.length > 0) {
			var f:Function = _factories.pop();
			f = null;
		}
	}
	
	public function start() : Void {
		stop();
		if (_factories.length > 0) {
			_isStarted = true;
			if (delay > 0) {
				var factory:Function = _factories.shift();
				if (factory != null) {
					var object:DisplayObject = factory();
					if (_postFactory != null)
						_postFactory(object);
				}
				factory = null;
				_delayedCall = cast Ice.animator.delayCall(start, delay);
			} else {
				createWithoutDelay();
			}
		}
		return;
	}
	
	private function createWithoutDelay() : Void {
		if (_factories.length > 0) {
			while (_factories.length > 0) {
				var factory:Function = _factories.shift();
				if (factory != null) {
					var object:DisplayObject = factory();
					if (_postFactory != null)
						_postFactory(object);
				}
				factory = null;
			}
		}
	}
	
	private function stop() : Void {
		_isStarted = false;
		if (_delayedCall != null) {
			Ice.animator.remove(_delayedCall);
			_delayedCall = null;
		}
	}
	
	public function dispose() : Void {
		stop();
		removeAll();
		_factories = null;
		_postFactory = null;
	}
}