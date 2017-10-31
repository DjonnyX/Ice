package com.flicker.data;

import haxe.Constraints.Function;
import haxe.Http;

import com.flicker.events.EventDispatcher;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Loader extends EventDispatcher
{
	private var _post:Bool = false;
	private var _http:Http;
	
	public function new(src:String, ?params:Dynamic) 
	{
		super();
		_http = new Http(src);
		_http.async = true;
		if (params != null) {
			for (k in Reflect.fields(params)) {
				var p:Dynamic = Reflect.getProperty(params, k);
				switch (k) {
					case 'header':
					{
						/*var hdr:HttpHeader = cast p;
						if (hdr != null) {
							if (hdr.isValid)
								_http.setHeader(hdr.name, hdr.value);
						}*/
					}
					case 'parameter':
					{
						/*var param:HttpParameter = cast p;
						if (param != null) {
							if (param.isValid)
								_http.setParameter(param.name, param.value);
						}*/
					}
					case 'onComplete':
					{
						var onCompFunc:String->Void = cast p;
						if (onCompFunc != null)
							_http.onData = onCompFunc;
					}
					case 'onError':
					{
						var onErrFunc:String->Void = cast p;
						if (onErrFunc != null)
							_http.onError = onErrFunc;
					}
					case 'onStatus':
					{
						var onStatusFunc:Int->Void = p;
						if (onStatusFunc != null)
							_http.onStatus = onStatusFunc;
					}
				}
			}
		}
	}
	
	public function load(post:Bool = false) : Void {
		_post = post;
		_http.request(post);
	}
	
	public function reload() : Void {
		if (_http != null) {
			_http.cancel();
			_http.request(_post);
		}
	}
	
	public function dispose() : Void
	{
		if (_http != null) {
			_http.cancel();
			_http = null;
		}
	}
}
/*
class HttpParameter {
	
	public var name:String;
	
	public var value:String;
	
	public var isValid(get, never):Bool;
	
	private function get_isValid():Bool {
		return name != null && value != null;
	}
	
	public function new() {}
}

class HttpHeader extends HttpParameter {
	
	public function new() {
		super();
	}
}*/