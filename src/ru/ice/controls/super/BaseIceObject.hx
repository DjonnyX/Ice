package ru.ice.controls.super;

import haxe.Constraints.Function;

import ru.ice.layout.params.ILayoutParams;
import ru.ice.theme.ThemeStyleProvider;
import ru.ice.animation.IAnimatable;
import ru.ice.display.DisplayObject;
import ru.ice.data.PropertiesProxy;
import ru.ice.events.LayoutEvent;
import ru.ice.data.ElementData;
import ru.ice.math.Rectangle;
import ru.ice.utils.ArrayUtil;
import ru.ice.display.Sprite;
import ru.ice.layout.ILayout;
import ru.ice.display.Stage;
import ru.ice.events.Event;
import ru.ice.core.Ice;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class BaseIceObject extends Sprite
{
	/**
	 * Устанавливает ширину равную ширине контента
	 */
	public static inline var AUTO_SIZE_CONTENT_WIDTH:String = 'autosize-content-width';
	/**
	 * Устанавливает высоту равную высоте контента
	 */
	public static inline var AUTO_SIZE_CONTENT_HEIGHT:String = 'autosize-content-height';
	/**
	 * Устанавливает размеры равные размерам контента
	 */
	public static inline var AUTO_SIZE_CONTENT:String = 'autosize-content';
	/**
	 * Устанавливает размеры равные размерам родителя
	 */
	public static inline var AUTO_SIZE_STAGE:String = 'autosize-stage';
	/**
	 * Не применяет трансформации
	 */
	public static inline var AUTO_SIZE_NONE:String = 'autosize-none';
	/**
	 * Колбэк ресайза
	 */
	public var onResize:Dynamic->Void;
	/**
	 * Объект от которого вызываеся метод initialize
	 * Это сделано для предотвращения применения дефолтовых скинов,
	 * если заданы кастомные стили.
	 */
	public var initializedParent:BaseIceObject;
	
	private var _isInitialized:Bool = false;
	/**
	 * Возвращает true, если инициализация отработала.
	 */
	public var isInitialized(get, never):Bool;
	private function get_isInitialized():Bool {
		if (initializedParent != null)
			return initializedParent.isInitialized;
		return _isInitialized;
	}
	/**
	 * Предыдущий глобальный стиль.
	 */
	private var _lastStyleName:String;
	
	private var _styleName:String;
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
		return get_styleName();
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
		return get_styleFactory();
	}
	
	private function applyStylesIfNeeded() : Void {
		if (_styleFactory != null && _styleFactory != _lastStyleFactory) {
			_styleFactory(this);
			_lastStyleFactory = _styleFactory;
			return;
		}
		if (_styleName != null && _lastStyleName != _styleName) {
			var styleProviderFactory:Function = ThemeStyleProvider.getStyleFactoryFor(this, _styleName);
			if (styleProviderFactory != null) {
				styleProviderFactory(this);
				_lastStyleName = _styleName;
			} else {
				#if debug
					trace('Style is not regitred in the styleProvider.');
				#end
			}
		}
	}
	
	private var _layout:ILayout;
	public var layout(get,set):ILayout;
	private function get_layout() : ILayout {
		return _layout;
	}
	private function set_layout(v:ILayout) : ILayout {
		if (_layout != v) {
			_layout = v;
			_layout.owner = this;
			if (_autosize == AUTO_SIZE_STAGE) {
				if (parent != null)
					resizeToStage();
			} else if (_autosize == AUTO_SIZE_CONTENT) {
				resizeToContent();
			} else if (_autosize == AUTO_SIZE_CONTENT_WIDTH) {
				resizeToContentWidth();
			} else if (_autosize == AUTO_SIZE_CONTENT_HEIGHT) {
				resizeToContentHeight();
			}
		}
		return get_layout();
	}
	
	private var _layoutParams:ILayoutParams;
	public var layoutParams(get,set):ILayoutParams;
	private function get_layoutParams() : ILayoutParams {
		return _layoutParams;
	}
	private function set_layoutParams(v:ILayoutParams) : ILayoutParams {
		if (_layoutParams != v) {
			_layoutParams = v;
			updateLayout();
		}
		return get_layoutParams();
	}
	
	private var _autosize:String = AUTO_SIZE_NONE;
	public var autosize(get, set):String;
	private function get_autosize() : String {
		return _autosize;
	}
	private function set_autosize(v:String) : String {
		if (_autosize != v) {
			_autosize = v;
			if (_autosize == AUTO_SIZE_STAGE) {
				if (parent != null)
					resizeToStage();
			} else if (_autosize == AUTO_SIZE_CONTENT) {
				resizeToContent();
			} else if (_autosize == AUTO_SIZE_CONTENT_WIDTH) {
				resizeToContentWidth();
			} else if (_autosize == AUTO_SIZE_CONTENT_HEIGHT) {
				resizeToContentHeight();
			}
		}
		return get_autosize();
	}
	
	private var _propertiesProxy:PropertiesProxy = new PropertiesProxy();
	
	public function new(?elementData:ElementData, ?initial:Bool = false)
	{
		super(elementData, initial);
		addEventListener(LayoutEvent.INVALIDATE_TRANSFORM, invalidSizeHandler);
	}
	
	private override function addedToStage() : Void {
		if (initializedParent != null) {
			if (initializedParent.isInitialized) {
				if (!_isInitialized) {
					_isInitialized = true;
					initialize();
				}
			}
			super.addedToStage();
			return;
		}
		if (!_isInitialized) {
			_isInitialized = true;
			initialize();
		}
		super.addedToStage();
	}
	
	@:allow(ru.ice.core.Ice, ru.ice.controls)
	private function initialize() : Void {
		applyStylesIfNeeded();
	}
	
	public override function update() : Void
	{
		super.update();
		
		var invalidData:Dynamic = invalidSizeOrPosition();
		if (invalidData == null)
			return;
		dispatchEvent(new LayoutEvent(LayoutEvent.INVALIDATE_TRANSFORM, true, invalidData));
		_propertiesProxy.fromObject(invalidData.targetObject);
	}
	
	private function invalidSizeOrPosition():Dynamic {
		var targetObject:DisplayObject = _autosize == AUTO_SIZE_CONTENT || _autosize == AUTO_SIZE_CONTENT_WIDTH || _autosize == AUTO_SIZE_CONTENT_HEIGHT ? this : _autosize == AUTO_SIZE_STAGE ? parent : null;
		if (targetObject == null)
			return null;
		
		var invalidateWidth:Bool = false;
		var invalidateHeight:Bool = false;
		var invalidateSize:Bool = false;
		var invalidatePosition:Bool = false;
		
		if (_propertiesProxy.isInvalidWidth(targetObject))
			invalidateWidth = true;
		
		if (_propertiesProxy.isInvalidHeight(targetObject))
			invalidateHeight = true;
		
		if (invalidateWidth || invalidateHeight)
			invalidateSize = true;
		
		if (_propertiesProxy.isInvalidPosition(targetObject))
			invalidatePosition = true;
		
		if (invalidatePosition || invalidateSize)
			return {targetObject:targetObject, invalidatePosition:invalidatePosition, invalidateSize:invalidateSize, invalidateWidth:invalidateWidth, invalidateHeight:invalidateHeight, toStage:_autosize == AUTO_SIZE_STAGE};
		
		return null;
	}
	
	private function invalidSizeHandler(e:LayoutEvent, data:Dynamic) : Void
	{
		var isSizeChanged:Bool = false;
		if (e.invalidateSize) {
			if (e.target == this) {
				if (_autosize == AUTO_SIZE_STAGE)
					isSizeChanged = resizeToStage();
			} else
			if (_autosize == AUTO_SIZE_CONTENT) {
				isSizeChanged = resizeToContent();
			} else if (_autosize == AUTO_SIZE_CONTENT_WIDTH) {
				isSizeChanged = resizeToContentWidth();
			} else if (_autosize == AUTO_SIZE_CONTENT_HEIGHT) {
				isSizeChanged = resizeToContentHeight();
			}
		}
		data.isSizeChanged = isSizeChanged;
		resize(data);
		dispatchEventWith(Event.RESIZE, true, data);
	}
	
	public function resize(?data:Dynamic) : Void {
		if (onResize != null)
			onResize(data);
	}
	
	private function resizeToContent() : Bool
	{
		var isSizeChanged:Bool = false;
		var w:Float = width, h:Float = height;
		if (_layout != null) {
			updateLayout();
			isSizeChanged = w != _layout.bound.width || h != _layout.bound.height;
			if (isSizeChanged)
				_propertiesProxy.fromObject(_layout.bound);
		} else {
			var b:Rectangle = bound;
			isSizeChanged = w != b.width || h != b.height;
			if (isSizeChanged) {
				setSize(b.width, b.height);
				_propertiesProxy.fromObject(this);
			}
		}
		return isSizeChanged;
	}
	
	private function resizeToContentWidth() : Bool
	{
		var isSizeChanged:Bool = false;
		var w:Float = width;
		if (_layout != null) {
			updateLayout();
			isSizeChanged = w != _layout.bound.width;
			if (isSizeChanged)
				_propertiesProxy.fromObject(_layout.bound);
		} else {
			var tcw:Float = totalContentWidth;
			isSizeChanged = w != tcw;
			if (isSizeChanged) {
				width = tcw;
				_propertiesProxy.fromObject(this);
			}
		}
		return isSizeChanged;
		//_propertiesProxy.fromObject(this);
	}
	
	private function resizeToContentHeight() : Bool
	{
		var isSizeChanged:Bool = false;
		var h:Float = height;
		if (_layout != null) {
			updateLayout();
			isSizeChanged = h != _layout.bound.height;
			if (isSizeChanged)
				_propertiesProxy.fromObject(_layout.bound);
		} else {
			var tch:Float = totalContentHeight;
			isSizeChanged = h != tch;
			if (isSizeChanged) {
				height = tch;
				_propertiesProxy.fromObject(this);
			}
		}
		return isSizeChanged;
	}
	
	private function resizeToStage() : Bool
	{
		var isSizeChanged:Bool = false;
		var w:Float = width, h:Float = height;
		if (parent != null) {
			var pw:Float = parent.width, ph:Float = parent.height;
			isSizeChanged = w != pw || h != ph;
			if (isSizeChanged) {
				setSize(pw, ph);
				updateLayout();
				_propertiesProxy.fromObject(parent);
			}
		}
		return isSizeChanged;
	}
	
	private function updateLayout() : Void
	{
		if (_layout != null)
			_layout.update();
	}
	
	public override function dispose() : Void
	{
		_lastStyleFactory = null;
		_styleFactory = null;
		onResize = null;
		if (_layout != null) {
			_layout.dispose();
			_layout = null;
		}
		_propertiesProxy = null;
		removeEventListener(LayoutEvent.INVALIDATE_TRANSFORM, invalidSizeHandler);
		super.dispose();
	}
}