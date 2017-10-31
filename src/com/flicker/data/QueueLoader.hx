package com.flicker.data;

import haxe.Constraints.Function;
import com.flicker.events.EventDispatcher;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class QueueLoader extends EventDispatcher
{
	private var _dictionary:Dynamic = {};
	
	private var _contents:Array<Dynamic> = [];
	
	private var _resources:Array<Dynamic> = [];
	
	private var _onComplete:Function;
	
	private var _loader:Loader;
	
	public function new(?params:Dynamic) 
	{
		super();
		if (params != null) {
			for (k in Reflect.fields(params)) {
				var p:Dynamic = Reflect.getProperty(params, k);
				switch (k) {
					case 'onComplete': {
						_onComplete = cast p;
					}
				}
			}
		}
	}
	
	public function getResource(id:String) : Dynamic {
		return Reflect.getProperty(_dictionary, id);
	}
	
	public function addResource(id:String, resource:String) : Void {
		_resources.push({id:id, resource:resource});
	}
	
	public function load() : Void {
		next();
	}
	
	private function next() : Void {
		if (_resources.length == 0) {
			if (_onComplete != null)
				_onComplete();
		} else {
			var res:Dynamic = _resources[0];
			_resources.splice(0, 1);
			removeLoader();
			_loader = new Loader(res.resource, {'onComplete':function(data:String) : Void {
					_contents.push({id:res.id, url:res.resource, content:data});
					Reflect.setField(_dictionary, res.id, data);
					next();
				}
			});
			_loader.load();
		}
	}
	
	private function removeLoader() : Void {
		if (_loader != null) {
			_loader.dispose();
			_loader = null;
		}
	}
	
	public function dispose() : Void
	{
		removeLoader();
		_resources = null;
	}
}