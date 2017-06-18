package ru.ice.controls;

import haxe.Constraints.Function;
import ru.ice.events.Event;

import ru.ice.controls.super.BaseStatesControl;
import ru.ice.data.ElementData;
import ru.ice.display.DisplayObject;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class DockScreen extends Screen
{
	public var dockLeftFactory(get, set):Function;
	private var _dockLeftFactory:Function;
	public function get_dockLeftFactory() : Function {
		return _dockLeftFactory;
	}
	public function set_dockLeftFactory(v:Function) : Function {
		if (_dockLeftFactory != v) {
			_dockLeftFactory = v;
		}
		return get_dockLeftFactory();
	}
	
	public var dockRightFactory(get, set):Function;
	private var _dockRightFactory:Function;
	public function get_dockRightFactory() : Function {
		return _dockRightFactory;
	}
	public function set_dockRightFactory(v:Function) : Function {
		if (_dockRightFactory != v) {
			_dockRightFactory = v;
		}
		return get_dockRightFactory();
	}
	
	public var dockTopFactory(get, set):Function;
	private var _dockTopFactory:Function;
	public function get_dockTopFactory() : Function {
		return _dockTopFactory;
	}
	public function set_dockTopFactory(v:Function) : Function {
		if (_dockTopFactory != v) {
			_dockTopFactory = v;
		}
		return get_dockTopFactory();
	}
	
	public var dockBottomFactory(get, set):Function;
	private var _dockBottomFactory:Function;
	public function get_dockBottomFactory() : Function {
		return _dockBottomFactory;
	}
	public function set_dockBottomFactory(v:Function) : Function {
		if (_dockBottomFactory != v) {
			_dockBottomFactory = v;
		}
		return get_dockBottomFactory();
	}
	
	private var _dockLeftContainer:BaseStatesControl;
	private var _dockRightContainer:BaseStatesControl;
	private var _dockTopContainer:BaseStatesControl;
	private var _dockBottomContainer:BaseStatesControl;
	
	/**
	 * Возвращает true, если левый док открыт
	 */
	public var isDockLeftOpened(get, never):Bool;
	private var _isDockLeftOpened:Bool = false;
	public function get_isDockLeftOpened() : Bool {
		return _isDockLeftOpened != null;
	}
	
	/**
	 * Возвращает true, если левый док активен
	 */
	public var dockLeftEnabled(get, never):Bool;
	public function get_dockLeftEnabled() : Bool {
		return _dockLeft != null;
	}
	
	/**
	 * Добавляет объект в левый док
	 */
	public var dockLeft(get, set):DisplayObject;
	private var _dockLeft:DisplayObject;
	public function get_dockLeft() : DisplayObject {
		return _dockLeft;
	}
	public function set_dockLeft(v:DisplayObject) : DisplayObject {
		if (_dockLeft != v) {
			if (v != null) {
				if (_dockLeftContainer == null) {
					_dockLeftContainer = new BaseStatesControl(new ElementData({'name':'dock'}));
					_dockLeftContainer.styleFactory = _dockLeftFactory;
					_dockLeftContainer.addEventListener(Event.TRIGGERED, dockLeftTriggeredHandler);
					_dockLeftContainer.includeInLayout = false;
					super.addChild(_dockLeftContainer);
				} else if (_dockLeft != null) {
					_dockLeft.removeFromParent();
				}
				_dockLeftContainer.addChild(v);
			} else {
				if (_dockLeft != null) {
					_dockLeft.removeFromParent(true);
					_dockLeft = null;
				}
				if (_dockLeftContainer != null) {
					_dockLeftContainer.removeEventListeners();
					_dockLeftContainer.removeFromParent(true);
					_dockLeftContainer = null;
				}
			}
			_dockLeft = v;
		}
		return get_dockLeft();
	}
	
	/**
	 * Меняет состояние левого дока
	 */
	public function dockLeftToggle() : Void {
		_isDockLeftOpened = !_isDockLeftOpened;
		
	}
	
	private function dockLeftTriggeredHandler(e:Event) : Void {
		dockLeftToggle();
	}
	
	/**
	 * Возвращает true, если правый док открыт
	 */
	public var isDockRightOpened(get, never):Bool;
	private var _isDockRightOpened:Bool = false;
	public function get_isDockRightOpened() : Bool {
		return _isDockRightOpened != null;
	}
	
	/**
	 * Возвращает true, если правый док активен
	 */
	public var dockRightEnabled(get, never):Bool;
	public function get_dockRightEnabled() : Bool {
		return _dockRight != null;
	}
	
	/**
	 * Добавляет объект в правый док
	 */
	public var dockRight(get, set):DisplayObject;
	private var _dockRight:DisplayObject;
	public function get_dockRight() : DisplayObject {
		return _dockRight;
	}
	public function set_dockRight(v:DisplayObject) : DisplayObject {
		if (_dockRight != v) {
			if (v != null) {
				if (_dockRightContainer == null) {
					_dockRightContainer = new BaseStatesControl(new ElementData({'name':'dock'}));
					_dockRightContainer.styleFactory = _dockRightFactory;
					_dockRightContainer.addEventListener(Event.TRIGGERED, dockRightTriggeredHandler);
					_dockRightContainer.includeInLayout = false;
					super.addChild(_dockRightContainer);
				} else if (_dockRight != null) {
					_dockRight.removeFromParent();
				}
				_dockRightContainer.addChild(v);
			} else {
				if (_dockRight != null) {
					_dockRight.removeFromParent(true);
					_dockRight = null;
				}
				if (_dockRightContainer != null) {
					_dockRightContainer.removeEventListeners();
					_dockRightContainer.removeFromParent(true);
					_dockRightContainer = null;
				}
			}
			_dockRight = v;
		}
		return get_dockRight();
	}
	
	/**
	 * Меняет состояние правого дока
	 */
	public function dockRightToggle() : Void {
		_isDockRightOpened = !_isDockRightOpened;
	}
	
	private function dockRightTriggeredHandler(e:Event) : Void {
		dockRightToggle();
	}
	
	/**
	 * Возвращает true, если правый док открыт
	 */
	public var isDockTopOpened(get, never):Bool;
	private var _isDockTopOpened:Bool = false;
	public function get_isDockTopOpened() : Bool {
		return _isDockTopOpened != null;
	}
	
	/**
	 * Возвращает true, если верхний док активен
	 */
	public var dockTopEnabled(get, never):Bool;
	public function get_dockTopEnabled() : Bool {
		return _dockTop != null;
	}
	
	/**
	 * Добавляет объект в верхний док
	 */
	public var dockTop(get, set):DisplayObject;
	private var _dockTop:DisplayObject;
	public function get_dockTop() : DisplayObject {
		return _dockTop;
	}
	public function set_dockTop(v:DisplayObject) : DisplayObject {
		if (_dockTop != v) {
			if (v != null) {
				if (_dockTopContainer == null) {
					_dockTopContainer = new BaseStatesControl(new ElementData({'name':'dock'}));
					_dockTopContainer.styleFactory = _dockTopFactory;
					_dockTopContainer.addEventListener(Event.TRIGGERED, dockTopTriggeredHandler);
					_dockTopContainer.includeInLayout = false;
					super.addChild(_dockTopContainer);
				} else if (_dockTop != null) {
					_dockTop.removeFromParent();
				}
				_dockTopContainer.addChild(v);
			} else {
				if (_dockTop != null) {
					_dockTop.removeFromParent(true);
					_dockTop = null;
				}
				if (_dockTopContainer != null) {
					_dockTopContainer.removeEventListeners();
					_dockTopContainer.removeFromParent(true);
					_dockTopContainer = null;
				}
			}
			_dockTop = v;
		}
		return get_dockTop();
	}
	
	/**
	 * Меняет состояние верхнего дока
	 */
	public function dockTopToggle() : Void {
		_isDockTopOpened = !_isDockTopOpened;
	}
	
	private function dockTopTriggeredHandler(e:Event) : Void {
		dockTopToggle();
	}
	
	/**
	 * Возвращает true, если правый док открыт
	 */
	public var isDockBottomOpened(get, never):Bool;
	private var _isDockBottomOpened:Bool = false;
	public function get_isBottomTopOpened() : Bool {
		return _isDockBottomOpened != null;
	}
	
	/**
	 * Возвращает true, если нижний док активен
	 */
	public var dockBottomEnabled(get, never):Bool;
	public function get_dockBottomEnabled() : Bool {
		return _dockBottom != null;
	}
	
	/**
	 * Добавляет объект в нижний док
	 */
	public var dockBottom(get, set):DisplayObject;
	private var _dockBottom:DisplayObject;
	public function get_dockBottom() : DisplayObject {
		return _dockBottom;
	}
	public function set_dockBottom(v:DisplayObject) : DisplayObject {
		if (_dockBottom != v) {
			if (v != null) {
				if (_dockBottomContainer == null) {
					_dockBottomContainer = new BaseStatesControl(new ElementData({'name':'dock'}));
					_dockBottomContainer.styleFactory = _dockBottomFactory;
					_dockBottomContainer.addEventListener(Event.TRIGGERED, dockBottomTriggeredHandler);
					_dockBottomContainer.includeInLayout = false;
					super.addChild(_dockBottomContainer);
				} else if (_dockBottom != null) {
					_dockBottom.removeFromParent();
				}
				_dockBottomContainer.addChild(v);
			} else {
				if (_dockBottom != null) {
					_dockBottom.removeFromParent(true);
					_dockBottom = null;
				}
				if (_dockBottomContainer != null) {
					_dockBottomContainer.removeEventListeners();
					_dockBottomContainer.removeFromParent(true);
					_dockBottomContainer = null;
				}
			}
			_dockBottom = v;
		}
		return get_dockBottom();
	}
	
	/**
	 * Меняет состояние нижнего дока
	 */
	public function dockBottomToggle() : Void {
		_isDockBottomOpened = !_isDockBottomOpened;
	}
	
	private function dockBottomTriggeredHandler(e:Event) : Void {
		dockBottomToggle();
	}
	
	public var dockLength(get, never) : Bool;
	private function get_dockLength() : Bool {
		var length:Int = 0;
		if (dockLeftEnabled)
			length ++;
		if (dockRightEnabled)
			length ++;
		if (dockTopEnabled)
			length ++;
		if (dockBottomEnabled)
			length ++;
		return length;
	}
	
	public var content(get, set):DisplayObject;
	private var _content:DisplayObject;
	public function get_content() : DisplayObject {
		return _content;
	}
	public function set_content(v:DisplayObject) : DisplayObject {
		if (_content != v) {
			if (v != null) {
				if (_contentContainer == null) {
					_contentContainer = new BaseStatesControl(new ElementData({'name':'content'}));
					_contentContainer.addEventListener(Event.TRIGGERED, dockBottomTriggeredHandler);
					_contentContainer.includeInLayout = false;
					super.addChild(_contentContainer);
				} else if (_content != null) {
					_content.removeFromParent();
				}
				_contentContainer.addChild(v);
			} else {
				if (_content != null) {
					_content.removeFromParent(true);
					_content = null;
				}
				if (_contentContainer != null) {
					_contentContainer.removeEventListeners();
					_contentContainer.removeFromParent(true);
					_contentContainer = null;
				}
			}
			_content = v;
		}
		return get_content();
	}
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'dock', 'interactive':false});
		else {
			elementData.name = 'dock';
			elementData.interactive = false;
		}
		super(elementData);
	}
	
	/**
	 * Объект добавляются по низу доков
	 * @param child
	 * @return
	 */
	public override function addChild(child:DisplayObject) : DisplayObject {
		if (child == null) {
			#if debug
				throw "Parameter 'child' must be non null.";
			#end
			return null;
		}
		var index:Int = _children.length - dockLength;
		insertChildAt(child, index);
		child._parent = this;
		element.appendChild(child.element);
		child.addedToStage();
		return child;
	}
	
	public override function dispose() : Void {
		dockLeft = null;
		dockRight = null;
		dockTop = null;
		dockBottom = null;
		content = null;
		_dockLeftFactory = null;
		_dockRightFactory = null;
		_dockTopFactory = null;
		_dockBottomFactory = null;
		super.dispose();
	}
}