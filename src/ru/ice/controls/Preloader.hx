package ru.ice.controls;

import haxe.Constraints.Function;
import ru.ice.data.ElementData;

import ru.ice.controls.Image;
import ru.ice.controls.super.IceControl;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Preloader extends IceControl
{
	public static inline var DEFAULT_STYLE:String = 'default-preloader-style';
	
	public var imageStyleFactory(never, set) : Function;
	private function set_imageStyleFactory(v:Function) : Function {
		if (_img != null)
			_img.styleFactory = v;
		return v;
	}
	
	public var imageContainerStyleFactory(never, set) : Function;
	private function set_imageContainerStyleFactory(v:Function) : Function {
		if (_imgContainer != null)
			_imgContainer.styleFactory = v;
		return v;
	}
	
	private var _img:Image;
	
	private var _imgContainer:IceControl;

	public function new() 
	{
		super(new ElementData({
			'name':'prd',
			'interactive':false
		}));
		_imgContainer = new IceControl(new ElementData({
			'name':'c',
			'interactive':false
		}));
		addChild(_imgContainer);
		_img = new Image();
		_imgContainer.addChild(_img);
		styleName = DEFAULT_STYLE;
	}
	
	public override function dispose() : Void {
		super.dispose();
	}
}