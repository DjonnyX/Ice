package ru.ice.controls;

import haxe.Constraints.Function;
import ru.ice.animation.Tween;
import ru.ice.controls.super.BaseStatesControl;
import ru.ice.controls.super.IceControl;
import ru.ice.animation.Transitions;
import ru.ice.animation.IAnimatable;
import ru.ice.events.FingerEvent;
import ru.ice.controls.Scroller;
import ru.ice.controls.Button;
import ru.ice.data.ElementData;
import ru.ice.display.Sprite;
import ru.ice.events.Event;
import ru.ice.events.WheelScrollEvent;
//import ru.ice.utils.FloatUtil;
import ru.ice.math.Point;
import ru.ice.core.Ice;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class ScrollBar extends Scroller
{
	public static inline var DEFAULT_HORIZONTAL_STYLE : String = 'default-horizontal-scrollbar-style';
	public static inline var DEFAULT_VERTICAL_STYLE : String = 'default-vertical-scrollbar-style';
	public static inline var DIRECTION_HORIZONTAL : String = 'direction-horizontal';
	public static inline var DIRECTION_VERTICAL : String = 'direction-vertical';
	
	/**
	 * public
	 * Свойство ratio задает нелинейный коэффициент соотношения высоты контента к скроллеру
	 * @return Float
	 */
	public var ratio(get, set):Float;
	private var _ratio:Float = .75;
	private function get_ratio():Float {
		return _ratio;
	}
	private function set_ratio(v:Float):Float {
		if (_ratio != v)
			_ratio = v;
		return get_ratio();
	}
	
	private override function set_isHover(v:Bool) : Bool {
		if (_isHover != v) {
			_isHover = v;
			updateState();
			dispatchEventWith(v||_isPress?Event.SCROLLBAR_MAXIMIZE:Event.SCROLLBAR_MINIMIZE, true);
		}
		return get_isHover();
	}
	
	/**
	 * public
	 * Напрвленность.
	 * Доступные значения: DIRECTION_HORIZONTAL(горизонтальная) и DIRECTION_VERTICAL(вертикальная).
	 * @return String
	 */
	public var direction(get, set):String;
	private var _direction:String;
	private function get_direction():String {
		return _direction;
	}
	private function set_direction(v:String):String {
		if (_direction != v) {
			if (!_isInitialized) {
				_direction = v;
				switch (v) {
					case DIRECTION_VERTICAL:
					{
						_isDraggingHorizontally = false;
						_isDraggingVertically = true;
						styleName = DEFAULT_VERTICAL_STYLE;
					}
					default:
					{
						_isDraggingHorizontally = true;
						_isDraggingVertically = false;
						styleName = DEFAULT_HORIZONTAL_STYLE;
					}
				}
				updateThumbSize();
			} else {
				#if debug
					throw 'Direction can not be changed after initialized';
				#end
			}
		}
		return get_direction();
	}
	
	/**
	 * public
	 * Возвращает true, если "бегунок" сжимается, т.е. выходит за пределы допустимых позиций.
	 * @return Bool
	 */
	public var isOutScrollPosition(get, never) : Bool;
	private function get_isOutScrollPosition() : Bool {
		if (_direction == DIRECTION_HORIZONTAL) {
			var sp:Float = horizontalScrollPosition;
			return sp > maxScrollX || sp < 0;
		} else if (_direction == DIRECTION_VERTICAL) {
			var sp:Float = verticalScrollPosition;
			return sp > maxScrollY || sp < 0;
		}
		return false;
	}
	
	/**
	 * override
	 */
	private override function get_horizontalScrollPosition() : Float {
		var ts:Float = getThumbActualSize(getThumbSize());
		var p:Float = maxScrollX;
		var xx:Float = _content.x;
		var s:Float = p == 0 ? 0 : xx / p;
		if (s > 1) {
			xx += calculateSpringDistance(ts - _thumb.width);
		} else if(s <= 0) {
			xx -= calculateSpringDistance(ts - _thumb.width);
		}
		return p == 0 ? 0 : xx / p;
	}
	
	/**
	 * override
	 */
	private override function get_verticalScrollPosition() : Float {
		var ts:Float = getThumbActualSize(getThumbSize());
		var p:Float = maxScrollY;
		var yy:Float = _content.y;
		var s:Float = p == 0 ? 0 : yy / p;
		if (s > 1) {
			yy += calculateSpringDistance(ts - _thumb.height);
		} else if(s <= 0) {
			yy -= calculateSpringDistance(ts - _thumb.height);
		}
		return p == 0 ? 0 : yy / p;
	}
	
	private var _helperPoint:Point = new Point();
	
	/**
	 * public
	 * Бегунок
	 * @return ScrollBarThumb
	 */
	public var thumb(get, never) : ScrollBarThumb;
	private var _thumb:ScrollBarThumb;
	private function get_thumb() : ScrollBarThumb {
		return _thumb;
	}
	
	/**
	 * public
	 * Функция стиля бегунка
	 * @return Function
	 */
	public var thumbStyleFactory(never, set):Function;
	private function set_thumbStyleFactory(v:Function):Function {
		_thumb.styleFactory = v;
		return v;
	}
	
	/**
	 * public
	 * Указывает минимальный размер бегунка
	 * @return Function
	 */
	public var minThumbSize(get, set) : Float;
	private var _minThumbSize : Float = 0;
	public function get_minThumbSize() : Float {
		return _minThumbSize;
	}
	public function set_minThumbSize(v:Float) : Float {
		if (_minThumbSize != v) {
			_minThumbSize = v;
			setScrollParams();
		}
		return get_minThumbSize();
	}
	
	/**
	 * Анимация по оси X.
	 */
	@:noPrivateAccess
	private var _wTween:IAnimatable;
	
	/**
	 * Анимация по оси Y.
	 */
	@:noPrivateAccess
	private var _hTween:IAnimatable;
	/**
	 * Анимация по оси X.
	 */
	@:noPrivateAccess
	private var _helpTween:IAnimatable;
	
	private var _ownerSize(default, null):Float = 0;
	private var _ownerContentSize(default, null):Float = 0;
	
	public var offsetRatioFunction(get, set):Float->Float->Float->Float;
	private var _offsetRatioFunction : Float->Float->Float->Float;
	private function get_offsetRatioFunction() : Float->Float->Float->Float {
		return _offsetRatioFunction;
	}
	private function set_offsetRatioFunction(v:Float->Float->Float->Float) : Float->Float->Float->Float {
		if (_offsetRatioFunction != v)
			_offsetRatioFunction = v;
		return _offsetRatioFunction;
	}
	
	public function new(?elementData:ElementData, ?thumbElementData:ElementData, direction:String = 'direction-horizontal') 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'scrollbar'});
		super(elementData);
		if (thumbElementData == null)
			thumbElementData = new ElementData({'name':'thumb'});
		
		_ppmsScale = 1;
		
		_thumb = new ScrollBarThumb(thumbElementData);
		addItem(_thumb);
		this.direction = direction;
	}
	
	@:allow(ru.ice.controls)
	private function setScrollParams(?os:Float, ?ocs:Float) : Void {
		if (os != null)
			_ownerSize = os;
		if (ocs != null)
			_ownerContentSize = ocs;
		if (_ownerContentSize == null && _ownerSize == null)
			return;
		calculateViewportOffset();
		if (_direction == DIRECTION_VERTICAL)
			_thumb.height = getThumbSize();
		else
			_thumb.width = getThumbSize();
	}
	
	private function getThumbSize() : Float {
		var thumbSize:Float = _ownerContentSize > 0 ? Math.pow(Math.abs(_ownerSize / _ownerContentSize), (_ratio - Math.abs(_ownerSize / _ownerContentSize) * _ratio)) : 0;
		if (_direction == DIRECTION_VERTICAL) {
			thumbSize *= _height;
			thumbSize = getThumbActualSize(thumbSize);
		} else {
			thumbSize *= _width;
			thumbSize = getThumbActualSize(thumbSize);
		}
		return thumbSize;
	}
	
	private function getThumbActualSize(size:Float) : Float {
		/*if (Math.isNaN(size))
			return 0;*/
		if (size < _minThumbSize)
			size = _minThumbSize;
		return size;
	}
	
	private override function stageMoveHandler(e:FingerEvent) : Void
	{
		if (_isPress) {
			e.stopImmediatePropagation();
			_isDragging = true;
			
			_prevTP = _curTP;
			_curTP = e.touchPoint.clone();
			_locCurTP = globalToLocal(_curTP);
			
			calculateViewportBound();
			
			if (_isDraggingHorizontally) {
				_content.x = _viewportBound.x;
				_thumb.width = _viewportBound.width;
				scrollX();
			}
			if (_isDraggingVertically) {
				_content.y = _viewportBound.y;
				_thumb.height = _viewportBound.height;
				scrollY();
			}
		}
	}
	
	private override function stageUpHandler(e:FingerEvent) : Void
	{
		super.stageUpHandler(e);
		if (!_isHover) dispatchEventWith(Event.SCROLLBAR_MINIMIZE, true);
	}
	
	private override function wheelScrollHandler(e:WheelScrollEvent) : Void
	{
		if (e.ctrlKey)
			return;
		e.stopImmediatePropagation();
		
		var currentTime:Float = Date.now().getTime();
		var wheelTime:Float = currentTime - _lastWheelTime;
		_lastWheelTime = currentTime;
		
		if (wheelTime > Scroller.WHEEL_TIME_TRESHOLD || _wheelTreshold == Scroller.WHEEL_TRESHOLD) {
			var offsetRatio:Float = offsetRatioFunction != null ? offsetRatioFunction(_ownerSize, _ownerContentSize, _ratio) : Math.abs(_ownerSize / _ownerContentSize) * _ratio;
			var spinX:Float = (e.deltaX > 0 ? -1 : 1) * offsetRatio;
			var spinY:Float = (e.deltaY > 0 ? -1 : 1) * offsetRatio;
			
			throwWheel(spinX, spinY, false);
		}
		
		if (wheelTime < Scroller.WHEEL_TIME_TRESHOLD)
			_wheelTreshold += 1;
		else
			_wheelTreshold = 0;
	}
	
	private var _lastOwnerContentSize:Float = 0;
	private var _lastOwnerSize:Float = 0;
	private var _lastRatio:Float = 0;
	private var _lastDirection:String;
	private var _lastWidth:Float = 0;
	private var _lastHeight:Float = 0;
	private var _lastMaxScrollX:Float = 0;
	private var _lastMaxScrollY:Float = 0;
	
	private override function get_maxScrollX():Float {
		if (_lastWidth != _width || _lastDirection != _direction || _lastRatio != _ratio || _lastOwnerSize != _ownerSize || _lastOwnerContentSize != _ownerContentSize) {
			_lastDirection = _direction;
			_lastRatio = _ratio;
			_lastOwnerSize = _ownerSize;
			_lastOwnerContentSize = _ownerContentSize;
			_lastMaxScrollX = _width - getThumbSize();
			return _lastMaxScrollX;
		}
		return _lastMaxScrollX;
	}
	
	private override function get_maxScrollY():Float {
		if (_lastHeight != _height || _lastDirection != _direction || _lastRatio != _ratio || _lastOwnerSize != _ownerSize || _lastOwnerContentSize != _ownerContentSize) {
			_lastDirection = _direction;
			_lastRatio = _ratio;
			_lastOwnerSize = _ownerSize;
			_lastOwnerContentSize = _ownerContentSize;
			_lastMaxScrollY = _height - getThumbSize();
			return _lastMaxScrollY;
		}
		return _lastMaxScrollY;
	}
	
	/**
	 * Считает начальные размеры сдвига (без эластичности)
	 */
	private override function calculateViewportOffset() : Void
	{
		// По X
		if (_isDraggingHorizontally) {
			var ts:Float = getThumbSize();
			var vw:Float = ts;
			var dec:Float = _thumb.width - vw;
			var offsetLeft:Float = 0;
			var rightOffset:Float = _startPos.x + vw - _width;
			if (_startPos.x <= 0)
				offsetLeft = calculateSpringOffset(dec);
			else if (rightOffset >= 0)
				offsetLeft = _width - vw + calculateSpringOffset(rightOffset);
			else
				offsetLeft = _startPos.x;
			_viewportOffset.x = offsetLeft;
		} else {
			_viewportOffset.x = 0;
		}
		// По Y
		if (_isDraggingVertically) {
			var ts:Float = getThumbSize();
			var vh:Float = ts;
			var dec:Float = _thumb.height - vh;
			var offsetTop:Float = 0;
			var bottomOffset:Float = _startPos.y + vh - _height;
			if (_startPos.y <= 0)
				offsetTop = calculateSpringOffset(dec);
			else if (bottomOffset >= 0)
				offsetTop = _height - vh + calculateSpringOffset(bottomOffset);
			else
				offsetTop = _startPos.y;
			_viewportOffset.y = offsetTop;
		} else {
			_viewportOffset.y = 0;
		}
	}
	
	/**
	 * Считает позиции и размеры вьюпорта
	 */
	private override function calculateViewportBound() : Void
	{
		// Новая координата вьюпорта для линейного перемещения
		var offsetViewport:Point = _locCurTP.deduct(_locStartTP).add(_viewportOffset, false);
		// По X
		if (_isDraggingHorizontally) {
			var vw:Float = getThumbSize();
			var ww:Float = 0;
			var offsetLeft:Float = 0;
			var rightOffset:Float = offsetViewport.x + vw - _width;
			if (offsetViewport.x <= 0) {
				_viewportAbsOffset.x = offsetViewport.x;
				offsetLeft = 0;
				ww = getThumbActualSize(vw - Math.abs(calculateSpringDistance(offsetViewport.x)));
			} else if (rightOffset >= 0) {
				_viewportAbsOffset.x = offsetViewport.x;
				ww = getThumbActualSize(vw - Math.abs(calculateSpringDistance(rightOffset)));
				offsetLeft = _width - ww;
			} else {
				offsetLeft = offsetViewport.x;
				ww = getThumbActualSize(vw);
			}
			_viewportBound.x = offsetLeft;
			_viewportBound.width = ww;
		} else {
			_viewportBound.x = 0;
			_viewportBound.width = 0;
		}
		// По Y
		if (_isDraggingVertically) {
			var vh:Float = getThumbSize();
			var hh:Float = 0;
			var offsetTop:Float = 0;
			var bottomOffset:Float = offsetViewport.y + vh - _height;
			if (offsetViewport.y <= 0) {
				_viewportAbsOffset.y = offsetViewport.y;
				offsetTop = 0;
				hh = getThumbActualSize(vh - Math.abs(calculateSpringDistance(offsetViewport.y)));
			} else if (bottomOffset >= 0) {
				_viewportAbsOffset.y = offsetViewport.y;
				hh = getThumbActualSize(vh - Math.abs(calculateSpringDistance(bottomOffset)));
				offsetTop = _height - hh;
			} else {
				offsetTop = offsetViewport.y;
				hh = getThumbActualSize(vh);
			}
			_viewportBound.y = offsetTop;
			_viewportBound.height = hh;
			
		} else {
			_viewportBound.y = 0;
			_viewportBound.height = 0;
		}
	}
	
	private override function throwScroll() : Void
	{
		if (_thumb == null)
			return;
		if (_isDraggingHorizontally) {
			var ts:Float = getThumbSize();
			var durationX:Float;
			var rightOffset:Float = _content.x - maxScrollX;
			durationX = calculateDynamicThrowDurationByDistance(Math.abs(_viewportAbsOffset.x));
			if (_content.x <= 0 && _thumb.width < ts) {
				Ice.animator.remove(_wTween);
				Ice.animator.remove(_xTween);
				_content.x = 0;
				_xTween = Ice.animator.tween(_content, durationX, {x:0, transitionFunc:_throwEase, onUpdate:scrollX});
				_wTween = Ice.animator.tween(_thumb, durationX, {width:ts, transitionFunc:_throwEase});
			} else if (rightOffset > 0) {
				Ice.animator.remove(_xTween);
				Ice.animator.remove(_wTween);
				_xTween = Ice.animator.tween(_content, durationX, {x:_width - ts, transitionFunc:_throwEase, onUpdate:scrollX});
				_wTween = Ice.animator.tween(_thumb, durationX, {width:ts, transitionFunc:_throwEase});
			} else if (_velocityX != 0 && !Math.isNaN(_velocityX))
				throwScrollInertialForceX();
		}
		if (_isDraggingVertically) {
			var ts:Float = getThumbSize();
			var durationY:Float;
			var bottomOffset:Float = _content.y - maxScrollY;
			durationY = calculateDynamicThrowDurationByDistance(Math.abs(_viewportAbsOffset.y));
			if (_content.y <= 0 && _thumb.height < ts) {
				Ice.animator.remove(_hTween);
				Ice.animator.remove(_yTween);
				_content.y = 0;
				_yTween = Ice.animator.tween(_content, durationY, {y:0, transitionFunc:_throwEase, onUpdate:scrollY});
				_hTween = Ice.animator.tween(_thumb, durationY, {height:ts, transitionFunc:_throwEase});
			} else if (bottomOffset > 0) {
				Ice.animator.remove(_yTween);
				Ice.animator.remove(_hTween);
				_yTween = Ice.animator.tween(_content, durationY, {y:_height - ts, transitionFunc:_throwEase, onUpdate:scrollY});
				_hTween = Ice.animator.tween(_thumb, durationY, {height:ts, transitionFunc:_throwEase});
			} else if (_velocityY != 0 && !Math.isNaN(_velocityY))
				throwScrollInertialForceY();
		}
	}
	
	private override function throwScrollInertialForceX(distance:Float = null, withoutAnimation:Bool = false) : Void
	{
		var vw:Float = getThumbSize();
		
		Ice.animator.remove(_helpTween);
		Ice.animator.remove(_xTween);
		Ice.animator.remove(_wTween);
		
		var ppms:Float = 0, pathLength:Float;
		if (distance == null) {
			ppms = calculatePPMS(_velocityX, _scopeVelocityX);
			pathLength = -calculateThrowDistance(ppms);
		} else
			pathLength = distance;
		
		var contentPos:Float = _content.x + pathLength; 
		var offset:Float = contentPos - maxScrollX;
		var pos:Float = _content.x;
		var springPath:Float = 0, duration:Float;
		
		if (contentPos > 0)
			springPath = calculateSpringOffset(contentPos);
		else if (offset < 0)
			springPath = _width - vw + calculateSpringOffset(offset);
		
		pos += springPath;
		
		if (contentPos < 0) {
			duration = calculateDynamicThrowDurationByDistance(Math.abs(pos));
			if (withoutAnimation) {
				_content.x = 0;
				scrollX();
			} else {
				_helperPoint.x = _content.x;
				_helpTween = Ice.animator.tween(_helperPoint, .5, {x:0, transition:Transitions.EASE_OUT_BACK, onUpdate:function () {
						if (_helperPoint.x >= 0) {
							_content.x = _helperPoint.x;
						} else {
							setElasticThumbWidth(Math.abs(_helperPoint.x));
							_content.x = 0;
						}
						scrollX();
					}
				});
			}
		} else if (offset > 0) {
			duration = calculateDynamicThrowDurationByDistance(Math.abs(pos) - maxScrollX);
			if (withoutAnimation) {
				_content.x = maxScrollX;
				scrollX();
			} else {
				_helperPoint.x = _content.x;
				_helpTween = Ice.animator.tween(_helperPoint, .5, {x:maxScrollX, transition:Transitions.EASE_OUT_BACK, onUpdate:function () {
						if (_helperPoint.x <= maxScrollX) {
							_content.x = _helperPoint.x;
						} else {
							setElasticThumbWidth(Math.abs(_helperPoint.x - maxScrollX));
							_content.x = _width - _thumb.width;
						}
						scrollX();
					}
				});
			}
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
	
	private override function throwScrollInertialForceY(distance:Float = null, withoutAnimation:Bool = false) : Void
	{
		var vh:Float = getThumbSize();
		
		Ice.animator.remove(_helpTween);
		Ice.animator.remove(_yTween);
		Ice.animator.remove(_hTween);
		
		var ppms:Float = 0, pathLength:Float;
		if (distance == null) {
			ppms = calculatePPMS(_velocityY, _scopeVelocityY);
			pathLength = -calculateThrowDistance(ppms);
		} else
			pathLength = distance;
		
		var contentPos:Float = _content.y + pathLength; 
		var offset:Float = contentPos - maxScrollY;
		var pos:Float = _content.y;
		var springPath:Float = 0, duration:Float;
		
		if (contentPos > 0)
			springPath = calculateSpringOffset(contentPos);
		else if (offset < 0)
			springPath = _width - vh + calculateSpringOffset(offset);
		
		pos += springPath;
		
		if (contentPos < 0) {
			duration = calculateDynamicThrowDurationByDistance(Math.abs(pos));
			if (withoutAnimation) {
				_content.y = 0;
				scrollY();
			} else {
				_helperPoint.y = _content.y;
				_helpTween = Ice.animator.tween(_helperPoint, .5, {y:0, transition:Transitions.EASE_OUT_BACK, onUpdate:function () {
						if (_helperPoint.y >= 0) {
							_content.y = _helperPoint.y;
						} else {
							setElasticThumbHeight(Math.abs(_helperPoint.y));
							_content.y = 0;
						}
						scrollY();
					}
				});
			}
		} else if (offset > 0) {
			duration = calculateDynamicThrowDurationByDistance(Math.abs(pos) - maxScrollY);
			if (withoutAnimation) {
				_content.y = maxScrollY;
				scrollY();
			} else {
				_helperPoint.y = _content.y;
				_helpTween = Ice.animator.tween(_helperPoint, .5, {y:maxScrollY, transition:Transitions.EASE_OUT_BACK, onUpdate:function () {
						if (_helperPoint.y <= maxScrollY) {
							_content.y = _helperPoint.y;
						} else {
							setElasticThumbHeight(Math.abs(_helperPoint.y - maxScrollY));
							_content.y = _height - _thumb.height;
						}
						scrollY();
					}
				});
			}
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
	
	private function setElasticThumbWidth(distance:Float): Void
	{
		var vw:Float = getThumbSize();
		var w:Float = getThumbActualSize(vw - Math.abs(calculateSpringDistance(distance)));
		_thumb.width = w;
	}
	
	private function setElasticThumbHeight(distance:Float): Void
	{
		var vh:Float = getThumbSize();
		var h:Float = getThumbActualSize(vh - Math.abs(calculateSpringDistance(distance)));
		_thumb.height = h;
	}
	
	public function setScrollPosition(ratio:Float) : Void
	{
		clearAnimations();
		if (_direction == DIRECTION_VERTICAL) {
			var p:Dynamic = getThumbParamsByRatio(ratio);
			thumb.height = p.size;
			verticalScrollPosition = p.ratio;
		} else {
			var p:Dynamic = getThumbParamsByRatio(ratio);
			thumb.width = p.size;
			horizontalScrollPosition = p.ratio;
		}
	}
	
	/**
	 * Возвращает нормализованный ratio и размер themb'а {ratio:..., size:...}
	 */
	private function getThumbParamsByRatio(ratio:Float) : Dynamic {
		var r:Float = ratio;
		var size:Float = getThumbSize();
		if (ratio > 1) {
			r = 1;
			var ras:Float = getThumbActualSize(size / ratio);
			var as:Float = getThumbActualSize(size);
			var sRatio:Float = 0;
			if (_direction == DIRECTION_VERTICAL) {
				var maxScrollY:Float = this.maxScrollY + as - ras;
				sRatio = this.maxScrollY / maxScrollY;
			} else {
				var maxScrollX:Float = this.maxScrollX + as - ras;
				sRatio = this.maxScrollX / maxScrollX;
			}
			return {ratio:r / sRatio, size:ras};
		} else if (ratio < 0) {
			r = 0;
			return {ratio:r, size:getThumbActualSize(size + (size * ratio))};
		}
		return {ratio:r, size:getThumbActualSize(size)};
	}
	
	/**
	 * Очищает все анимации "ползунка"
	 */
	private override function clearAnimations() : Void
	{
		super.clearAnimations();
		if (_wTween != null) {
			Ice.animator.remove(_wTween);
			_wTween = null;
		}
		if (_hTween != null) {
			Ice.animator.remove(_hTween);
			_hTween = null;
		}
		if (_helpTween != null) {
			Ice.animator.remove(_helpTween);
			_helpTween = null;
		}
	}
	
	public override function resize(?data:ResizeData) : Void {}
	
	public override function resizeContent(?data:ResizeData) : Void {}
	
	private function updateThumbSize() : Void
	{
		setScrollParams();
	}
	
	public override function dispose() : Void
	{
		_offsetRatioFunction = null;
		if (_thumb != null) {
			_thumb.removeFromParent(true);
			_thumb = null;
		}
		super.dispose();
	}
}

class ScrollBarThumb extends BaseStatesControl {
	public function new (?elementData:ElementData, ?initial:Bool = false) {
		super(elementData, initial, false);
	}
}