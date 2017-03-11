package ru.ice.theme;

import ru.ice.animation.IAnimatable;
import ru.ice.animation.Tween;
import ru.ice.controls.DelayedRenderer;
import ru.ice.display.DisplayObject;
import ru.ice.layout.params.AnchorLayoutParams;
import ru.ice.controls.super.BaseIceObject;
import ru.ice.layout.VerticalLayout;
import ru.ice.layout.AnchorLayout;

import ru.ice.core.Ice;
import ru.ice.controls.Label;
import ru.ice.controls.Button;
import ru.ice.controls.Scroller;
import ru.ice.controls.ScrollBar;
import ru.ice.controls.ScrollPlane;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Theme extends BaseTheme
{
	public function new() 
	{
		super();
		setStyles();
	}
	
	private function setStyles() : Void {
		setStyle(Label, Label.DEFAULT_LABEL_STYLE, setDefaultLabelStyle);
		setStyle(Scroller, Scroller.DEFAULT_SCROLLER_STYLE, setDefaultScrollerStyle);
		setStyle(Button, Button.DEFAULT_SIMPLE_BUTTON_STYLE, setDefaultSimpleButtonStyle);
		setStyle(ScrollPlane, ScrollPlane.DEFAULT_SCROLLPLANE_STYLE, setDefaultScrollPlaneStyle);
		setStyle(ScrollBar, ScrollBar.DEFAULT_VERTICAL_SCROLLBAR_STYLE, setDefaultVerticalScrollbarStyle);
		setStyle(ScrollBar, ScrollBar.DEFAULT_HORIZONTAL_SCROLLBAR_STYLE, setDefaultHorizontalScrollbarStyle);
		setStyle(DelayedRenderer, DelayedRenderer.DEFAULT_DELAYED_RENDERER_STYLE, setDefaultDelayedRendererStyle);
	}
	
	/**
	 * Стиль обычной кнопки по-умолчанию
	 */
	private function setDefaultSimpleButtonStyle(renderer:Button) : Void {
		var layout = new AnchorLayout();
		layout.paddingLeft = 10;
		layout.paddingRight = 10;
		layout.paddingTop = 10;
		layout.paddingBottom = 10;
		renderer.layout = layout;
		renderer.addClass(['simple-button']);
		
		renderer.contentBoxStyleFactory = function(box:BaseIceObject) : Void {
			var lParams:AnchorLayoutParams = new AnchorLayoutParams();
			lParams.isCenter = true;
			box.layoutParams = lParams;
		}
		renderer.upStyleFactory = function(button:Button) : Void {
			button.removeClass(['simple-button-down', 'simple-button-hover', 'simple-button-disabled']);
			button.addClass(['simple-button-up']);
		}
		renderer.downStyleFactory = function(button:Button) : Void {
			button.removeClass(['simple-button-up', 'simple-button-hover', 'simple-button-disabled']);
			button.addClass(['simple-button-down']);
		}
		renderer.hoverStyleFactory = function(button:Button) : Void {
			button.removeClass(['simple-button-up', 'simple-button-down', 'simple-button-disabled']);
			button.addClass(['simple-button-hover']);
		}
		renderer.disabledStyleFactory = function(button:Button) : Void {
			button.removeClass(['simple-button-up', 'simple-button-down', 'simple-button-hover']);
			button.addClass(['simple-button-disabled']);
		}
	}
	
	private function setDefaultDelayedRendererStyle(renderer:DelayedRenderer) : Void {
		renderer.delay = .1;
		renderer.transitionFactory = function(object:DisplayObject) : Void {
			object.addClass(['delayed-renderer']);
		}
	}
	
	/**
	 * Стиль скроллера по-умолчанию
	 */
	private function setDefaultScrollerStyle(renderer:Scroller) : Void {
		renderer.addClass(['scroller']);
	}
	
	/**
	 * Стиль лейбела по-умолчанию
	 */
	private function setDefaultLabelStyle(renderer:Label) : Void {
		renderer.addClass(['label']);
	}
	
	/**
	 * Стиль горизонтального скроллбара по-умолчанию
	 */
	private function setDefaultHorizontalScrollbarStyle(renderer:ScrollBar) : Void {
		renderer.addClass(['scroll-bar-horizontal-track']);
		renderer.minThumbSize = 16;
		
		var thumbTween:IAnimatable = null;
		renderer.thumb.touchable = false;
		renderer.thumb.height = 8;
		renderer.thumb.addClass(['scroll-bar-horizontal-thumb']);
		renderer.upStyleFactory = function(renderer:ScrollBar) : Void {
			if (thumbTween != null) {
				Ice.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.height != 8)
				 thumbTween = cast Ice.animator.tween(renderer.thumb, .1, {height:8});
			renderer.thumb.removeClass(['horizontal-thumb-down-state', 'horizontal-thumb-hover-state', 'horizontal-thumb-disabled-state']);
			renderer.thumb.addClass(['horizontal-thumb-up-state']);
		}
		renderer.downStyleFactory = function(renderer:ScrollBar) : Void {
			if (thumbTween != null) {
				Ice.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.height != 16)
				 thumbTween = cast Ice.animator.tween(renderer.thumb, .1, {height:16});
			renderer.thumb.removeClass(['horizontal-thumb-up-state', 'horizontal-thumb-hover-state', 'horizontal-thumb-disabled-state']);
			renderer.thumb.addClass(['horizontal-thumb-down-state']);
		}
		renderer.hoverStyleFactory = function(renderer:ScrollBar) : Void {
			if (thumbTween != null) {
				Ice.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.height != 16)
				 thumbTween = cast Ice.animator.tween(renderer.thumb, .1, {height:16});
			renderer.thumb.removeClass(['horizontal-thumb-up-state', 'horizontal-thumb-down-state', 'horizontal-thumb-disabled-state']);
			renderer.thumb.addClass(['horizontal-thumb-hover-state']);
		}
		renderer.disabledStyleFactory = function(renderer:ScrollBar) : Void {
			if (thumbTween != null) {
				Ice.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.height != 8)
				 thumbTween = cast Ice.animator.tween(renderer.thumb, .1, {height:8});
			renderer.thumb.removeClass(['horizontal-thumb-up-state', 'horizontal-thumb-down-state', 'horizontal-thumb-hover-state']);
			renderer.thumb.addClass(['horizontal-thumb-disabled-state']);
		}
	
		/*renderer.thumbStyleFactory = function(thumb:ScrollBarThumb) : Void {
			var thumbTween:IAnimatable = null;
			thumb.height = 8;
			thumb.addClass(['scroll-bar-horizontal-thumb']);
			thumb.upStyleFactory = function(thumb:ScrollBarThumb) : Void {
				if (thumbTween != null) {
					Ice.animator.remove(thumbTween);
					thumbTween = null;
				}
				if (thumb.height != 8)
					 thumbTween = cast Ice.animator.tween(thumb, .1, {height:8});
				thumb.removeClass(['horizontal-thumb-down-state', 'horizontal-thumb-hover-state', 'horizontal-thumb-disabled-state']);
				thumb.addClass(['horizontal-thumb-up-state']);
			}
			thumb.downStyleFactory = function(thumb:ScrollBarThumb) : Void {
				if (thumbTween != null) {
					Ice.animator.remove(thumbTween);
					thumbTween = null;
				}
				if (thumb.height != 16)
					 thumbTween = cast Ice.animator.tween(thumb, .1, {height:16});
				thumb.removeClass(['horizontal-thumb-up-state', 'horizontal-thumb-hover-state', 'horizontal-thumb-disabled-state']);
				thumb.addClass(['horizontal-thumb-down-state']);
			}
			thumb.hoverStyleFactory = function(thumb:ScrollBarThumb) : Void {
				if (thumbTween != null) {
					Ice.animator.remove(thumbTween);
					thumbTween = null;
				}
				if (thumb.height != 16)
					 thumbTween = cast Ice.animator.tween(thumb, .1, {height:16});
				thumb.removeClass(['horizontal-thumb-up-state', 'horizontal-thumb-down-state', 'horizontal-thumb-disabled-state']);
				thumb.addClass(['horizontal-thumb-hover-state']);
			}
			thumb.disabledStyleFactory = function(thumb:ScrollBarThumb) : Void {
				if (thumbTween != null) {
					Ice.animator.remove(thumbTween);
					thumbTween = null;
				}
				if (thumb.height != 8)
					 thumbTween = cast Ice.animator.tween(thumb, .1, {height:8});
				thumb.removeClass(['horizontal-thumb-up-state', 'horizontal-thumb-down-state', 'horizontal-thumb-hover-state']);
				thumb.addClass(['horizontal-thumb-disabled-state']);
			}
		}*/
	}
	
	/**
	 * Стиль вертикального скроллбара по-умолчанию
	 */
	private function setDefaultVerticalScrollbarStyle(renderer:ScrollBar) : Void {
		renderer.addClass(['scroll-bar-vertical-track']);
		renderer.minThumbSize = 16;
		
		var thumbTween:IAnimatable = null;
		renderer.thumb.touchable = false;
		renderer.thumb.width = 8;
		renderer.thumb.addClass(['scroll-bar-vertical-thumb']);
		renderer.upStyleFactory = function(renderer:ScrollBar) : Void {
			if (thumbTween != null) {
				Ice.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.width != 8)
				 thumbTween = cast Ice.animator.tween(renderer.thumb, .1, {width:8});
			renderer.thumb.removeClass(['vertical-thumb-down-state', 'vertical-thumb-hover-state', 'vertical-thumb-disabled-state']);
			renderer.thumb.addClass(['vertical-thumb-up-state']);
		}
		renderer.downStyleFactory = function(renderer:ScrollBar) : Void {
			if (thumbTween != null) {
				Ice.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.width != 16)
				 thumbTween = cast Ice.animator.tween(renderer.thumb, .1, {width:16});
			renderer.thumb.removeClass(['vertical-thumb-up-state', 'vertical-thumb-hover-state', 'vertical-thumb-disabled-state']);
			renderer.thumb.addClass(['vertical-thumb-down-state']);
		}
		renderer.hoverStyleFactory = function(renderer:ScrollBar) : Void {
			if (thumbTween != null) {
				Ice.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.width != 16)
				 thumbTween = cast Ice.animator.tween(renderer.thumb, .1, {width:16});
			renderer.thumb.removeClass(['vertical-thumb-up-state', 'vertical-thumb-down-state', 'vertical-thumb-disabled-state']);
			renderer.thumb.addClass(['vertical-thumb-hover-state']);
		}
		renderer.disabledStyleFactory = function(renderer:ScrollBar) : Void {
			if (thumbTween != null) {
				Ice.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.width != 8)
				 thumbTween = cast Ice.animator.tween(renderer.thumb, .1, {width:8});
			renderer.thumb.removeClass(['vertical-thumb-up-state', 'vertical-thumb-down-state', 'vertical-thumb-hover-state']);
			renderer.thumb.addClass(['vertical-thumb-disabled-state']);
		}
		
		/*renderer.thumbStyleFactory = function(thumb:ScrollBarThumb) : Void {
			var thumbTween:IAnimatable = null;
			thumb.width = 8;
			thumb.addClass(['scroll-bar-vertical-thumb']);
			thumb.upStyleFactory = function(thumb:ScrollBarThumb) : Void {
				if (thumbTween != null) {
					Ice.animator.remove(thumbTween);
					thumbTween = null;
				}
				if (thumb.width != 8)
					 thumbTween = cast Ice.animator.tween(thumb, .1, {width:8});
				thumb.removeClass(['vertical-thumb-down-state', 'vertical-thumb-hover-state', 'vertical-thumb-disabled-state']);
				thumb.addClass(['vertical-thumb-up-state']);
			}
			thumb.downStyleFactory = function(thumb:ScrollBarThumb) : Void {
				if (thumbTween != null) {
					Ice.animator.remove(thumbTween);
					thumbTween = null;
				}
				if (thumb.width != 16)
					 thumbTween = cast Ice.animator.tween(thumb, .1, {width:16});
				thumb.removeClass(['vertical-thumb-up-state', 'vertical-thumb-hover-state', 'vertical-thumb-disabled-state']);
				thumb.addClass(['vertical-thumb-down-state']);
			}
			thumb.hoverStyleFactory = function(thumb:ScrollBarThumb) : Void {
				if (thumbTween != null) {
					Ice.animator.remove(thumbTween);
					thumbTween = null;
				}
				if (thumb.width != 16)
					 thumbTween = cast Ice.animator.tween(thumb, .1, {width:16});
				thumb.removeClass(['vertical-thumb-up-state', 'vertical-thumb-down-state', 'vertical-thumb-disabled-state']);
				thumb.addClass(['vertical-thumb-hover-state']);
			}
			thumb.disabledStyleFactory = function(thumb:ScrollBarThumb) : Void {
				if (thumbTween != null) {
					Ice.animator.remove(thumbTween);
					thumbTween = null;
				}
				if (thumb.width != 8)
					 thumbTween = cast Ice.animator.tween(thumb, .1, {width:8});
				thumb.removeClass(['vertical-thumb-up-state', 'vertical-thumb-down-state', 'vertical-thumb-hover-state']);
				thumb.addClass(['vertical-thumb-disabled-state']);
			}
		}*/
	}
	
	/**
	 * Стиль скроллплейна по-умолчанию
	 */
	private function setDefaultScrollPlaneStyle(renderer:Scroller) : Void {
		renderer.addClass(['scroller']);
		
		var layout = new VerticalLayout();
		layout.paddingLeft = 20;
		layout.paddingRight = 20;
		layout.paddingTop = 20;
		layout.paddingBottom = 20;
		layout.gap = 10;
		renderer.layout = layout;
		
		renderer.delayedRendererStyleFactory = function(delayedRenderer:DelayedRenderer) : Void {
			delayedRenderer.delay = .01;
			delayedRenderer.transitionFactory = function(object:DisplayObject) : Void {
				object.addClass(['delayed-renderer']);
			}
		}
	}
}