package ru.ice.controls.super;

import haxe.Constraints.Function;
import ru.ice.display.Stage;

import ru.ice.controls.super.InteractiveControl;
import ru.ice.controls.super.IceControl;
import ru.ice.display.DisplayObject;
import ru.ice.events.FingerEvent;
import ru.ice.data.ElementData;
import ru.ice.theme.BaseTheme;
import ru.ice.math.Rectangle;
import ru.ice.controls.Label;
import ru.ice.layout.ILayout;
import ru.ice.events.Event;
import ru.ice.theme.Theme;
import ru.ice.math.Point;
import ru.ice.core.Ice;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class BaseStatesControl extends InteractiveControl
{
	public static inline var STATE_UP:String = 'up';
	public static inline var STATE_DOWN:String = 'down';
	public static inline var STATE_HOVER:String = 'hover';
	public static inline var STATE_SELECT:String = 'select';
	public static inline var STATE_DISABLED:String = 'disabled';
	
	private var _allowDeselect:Bool = false;
	public var allowDeselect(get, set) : Bool;
	private function get_allowDeselect() : Bool {
		return _allowDeselect;
	}
	private function set_allowDeselect(v:Bool) : Bool {
		if (_allowDeselect != v)
			_allowDeselect = v;
		return get_allowDeselect();
	}
	
	private var _isToggle:Bool = false;
	public var isToggle(get, set) : Bool;
	private function get_isToggle() : Bool {
		return _isToggle;
	}
	private function set_isToggle(v:Bool) : Bool {
		if (_isToggle != v)
			_isToggle = v;
		return get_isToggle();
	}
	
	private var _isSelect:Bool = false;
	public var isSelect(get, set) : Bool;
	private function get_isSelect() : Bool {
		return _isSelect;
	}
	private function set_isSelect(v:Bool) : Bool {
		if (_isSelect != v)
			_isSelect = v;
		return get_isSelect();
	}
	
	private var _upStyleFactory:Function;
	public var upStyleFactory(get, set) : Function;
	private function get_upStyleFactory() : Function {
		return _upStyleFactory;
	}
	private function set_upStyleFactory(v:Function) : Function {
		if (_upStyleFactory != v)
			_upStyleFactory = v;
			if (_style != v)
				updateState();
		return get_upStyleFactory();
	}
	
	private var _downStyleFactory:Function;
	public var downStyleFactory(get, set) : Function;
	private function get_downStyleFactory() : Function {
		return _downStyleFactory;
	}
	private function set_downStyleFactory(v:Function) : Function {
		if (_downStyleFactory != v)
			_downStyleFactory = v;
			if (_style != v)
				updateState();
		return get_downStyleFactory();
	}
	
	private var _hoverStyleFactory:Function;
	public var hoverStyleFactory(get, set) : Function;
	private function get_hoverStyleFactory() : Function {
		return _hoverStyleFactory;
	}
	private function set_hoverStyleFactory(v:Function) : Function {
		if (_hoverStyleFactory != v)
			_hoverStyleFactory = v;
			if (_style != v)
				updateState();
		return get_hoverStyleFactory();
	}
	
	private var _selectStyleFactory:Function;
	public var selectStyleFactory(get, set) : Function;
	private function get_selectStyleFactory() : Function {
		return _selectStyleFactory;
	}
	private function set_selectStyleFactory(v:Function) : Function {
		if (_selectStyleFactory != v)
			_selectStyleFactory = v;
			if (_style != v)
				updateState();
		return get_selectStyleFactory();
	}
	
	private var _disabledStyleFactory:Function;
	public var disabledStyleFactory(get, set) : Function;
	private function get_disabledStyleFactory() : Function {
		return _disabledStyleFactory;
	}
	private function set_disabledStyleFactory(v:Function) : Function {
		if (_disabledStyleFactory != v)
			_disabledStyleFactory = v;
			if (_style != v)
				updateState();
		return get_disabledStyleFactory();
	}
	
	private var _state:String;
	public var state(get, set) : String;
	private function get_state() : String {
		return _state;
	}
	private function set_state(v:String) : String {
		if (_state != v) {
			_state = v;
			if (_isInitialized)
				updateState();
		}
		return get_state();
	}
	
	private var _lastState:String;
	
	private override function set_isHover(v:Bool) : Bool {
		if (_isHover != v) {
			_isHover = v;
			updateState();
		}
		return get_isHover();
	}
	
	private var _useTouchableClass:Bool = true;
	
	public function updateState() : Void
	{
		switch(_state) {
			case STATE_UP: {
				if(_isHover && !Ice.isDragging) {
					if (_hoverStyleFactory != null)
						_hoverStyleFactory(this);
				} else {
					if (_upStyleFactory != null)
						_upStyleFactory(this);
				}
			}
			case STATE_DOWN: {
				if (_downStyleFactory != null)
					_downStyleFactory(this);
			}
			case STATE_SELECT: {
				if (_selectStyleFactory != null)
					_selectStyleFactory(this);
			}
			case STATE_DISABLED: {
				if (_disabledStyleFactory != null)
					_disabledStyleFactory(this);
			}
		}
	}
	
	public function new(?elementData:ElementData, ?initial:Bool = false, ?useTouchableClass:Bool = true)
	{
		_useTouchableClass = useTouchableClass;
		if (elementData == null)
			elementData = new ElementData({'name':'so'});
		super(elementData, initial);
		state = STATE_UP;
		stage.addEventListener(FingerEvent.UP, stageUpHandler);
		addEventListener(FingerEvent.DOWN, downHandler);
		addEventListener(FingerEvent.UP, upHandler);
		if (_useTouchableClass)
			addClass(['i-touchable']);
		addEventListener(Event.HOVER, hoverHandler);
	}
	
	private function hoverHandler(e:Event, ?data:Dynamic) : Void {
		data.objects.push(this);
	}
	
	public override function initialize() : Void {
		super.initialize();
		updateState();
	}
	
	private override function resetState(target:DisplayObject) : Void {
		if (_useTouchableClass)
			removeClass(['i-touchable']);
		_isPress = false;
		_isSelect = false;
		state = STATE_UP;
		super.resetState(target);
	}
	
	private var _isPress:Bool = false;
	
	private function upHandler(e:FingerEvent) : Void {
		if (_useTouchableClass)
			addClass(['i-touchable']);
		stage.removeEventListener(FingerEvent.MOVE, stageMoveHandler);
		if (e.isMouse && e.key != FingerEvent.KEY_LEFT)
			return;
		if (_isPress) {
			_isPress = false;
			if (_isToggle)
				_isSelect = !_isSelect;
			state = _isSelect ? STATE_SELECT : STATE_UP;
			dispatchEventWith(Event.TRIGGERED, true);
		} else
			state = STATE_UP;
	}
	
	private function downHandler(e:FingerEvent) : Void {
		stage.addEventListener(FingerEvent.MOVE, stageMoveHandler);
		if (e.isMouse && e.key != FingerEvent.KEY_LEFT)
			return;
		Ice.globalPressed = true;
		_isPress = true;
		state = STATE_DOWN;
	}
	
	private function stageMoveHandler(e:FingerEvent) : Void {}
	
	private function stageUpHandler(e:FingerEvent) : Void {
		stage.removeEventListener(FingerEvent.MOVE, stageMoveHandler);
		if (e.isMouse && e.key != FingerEvent.KEY_LEFT)
			return;
		Ice.globalPressed = false;
		_isPress = false;
		state = _isSelect ? STATE_SELECT : STATE_UP;
	}
	
	override public function dispose() :Void {
		stage.removeEventListener(FingerEvent.MOVE, stageMoveHandler);
		stage.removeEventListener(FingerEvent.UP, stageUpHandler);
		removeEventListener(FingerEvent.DOWN, downHandler);
		removeEventListener(FingerEvent.UP, upHandler);
		removeEventListener(Event.HOVER, hoverHandler);
		super.dispose();
	}
}