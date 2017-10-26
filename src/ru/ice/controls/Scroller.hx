package ru.ice.controls;

import js.html.ButtonElement;
import js.html.Element;
import js.html.TouchEvent;
import js.html.svg.SVGElement;

import haxe.Constraints.Function;

import ru.ice.animation.IAnimatable;
import ru.ice.animation.Tween;
import ru.ice.animation.Transitions;
import ru.ice.core.Ice;
import ru.ice.controls.super.InteractiveControl;
import ru.ice.controls.super.IceControl;
import ru.ice.data.ElementData;
import ru.ice.events.Event;
import ru.ice.events.FingerEvent;
import ru.ice.events.WheelScrollEvent;
import ru.ice.display.DisplayObject;
import ru.ice.math.Point;
import ru.ice.math.Rectangle;
import ru.ice.layout.ILayout;
import ru.ice.controls.super.BaseStatesControl;
import ru.ice.display.SvgSprite;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Scroller extends BaseStatesControl
{
	public static inline var DEFAULT_STYLE : String = 'default-scroller-style';
	
	private static inline var PAGGINATION_NONE:String = 'none';
	
	private static inline var PAGGINATION_HORIZONTAL:String = 'paggination-horizontal';
	
	private static inline var PAGGINATION_VERTICAL:String = 'paggination-vertical';
	
	private static inline var MAX_ACTION_BOUND_SIZE:Int = 11;
	
	private static inline var WHEEL_TRESHOLD:Int = 2;
	
	private static inline var WHEEL_TIME_TRESHOLD:Int = 40;
	
	public static inline var WHEEL_SCROLL_RATIO:Float = .75;
	
	/**
	 * Вес одного пикселя холста
	 */
	private static inline var CANVAS_PIXEL_WEIGHT:Float = .1;
	
	/**
	 * Упругость "пружины". Сталь 78500 МПа
	 */
	private static inline var SPRING_STRENGTH:Float = 78500;
	
	/**
	 * Масса "холста"
	 */
	private static inline var SPRING_WEIGHT:Float = 1000000;
	
	/**
	 * Нелинейный коэффициент упругости пружины
	 */
	private static inline var SPRING_TENSION:Float = 1.432;
	
	public static inline var DURATION_POWER:Float = 1000;
	
	public static inline var MAXIMUM_VELOCITY_ITERATIONS:Float = 4;
	
	public static inline var MINIMUM_VELOCITY:Float = .05;
	
	public static inline var CURRENT_VELOCITY_WEIGHT:Float = 1.33;
	
	public static var VELOCITY_WEIGHTS:Array<Float> = [0.1, 0.33, 0.66, 1];
	
	private static function defaultThrowEase(ratio:Float):Float
	{
		ratio -= 1;
		return 1 - ratio * ratio * ratio * ratio;
	}
	
	private function _easeOutBack(ratio:Float):Float
    {
        var invRatio:Float = ratio - 1;            
        var s:Float = _easeBackRatio;
        return (Math.pow(invRatio, 4) * ((s + 1) * invRatio + s) + 1);
    }
	
	private var _easeBackRatio:Float = 1.970158;
	
	private var _easeBackTimeRatio:Float = 0.550158;
	
	private var _throwEase:Float->Float = defaultThrowEase;
	
	private var _lastWheelTime:Float = 0;
	
	private var _logDecelerationRate:Float = -0.0029;
	
	private var _ppmsScale:Float = 2.56;
	
	private var _content:IceControl;
	
	private var _forelayer:IceControl;
	
	private var _enableBarriers:Bool = false;
	public var enableBarriers(get, set):Bool;
	private function get_enableBarriers():Bool{
		return _enableBarriers;
	}
	private function set_enableBarriers(v:Bool):Bool {
		if (_enableBarriers != v) {
			_enableBarriers = v;
			if (v && _barrier == null) {
				_barrier = new Barrier();
				_barrier.styleFactory = _barrierStyleFactory;
				addChildAt(_barrier, 0);
				updateHorizontalBarriers();
				updateVerticalBarriers();
			} else if (!v && _barrier != null) {
				_barrier.removeFromParent(true);
				_barrier = null;
			}
		}
		return get_enableBarriers();
	}
	
	private var _snapToPages:Bool = false;
	public var snapToPages(get, set):Bool;
	private function get_snapToPages():Bool{
		return _snapToPages;
	}
	private function set_snapToPages(v:Bool):Bool {
		_snapToPages = v;
		return get_snapToPages();
	}
	
	private var _paggination:String = PAGGINATION_NONE;
	public var paggination(get, set):String;
	private function get_paggination() : String {
		return _paggination;
	}
	private function set_paggination(v:String) : String {
		if (_paggination != v) {
			_paggination = v;
			switch (v) {
				case PAGGINATION_HORIZONTAL: {
					
				}
				case PAGGINATION_VERTICAL: {
					
				}
				default: {
					
				}
			}
		}
		return get_paggination();
	}
	
	private var _horizontalPages:Int;
	public var horizontalPages(get, never):Int;
	private function get_horizontalPages():Int {
		return _horizontalPages;
	}
	
	private var _verticalPages:Int;
	public var verticalPages(get, never):Int;
	private function get_verticalPages():Int {
		return _verticalPages;
	}
	
	public var maxScrollX(get, never):Float;
	private function get_maxScrollX():Float {
		return _width - (_content.width < _width ? _width : _content.width);
	}
	
	public var maxScrollY(get, never):Float;
	private function get_maxScrollY():Float {
		return _height - (_content.height < _height ? _height : _content.height);
	}
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
	public var isDraggingHorizontally(get, set) : Bool;
	private function get_isDraggingHorizontally() : Bool {
		return _isDraggingHorizontally;
	}
	private function set_isDraggingHorizontally(v:Bool) : Bool {
		if (_isDraggingHorizontally != v)
			_isDraggingHorizontally = v;
		return get_isDraggingHorizontally();
	}
	
	private var _isDraggingVertically:Bool = true;
	public var isDraggingVertically(get, set) : Bool;
	private function get_isDraggingVertically() : Bool {
		return _isDraggingVertically;
	}
	private function set_isDraggingVertically(v:Bool) : Bool {
		if (_isDraggingVertically != v)
			_isDraggingVertically = v;
		return get_isDraggingVertically();
	}
	
	private var _isDragging:Bool = false;
	public var isDragging(get, never) : Bool;
	private function get_isDragging() : Bool {
		return _isDragging;
	}
	
	private var _barrier:Barrier;
	
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
	
	/**
	 * public
	 * Возвращает текущую горизонтальную позицию в процентах от 0 до 1
	 * @return Float
	 */
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
	
	/**
	 * public
	 * Возвращает текущую вертикальную позицию в процентах от 0 до 1
	 * @return Float
	 */
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
	
	public var contentStyleFactory(never, set) : Function;
	private function set_contentStyleFactory(v:Function) : Function {
		_content.styleFactory = v;
		return v;
	}
	
	private var _barrierStyleFactory : Function;
	public var barrierStyleFactory(get, set) : Function;
	private function set_barrierStyleFactory(v:Function) : Function {
		if (_barrierStyleFactory != v) {
			_barrierStyleFactory = v;
			if (_barrier != null)
				_barrier.styleFactory = v;
		}
		return v;
	}
	private function get_barrierStyleFactory() : Function {
		return _barrierStyleFactory;
	}
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'scroller'});
		super(elementData);
		addClass(['i-clipped', 'i-draggable']);
		_content = new IceControl(new ElementData({'name':'content', 'interactive':false}));
		_content.onResize = resizeContent;
		addChild(_content);
		_forelayer = new IceControl(new ElementData({'name':'fore', 'interactive':false}));
		addChild(_forelayer);
		addEventListener(WheelScrollEvent.SCROLL, wheelScrollHandler);
		styleName = DEFAULT_STYLE;
	}
	
	public function addToContentDelayedItemFactory(factory:Function, ?owner:IceControl, ?content:IceControl) : Void {
		_content.addDelayedItemFactory(factory, owner != null ? owner : this, content != null ? content : _content);
	}
	
	public override function resize(?data:ResizeData) : Void
	{
		super.resize(data);
		if (!_isDragging && _isTweensComplete)
			clearAnimations();
		resetScrollParams();
		if (!_isPress) {
			throwScroll();
			layoutBarriers();
		}
	}
	
	public function resizeContent(?data:ResizeData) : Void
	{
		if (!_isDragging && _isTweensComplete)
			clearAnimations();
		resetScrollParams();
		if (!_isPress)
			throwScroll();
	}
	
	private function layoutBarriers() : Void {
		if (_barrier == null)
			return;
		_barrier.setSize(_width, _height);
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
	
	private var _wheelTreshold:Float = 0;
	
	private function wheelScrollHandler(e:WheelScrollEvent) : Void
	{
		if (e.ctrlKey)
			return;
		e.stopImmediatePropagation();
		var currentTime:Float = Date.now().getTime();
		if (_lastWheelTime == 0)
			_lastWheelTime = currentTime;
		var wheelTime:Float = currentTime - _lastWheelTime;
		_lastWheelTime = currentTime;
		
		if (wheelTime > WHEEL_TIME_TRESHOLD || _wheelTreshold <= WHEEL_TRESHOLD) {
			var spinX:Float = e.deltaX > 0 ? -1 : 1;
			var spinY:Float = e.deltaY > 0 ? -1 : 1;
			
			throwWheel(spinX, spinY, false);
		}
		
		if (wheelTime < WHEEL_TIME_TRESHOLD)
			_wheelTreshold += 1;
		else
			_wheelTreshold = 0;
	}
	
	public function simWheelScroll(e:WheelScrollEvent) : Void {
		wheelScrollHandler(e);
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
				throwScrollInertialForceX(spinX * _width * WHEEL_SCROLL_RATIO, withoutAnimation);
		}
		
		if (_isDraggingVertically) {
			if (!Math.isNaN(spinY))
				throwScrollInertialForceY(spinY * _height * WHEEL_SCROLL_RATIO, withoutAnimation);
		}
	}
	
	private var _iTarget:InteractiveControl;
	
	private var _tmpLocStartTP:Point;
	
	private override function downHandler(e:FingerEvent) : Void
	{
		super.downHandler(e);
		// Проверка на нажатую левую кнопку мыши, если устройством ввода является мышь.
		if (e.key != FingerEvent.KEY_LEFT && e.isMouse)
			return;
		_isBeginPress = true;
		_iTarget = Std.is(e.target, InteractiveControl) ? cast e.target : null;
		
		e.stopImmediatePropagation();
		
		_isDragging = true;
		
		// Удаляет все анимации, во избежание блокирования ввода
		clearAnimations();
		
		_velocityX = 0;
		_velocityY = 0;
		
		_startTP = _curTP = _prevTP = e.touchPoint.clone();
		_startPos.move(_content.x, _content.y);
		_tmpLocStartTP = _locStartTP = _locCurTP = globalToLocal(_startTP); //e.touchPoint.clone();
		
		calculateViewportOffset();
		
		_isCalcVelocity = true;
	}
	
	public function simFingerDown(e:FingerEvent) : Void {
		downHandler(e);
	}
	
	private override function upHandler(e:FingerEvent) : Void
	{
		removeClass(['i-dragging']);
		addClass(['i-draggable']);
		if (e.key != FingerEvent.KEY_LEFT && e.isMouse)
			return;
		var isPress:Bool = _isPress;
		super.stageUpHandler(e);
		
		if (isPress)
			pressOut(e);
	}
	
	public function simFingerUp(e:FingerEvent) : Void {
		upHandler(e);
	}
	
	private override function stageUpHandler(e:FingerEvent) : Void
	{
		if (e.key != FingerEvent.KEY_LEFT && e.isMouse)
			return;
		var isPress:Bool = _isPress;
		super.stageUpHandler(e);
		
		if (isPress)
			pressOut(e);
	}
	
	public function simFingerStageUp(e:FingerEvent) : Void {
		stageUpHandler(e);
	}
	
	private function pressOut(e:FingerEvent) : Void {
		
		e.stopImmediatePropagation();
			
		_isDragging = false;
		stopScrolling();
		if (_paggination == PAGGINATION_HORIZONTAL) {
			var lastX:Float = _content.x;
			var newX:Float = calcPositionByHorrizontalPaggination(_content.x);
			if (newX != lastX) {
				Ice.animator.remove(_xTween);
				var durationX:Float = calculateDynamicThrowDurationByDistance(Math.abs(Math.abs(newX) - Math.abs(lastX)));
				_xTween = Ice.animator.tween(_content, durationX, {x:newX, transitionFunc:_throwEase, onUpdate:scrollX});
			}
		}
		if (_paggination == PAGGINATION_VERTICAL) {
			var lastY:Float = _content.y;
			var newY:Float = calcPositionByVerticalPaggination(_content.y);
			if (newY != lastY) {
				var durationY:Float = calculateDynamicThrowDurationByDistance(Math.abs(Math.abs(newY) - Math.abs(lastY)));
				Ice.animator.remove(_yTween);
				_yTween = Ice.animator.tween(_content, 1, {y:newY, transitionFunc:_throwEase, onUpdate:scrollY});
			}
		}
	}
	
	private var _isBeginPress:Bool = false;
	public static var isStopAction:Bool = false;
	
	private override function stageMoveHandler(e:FingerEvent) : Void
	{
		if (_isPress) {
			e.stopImmediatePropagation();
			
			var tp:Point = e.touchPoint.clone();
			var ltp:Point = globalToLocal(tp);
			
			if (_isBeginPress && _iTarget != null && _iTarget != this) {
				var dragLength:Float = ltp.measureDistance(_tmpLocStartTP, _isDraggingHorizontally, _isDraggingVertically);
				if (dragLength > MAX_ACTION_BOUND_SIZE) {
					removeClass(['i-draggable']);
					addClass(['i-dragging']);
					Ice.isDragging = true;
					_iTarget.resetState(this);
					_isBeginPress = false;
				} else {
					_startTP = _curTP = _prevTP = e.touchPoint.clone();
					_startPos.move(_content.x, _content.y);
					_locStartTP = _locCurTP = globalToLocal(e.touchPoint);
					
					//calculateViewportOffset();
					return;
				}
			} else if (_iTarget == null && _isBeginPress) {
				_isBeginPress = false;
				removeClass(['i-draggable']);
				addClass(['i-dragging']);
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
	
	public function simFingerStageMove(e:FingerEvent) : Void {
		stageMoveHandler(e);
	}
	
	public override function update(emitResize:Bool = true) : Void
	{
		super.update(emitResize);
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
			var vw:Float = _content.width < _width ? _width : _content.width;
			var offsetLeft:Float = 0;
			var rightOffset:Float = _startPos.x + vw - _width;
			if (_startPos.x > 0)
				offsetLeft = calculateSpringOffset(_startPos.x);
			else if (rightOffset < 0)
				offsetLeft = _width - vw + calculateSpringOffset(rightOffset);
			else
				offsetLeft = _startPos.x;
			_viewportOffset.x = offsetLeft;
		} else {
			_viewportOffset.x = 0;
		}
		// По Y
		if (_isDraggingVertically) {
			var vh:Float = _content.height < _height ? _height : _content.height;
			//_maxScrollY = contentHeight - vh;
			var offsetTop:Float = 0;
			var bottomOffset:Float = _startPos.y + vh - _height;
			if (_startPos.y > 0)
				offsetTop = calculateSpringOffset(_startPos.y);
			else if (bottomOffset < 0)
				offsetTop = _height - vh + calculateSpringOffset(bottomOffset);
			else
				offsetTop = _startPos.y;
			_viewportOffset.y = offsetTop;
		} else {
			//_maxScrollY = 0;
			_viewportOffset.y = 0;
		}
		
		_horizontalPages = Math.ceil(_content.width / _width);
		_verticalPages = Math.floor(_content.height / _height);
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
			var vw:Float = _content.width < _width ? _width : _content.width;
			var offsetLeft:Float = 0;
			var rightOffset:Float = offsetViewport.x + vw - _width;
			if (offsetViewport.x > 0) {
				_viewportAbsOffset.x = offsetViewport.x;
				offsetLeft = calculateSpringDistance(offsetViewport.x);
			} else if (rightOffset < 0) {
				_viewportAbsOffset.x = offsetViewport.x;
				offsetLeft = _width - vw + calculateSpringDistance(rightOffset);
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
			var vh:Float = _content.height < _height ? _height : _content.height;
			var offsetTop:Float = 0;
			var bottomOffset:Float = offsetViewport.y + vh - _height;
			if (offsetViewport.y > 0) {
				offsetTop = calculateSpringDistance(offsetViewport.y);
				_viewportAbsOffset.y = offsetViewport.y;
			} else if (bottomOffset < 0) {
				var tension:Float = calculateSpringDistance(bottomOffset);
				offsetTop = _height - vh + tension;
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
		_horizontalPages = Math.ceil(_content.width / _width);
		_verticalPages = Math.floor(_content.height / _height);
	}
	
	/*public function scrollToHorizontalPosition(position:Float) : Void {
		var sp:Float = horizontalScrollPosition;
		if (Math.isNaN(position) || horizontalScrollPosition == sp)
			return;
		}
		var distance:Float = sp;
		var duration:Float = calculateDynamicThrowDurationByDistance();
		Ice.animator.remove(_xTween);
		_xTween = Ice.animator.tween(_content, durationX, {x:0, transitionFunc:_throwEase, onUpdate:scrollX});
		
	}*/
	
	/**
	 * Очищает все анимации холста
	 */
	private function clearAnimations() : Void
	{
		Ice.animator.remove(_xTween);
		Ice.animator.remove(_yTween);
	}
	
	private function scrollX() : Void {
		updateHorizontalBarriers();
		dispatchEventWith(Event.SCROLL, true, {direction:'horizontal'});
	}
	
	private function scrollY() : Void {
		updateVerticalBarriers();
		dispatchEventWith(Event.SCROLL, true, {direction:'vertical'});
	}
	
	private function updateHorizontalBarriers() : Void {
		if (_barrier == null)
			return;
		var sp:Float = horizontalScrollPosition;
		if (sp < 0) {
			_barrier.leftTension = Math.abs(_content.x * .535);
			_barrier.rightTension = 0;
		} else if (sp > 1) {
			_barrier.rightTension = Math.abs((_content.x + _content.width - _width) * .535);
			_barrier.leftTension = 0;
		} else {
			_barrier.leftTension = 0;
			_barrier.rightTension = 0;
		}
	}
	
	
	private function updateVerticalBarriers() : Void {
		if (_barrier == null)
			return;
		var sp:Float = verticalScrollPosition;
		if (sp < 0) {
			_barrier.topTension = Math.abs(_content.y * .535);
			_barrier.bottomTension = 0;
		} else if (sp > 1) {
			_barrier.bottomTension = Math.abs((_content.y + _content.height - _height) * .535);
			_barrier.topTension = 0;
		} else {
			_barrier.topTension = 0;
			_barrier.bottomTension = 0;
		}
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
			if (_content._x > 0 || (rightOffset < 0 && maxScrollX > 0)) {
				Ice.animator.remove(_xTween);
				_xTween = Ice.animator.tween(_content, durationX, {x:0, transitionFunc:_throwEase, onUpdate:scrollX});
			} else if (rightOffset < 0) {
				Ice.animator.remove(_xTween);
				_xTween = Ice.animator.tween(_content, durationX, {x:maxScrollX, transitionFunc:_throwEase, onUpdate:scrollX});
			} else if (_velocityX != 0 && !Math.isNaN(_velocityX)) {
				throwScrollInertialForceX();
			}
		}
		
		if (_isDraggingVertically) {
			var durationY:Float;
			var bottomOffset:Float = _content._y - maxScrollY;
			
			durationY = calculateDynamicThrowDurationByDistance(Math.abs(_viewportAbsOffset.y));
			if (_content._y > 0 || (bottomOffset < 0 && maxScrollY > 0)) {
				Ice.animator.remove(_yTween);
				_yTween = Ice.animator.tween(_content, durationY, {y:0, transitionFunc:_throwEase, onUpdate:scrollY});
			} else if (bottomOffset < 0) {
				Ice.animator.remove(_yTween);
				_yTween = Ice.animator.tween(_content, durationY, {y:maxScrollY, transitionFunc:_throwEase, onUpdate:scrollY});
			} else if (_velocityY != 0 && !Math.isNaN(_velocityY)) {
				throwScrollInertialForceY();
			}
		}
	}
	
	private function throwScrollInertialForceX(distance:Float = null, withoutAnimation:Bool = false) : Void
	{
		var vw:Float = _content._width < _width ? _width : _content._width;
		
		Ice.animator.remove(_xTween);
		var ppms:Float = 0, pathLength:Float;
		if (distance == null) {
			ppms = calculatePPMS(_velocityX, _scopeVelocityX);
			pathLength = -calculateThrowDistance(ppms);
		} else
			pathLength = Math.isNaN(distance) ? 0 : distance;
		
		var contentPos:Float = _content._x + pathLength; 
		var offset:Float = contentPos - maxScrollX;
		var pos:Float = _content._x;
		var springPath:Float = 0, duration:Float;
		
		if (contentPos > 0 || (offset < 0 && maxScrollX > 0))
			springPath = calculateSpringOffset(contentPos);
		else if (offset < 0)
			springPath = _width - vw + calculateSpringOffset(offset);
		
		pos += springPath;
		
		if (contentPos > 0 || (offset < 0 && maxScrollX > 0)) {
			if (distance != null)
				duration = calculateDynamicThrowDurationByDistance(Math.abs(pos));
			else {
				duration = calculateDynamicThrowDuration(ppms);
				duration = duration / _easeBackRatio;
			}
			
			if (withoutAnimation) {
				_content.x = 0;
				scrollX();
			} else
				_xTween = Ice.animator.tween(_content, duration / _easeBackTimeRatio, {x:0, transitionFunc:_easeOutBack, onUpdate:scrollX});
		} else if (offset < 0) {
			if (distance != null)
				duration = calculateDynamicThrowDurationByDistance(Math.abs(offset));
			else {
				duration = calculateDynamicThrowDuration(ppms);
				duration = duration / _easeBackRatio;
			}
			
			if (withoutAnimation) {
				_content.x = maxScrollX;
				scrollX();
			} else
				_xTween = Ice.animator.tween(_content, duration / _easeBackTimeRatio, {x:maxScrollX, transitionFunc:_easeOutBack, onUpdate:scrollX});
		} else {
			if (distance != null)
				duration = calculateDynamicThrowDurationByDistance(Math.abs(distance));
			else
				duration = calculateDynamicThrowDuration(ppms);
			
			if (withoutAnimation) {
				if (_paggination == PAGGINATION_HORIZONTAL) {
					_content.x = calcPositionByHorrizontalPaggination(contentPos);
				} else 
					_content.x = contentPos;
				scrollX();
			} else {
				var newX:Float = 0;
				if (_paggination == PAGGINATION_HORIZONTAL)
					newX = calcPositionByHorrizontalPaggination(contentPos);
				else 
					newX = contentPos;
				_xTween = Ice.animator.tween(_content, duration, {x:newX, transitionFunc:_throwEase, onUpdate:scrollX});
			}
		}
	}
	
	private function posToHorizontalScrollPosition(pos:Float) : Float {
		return maxScrollX == 0 ? 0 : pos / maxScrollX;
	}
	
	private function horizontalScrollPositionToPos(pos:Float) : Float {
		return maxScrollX == 0 ? 0 : maxScrollX * pos;
	}
	
	private function calcPositionByHorrizontalPaggination(pos:Float) : Float {
		pos = posToHorizontalScrollPosition(pos);
		var hp:Int = horizontalPages;
		var pagginationStep:Float = 1 / hp;
		for (i in 0...hp) {
			var cellStart:Float = i * pagginationStep;
			var cellMiddle:Float = cellStart + pagginationStep * .5;
			var cellEnd:Float = cellStart + pagginationStep;
			if (pos < cellMiddle)
				return horizontalScrollPositionToPos(cellStart);
			else 
			if (pos >= cellMiddle && pos <= cellEnd)
				return horizontalScrollPositionToPos(cellEnd);
		}
		return horizontalScrollPositionToPos(1);
	}
	
	private function throwScrollInertialForceY(distance:Float = null, withoutAnimation:Bool = false) : Void
	{
		var vh:Float = _content.height < _height ? _height : _content.height;
		
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
			springPath = _height - vh + calculateSpringOffset(offset);
		
		pos += springPath;
		
		if (contentPos > 0 || (offset < 0 && maxScrollY > 0)) {
			if (distance != null)
				duration = calculateDynamicThrowDurationByDistance(Math.abs(pos));
			else {
				duration = calculateDynamicThrowDuration(ppms);
				duration = duration / _easeBackRatio;
			}
			
			if (withoutAnimation) {
				_content.y = 0;
				scrollY();
			} else
				_yTween = Ice.animator.tween(_content, duration / _easeBackTimeRatio, {y:0, transitionFunc:_easeOutBack, onUpdate:scrollY});
		} else if (offset < 0) {
			if (distance != null)
				duration = calculateDynamicThrowDurationByDistance(Math.abs(offset));
			else {
				duration = calculateDynamicThrowDuration(ppms);
				duration = duration / _easeBackRatio;
			}
			
			if (withoutAnimation) {
				_content.y = maxScrollY;
				scrollY();
			} else
				_yTween = Ice.animator.tween(_content, duration / _easeBackTimeRatio, {y:maxScrollY, transitionFunc:_easeOutBack, onUpdate:scrollY});
		} else {
			if (distance != null)
				duration = calculateDynamicThrowDurationByDistance(Math.abs(distance));
			else
				duration = calculateDynamicThrowDuration(ppms);
			
			if (withoutAnimation) {
				_content.y = contentPos;
				scrollY();
			} else {
				var newY:Float = 0;
				if (_paggination == PAGGINATION_VERTICAL)
					newY = calcPositionByVerticalPaggination(contentPos);
				else 
					newY = contentPos;
				_yTween = Ice.animator.tween(_content, duration, {y:newY, transitionFunc:_throwEase, onUpdate:scrollY});
			}
		}
	}
	
	private function posToVerticalScrollPosition(pos:Float) : Float {
		return maxScrollY == 0 ? 0 : pos / maxScrollY;
	}
	
	private function verticalScrollPositionToPos(pos:Float) : Float {
		return maxScrollY == 0 ? 0 : maxScrollY * pos;
	}
	
	private function calcPositionByVerticalPaggination(pos:Float) : Float {
		pos = posToVerticalScrollPosition(pos);
		var vp:Int = verticalPages;
		var pagginationStep:Float = 1 / vp;
		for (i in 0...vp) {
			var cellStart:Float = i * pagginationStep;
			var cellMiddle:Float = cellStart + pagginationStep * .5;
			var cellEnd:Float = cellStart + pagginationStep;
			if (pos < cellMiddle)
				return verticalScrollPositionToPos(cellStart);
			else 
			if (pos >= cellMiddle && pos <= cellEnd)
				return verticalScrollPositionToPos(cellEnd);
		}
		return verticalScrollPositionToPos(1);
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
		return Math.pow(Math.abs(distance), SPRING_TENSION) / (distance > 0 ? 1 : -1);
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
		return Math.pow(Math.abs(distance), 1 / SPRING_TENSION) * (distance > 0 ? 1 : -1);
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
		
		throwScroll();
		
		_isCalcVelocity = false;
	}
	
	public function contentChildren() : Array<DisplayObject> {
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
		clearAnimations();
		_barrierStyleFactory = null;
		removeEventListener(WheelScrollEvent.SCROLL, wheelScrollHandler);
		stopScrolling();
		if (_content != null) {
			_content.removeFromParent(true);
			_content = null;
		}
		if (_forelayer != null) {
			_forelayer.removeFromParent(true);
			_forelayer = null;
		}
		if (_barrier != null) {
			_barrier.removeFromParent(true);
			_barrier = null;
		}
		super.dispose();
	}
}

class Barrier extends IceControl
{
	private var _maxTension:Float = 0;
	public var maxTension(get, set):Float;
	private function get_maxTension():Float{
		return _maxTension;
	}
	private function set_maxTension(v:Float):Float {
		if (_maxTension != v) {
			_maxTension = v;
			if (_maxTension > 0 && _leftTension > _maxTension)
				_leftTension = _maxTension;
			if (_maxTension > 0 && _rightTension > _maxTension)
				_rightTension = _maxTension;
			if (_maxTension > 0 && _topTension > _maxTension)
				_topTension = _maxTension;
			if (_maxTension > 0 && _bottomTension > _maxTension)
				_bottomTension = _maxTension;
			updateBarriers();
		}
		return get_maxTension();
	}
	
	private var _barrierColor:String = 'rgb(0,0,0)';
	public var barrierColor(get, set):String;
	private function get_barrierColor():String{
		return _barrierColor;
	}
	private function set_barrierColor(v:String):String {
		if (_barrierColor != v) {
			_barrierColor = _barrierTopColor = _barrierBottomColor = _barrierLeftColor = _barrierRightColor = v;
			updateBarriers();
		}
		return get_barrierColor();
	}
	
	private var _barrierTopColor:String = 'rgb(0,0,0)';
	public var barrierTopColor(get, set):String;
	private function get_barrierTopColor():String{
		return _barrierTopColor;
	}
	private function set_barrierTopColor(v:String):String {
		if (_barrierTopColor != v) {
			_barrierTopColor = v;
			updateTopBarrier();
		}
		return get_barrierTopColor();
	}
	
	private var _barrierBottomColor:String = 'rgb(0,0,0)';
	public var barrierBottomColor(get, set):String;
	private function get_barrierBottomColor():String{
		return _barrierBottomColor;
	}
	private function set_barrierBottomColor(v:String):String {
		if (_barrierBottomColor != v) {
			_barrierBottomColor = v;
			updateBottomBarrier();
		}
		return get_barrierBottomColor();
	}
	
	private var _barrierLeftColor:String = 'rgb(0,0,0)';
	public var barrierLeftColor(get, set):String;
	private function get_barrierLeftColor():String{
		return _barrierLeftColor;
	}
	private function set_barrierLeftColor(v:String):String {
		if (_barrierLeftColor != v) {
			_barrierLeftColor = v;
			updateLeftBarrier();
		}
		return get_barrierLeftColor();
	}
	
	private var _barrierRightColor:String = 'rgb(0,0,0)';
	public var barrierRightColor(get, set):String;
	private function get_barrierRightColor():String{
		return _barrierColor;
	}
	private function set_barrierRightColor(v:String):String {
		if (_barrierRightColor != v) {
			_barrierRightColor = v;
			updateRightBarrier();
		}
		return get_barrierRightColor();
	}
	
	private var _left:SVGElement;
	private var _right:SVGElement;
	private var _top:SVGElement;
	private var _bottom:SVGElement;
	
	private var _leftTension:Float = 0;
	public var leftTension(get, set):Float;
	private function get_leftTension():Float{
		return _leftTension;
	}
	private function set_leftTension(v:Float):Float {
		if (_leftTension != v) {
			_leftTension = v;
			if (_maxTension > 0 && _leftTension > _maxTension)
				_leftTension = _maxTension;
			updateLeftBarrier();
		}
		return get_leftTension();
	}
	
	private var _rightTension:Float = 0;
	public var rightTension(get, set):Float;
	private function get_rightTension():Float{
		return _rightTension;
	}
	private function set_rightTension(v:Float):Float {
		if (_rightTension != v) {
			_rightTension = v;
			if (_maxTension > 0 && _rightTension > _maxTension)
				_rightTension = _maxTension;
			updateRightBarrier();
		}
		return get_rightTension();
	}
	
	private var _topTension:Float = 0;
	public var topTension(get, set):Float;
	private function get_topTension():Float{
		return _topTension;
	}
	private function set_topTension(v:Float):Float {
		if (_topTension != v) {
			_topTension = v;
			if (_maxTension > 0 && _topTension > _maxTension)
				_topTension = _maxTension;
			updateTopBarrier();
		}
		return get_topTension();
	}
	
	private var _bottomTension:Float = 0;
	public var bottomTension(get, set):Float;
	private function get_bottomTension():Float{
		return _bottomTension;
	}
	private function set_bottomTension(v:Float):Float {
		if (_bottomTension != v) {
			_bottomTension = v;
			if (_maxTension > 0 && _bottomTension > _maxTension)
				_bottomTension = _maxTension;
			updateBottomBarrier();
		}
		return get_bottomTension();
	}
	
	private var _paddingForBlur:Float = 8;
	public var paddingForBlur(get, set):Float;
	private function get_paddingForBlur():Float{
		return _paddingForBlur;
	}
	private function set_paddingForBlur(v:Float):Float {
		if (_paddingForBlur != v) {
			_paddingForBlur = v;
			setSize(_width, _height);
		}
		return get_paddingForBlur();
	}
	
	private var _vertex:Array<{x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float}> = [];
	
	public function new () {
		super(new ElementData({'name':'svg'}));
		_element.innerHTML =
		'<defs>'
			+'<filter id="f1" x="0" y="0">'
				/*+'<feGaussianBlur in="SourceGraphic" stdDeviation="2" />'*/
			+'</filter>'
		+'</defs>';
		_left = createSvg('path');
		_right = createSvg('path');
		_top = createSvg('path');
		_bottom = createSvg('path');
		_element.appendChild(_left);
		_element.appendChild(_right);
		_element.appendChild(_top);
		_element.appendChild(_bottom);
		
		for (i in 0...4)
			_vertex.push({x1:0,y1:0,x2:0,y2:0,x3:0,y3:0});
	}
	
	private function updateLeftBarrier() : Void {
		var v:{x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float} = _vertex[0];
		v.x1 = v.x3 = v.y1 = 0;
		v.x2 = _leftTension;
		v.y3 = _height;
		v.y2 = _height * .5;
		applyVertex(_left, v, _barrierLeftColor);
	}
	
	private function updateRightBarrier() : Void {
		var v:{x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float} = _vertex[1];
		v.x1 = v.x3 = _width;
		v.y1 = 0;
		v.x2 = _width - _rightTension;
		v.y3 = _height;
		v.y2 = _height * .5;
		applyVertex(_right, v, _barrierRightColor);
	}
	
	private function updateTopBarrier() : Void {
		var v:{x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float} = _vertex[2];
		v.x1 = v.y1 = v.y3 = 0;
		v.x2 = _width * .5;
		v.x3 = _width;
		v.y2 = _topTension;
		applyVertex(_top, v, _barrierTopColor);
	}
	
	private function updateBottomBarrier() : Void {
		var v:{x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float} = _vertex[3];
		v.x1 = 0;
		v.y2 = height - _bottomTension;
		v.y1 = v.y3 = _height;
		v.x2 = _width * .5;
		v.x3 = _width;
		applyVertex(_bottom, v, _barrierBottomColor);
	}
	
	private function applyVertex(barrier:SVGElement, v:{x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float}, color:String) : Void {
		setSvgParams(barrier, {d:'M' + v.x1 + ',' + v.y1 + 'C' + v.x1 + ',' + v.y1 + ' ' + v.x2 + ',' + v.y2 + ' ' + v.x3 + ',' + v.y3, fill:color/*, filter:'url(#f1)'*/});
	}
	
	public override function setSize(width:Float, height:Float) : Void {
		super.setSize(width, height);
		updateBarriers();
	}
	
	private function updateBarriers() : Void {
		updateLeftBarrier();
		updateRightBarrier();
		updateTopBarrier();
		updateBottomBarrier();
	}
	
	public override function dispose() : Void {
		_vertex = null;
		if (_left != null) {
			if (_left.parentElement != null) {
				_left.parentElement.removeChild(_left);
				_left = null;
			}
		}
		if (_right != null) {
			if (_right.parentElement != null) {
				_right.parentElement.removeChild(_right);
				_right = null;
			}
		}
		if (_top != null) {
			if (_top.parentElement != null) {
				_top.parentElement.removeChild(_top);
				_top = null;
			}
		}
		if (_bottom != null) {
			if (_bottom.parentElement != null) {
				_bottom.parentElement.removeChild(_bottom);
				_bottom = null;
			}
		}
		super.dispose();
	}
}