package ru.ice.controls;

import haxe.Constraints.Function;
import ru.ice.animation.Tween;
import ru.ice.controls.super.BaseStatesObject;
import ru.ice.controls.super.BaseIceObject;
import ru.ice.animation.Transitions;
import ru.ice.animation.IAnimatable;
import ru.ice.events.FingerEvent;
import ru.ice.events.LayoutEvent;
import ru.ice.controls.Scroller;
import ru.ice.controls.Button;
import ru.ice.data.ElementData;
import ru.ice.display.Sprite;
import ru.ice.events.Event;
import ru.ice.math.Point;
import ru.ice.core.Ice;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class ScrollBar extends Scroller
{
	public static inline var DEFAULT_HORIZONTAL_SCROLLBAR_STYLE : String = 'default-horizontal-scrollbar-style';
	public static inline var DEFAULT_VERTICAL_SCROLLBAR_STYLE : String = 'default-vertical-scrollbar-style';
	public static inline var DIRECTION_HORIZONTAL : String = 'direction-horizontal';
	public static inline var DIRECTION_VERTICAL : String = 'direction-vertical';
	
	private var _direction:String;
	public var direction(get, set):String;
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
						autosize = BaseIceObject.AUTO_SIZE_CONTENT_WIDTH;
						_isDraggingHorizontally = false;
						_isDraggingVertically = true;
						styleName = DEFAULT_VERTICAL_SCROLLBAR_STYLE;
					}
					default:
					{
						autosize = BaseIceObject.AUTO_SIZE_CONTENT_HEIGHT;
						_isDraggingHorizontally = true;
						_isDraggingVertically = false;
						styleName = DEFAULT_HORIZONTAL_SCROLLBAR_STYLE;
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
	
	private var _helperPoint:Point = new Point();
	
	private var _thumb:ScrollBarThumb;
	public var thumb(get, never) : ScrollBarThumb;
	private function get_thumb() : ScrollBarThumb {
		return _thumb;
	}
	
	public var thumbStyleFactory(never, set):Function;
	private function set_thumbStyleFactory(v:Function):Function {
		_thumb.styleFactory = v;
		return v;
	}
	
	private var _minThumbSize : Float = 0;
	public var minThumbSize(get, set) : Float;
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
	
	public function new(?elementData:ElementData, ?thumbElementData:ElementData, direction:String = 'direction-horizontal') 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'scrollbar'});
		super(elementData);
		if (thumbElementData == null)
			thumbElementData = new ElementData({'name':'thumb'});
		
		_ppmsScale = 1;
		
		_thumb = new ScrollBarThumb(thumbElementData);
		_thumb.autosize = BaseIceObject.AUTO_SIZE_CONTENT;
		_thumb.initializedParent = this;
		addItem(_thumb);
		this.direction = direction;
	}
	
	@:allow(ru.ice.core.Ice)
	private override function initialize() : Void {
		super.initialize();
		_thumb.initialize();
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
		/*if (_isDraggingHorizontally) {
			var ts:Float = getThumbSize();
			var vw:Float = ts;
			maxScrollX = contentWidth - vw;
		} else {
			maxScrollX = 0;
		}
		if (_isDraggingVertically) {
			var ts:Float = getThumbSize();
			var vh:Float = ts;
			maxScrollY = contentHeight - vh;
		} else {
			maxScrollY = 0;
		}*/
		if (_direction == DIRECTION_VERTICAL)
			_thumb.height = getThumbSize();
		else
			_thumb.width = getThumbSize();
	}
	
	private function getThumbSize() : Float {
		var size:Float = 0;
		var thumbSize:Float = _ownerContentSize > 0 ? Math.abs(_ownerSize / _ownerContentSize) : 0;
		if (_direction == DIRECTION_VERTICAL) {
			thumbSize *= contentHeight;
			thumbSize = getThumbActualSize(thumbSize);
		} else {
			thumbSize *= contentWidth;
			thumbSize = getThumbActualSize(thumbSize);
		}
		return thumbSize;
	}
	
	private function getThumbActualSize(size:Float) : Float {
		if (Math.isNaN(size))
			return 0;
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
			_curTP = e.touchPoint;
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
	
	/*private override function get_maxScrollX() : Float
	{
		return _isDraggingHorizontally ? contentWidth - getThumbSize() : 0;
	}
	
	private override function get_maxScrollY() : Float
	{
		return _isDraggingVertically ? contentHeight - getThumbSize() : 0;
	}*/
	
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
			maxScrollX = contentWidth - vw;
			var offsetLeft:Float = 0;
			var rightOffset:Float = _startPos.x + vw - contentWidth;
			if (_startPos.x <= 0)
				offsetLeft = calculateSpringOffset(dec);
			else if (rightOffset >= 0)
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
			var ts:Float = getThumbSize();
			var vh:Float = ts;
			var dec:Float = _thumb.height - vh;
			maxScrollY = contentHeight - vh;
			var offsetTop:Float = 0;
			var bottomOffset:Float = _startPos.y + vh - contentHeight;
			if (_startPos.y <= 0)
				offsetTop = calculateSpringOffset(dec);
			else if (bottomOffset >= 0)
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
	private override function calculateViewportBound() : Void
	{
		// Новая координата вьюпорта для линейного перемещения
		var offsetViewport:Point = _locCurTP.deduct(_locStartTP).add(_viewportOffset, false);
		// По X
		if (_isDraggingHorizontally) {
			var vw:Float = getThumbSize();
			var ww:Float = 0;
			var offsetLeft:Float = 0;
			var rightOffset:Float = offsetViewport.x + vw - contentWidth;
			if (offsetViewport.x <= 0) {
				_viewportAbsOffset.x = offsetViewport.x;
				offsetLeft = 0;
				ww = getThumbActualSize(vw - Math.abs(calculateSpringDistance(offsetViewport.x)));
			} else if (rightOffset >= 0) {
				_viewportAbsOffset.x = offsetViewport.x;
				ww = getThumbActualSize(vw - Math.abs(calculateSpringDistance(rightOffset)));
				offsetLeft = contentWidth - ww;
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
			var bottomOffset:Float = offsetViewport.y + vh - contentHeight;
			if (offsetViewport.y <= 0) {
				_viewportAbsOffset.y = offsetViewport.y;
				offsetTop = 0;
				hh = getThumbActualSize(vh - Math.abs(calculateSpringDistance(offsetViewport.y)));
			} else if (bottomOffset >= 0) {
				_viewportAbsOffset.y = offsetViewport.y;
				hh = getThumbActualSize(vh - Math.abs(calculateSpringDistance(bottomOffset)));
				offsetTop = contentHeight - hh;
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
				_xTween = Ice.animator.tween(_content, durationX, {x:contentWidth - ts, transitionFunc:_throwEase, onUpdate:scrollX});
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
				_yTween = Ice.animator.tween(_content, durationY, {y:contentHeight - ts, transitionFunc:_throwEase, onUpdate:scrollY});
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
			springPath = contentWidth - vw + calculateSpringOffset(offset);
		
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
							_content.x = contentWidth - _thumb.width;
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
			springPath = contentWidth - vh + calculateSpringOffset(offset);
		
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
							_content.y = contentHeight - _thumb.height;
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
		if (_direction == DIRECTION_VERTICAL)
			verticalScrollPosition = ratio;
		else
			horizontalScrollPosition = ratio;
	}
	
	/**
	 * Очищает все анимации "ползунка"
	 */
	private override function clearAnimations() : Void
	{
		super.clearAnimations();
		Ice.animator.remove(_wTween);
		Ice.animator.remove(_hTween);
		Ice.animator.remove(_helpTween);
	}
	
	public override function resize(?data:Dynamic) : Void
	{
		super.resize(data);
		/*if (_isDraggingHorizontally) {
			var ts:Float = getThumbSize();
			var vw:Float = ts;
			maxScrollX = contentWidth - vw;
		} else {
			maxScrollX = 0;
		}
		if (_isDraggingVertically) {
			var ts:Float = getThumbSize();
			var vh:Float = ts;
			maxScrollY = contentHeight - vh;
		} else {
			maxScrollY = 0;
		}*/
		updateThumbSize();
	}
	
	private function updateThumbSize() : Void
	{
		setScrollParams();
	}
	
	public override function dispose() : Void
	{
		if (_thumb != null) {
			_thumb.removeFromParent(true);
			_thumb = null;
		}
		super.dispose();
	}
}

class ScrollBarThumb extends BaseStatesObject {
	public function new (?elementData:ElementData, ?initial:Bool = false) {
		super(elementData, initial);
	}
}