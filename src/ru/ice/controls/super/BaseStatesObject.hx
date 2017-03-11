package ru.ice.controls.super;

import haxe.Constraints.Function;

import ru.ice.display.DisplayObject;
import ru.ice.events.Event;
import ru.ice.math.Point;
import ru.ice.math.Rectangle;
import ru.ice.controls.super.BaseIceObject;
import ru.ice.controls.super.InteractiveObject;
import ru.ice.events.FingerEvent;
import ru.ice.data.ElementData;
import ru.ice.theme.BaseTheme;
import ru.ice.theme.Theme;
import ru.ice.controls.Label;
import ru.ice.layout.ILayout;
import ru.ice.core.Ice;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class BaseStatesObject extends InteractiveObject
{
	public static inline var STATE_UP:String = 'up';
	public static inline var STATE_DOWN:String = 'down';
	public static inline var STATE_HOVER:String = 'hover';
	public static inline var STATE_DISABLED:String = 'disabled';
	
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
	
	private var _isHover:Bool = false;
	public var isHover(get, set) : Bool;
	private function get_isHover() : Bool {
		return _isHover;
	}
	private function set_isHover(v:Bool) : Bool {
		if (_isHover != v) {
			_isHover = v;
			updateState();
		}
		return get_isHover();
	}
	
	private function updateState() : Void
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
			case STATE_DISABLED: {
				if (_disabledStyleFactory != null)
					_disabledStyleFactory(this);
			}
		}
	}
	
	public function new(?elementData:ElementData, ?initial:Bool = false) 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'statesobject'});
		super(elementData, initial);
		autosize = BaseIceObject.AUTO_SIZE_NONE;
		state = STATE_UP;
		stage.addEventListener(FingerEvent.MOVE, stageMoveHandler);
		stage.addEventListener(FingerEvent.UP, stageUpHandler);
		addEventListener(FingerEvent.DOWN, downHandler);
		addEventListener(FingerEvent.UP, upHandler);
	}
	
	@:allow(ru.ice.core.Ice)
	private override function initialize() : Void {
		updateState();
		super.initialize();
	}
	
	private override function resetState(target:DisplayObject) : Void {
		_isPress = false;
		state = STATE_UP;
		super.resetState(target);
	}
	
	private var _isPress:Bool = false;
	
	private function upHandler(e:FingerEvent) : Void {
		if (e.isMouse && e.key != FingerEvent.KEY_LEFT)
			return;
		state = STATE_UP;
		if (_isPress) {
			_isPress = false;
			dispatchEventWith(Event.TRIGGERED, false);
		}
	}
	
	private function downHandler(e:FingerEvent) : Void {
		if (e.isMouse && e.key != FingerEvent.KEY_LEFT)
			return;
		_isPress = true;
		state = STATE_DOWN;
	}
	
	private function stageMoveHandler(e:FingerEvent) : Void {}
	
	private override function mouseMove(e:FingerEvent) : Void {
		super.mouseMove(e);
		if (e.isMouse && !_isPress) 
			isHover = e.target == this;
	}
	
	private function stageUpHandler(e:FingerEvent) : Void {
		if (e.isMouse && e.key != FingerEvent.KEY_LEFT)
			return;
		_isPress = false;
		state = STATE_UP;
	}
	
	override public function dispose() :Void {
		stage.removeEventListener(FingerEvent.MOVE, stageMoveHandler);
		stage.removeEventListener(FingerEvent.UP, stageUpHandler);
		removeEventListener(FingerEvent.DOWN, downHandler);
		removeEventListener(FingerEvent.UP, upHandler);
		super.dispose();
	}
}