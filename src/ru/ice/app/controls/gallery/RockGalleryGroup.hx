package ru.ice.app.controls.gallery;

import haxe.Constraints.Function;

import ru.ice.layout.params.RockLayoutParams;
import ru.ice.controls.super.IceControl;
import ru.ice.display.DisplayObject;
import ru.ice.data.ElementData;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class RockGalleryGroup extends IceControl
{
	public static inline var DEFAULT_STYLE:String = 'default-rock-gallery-group-style';
	
	private var _galleryContainer:IceControl;
	private var _headerContainer:IceControl;
	
	private var _galleryDBFactory:Function;
	private var _headerDBFactory:Function;
	
	private var _headerStyleFactory:Function;
	public var headerStyleFactory(get, set) : Function;
	private function set_headerStyleFactory(v:Function) : Function {
		if (_headerStyleFactory != v) {
			_headerStyleFactory = v;
			if (_headerContainer != null)
				_headerContainer.styleFactory = v;
		}
		return get_headerStyleFactory();
	}
	private function get_headerStyleFactory() : Function {
		return _headerStyleFactory;
	}
	
	private var _galleryStyleFactory:Function;
	public var galleryStyleFactory(get, set) : Function;
	private function set_galleryStyleFactory(v:Function) : Function {
		if (_galleryStyleFactory != v) {
			_galleryStyleFactory = v;
			if (_galleryContainer != null)
				_galleryContainer.styleFactory = v;
		}
		return get_galleryStyleFactory();
	}
	private function get_galleryStyleFactory() : Function {
		return _galleryStyleFactory;
	}
	
	private var _galleryData:Array<Dynamic>;
	public var galleryData(get, set) : Array<Dynamic>;
	private function set_galleryData(v:Array<Dynamic>) : Array<Dynamic> {
		if (_galleryData != v) {
			_galleryData = v;
			removeGalleryContainer();
			_galleryDBFactory = function() : DisplayObject {
				_galleryContainer = new IceControl(new ElementData({'name':'container', 'interactive':false}));
				_galleryContainer.styleFactory = _galleryStyleFactory;
				for (i in  _galleryData) {
					var factory:Function = function() : DisplayObject {
						var item:RockGalleryItemRenderer = new RockGalleryItemRenderer();
						item.data = i;
						var rLayoutParams:RockLayoutParams = new RockLayoutParams();
						var r:Float = Math.random() * 10;
						rLayoutParams.horizontalRatio = cast i.ratio;// r < 7 ? r < 3 ? 1 : 2 : 4;
						rLayoutParams.verticalRatio = cast i.ratio;//r < 7 ? r < 3 ? 1 : 2 : 4;
						item.layoutParams = rLayoutParams;
						return _galleryContainer.addChild(item);
					}
					_galleryContainer.addDelayedItemFactory(factory);
				}
				return addChild(_galleryContainer);
			}
			addDelayedItemFactory(_galleryDBFactory);
		}
		return get_galleryData();
	}
	private function get_galleryData() : Array<Dynamic> {
		return _galleryData;
	}
	
	private var _headerData:Dynamic;
	public var headerData(get, set) : Dynamic;
	private function set_headerData(v:Dynamic) : Dynamic {
		if (_headerData != v) {
			_headerData = v;
			removeHeaderContainer();
			_headerDBFactory = function() : DisplayObject {
				_headerContainer = new IceControl(new ElementData({'name':'div', 'interactive':false}));
				_headerContainer.styleFactory = _headerStyleFactory;
				_headerContainer.innerHTML = _headerData;
				return addChild(_headerContainer);
			}
			addDelayedItemFactory(_headerDBFactory);
		}
		return get_headerData();
	}
	private function get_headerData() : Dynamic {
		return _headerData;
	}
	
	public function new(?elementData:ElementData)
	{
		if (elementData == null)
			elementData = new ElementData({'name':'rg-group'});
		super(elementData);
		styleName = DEFAULT_STYLE;
	}
	
	private function removeGalleryContainer() : Void {
		if (_galleryDBFactory != null) {
			_delayedBuilder.remove(_galleryDBFactory);
			_galleryDBFactory = null;
		}
		if (_galleryContainer != null) {
			_galleryContainer.removeFromParent(true);
			_galleryContainer = null;
		}
	}
	
	private function removeHeaderContainer() : Void {
		if (_headerDBFactory != null) {
			_delayedBuilder.remove(_headerDBFactory);
			_headerDBFactory = null;
		}
		if (_headerContainer != null) {
			_headerContainer.removeFromParent(true);
			_headerContainer = null;
		}
	}
	
	public override function dispose() : Void {
		removeGalleryContainer();
		removeHeaderContainer();
		super.dispose();
	}
}