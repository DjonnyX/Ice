package ru.ice.app.screens;

import haxe.Json;
import haxe.Constraints.Function;

import ru.ice.controls.ScreenNavigator;

import ru.ice.app.controls.gallery.RockGalleryItemRenderer;
import ru.ice.app.controls.gallery.RockGalleryGroup;
import ru.ice.layout.params.RockLayoutParams;
import ru.ice.controls.super.IceControl;
import ru.ice.display.DisplayObject;
import ru.ice.layout.VerticalLayout;
import ru.ice.animation.Transitions;
import ru.ice.controls.ScrollPlane;
import ru.ice.display.DOMExpress;
import ru.ice.data.ElementData;
import ru.ice.controls.Screen;
import ru.ice.controls.Button;
import ru.ice.controls.Image;
import ru.ice.display.Sprite;
import ru.ice.events.Event;
import ru.ice.data.Loader;
import ru.ice.core.Ice;


/**
 * ...
 * @author Evgenii Grebennikov
 */
class PortfolioGalleryScreen extends Screen
{
	public static inline var DEFAULT_STYLE:String = 'default-portfolio-gallery-screen-style';
	
	private var _plane:ScrollPlane;
	private var _overlay:IceControl;
	private var _planeGroups:Array<IceControl> = [];
	
	private var _planeStyleFactory:Function;
	public var planeStyleFactory(get, set) : Function;
	private function set_planeStyleFactory(v:Function) : Function {
		if (_planeStyleFactory != v) {
			_planeStyleFactory = v;
			if (_plane != null)
				_plane.styleFactory = v;
		}
		return get_planeStyleFactory();
	}
	private function get_planeStyleFactory() : Function {
		return _planeStyleFactory;
	}
	
	private var _planeGroupStyleFactory:Function;
	public var planeGroupStyleFactory(get, set) : Function;
	private function set_planeGroupStyleFactory(v:Function) : Function {
		if (_planeGroupStyleFactory != v) {
			_planeGroupStyleFactory = v;
			if (_planeGroups.length > 0) {
				for (item in _planeGroups) {
					item.styleFactory = v;
				}
			}
		}
		return get_planeGroupStyleFactory();
	}
	private function get_planeGroupStyleFactory() : Function {
		return _planeGroupStyleFactory;
	}
	
	public var data:Array<Dynamic>;
	
	/*private var _data:Array<Dynamic>;
	public var data(get, set) : Dynamic;
	private function set_data(v:Dynamic) : Dynamic {
		if (_data != v)
			_data = v;
		return get_data();
	}
	private function get_data() : Dynamic {
		return _data;
	}*/
	
	public function new() {
		super();
	}
	
	override public function initialize():Void 
	{
		_plane = new ScrollPlane();
		addChild(_plane);
		for (j in data) {
			var factory:Function = function() : DisplayObject {
				var group:RockGalleryGroup = new RockGalleryGroup();
				group.headerData = cast j.header;
				group.galleryData = cast j.gallery;
				return _plane.addItem(group);
			}
			_plane.addToContentDelayedItemFactory(factory);
		}
		/*_overlay = new  IceControl(new ElementData({'name':'ov'}));
		_overlay.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_PARENT);
		_overlay.style = {
			'background-color':'#000000',
			'opacity':.5,
			'zIndex':'9999',
			'interactive':false
		};*/
		
		this.styleName = DEFAULT_STYLE;
		super.initialize();
	}
	
	private override function transitionOutStart(e:Event) : Void {
		super.transitionOutStart(e);
		if (_plane != null)
			_plane.hideScrollBars();
	}
	
	/*private override function updateStyleFactory() : Void {
		if (_planeStyleFactory != null && _plane != null )
			_plane.styleFactory = _planeStyleFactory;
	}*/
	
	public override function dispose() : Void {
		_planeStyleFactory = null;
		_planeGroupStyleFactory = null;
		while (_planeGroups.length > 0) {
			var item:IceControl = _planeGroups.pop();
			item.removeFromParent(true);
			item = null;
		}
		if (_plane != null) {
			_plane.removeFromParent(true);
			_plane = null;
		}
		super.dispose();
	}
}