package ru.ice.app.controls;

import haxe.Constraints.Function;

import ru.ice.controls.super.IceControl;
import ru.ice.controls.Label;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Article extends IceControl
{
	public static inline var DEFAULT_STYLE:String = 'default-article-style';
	
	private var _caption:Label;
	private var _content:Label;
	
	private var _captionStyleFactory:Function;
	public var captionStyleFactory(get, set) : Function;
	private function set_captionStyleFactory(v:Function) : Function {
		if (_captionStyleFactory != v) {
			_captionStyleFactory = v;
			if (_caption != null)
				_caption.styleFactory = v;
		}
		return get_captionStyleFactory();
	}
	private function get_captionStyleFactory() : Function {
		return _captionStyleFactory;
	}
	
	private var _contentStyleFactory:Function;
	public var contentStyleFactory(get, set) : Function;
	private function set_contentStyleFactory(v:Function) : Function {
		if (_contentStyleFactory != v) {
			_contentStyleFactory = v;
			if (_content != null)
				_content.styleFactory = v;
		}
		return get_contentStyleFactory();
	}
	private function get_contentStyleFactory() : Function {
		return _contentStyleFactory;
	}
	
	public function new() {
		super();
		styleName = DEFAULT_STYLE;
	}
	
	private var _src:Dynamic;
	public var src(get, set) : Dynamic;
	private function get_src() : Dynamic {
		return _src;
	}
	private function set_src(v:Dynamic) : Dynamic {
		if (_src != v) {
			_src = v;
			if (_src) {
				if (_src.caption != null) {
					if (_caption == null)
						createCaption();
					_caption.text = _src.caption;
				} else
					removeCaption();
				
				if (_src.content != null) {
					if (_content == null)
						createContent();
					_content.text = _src.content;
				} else
					removeContent();
			} else {
				removeCaption();
				removeContent();
			}
		}
		return get_src();
	}
	
	private function createCaption() : Void {
		_caption = new Label();
		if (_captionStyleFactory != null)
			_caption.styleFactory = _captionStyleFactory;
		addChild(_caption);
	}
	
	private function createContent() : Void {
		_content = new Label();
		if (_contentStyleFactory != null)
			_content.styleFactory = _contentStyleFactory;
		addChild(_content);
	}
	
	private function removeCaption() : Void {
		if (_caption != null) {
			_caption.removeFromParent(true);
			_caption = null;
		}
	}
	
	private function removeContent() : Void {
		if (_content != null) {
			_content.removeFromParent(true);
			_content = null;
		}
	}
	
	override public function dispose():Void 
	{
		_src = null;
		_captionStyleFactory = null;
		_contentStyleFactory = null;
		removeCaption();
		removeContent();
		super.dispose();
	}
}