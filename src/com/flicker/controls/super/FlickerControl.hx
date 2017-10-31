package com.flicker.controls.super;

import haxe.Constraints.Function;
import com.flicker.utils.MathUtil;

import com.flicker.layout.params.ILayoutParams;
import com.flicker.controls.DelayedBuilder;
import com.flicker.theme.ThemeStyleProvider;
import com.flicker.animation.IAnimatable;
import com.flicker.display.DisplayObject;
import com.flicker.data.ElementData;
import com.flicker.layout.BaseLayout;
import com.flicker.math.Rectangle;
import com.flicker.display.Sprite;
import com.flicker.layout.ILayout;
import com.flicker.display.Stage;
import com.flicker.events.Event;
import com.flicker.core.Flicker;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class FlickerControl extends Sprite
{
	public static inline var SNAP_NONE:String = 'snap-none';
	public static inline var SNAP_TO_SELF:String = 'snap-to-self';
	public static inline var SNAP_TO_PARENT:String = 'snap-to-parent';
	public static inline var SNAP_TO_CONTENT:String = 'snap-to-content';
	public static inline var SNAP_TO_HTML_CONTENT:String = 'snap-to-html-content';
	public static inline var SNAP_TO_CUSTOM_OBJECT:String = 'snap-to-custom-object';
	
	private var _snapWidth:Dynamic = SNAP_TO_CONTENT;
	public var snapWidth(get, never) : Dynamic;
	private function get_snapWidth() : Dynamic {
		return _snapWidth;
	}
	
	private var _snapHeight:Dynamic = SNAP_TO_CONTENT;
	public var snapHeight(get, never) : Dynamic;
	private function get_snapHeight() : Dynamic {
		return _snapHeight;
	}
	
	private var _snapWidthObject:DisplayObject;
	private var _snapHeightObject:DisplayObject;
	
	/**
	 * Привязка к объектам.
	 * Применяется на следующей итерации после вызова.
	 */
	public function snapTo(?width:Dynamic, ?height:Dynamic) : Void {
		if (width != null) {
			if (Std.is(width, String)) {
				_snapWidth = width;
			} else if (Std.is(width, DisplayObject)) {
				_snapWidthObject = cast width;
				_snapWidth = SNAP_TO_CUSTOM_OBJECT;
			}
		}
		if (height != null) {
			if (Std.is(height, String)) {
				_snapHeight = height;
			} else if (Std.is(width, DisplayObject)) {
				_snapHeightObject = cast height;
				_snapHeight = SNAP_TO_CUSTOM_OBJECT;
			}
		}
	}
	
	private var _emitResizeEvents:Bool = true;
	public var emitResizeEvents(get, set):Bool;
	private function get_emitResizeEvents() : Bool {
		return _emitResizeEvents;
	}
	private function set_emitResizeEvents(v:Bool) : Bool {
		if (_emitResizeEvents != v) {
			_emitResizeEvents = _includeInLayout ? v : false;
		}
		return _emitResizeEvents;
	}
	/**
	 * Колбэк ресайза
	 */
	public var onResize:ResizeData->Void;
	
	/**
	 * Предыдущий глобальный стиль.
	 */
	private var _lastStyleName:String;
	
	private var _styleName:String;
	
	/**
	 * Убирает/добавляет объект в лэйаута.
	 */
	public var includeInLayout(get, set) : Bool;
	private var _includeInLayout:Bool = true;
	private function get_includeInLayout() : Bool {
		return _includeInLayout;
	}
	private function set_includeInLayout(v:Bool) : Bool {
		if (_includeInLayout != v) {
			_includeInLayout = v;
			if (!v)
				_emitResizeEvents = false;
			dispatchEventWith(v ? Event.INCLUDE_IN_LAYOUT : Event.EXCLUDE_FROM_LAYOUT, true);
		}
		return _includeInLayout;
	}
	/**
	 * Текущий глобальный стиль.
	 */
	public var styleName(get, set) : String;
	private function get_styleName() : String {
		return _styleName;
	}
	private function set_styleName(v:String) : String {
		if (_styleName != v) {
			_styleName = v;
			if (_isInitialized)
				applyStylesIfNeeded();
		}
		return _styleName;
	}
	
	private var _lastStyleFactory:Function;
	private var _styleFactory:Function;
	public var styleFactory(get, set) : Function;
	private function get_styleFactory() : Function {
		return _styleFactory;
	}
	private function set_styleFactory(v:Function) : Function {
		if (_styleFactory != v) {
			_styleFactory = v;
			if (_isInitialized)
				applyStylesIfNeeded();
		}
		return _styleFactory;
	}
	
	private function applyStylesIfNeeded() : Void {
		if (_styleFactory != null) {
			if (_styleFactory != _lastStyleFactory) {
				_styleFactory(this);
				updateStyleFactory();
				_lastStyleFactory = _styleFactory;
			}
		} else
		if (_styleName != null && _lastStyleName != _styleName) {
			var styleProviderFactory:Function = ThemeStyleProvider.getStyleFactoryFor(this, _styleName);
			if (styleProviderFactory != null) {
				styleProviderFactory(this);
				updateStyleFactory();
				_lastStyleName = _styleName;
			} else {
				#if debug
					trace('Style is not regitred in the styleProvider.');
				#end
			}
		}
	}
	
	private function updateStyleFactory() : Void {}
	
	private var _layout:ILayout;
	public var layout(get,set):ILayout;
	private function get_layout() : ILayout {
		return _layout;
	}
	private function set_layout(v:ILayout) : ILayout {
		if (_layout != v) {
			if (v == null) {
				/*for (child in children) {
					var c:IceControl = cast child;
					if (c != null) c.parentHasLayout = false;
				}*/
				if (_layout != null) {
					_layout.removeEventListener(Event.CHANGE_PARAMS, changeLayoutParamsHandler);
					_layout.dispose();
					_layout = null;
				}
			} else {
				/*for (child in children) {
					var c:IceControl = cast child;
					if (c != null) c.parentHasLayout = true;
				}*/
				_layout = v;
				_layout.addEventListener(Event.CHANGE_PARAMS, changeLayoutParamsHandler);
				_layout.owner = this;
				calcLayoutParams();
				if (_isInitialized)
					_layout.update();
			}
		}
		return _layout;
	}
	
	private function changeLayoutParamsHandler(e:Event) : Void {
		e.stopImmediatePropagation();
		calcLayoutParams();
	}
	
	private var _maxWidth:Float = MathUtil.INT_MIN_VALUE;
	public var maxWidth(get, never) : Float;
	private function get_maxWidth() : Float {
		return _maxWidth;
	}
	private var _maxHeight:Float = MathUtil.INT_MIN_VALUE;
	public var maxHeight(get, never) : Float;
	private function get_maxHeight() : Float {
		return _maxHeight;
	}
	
	private function calcLayoutParams() : Void {
		
		_maxWidth = _layout.maxWidth;
		_maxHeight = _layout.maxHeight;
		_paddingLeft = _layout.paddingLeft;
		_paddingRight = _layout.paddingRight;
		_paddingTop = _layout.paddingTop;
		_paddingBottom = _layout.paddingBottom;
		
		_paddingH = _paddingLeft + _paddingRight;
		_paddingV = _paddingTop + _paddingBottom;
		
		_commonPaddingLeft = _layout.commonPaddingLeft;
		_commonPaddingRight = _layout.commonPaddingRight;
		_commonPaddingTop = _layout.commonPaddingTop;
		_commonPaddingBottom = _layout.commonPaddingBottom;
	}
	
	private var _layoutParams:ILayoutParams;
	public var layoutParams(get,set):ILayoutParams;
	private function get_layoutParams() : ILayoutParams {
		return _layoutParams;
	}
	private function set_layoutParams(v:ILayoutParams) : ILayoutParams {
		if (_layoutParams != v) {
			_layoutParams = v;
			if (_layout != null)
				_layoutParams.layout = _layout;
			updateLayout();
		}
		return _layoutParams;
	}
	
	private var _commonPaddingLeft:Float = 0;
	public var commonPaddingLeft(get, never) : Float;
	private function get_commonPaddingLeft() : Float {
		return _commonPaddingLeft;
	}
	
	private var _commonPaddingRight:Float = 0;
	public var commonPaddingRight(get, never) : Float;
	private function get_commonPaddingRight() : Float {
		return _commonPaddingRight;
	}
	
	private var _commonPaddingTop:Float = 0;
	public var commonPaddingTop(get, never) : Float;
	private function get_commonPaddingTop() : Float {
		return _commonPaddingTop;
	}
	
	private var _commonPaddingBottom:Float = 0;
	public var commonPaddingBottom(get, never) : Float;
	private function get_commonPaddingBottom() : Float {
		return _commonPaddingBottom;
	}
	
	private var _paddingH:Float = 0;
	private var _paddingV:Float = 0;
	
	private var _paddingLeft : Float = 0;
	public var paddingLeft(get, never) : Float;
	private function get_paddingLeft() : Float {
		return _paddingLeft;
	}
	
	private var _paddingRight : Float = 0;
	public var paddingRight(get, never) : Float;
	private function get_paddingRight() : Float {
		return _paddingRight;
	}
	
	private var _paddingTop : Float = 0;
	public var paddingTop(get, never) : Float;
	private function get_paddingTop() : Float {
		return _paddingTop;
	}
	
	private var _paddingBottom : Float = 0;
	public var paddingBottom(get, never) : Float;
	private function get_paddingBottom() : Float {
		return _paddingBottom;
	}
	
	private var _isComplexControl:Bool = false;
	public var isComplexControl(get, set):Bool;
	private function set_isComplexControl(v:Bool):Bool {
		if (_isComplexControl != v) {
			_isComplexControl = v;
		}
		return _isComplexControl;
	}
	private function get_isComplexControl():Bool {
		return _isComplexControl;
	}
	
	public var onReposition(get, set):Function;
	private var _onReposition:Function;
	private function set_onReposition(v:Function):Function {
		if (_onReposition != v)
			_onReposition = v;
		return _onReposition;
	}
	private function get_onReposition():Function {
		return _onReposition;
	}
	
	private var _childIsReposition:Bool = false;
	
	private var _needResize:Bool = false;
	public var needResize(get, set):Bool;
	private function set_needResize(v:Bool):Bool {
		if (_needResize != v)
			_needResize = v;
		return _needResize;
	}
	private function get_needResize():Bool {
		return _needResize;
	}
	
	@:allow(com.flicker.layout.BaseLayout)
	private var _propertiesProxy:PropertiesProxy = new PropertiesProxy();
	
	private var _layoutRegion:Rectangle = new Rectangle();
	
	private var _delayedBuilder:DelayedBuilder;
	
	private var _delayedBuilderStyleFactory:Function;
	public var delayedBuilderStyleFactory(never, set) : Function;
	private function set_delayedBuilderStyleFactory(v:Function) : Function {
		if (_delayedBuilderStyleFactory != v) {
			_delayedBuilderStyleFactory = v;
			if (_delayedBuilder != null)
				_delayedBuilder.styleFactory = v;
		}
		return v;
	}
	
	public function new(?elementData:ElementData, ?initial:Bool = false)
	{
		super(elementData, initial);
		snapTo(SNAP_TO_SELF, SNAP_TO_SELF);
		addEventListener(Event.RESIZE, _resizeHandler);
		addEventListener(Event.INCLUDE_IN_LAYOUT, _includeInHandler);
		addEventListener(Event.EXCLUDE_FROM_LAYOUT, _excludeFromHandler);
	}
	
	private function _includeInHandler(e:Event) : Void {
		var d:DisplayObject = cast e.target;
		if (d == this)
			return;
		e.stopImmediatePropagation();
		if (_layout != null)
			_layout.include(d);
	}
	
	private function _excludeFromHandler(e:Event) : Void {
		var d:DisplayObject = cast e.target;
		if (d == this)
			return;
		e.stopImmediatePropagation();
		if (_layout != null)
			_layout.exclude(d);
	}
	
	private function createDelayedBuilder(owner:FlickerControl, content:FlickerControl) : Void {
		_delayedBuilder = new DelayedBuilder(owner, content);
		_delayedBuilder.styleFactory = _delayedBuilderStyleFactory;
		if (_isInitialized) {
			_delayedBuilder.applyStylesIfNeeded();
			_delayedBuilder.start();
		}
	}
	
	private function _resizeHandler(event:Event, ?data:Dynamic) : Void {
		if (!emitResizeEvents)
			event.stopImmediatePropagation();
	}
	
	public override function initialize() : Void {
		if (_delayedBuilder != null) {
			_delayedBuilder.applyStylesIfNeeded();
			_delayedBuilder.start();
		}
		applyStylesIfNeeded();
		super.initialize();
	}
	
	/**
	 * В каждой итерации проверяется изменение размеров и позиции
	 * объекта. Если они менялись, то происходит перестроение лэйаута (если
	 * конечно он в этом нуждается).
	 */
	public override function update(emitResize:Bool = true) : ResizeData
	{
		super.update();
		
		if (!_isInitialized)
			return null;
		
		if (_layout != null) {
			if (_layout.needCalcParams)
				calcLayoutParams();
		}
		
		var invalidData:ResizeData = getInvalidData();
		
		// Если размеры не менялись то при наличии лэйаута, если
		// он нуждается в обновлении, то обновляется.
		if (invalidData == null) {
			if (_layout != null) {
				if (_layout.needResize || !_layoutRegion.compare(_layout.bound)) {
					_layout.update();
					_layoutRegion.copy(_layout.bound);
				}
			}
		} else {
			var tw:DisplayObject = invalidData.targetForSnapWidth;
			var th:DisplayObject = invalidData.targetForSnapHeight;
			
			_tmpWidth = MathUtil.INT_MIN_VALUE; _tmpHeight = MathUtil.INT_MIN_VALUE;
			if (invalidData.invalidateWidth)
				_tmpWidth = invalidData.width;
			if (invalidData.invalidateHeight)
				_tmpHeight = invalidData.height;
			// Апдейт лэйаута.
			if (_layout != null) {
				_layout.update(_tmpWidth, _tmpHeight);
				_layoutRegion.copy(_layout.bound);
			} else {
				if (Math.isFinite(_tmpWidth) && _tmpWidth > MathUtil.INT_MIN_VALUE) width = _tmpWidth;
				if (Math.isFinite(_tmpHeight) && _tmpHeight > MathUtil.INT_MIN_VALUE) height = _tmpHeight;
			}
			_propertiesProxy.setSize(_width, _height);
			
			if (emitResize && emitResizeEvents) {
				resize(invalidData);
				dispatchEventWith(Event.RESIZE, true, invalidData);
			}
			return invalidData;
		}
		return null;
	}
	
	private var _tmpWidth:Float;
	private var _tmpHeight:Float;
	
	/**
	 * Если размеры целевого объекта изменились, то возвращает
	 * объект с параметрами изменения, в противном null.
	 * @return Dynamic
	 */
	private function getInvalidData() : Dynamic
	{
		var targetForSnapWidth:DisplayObject = null;
		if (_snapWidth == SNAP_TO_SELF)
			targetForSnapWidth = this;
		else if (_snapWidth == SNAP_TO_PARENT)
			targetForSnapWidth = parent;
		else if (_snapWidth == SNAP_TO_CUSTOM_OBJECT)
			targetForSnapWidth = _snapWidthObject;
		
		var targetForSnapHeight:DisplayObject = null;
		if (_snapHeight == SNAP_TO_SELF)
			targetForSnapHeight = this;
		else if (_snapHeight == SNAP_TO_PARENT)
			targetForSnapHeight = parent;
		else if (_snapHeight == SNAP_TO_CUSTOM_OBJECT)
			targetForSnapHeight = _snapHeightObject;
		
		var invalidateWidth:Bool = false;
		var invalidateHeight:Bool = false;
		var invalidateSize:Bool = false;
		
		var tw:Float = 0;
		var th:Float = 0;
		
		if (_snapWidth == SNAP_TO_CONTENT) {
			_propertiesProxy.lastWidth = Math.NaN;
			tw = totalContentWidth + _commonPaddingRight;
			if (_propertiesProxy.width != tw)
				invalidateWidth = true;
		} else if (_snapWidth == SNAP_TO_HTML_CONTENT) {
			_propertiesProxy.lastWidth = Math.NaN;
			tw = htmlContentWidth;
			if (_propertiesProxy.width != tw)
				invalidateWidth = true;
		} else {
			if (_snapWidth == SNAP_TO_PARENT) {
				tw = targetForSnapWidth._width;
				if (_maxWidth > MathUtil.INT_MIN_VALUE) {
					if (_propertiesProxy.lastWidth != tw) {
						_propertiesProxy.lastWidth = tw;
						invalidateWidth = true;
						if (tw >= _maxWidth)
							tw = _maxWidth;
					}
				} else
				if (targetForSnapWidth != null && _propertiesProxy.width != tw) {
					_propertiesProxy.lastWidth = Math.NaN;
					invalidateWidth = true;
				}
			} else
			if (targetForSnapWidth != null && _propertiesProxy.width != targetForSnapWidth._width) {
				_propertiesProxy.lastWidth = Math.NaN;
				tw = targetForSnapWidth._width;
				invalidateWidth = true;
			}
		}
		
		if (_snapHeight == SNAP_TO_CONTENT) {
			th = totalContentHeight + _commonPaddingBottom;
			if (_propertiesProxy.height != th)
				invalidateHeight = true;
		} else if (_snapHeight == SNAP_TO_HTML_CONTENT) {
			th = htmlContentHeight;
			if (_propertiesProxy.height != th)
				invalidateHeight = true;
		} else {
			if (_snapHeight == SNAP_TO_PARENT) {
				th = targetForSnapHeight._height;
				if (targetForSnapHeight != null && _propertiesProxy.height != th) invalidateHeight = true;
			} else
			if (targetForSnapHeight != null && _propertiesProxy.height != targetForSnapHeight._height) {
				th = targetForSnapHeight._height;
				invalidateHeight = true;
			}
		}
		
		if (invalidateWidth || invalidateHeight || _needResize) {
			invalidateSize = true;
			_needResize = false;
		}
		if (invalidateSize)
			return (new ResizeData(targetForSnapWidth, targetForSnapHeight, invalidateSize, invalidateWidth, invalidateHeight, tw, th));
		
		return null;
	}
	
	public function resize(?data:ResizeData) : Void {
		if (onResize != null) onResize(data);
	}
	
	/**
	 * Обновляет лэйаут
	 */
	private function updateLayout() : Void
	{
		if (_layout != null && _isInitialized)
			_layout.update();
	}
	
	public function addDelayedItemFactory(factory:Function, ?owner:FlickerControl, ?content:FlickerControl) : Void {
		if (_delayedBuilder == null)
			createDelayedBuilder(owner != null ? owner : this, content != null ? content : this);
		_delayedBuilder.add(factory);
	}
	
	public override function dispose() : Void
	{
		removeEventListener(Event.RESIZE, _resizeHandler);
		removeEventListener(Event.INCLUDE_IN_LAYOUT, _includeInHandler);
		removeEventListener(Event.EXCLUDE_FROM_LAYOUT, _excludeFromHandler);
		_delayedBuilderStyleFactory = null;
		if (_delayedBuilder != null) {
			_delayedBuilder.dispose();
			_delayedBuilder = null;
		}
		_lastStyleFactory = null;
		_styleFactory = null;
		onResize = null;
		if (_layout != null) {
			_layout.removeEventListener(Event.CHANGE_PARAMS, changeLayoutParamsHandler);
			_layout.dispose();
			_layout = null;
		}
		_propertiesProxy = null;
		super.dispose();
	}
}

class ResizeData 
{
	private static var __pool:Array<ResizeData> = new Array<ResizeData>();
	
	private static function fromPool(targetForSnapWidth:DisplayObject, targetForSnapHeight:DisplayObject, invalidateSize:Bool, invalidateWidth:Bool, invalidateHeight:Bool, width:Float, height:Float):ResizeData
    {
		var data:ResizeData = null;
        if (__pool.length != 0) data = __pool.pop().reset(targetForSnapWidth, targetForSnapHeight, invalidateSize, invalidateWidth, invalidateHeight, width, height);
        else {
			data = new ResizeData(targetForSnapWidth, targetForSnapHeight, invalidateSize, invalidateWidth, invalidateHeight, width, height);
			toPool(data);
		}
		return data;
    }
	
    private static function toPool(data:ResizeData):Void
    {
        __pool[__pool.length] = data;
    }
	
	private var _targetForSnapWidth:DisplayObject;
	public var targetForSnapWidth(get, never):DisplayObject;
	public function get_targetForSnapWidth():DisplayObject {
		return _targetForSnapWidth;
	}
	
	private var _targetForSnapHeight:DisplayObject;
	public var targetForSnapHeight(get, never):DisplayObject;
	public function get_targetForSnapHeight():DisplayObject {
		return _targetForSnapHeight;
	}
	
	private var _invalidateSize:Bool;
	public var invalidateSize(get, never):Bool;
	public function get_invalidateSize():Bool {
		return _invalidateSize;
	}
	
	private var _invalidateWidth:Bool;
	public var invalidateWidth(get, never):Bool;
	public function get_invalidateWidth():Bool {
		return _invalidateWidth;
	}
	
	private var _invalidateHeight:Bool;
	public var invalidateHeight(get, never):Bool;
	public function get_invalidateHeight():Bool {
		return _invalidateHeight;
	}
	
	private var _width:Float;
	public var width(get, never):Float;
	public function get_width():Float {
		return _width;
	}
	
	private var _height:Float;
	public var height(get, never):Float;
	public function get_height():Float {
		return _height;
	}
	
	public function new(targetForSnapWidth:DisplayObject, targetForSnapHeight:DisplayObject, invalidateSize:Bool, invalidateWidth:Bool, invalidateHeight:Bool, width:Float, height:Float) {
		reset(targetForSnapWidth, targetForSnapHeight, invalidateSize, invalidateWidth, invalidateHeight, width, height);
	}
	
	public function reset(targetForSnapWidth:DisplayObject, targetForSnapHeight:DisplayObject, invalidateSize:Bool, invalidateWidth:Bool, invalidateHeight:Bool, width:Float, height:Float) : ResizeData {
		_targetForSnapWidth = targetForSnapWidth;
		_targetForSnapHeight = targetForSnapHeight;
		_invalidateSize = invalidateSize;
		_invalidateWidth = invalidateWidth;
		_invalidateHeight = invalidateHeight;
		_width = width;
		_height = height;
		return this;
	}
}

class PropertiesProxy 
{
	public var x:Float = 0;
	public var y:Float = 0;
	public var width:Float = 0;
	public var height:Float = 0;
	public var lastWidth:Float;
	public var lastHeight:Float;
	public var scaleX:Float = 1;
	public var scaleY:Float = 1;
	public var rotate:Float = 0;
	public var requestedWidth:Float = 0;
	public var requestedHeight:Float = 0;
	
	public function new(?d:Any) 
	{
		fromObject(d);
	}
	
	public function fromObject(?d:Any) : PropertiesProxy
	{
		if (d != null) {
			for (prop in Reflect.fields(this))
				Reflect.setField(this, prop, Reflect.getProperty(d, prop));
		}
		return this;
	}
	
	public function isInvalidWidth(?w:Float) : Bool {
		var result:Bool = false;
		if (w != null)
			result = width != w;
		return result;
	}
	
	public function isInvalidHeight(?h:Float) : Bool {
		var result:Bool = false;
		if (h != null)
			result = height != h;
		return result;
	}
	
	public function setSize(w:Float, h:Float) : Void {
		this.width = w;
		this.height = h;
	}
	
	public function setScale(sc:Float, sy:Float) : Void {
		this.scaleX = sc;
		this.scaleY = sy;
	}
}