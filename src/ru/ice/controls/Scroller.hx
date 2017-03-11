package ru.ice.controls;

import js.html.ButtonElement;
import js.html.Element;
import js.html.TouchEvent;
import ru.ice.controls.super.BaseStatesObject;

import haxe.Constraints.Function;

import ru.ice.animation.IAnimatable;
import ru.ice.animation.Tween;
import ru.ice.animation.Transitions;
import ru.ice.controls.DelayedRenderer;
import ru.ice.core.Ice;
import ru.ice.controls.super.InteractiveObject;
import ru.ice.controls.super.BaseIceObject;
import ru.ice.data.ElementData;
import ru.ice.events.Event;
import ru.ice.events.FingerEvent;
import ru.ice.events.WheelScrollEvent;
import ru.ice.display.DisplayObject;
import ru.ice.math.Point;
import ru.ice.math.Rectangle;
import ru.ice.utils.FloatUtil;
import ru.ice.layout.ILayout;
import ru.ice.utils.ArrayUtil;
import ru.ice.utils.DomUtils;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Scroller extends BaseStatesObject
{
	public static inline var DEFAULT_SCROLLER_STYLE : String = 'default-scroller-style';
	
	private static inline var MAX_ACTION_BOUND_SIZE:Int = 20;
	
	private static inline var MAX_WHEEL_ZERO_OPERATIONS:Int = 40;
	
	private static inline var WEHEEL_ICING:Float = .2;
	
	public static inline var WHEEL_SCROLL_RATIO:Float = .5;
	
	/**
	 * Вес одного пикселя холста
	 */
	private static inline var CANVAS_PIXEL_WEIGHT:Float = 1;
	
	/**
	 * Упругость "пружины". Сталь 78500 МПа
	 */
	private static inline var SPRING_STRENGTH:Float = 78500;
	
	/**
	 * Масса "холста"
	 */
	private static inline var SPRING_WEIGHT:Float = 1100000;
	
	/**
	 * Нелинейный коэффициент упругости пружины
	 */
	private static inline var SPRING_TENSION:Float = 1.432;
	
	public static inline var DURATION_POWER:Float = 1000;
	
	public static inline var MAXIMUM_VELOCITY_ITERATIONS:Float = 4;
	
	public static inline var MINIMUM_VELOCITY:Float = .02;
	
	public static inline var CURRENT_VELOCITY_WEIGHT:Float = 2.33;
	
	public static var VELOCITY_WEIGHTS:Array<Float> = [1, 1.33, 1.66, 2];
	
	private static function defaultThrowEase(ratio:Float):Float
	{
		ratio -= 1;
		return 1 - ratio * ratio * ratio * ratio;
	}
	
	private function _easeOutBack(ratio:Float):Float
    {
        var invRatio:Float = ratio - 1;            
        var s:Float = 0.45;
        return Math.pow(invRatio, 2) * ((s + 1) * invRatio + s) + 1;
    }
	
	private var _throwEase:Float->Float = defaultThrowEase;
	
	private var _wheelZero:Int = 0;
	
	private var _lastWheelTime:Float = 0;
	
	private var _logDecelerationRate:Float = -0.0024;
	
	private var _ppmsScale:Float = 5.16;
	
	private var _content:BaseIceObject;
	
	private var _forelayer:BaseIceObject;
	
	private var _snapToPages:Bool = false;
	public var snapToPages(get, set):Bool;
	private function get_snapToPages():Bool{
		return _snapToPages;
	}
	private function set_snapToPages(v:Bool):Bool {
		_snapToPages = v;
		return get_snapToPages();
	}
	
	public var maxScrollX:Float = 0;
	
	public var maxScrollY:Float = 0;
	
	/**
	 * Анимация по оси X.
	 */
	@:noPrivateAccess
	private var _xTween:IAnimatable;
	
	/**
	 * Анимация по оси Y.
	 */
	@:noPrivateAccess
	private var _yTween:IAnimatable;
	
	/**
	 * Начальная точка касания в глобальных координатах.
	 */
	@:noPrivateAccess
	private var _startTP:Point = new Point();
	
	/**
	 * Текущая точка касания в глобальных координатах.
	 */
	@:noPrivateAccess
	private var _curTP:Point = new Point();
	
	/**
	 * Предыдущая точка касания в глобальных координатах.
	 */
	@:noPrivateAccess
	private var _prevTP:Point = new Point();
	
	/**
	 * Начальная точка касания в локальных координатах.
	 */
	@:noPrivateAccess
	private var _locStartTP:Point = new Point();
	
	/**
	 * Текущая точка касания в глобальных координатах.
	 */
	@:noPrivateAccess
	private var _locCurTP:Point = new Point();
	/**
	 * Начальная позиция контента.
	 */
	@:noPrivateAccess
	private var _startPos:Point = new Point();
	
	/**
	 * Область вьюпорта
	 */
	private var _viewportBound:Rectangle = new Rectangle();
	
	/**
	 * Сдвиг вьюпорта с учетом "эластичности"
	 */
	private var _viewportOffset:Point = new Point();
	
	/**
	 * Для вычисления времени и пути
	 */
	private var _viewportAbsOffset:Point = new Point();
	
	private var _isDraggingHorizontally:Bool = true;
	
	private var _isDraggingVertically:Bool = true;
	
	private var _isDragging:Bool = false;
	
	/**
	 * Скорость холста по оси X
	 */
	private var _velocityX:Float = 0;
	/**
	 * Скорость холста по оси Y
	 */
	private var _velocityY:Float = 0;
	
	/**
	 * Скорости холста по оси Y
	 */
	private var _scopeVelocityX:Array<Float> = new Array<Float>();
	
	/**
	 * Скорости холста по оси Y
	 */
	private var _scopeVelocityY:Array<Float> = new Array<Float>();
	
	/**
	 * Время предыдущего касания
	 */
	@:noPrivateAccess
	private var _prevTouchTime:Float = 0;
	
	public var horizontalScrollPosition(get, set) : Float;
	private function get_horizontalScrollPosition() : Float {
		return maxScrollX == 0 ? 0 : _content.x / maxScrollX;
	}
	private function set_horizontalScrollPosition(v:Float) : Float {
		if (horizontalScrollPosition != v) {
			clearAnimations();
			_content.x = maxScrollX * v;
		}
		return get_horizontalScrollPosition();
	}
	
	public var verticalScrollPosition(get, set) : Float;
	private function get_verticalScrollPosition() : Float {
		return maxScrollY == 0 ? 0 : _content.y / maxScrollY;
	}
	private function set_verticalScrollPosition(v:Float) : Float {
		if (verticalScrollPosition != v) {
			clearAnimations();
			_content.y = maxScrollY * v;
		}
		return get_verticalScrollPosition();
	}
	
	private var _delayedRenderer:DelayedRenderer;
	
	public var delayedRendererStyleFactory(never, set) : Function;
	private function set_delayedRendererStyleFactory(v:Function) : Function {
		_delayedRenderer.styleFactory = v;
		return v;
	}
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null) {
			elementData = new ElementData(
			{
				'name':'scroller',
				'style':{'overflow': 'hidden'}
			});
		} else
			elementData.setStyle({'overflow': 'hidden'});
		
		super(elementData);
		autosize = BaseIceObject.AUTO_SIZE_STAGE;
		_content = new BaseIceObject(new ElementData({'name':'content', 'touchable':false}));
		_content.autosize = BaseIceObject.AUTO_SIZE_CONTENT;
		_content.onResize = resizeContent;
		addChild(_content);
		_forelayer = new BaseIceObject(new ElementData({'name':'forelayer', 'touchable':false}));
		addChild(_forelayer);
		addEventListener(WheelScrollEvent.SCROLL, wheelScrollHandler);
		styleName = DEFAULT_SCROLLER_STYLE;
		_delayedRenderer = new DelayedRenderer(this, _content);
	}
	
	@:allow(ru.ice.core.Ice)
	private override function initialize() : Void {
		super.initialize();
		_delayedRenderer.applyStylesIfNeeded();
	}
	
	public override function resize(?data:Dynamic) : Void
	{
		super.resize(data);
		if (data.invalidateSize) {
			resetScrollParams();
			if (!_isDragging && _isTweensComplete) {
				clearAnimations();
				throwScroll();
			}
		}
	}
	
	public function resizeContent(?data:Dynamic) : Void
	{
		if (data.invalidateSize) {
			resetScrollParams();
			if (!_isDragging && _isTweensComplete) {
				clearAnimations();
				throwScroll();
			}
		}
	}
	
	private var _isTweensComplete(get, never) : Bool;
	private function get__isTweensComplete() : Bool
	{
		if (_xTween != null) {
			if (!cast(_xTween, Tween).isComplete)
				return false;
		}
		if (_yTween != null) {
			if (!cast(_yTween, Tween).isComplete)
				return false;
		}
		return true;
	}
	
	private function resetScrollParams() : Void {
		calculateViewportOffset();
		_velocityX = 0;
		_velocityY = 0;
	}
	
	private function wheelScrollHandler(e:WheelScrollEvent) : Void
	{
		if (e.ctrlKey)
			return;
		e.stopImmediatePropagation();
		
		var currentTime:Float = Date.now().getTime();
		var wheelTime:Float = currentTime - _lastWheelTime;
		_lastWheelTime = currentTime;
		
		var spinX:Float = -FloatUtil.sign(e.deltaX);
		var spinY:Float = -FloatUtil.sign(e.deltaY);
		
		if (wheelTime < stage.tickLength * 100)
			_wheelZero ++;
		else
			_wheelZero = 0;
		
		throwWheel(spinX, spinY, _wheelZero > MAX_WHEEL_ZERO_OPERATIONS);
	}
	
	private function throwWheel(spinX:Float, spinY:Float, withoutAnimation:Bool = false) : Void
	{
		_isDragging = true;
		
		clearAnimations();
		
		calculateViewportOffset();
		
		_velocityX = 0;
		_velocityY = 0;
		
		if (_isDraggingHorizontally) {
			if (!Math.isNaN(spinX))
				throwScrollInertialForceX(spinX * contentWidth * WHEEL_SCROLL_RATIO, withoutAnimation);
		}
		
		if (_isDraggingVertically) {
			if (!Math.isNaN(spinY))
				throwScrollInertialForceY(spinY * contentHeight * WHEEL_SCROLL_RATIO, withoutAnimation);
		}
	}
	
	private var _iTarget:InteractiveObject;
	
	private var _tmpLocStartTP:Point;
	
	private override function downHandler(e:FingerEvent) : Void
	{
		super.downHandler(e);
		// Проверка на нажатую левую кнопку мыши, если устройством ввода является мышь.
		if (e.key != FingerEvent.KEY_LEFT && e.isMouse)
			return;
		
		_iTarget = Std.is(e.target, InteractiveObject) ? cast e.target : null;
		
		e.stopImmediatePropagation();
		
		_isDragging = true;
		
		// Удаляет все анимации, во избежание блокирования ввода
		clearAnimations();
		
		_startTP = _curTP = _prevTP = e.touchPoint.clone();
		_startPos.move(_content.x, _content.y);
		_tmpLocStartTP = _locStartTP = _locCurTP = globalToLocal(e.touchPoint);
		
		calculateViewportOffset();
		
		_isCalcVelocity = true;
	}
	
	private override function upHandler(e:FingerEvent) : Void
	{
		var isPress:Bool = _isPress;
		super.stageUpHandler(e);
		
		if (isPress)
			pressOut(e);
	}
	
	private override function stageUpHandler(e:FingerEvent) : Void
	{
		var isPress:Bool = _isPress;
		super.stageUpHandler(e);
		
		if (isPress)
			pressOut(e);
	}
	
	private function pressOut(e:FingerEvent) : Void {
		
		e.stopImmediatePropagation();
			
		_isDragging = false;
		
		stopScrolling();
	}
	
	public static var isStopAction:Bool = false;
	
	private override function stageMoveHandler(e:FingerEvent) : Void
	{
		if (_isPress) {
			e.stopImmediatePropagation();
			
			var tp:Point = e.touchPoint;
			var ltp:Point = globalToLocal(tp);
			
			if (_iTarget != null) {
				var dragLength:Float = ltp.measureDistance(_tmpLocStartTP, _isDraggingHorizontally, _isDraggingVertically);
				if (dragLength > MAX_ACTION_BOUND_SIZE) {
					Ice.isDragging = true;
					_iTarget.resetState(this);
				} else {
					_startTP = _curTP = _prevTP = e.touchPoint.clone();
					_startPos.move(_content.x, _content.y);
					_locStartTP = _locCurTP = globalToLocal(e.touchPoint);
					
					calculateViewportOffset();
					return;
				}
			}
			
			_isDragging = true;
			
			_prevTP = _curTP;
			_curTP = tp;
			_locCurTP = ltp;
			
			calculateViewportBound();
			
			if (_isDraggingHorizontally) {
				_content.x = _viewportBound.x;
				scrollX();
			}
			if (_isDraggingVertically) {
				_content.y = _viewportBound.y;
				scrollY();
			}
		}
	}
	
	public override function update() : Void
	{
		super.update();
		if (!_isDragging && !_isCalcVelocity)
			return;
		calculateVelocity();
	}
	
	/**
	 * Считает начальные размеры сдвига (без эластичности)
	 */
	private function calculateViewportOffset() : Void
	{
		// По X
		if (_isDraggingHorizontally) {
			var vw:Float = _content.contentWidth < contentWidth ? contentWidth : _content.contentWidth;
			maxScrollX = contentWidth - vw;
			var offsetLeft:Float = 0;
			var rightOffset:Float = _startPos.x + vw - contentWidth;
			if (_startPos.x > 0)
				offsetLeft = calculateSpringOffset(_startPos.x);
			else if (rightOffset < 0)
				offsetLeft = contentWidth - vw + calculateSpringOffset(rightOffset);
			else
				offsetLeft = _startPos.x;
			_viewportOffset.x = offsetLeft;
		} else {
			maxScrollX = 0;
			_viewportOffset.x = 0;
		}
		// По Y
		if (_isDraggingVertically) {
			var vh:Float = _content.contentHeight < contentHeight ? contentHeight : _content.contentHeight;
			maxScrollY = contentHeight - vh;
			var offsetTop:Float = 0;
			var bottomOffset:Float = _startPos.y + vh - contentHeight;
			if (_startPos.y > 0)
				offsetTop = calculateSpringOffset(_startPos.y);
			else if (bottomOffset < 0)
				offsetTop = contentHeight - vh + calculateSpringOffset(bottomOffset);
			else
				offsetTop = _startPos.y;
			_viewportOffset.y = offsetTop;
		} else {
			maxScrollY = 0;
			_viewportOffset.y = 0;
		}
	}
	
	/**
	 * Считает позиции и размеры вьюпорта
	 */
	private function calculateViewportBound() : Void
	{
		// Новая координата вьюпорта для линейного перемещения
		var offsetViewport:Point = _locCurTP.deduct(_locStartTP).add(_viewportOffset, false);
		// По X
		if (_isDraggingHorizontally) {
			var vw:Float = _content.contentWidth < contentWidth ? contentWidth : _content.contentWidth;
			var offsetLeft:Float = 0;
			var rightOffset:Float = offsetViewport.x + vw - contentWidth;
			if (offsetViewport.x > 0) {
				_viewportAbsOffset.x = offsetViewport.x;
				offsetLeft = calculateSpringDistance(offsetViewport.x);
			} else if (rightOffset < 0) {
				_viewportAbsOffset.x = offsetViewport.x;
				offsetLeft = contentWidth - vw + calculateSpringDistance(rightOffset);
			} else {
				offsetLeft = offsetViewport.x;
			}
			_viewportBound.x = offsetLeft;
			_viewportBound.width = vw;
		} else {
			_viewportBound.x = 0;
			_viewportBound.width = 0;
		}
		// По Y
		if (_isDraggingVertically) {
			var vh:Float = _content.contentHeight < contentHeight ? contentHeight : _content.contentHeight;
			var offsetTop:Float = 0;
			var bottomOffset:Float = offsetViewport.y + vh - contentHeight;
			if (offsetViewport.y > 0) {
				offsetTop = calculateSpringDistance(offsetViewport.y);
				_viewportAbsOffset.y = offsetViewport.y;
			} else if (bottomOffset < 0) {
				offsetTop = contentHeight - vh + calculateSpringDistance(bottomOffset);
				_viewportAbsOffset.y = offsetViewport.y;
			} else {
				offsetTop = offsetViewport.y;
			}
			_viewportBound.y = offsetTop;
			_viewportBound.height = vh;
		} else {
			_viewportBound.y = 0;
			_viewportBound.height = 0;
		}
	}
	
	/**
	 * Очищает все анимации холста
	 */
	private function clearAnimations() : Void
	{
		Ice.animator.remove(_xTween);
		Ice.animator.remove(_yTween);
	}
	
	private function scrollX() : Void {
		dispatchEventWith(Event.SCROLL, false, {direction:'horizontal'});
	}
	
	private function scrollY() : Void {
		dispatchEventWith(Event.SCROLL, false, {direction:'vertical'});
	}
	
	/**
	 * Запускает анимацию возврата вьюпорта в регионы холста или анимацию "инерции".
	 */
	private function throwScroll() : Void
	{
		if (_isDraggingHorizontally) {
			var durationX:Float;
			var rightOffset:Float = _content.x - maxScrollX;
			
			durationX = calculateDynamicThrowDurationByDistance(Math.abs(_viewportAbsOffset.x));
			if (_content.x > 0 || (rightOffset < 0 && maxScrollX > 0)) {
				Ice.animator.remove(_xTween);
				_xTween = Ice.animator.tween(_content, durationX, {x:0, transitionFunc:_throwEase, onUpdate:scrollX});
			} else if (rightOffset < 0) {
				Ice.animator.remove(_xTween);
				_xTween = Ice.animator.tween(_content, durationX, {x:maxScrollX, transitionFunc:_throwEase, onUpdate:scrollX});
			} else if (_velocityX != 0 && !Math.isNaN(_velocityX))
				throwScrollInertialForceX();
		}
		
		if (_isDraggingVertically) {
			var durationY:Float;
			var bottomOffset:Float = _content.y - maxScrollY;
			
			durationY = calculateDynamicThrowDurationByDistance(Math.abs(_viewportAbsOffset.y));
			if (_content.y > 0 || (bottomOffset < 0 && maxScrollY > 0)) {
				Ice.animator.remove(_yTween);
				_yTween = Ice.animator.tween(_content, durationY, {y:0, transitionFunc:_throwEase, onUpdate:scrollY});
			} else if (bottomOffset < 0) {
				Ice.animator.remove(_yTween);
				_yTween = Ice.animator.tween(_content, durationY, {y:maxScrollY, transitionFunc:_throwEase, onUpdate:scrollY});
			} else if (_velocityY != 0 && !Math.isNaN(_velocityY))
				throwScrollInertialForceY();
		}
	}
	
	private function throwScrollInertialForceX(distance:Float = null, withoutAnimation:Bool = false) : Void
	{
		var vw:Float = _content.contentWidth < contentWidth ? contentWidth : _content.contentWidth;
		
		Ice.animator.remove(_xTween);
		var ppms:Float = 0, pathLength:Float;
		if (distance == null) {
			ppms = calculatePPMS(_velocityX, _scopeVelocityX);
			pathLength = -calculateThrowDistance(ppms);
		} else
			pathLength = Math.isNaN(distance) ? 0 : distance;
		
		var contentPos:Float = _content.x + pathLength; 
		var offset:Float = contentPos - maxScrollX;
		var pos:Float = _content.x;
		var springPath:Float = 0, duration:Float;
		
		if (contentPos > 0 || (offset < 0 && maxScrollX > 0))
			springPath = calculateSpringOffset(contentPos);
		else if (offset < 0)
			springPath = contentWidth - vw + calculateSpringOffset(offset);
		
		pos += springPath;
		
		if (contentPos > 0 || (offset < 0 && maxScrollX > 0)) {
			duration = calculateDynamicThrowDurationByDistance(Math.abs(pos));
			
			if (withoutAnimation) {
				_content.x = 0;
				scrollX();
			} else
				_xTween = Ice.animator.tween(_content, duration, {x:0, transitionFunc:_easeOutBack, onUpdate:scrollX});
		} else if (offset < 0) {
			duration = calculateDynamicThrowDurationByDistance(Math.abs(Math.abs(pos) - maxScrollX));
			
			if (withoutAnimation) {
				_content.x = maxScrollX;
				scrollX();
			} else
				_xTween = Ice.animator.tween(_content, duration, {x:maxScrollX, transitionFunc:_easeOutBack, onUpdate:scrollX});
		} else {
			if (distance != null)
				duration = calculateDynamicThrowDurationByDistance(Math.abs(distance));
			else
				duration = calculateDynamicThrowDuration(ppms);
			
			if (withoutAnimation) {
				_content.x = contentPos;
				scrollX();
			} else
				_xTween = Ice.animator.tween(_content, duration, {x:contentPos, transitionFunc:_throwEase, onUpdate:scrollX});
		}
	}
	
	private function throwScrollInertialForceY(distance:Float = null, withoutAnimation:Bool = false) : Void
	{
		var vh:Float = _content.contentHeight < contentHeight ? contentHeight : _content.contentHeight;
		
		Ice.animator.remove(_yTween);
		var ppms:Float = 0, pathLength:Float;
		if (distance == null) {
			ppms = calculatePPMS(_velocityY, _scopeVelocityY);
			pathLength = -calculateThrowDistance(ppms);
		} else
			pathLength = Math.isNaN(distance) ? 0 : distance;
		
		var contentPos:Float = _content.y + pathLength; 
		var offset:Float = contentPos - maxScrollY;
		var pos:Float = _content.y;
		var springPath:Float = 0, duration:Float;
		
		if (contentPos > 0 || (offset < 0 && maxScrollY > 0))
			springPath = calculateSpringOffset(contentPos);
		else if (offset < 0)
			springPath = contentHeight - vh + calculateSpringOffset(offset);
		
		pos += springPath;
		
		if (contentPos > 0 || (offset < 0 && maxScrollY > 0)) {
			duration = calculateDynamicThrowDurationByDistance(Math.abs(pos));
			
			if (withoutAnimation) {
				_content.y = 0;
				scrollY();
			} else
				_yTween = Ice.animator.tween(_content, duration, {y:0, transitionFunc:_easeOutBack, onUpdate:scrollY});
		} else if (offset < 0) {
			duration = calculateDynamicThrowDurationByDistance(Math.abs(Math.abs(pos) - maxScrollY));
			
			if (withoutAnimation) {
				_content.y = maxScrollY;
				scrollY();
			} else
				_yTween = Ice.animator.tween(_content, duration, {y:maxScrollY, transitionFunc:_easeOutBack, onUpdate:scrollY});
		} else {
			if (distance != null)
				duration = calculateDynamicThrowDurationByDistance(Math.abs(distance));
			else
				duration = calculateDynamicThrowDuration(ppms);
			
			if (withoutAnimation) {
				_content.y = contentPos;
				scrollY();
			} else
				_yTween = Ice.animator.tween(_content, duration, {y:contentPos, transitionFunc:_throwEase, onUpdate:scrollY});
		}
	}
	
	/**
	 * Вычисление времени возврата "пружины" от пути.
	 */
	private function calculateDynamicThrowDurationByDistance(distance:Float) : Float {
		if (distance == 0)
			return 0;
		// Масса холста
		//var canvasWeight:Float = _content.width * _content.height * CANVAS_PIXEL_WEIGHT;
		// Вычисляется ремя возврата пружины с ниленейной зависимостью. Сопративление трения не учитываем
		return (SPRING_STRENGTH / SPRING_WEIGHT) * distance / Math.pow(distance, 1 / SPRING_TENSION);
	}
	
	/**
	 * Вычисление времени возврата "пружины" от пути.
	 */
	private function calculateSpringOffset(distance:Float) : Float {
		if (distance == 0)
			return 0;
		// Масса холста
		//var canvasWeight:Float = _content.width * _content.height * CANVAS_PIXEL_WEIGHT;
		// Вычисляется ремя возврата пружины с ниленейной зависимостью. Сопративление трения не учитываем
		return Math.pow(Math.abs(distance), SPRING_TENSION) / FloatUtil.sign(distance);
	}
	
	/**
	 * Вычисление времени возврата "пружины" от пути.
	 */
	private function calculateSpringDistance(distance:Float) : Float {
		if (distance == 0)
			return 0;
		// Масса холста
		//var canvasWeight:Float = _content.width * _content.height * CANVAS_PIXEL_WEIGHT;
		// Вычисляется ремя возврата пружины с ниленейной зависимостью. Сопративление трения не учитываем
		return Math.pow(Math.abs(distance), 1 / SPRING_TENSION) * FloatUtil.sign(distance);
	}
	
	private function calculateThrowDistance(pixelsPerMS:Float) : Float {
		if (pixelsPerMS == 0)
			return 0;
		return (pixelsPerMS - MINIMUM_VELOCITY) / _logDecelerationRate;
	}
	
	private function calculateDynamicThrowDuration(pixelsPerMS:Float) : Float {
		if (pixelsPerMS == 0)
			return 0;
		return Math.abs((Math.log(MINIMUM_VELOCITY / Math.abs(pixelsPerMS)) / _logDecelerationRate) / DURATION_POWER);
	}
	
	private function calculatePPMS(velocity:Float, scopeVelocity:Array<Float>) : Float
	{
		var sum:Float = velocity * CURRENT_VELOCITY_WEIGHT;
		var velocityCount:Int = scopeVelocity.length;
		var totalWeight:Float = CURRENT_VELOCITY_WEIGHT;
		for (i in 0 ... velocityCount) {
			var weight:Float = VELOCITY_WEIGHTS[i];
			sum += scopeVelocity.shift() * weight;
			totalWeight += weight;
		}
		return (sum / totalWeight) * _ppmsScale;
	}
	
	private function calculateVelocity() : Void
	{
		var currentTime:Float = Date.now().getTime();
		var timeOffset:Float = currentTime - _prevTouchTime;
		
		if (timeOffset > 0) {
			_scopeVelocityX[_scopeVelocityX.length] = _velocityX;
			if (_scopeVelocityX.length > MAXIMUM_VELOCITY_ITERATIONS)
				_scopeVelocityX.shift();
			_scopeVelocityY[_scopeVelocityY.length] = _velocityY;
			if (_scopeVelocityY.length > MAXIMUM_VELOCITY_ITERATIONS)
				_scopeVelocityY.shift();
			_velocityX = (_curTP.x - _prevTP.x) / timeOffset;
			_velocityY = (_curTP.y - _prevTP.y) / timeOffset;
			_prevTouchTime = currentTime;
			_prevTP = _curTP;
		}
	}
	
	private var _isCalcVelocity:Bool = false;
	
	private function stopScrolling() : Void
	{
		_isDragging = false;
		
		//stage.removeEventListener(FingerEvent.UP, stageFingerUpHandler);
		//stage.removeEventListener(FingerEvent.MOVE, stageFingerMoveHandler);
		
		throwScroll();
		
		_isCalcVelocity = false;
	}
	
	private override function get_layout() : ILayout {
		return _content.layout;
	}
	
	private override function set_layout(v:ILayout) : ILayout {
		_content.layout = v;
		return get_layout();
	}
	
	private override function updateLayout() : Void
	{
		if (layout != null)
			layout.update();
	}
	
	public function delayRender() : Void {
		_delayedRenderer.start();
	}
	
	public function addItemFactory(factory:Function) : Void {
		_delayedRenderer.add(factory);
	}
	
	private function get_contentChildren() : Array<DisplayObject> {
		return _content.children;
	}
	
	public function contentContains(child:DisplayObject) : Bool {
		return _content.contains(child);
	}
	
	public function addItem(child:DisplayObject) : DisplayObject {
		return _content.addChild(child);
	}
	
	public function removeItem(child:DisplayObject) : DisplayObject {
		return _content.removeChild(child);
	}
	
	public function getContentChildIndex(child:DisplayObject) : Int {

		return _content.getChildIndex(child);
	}
	
	override public function dispose() : Void
	{
		_delayedRenderer.dispose();
		_delayedRenderer = null;
		stopScrolling();
		//removeEventListener(WheelScrollEvent.SCROLL, wheelScrollHandler);
		//removeEventListener(FingerEvent.DOWN, fingerDownHandler);
		super.dispose();
	}
}