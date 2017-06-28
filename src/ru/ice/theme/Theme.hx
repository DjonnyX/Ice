package ru.ice.theme;

import ru.ice.animation.IAnimatable;
import ru.ice.animation.Tween;
import ru.ice.controls.DelayedBuilder;
import ru.ice.controls.Image;
import ru.ice.display.DisplayObject;
import ru.ice.events.Event;
import ru.ice.layout.HorizontalLayout;
import ru.ice.layout.params.AnchorLayoutParams;
import ru.ice.controls.super.BaseListItemControl;
import ru.ice.controls.super.IceControl;
import ru.ice.layout.VerticalLayout;
import ru.ice.layout.AnchorLayout;
import ru.ice.controls.itemRenderer.TabBarItemRenderer;
import ru.ice.controls.IScrollBar;
import ru.ice.core.Ice;
import ru.ice.controls.Label;
import ru.ice.controls.Header;
import ru.ice.controls.TabBar;
import ru.ice.controls.Button;
import ru.ice.controls.Screen;
import ru.ice.controls.Scroller;
//import ru.ice.controls.Preloader;
import ru.ice.controls.ScrollBar;
import ru.ice.controls.ScrollPlane;
import ru.ice.controls.VideoPlayer;

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
		setStyle(Label, Label.DEFAULT_STYLE, setDefaultLabelStyle);
		//setStyle(Header, Header.DEFAULT_STYLE, setDefaultHeaderStyle);
		setStyle(Button, Button.DEFAULT_STYLE, setDefaultSimpleButtonStyle);
		setStyle(Screen, Screen.DEFAULT_STYLE, setDefaultScreenStyle);
		//setStyle(TabBar, TabBar.DEFAULT_STYLE, setDefaultTabBarStyle);
		//setStyle(TabBarItemRenderer, TabBarItemRenderer.DEFAULT_STYLE, setDefaultTabBarItemRendererStyle);
		//setStyle(Preloader, Preloader.DEFAULT_STYLE, setPreloaderStyle);
		setStyle(Scroller, Scroller.DEFAULT_STYLE, setDefaultScrollerStyle);
		setStyle(ScrollPlane, ScrollPlane.DEFAULT_STYLE, setDefaultScrollPlaneStyle);
		setStyle(IScrollBar, ScrollBar.DEFAULT_VERTICAL_STYLE, setDefaultVerticalScrollbarStyle);
		setStyle(IScrollBar, ScrollBar.DEFAULT_HORIZONTAL_STYLE, setDefaultHorizontalScrollbarStyle);
		setStyle(DelayedBuilder, DelayedBuilder.DEFAULT_STYLE, setDefaultDelayedBuilderStyle);
		setStyle(VideoPlayer, VideoPlayer.DEFAULT_STYLE, setDefaultVideoPlayerStyle);
	}
	
	private function setDefaultVideoPlayerStyle(videoPlayer:VideoPlayer) : Void {
		videoPlayer.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_CONTENT);
		videoPlayer.videoContainerStyleFactory = function(renderer:IceControl) : Void {
			renderer.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_HTML_CONTENT);
		}
	}
	
	/*private function setDefaultHeaderStyle(header:Header) : Void {
		header.snapTo(IceControl.SNAP_TO_SELF, IceControl.SNAP_TO_SELF);
		var vLayout:VerticalLayout = new VerticalLayout();
		vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
		vLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_JUSTIFY;
		//vLayout.padding = 10;
		header.layout = vLayout;
		header.addClass(['i-header']);
		header.height = 70;
		header.containerStyleFactory = function(container:IceControl) : Void {
			container.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_PARENT);
			container.isClipped = true;
			var vLayout:VerticalLayout = new VerticalLayout();
			vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
			vLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
			vLayout.snapToStageWidth = true;
			vLayout.snapToStageHeight = true;
			container.layout = vLayout;
		}
		header.titleStyleFactory = function(title:IceControl) : Void {
			title.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_HTML_CONTENT);
			title.addClass(['i-header-title']);
		}
	}*/
	
	/*private function setPreloaderStyle(preloader:Preloader) : Void {
		preloader.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_PARENT);
		preloader.addClass(['i-preloader']);
		
		var vLayout:VerticalLayout = new VerticalLayout();
		vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
		vLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
		preloader.layout = vLayout;
		
		preloader.imageStyleFactory = function(image:Image) : Void {
			image.snapTo(IceControl.SNAP_TO_SELF, IceControl.SNAP_TO_SELF);
			image.stretchType = Image.FIT_TO_CONTAINER_SIZE;
			image.emitResizeEvents = false;
			image.proportional = true;
			image.alignCenter = false;
			image.src = 'assets/preloader_d_s.gif';
		}
		
		preloader.imageContainerStyleFactory = function(container:IceControl) : Void {
			container.snapTo(IceControl.SNAP_TO_SELF, IceControl.SNAP_TO_SELF);
			container.width = 96;
			container.height = 96;
		}
	}
	*/
	
	private function setDefaultScreenStyle(screen:Screen) : Void {
		screen.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_PARENT);
	}
	/**
	 * Стиль обычной кнопки по-умолчанию
	 */
	private function setDefaultSimpleButtonStyle(renderer:Button) : Void {
		renderer.addClass(['i-button']);
		renderer.snapTo(IceControl.SNAP_TO_CONTENT, IceControl.SNAP_TO_CONTENT);
		var hLayout:HorizontalLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_FIT;
		hLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_JUSTIFY;
		hLayout.paddingLeft = 10;
		hLayout.paddingRight = 10;
		renderer.layout = hLayout;
		renderer.labelStyleFactory = function(label:Label) : Void {
			label.addClass(['i-label']);
			label.wordwap = true;
		}
		renderer.contentBoxStyleFactory = function(box:IceControl) : Void {
			box.snapTo(IceControl.SNAP_TO_CONTENT, IceControl.SNAP_TO_CONTENT);
			var hLayout:HorizontalLayout = new HorizontalLayout();
			hLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_FIT;
			hLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			box.layout = hLayout;
		}
		renderer.upStyleFactory = function(button:Button) : Void {
			button.removeClass(['i-button-down', 'i-button-hover', 'i-button-disabled']);
			button.addClass(['i-button-up']);
		}
		renderer.downStyleFactory = function(button:Button) : Void {
			button.removeClass(['i-button-up', 'i-button-hover', 'i-button-disabled']);
			button.addClass(['i-button-down']);
		}
		renderer.hoverStyleFactory = function(button:Button) : Void {
			button.removeClass(['i-button-up', 'i-button-down', 'i-button-disabled']);
			button.addClass(['i-button-hover']);
		}
		renderer.disabledStyleFactory = function(button:Button) : Void {
			button.removeClass(['i-button-up', 'i-button-down', 'i-button-hover']);
			button.addClass(['i-button-disabled']);
		}
	}
	
	/**
	 * Стиль таббара по-умолчанию
	 */
	/*private function setDefaultTabBarStyle(tabbar:TabBar) : Void {
		tabbar.addClass(['i-tabbar']);
		tabbar.itemFactory = function(data:Dynamic) : BaseListItemControl {
			var item:TabBarItemRenderer = new TabBarItemRenderer();
			item.data = data;
			return cast item;
		}
		var hLayout:HorizontalLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_FIT;
		hLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_JUSTIFY;
		hLayout.paddingLeft = hLayout.paddingRight = 10;
		tabbar.layout = hLayout;
		tabbar.height = 80;
	}*/
	
	/**
	 * Стиль "оболочки" таба по-умолчанию
	 */
	/*private function setDefaultTabBarItemRendererStyle(renderer:TabBarItemRenderer) : Void {
		renderer.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_PARENT);
		renderer.buttonFactory = setTabBarButtonStyle;
	}*/
	
	/**
	 * Стиль кнопки таба по-умолчанию
	 */
	/*private function setTabBarButtonStyle(renderer:Button) : Void {
		renderer.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_PARENT);
		var hLayout:HorizontalLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_FIT;
		hLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_JUSTIFY;
		hLayout.paddingLeft = 10;
		hLayout.paddingRight = 10;
		renderer.layout = hLayout;
		renderer.addClass(['i-tabbar-button']);
		renderer.setPivot('center', 'center');
		renderer.labelInitializedStyleFactory = function(label:Label) : Void {
			label.addClass(['i-tabbar-button-label']);
			label.wordwap = false;
		}
		renderer.contentBoxStyleFactory = function(box:IceControl) : Void {
			box.snapTo(IceControl.SNAP_TO_SELF, IceControl.SNAP_TO_SELF);
			var hLayout:HorizontalLayout = new HorizontalLayout();
			hLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_FIT;
			hLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			hLayout.snapToStageHeight = true;
			box.layout = hLayout;
		}
		renderer.upStyleFactory = function(button:Button) : Void {
			button.labelStyleFactory = function(label:Label) : Void {
				label.removeClass(['i-tabbar-button-label-down', 'i-tabbar-button-label-hover', 'i-tabbar-button-label-select', 'i-tabbar-button-label-disabled']);
				label.addClass(['i-tabbar-button-label-up']);
			}
			button.removeClass(['i-tabbar-button-down', 'i-tabbar-button-hover', 'i-tabbar-button-select', 'i-tabbar-button-disabled']);
			button.addClass(['i-tabbar-button-up']);
		}
		renderer.downStyleFactory = function(button:Button) : Void {
			button.labelStyleFactory = function(label:Label) : Void {
				label.removeClass(['i-tabbar-button-label-up', 'i-tabbar-button-label-hover', 'i-tabbar-button-label-select', 'i-tabbar-button-label-disabled']);
				label.addClass(['i-tabbar-button-label-down']);
			}
			button.removeClass(['i-tabbar-button-up', 'i-tabbar-button-hover', 'i-tabbar-button-select', 'i-tabbar-button-disabled']);
			button.addClass(['i-tabbar-button-down']);
		}
		renderer.hoverStyleFactory = function(button:Button) : Void {
			button.labelStyleFactory = function(label:Label) : Void {
				label.removeClass(['i-tabbar-button-label-up', 'i-tabbar-button-label-down', 'i-tabbar-button-label-select', 'i-tabbar-button-label-disabled']);
				label.addClass(['i-tabbar-button-label-hover']);
			}
			button.removeClass(['i-tabbar-button-up', 'i-tabbar-button-down', 'i-tabbar-button-select', 'i-tabbar-button-disabled']);
			button.addClass(['i-tabbar-button-hover']);
		}
		renderer.selectStyleFactory = function(button:Button) : Void {
			button.labelStyleFactory = function(label:Label) : Void {
				label.removeClass(['i-tabbar-button-label-up', 'i-tabbar-button-label-down', 'i-tabbar-button-label-hover', 'i-tabbar-button-label-disabled']);
				label.addClass(['i-tabbar-button-label-select']);
			}
			button.removeClass(['i-tabbar-button-up', 'i-tabbar-button-down', 'i-tabbar-button-hover', 'i-tabbar-button-disabled']);
			button.addClass(['i-tabbar-button-select']);
		}
		renderer.disabledStyleFactory = function(button:Button) : Void {
			button.labelStyleFactory = function(label:Label) : Void {
				label.removeClass(['i-tabbar-button-label-up', 'i-tabbar-button-label-down', 'i-tabbar-button-label-hover', 'i-tabbar-button-label-select']);
				label.addClass(['i-tabbar-button-label-disabled']);
			}
			button.removeClass(['i-tabbar-button-up', 'i-tabbar-button-down', 'i-tabbar-button-hover', 'i-tabbar-button-select']);
			button.addClass(['i-tabbar-button-disabled']);
		}
	}*/
	
	/**
	 * Стиль "замедленного" строителя по-умолчанию
	 */
	private function setDefaultDelayedBuilderStyle(renderer:DelayedBuilder) : Void {
		renderer.delay = .1;
		renderer.postFactory = function(object:DisplayObject) : Void {
			object.addClass(['i-delayed-builder']);
		}
	}
	
	/**
	 * Стиль скроллера по-умолчанию
	 */
	private function setDefaultScrollerStyle(renderer:Scroller) : Void {
		renderer.addClass(['i-scroller']);
		
		renderer.contentStyleFactory = function(content:IceControl) : Void {
			content.snapTo(IceControl.SNAP_TO_CONTENT, IceControl.SNAP_TO_CONTENT);
			var vLayout:VerticalLayout = new VerticalLayout();
			vLayout.paddingLeft = 20;
			vLayout.paddingRight = 0;
			vLayout.paddingTop = 20;
			vLayout.paddingBottom = 20;
			vLayout.gap = 10;
			content.layout = vLayout;
		}
	}
	
	/**
	 * Стиль лейбела по-умолчанию
	 */
	private function setDefaultLabelStyle(label:Label) : Void {
		label.addClass(['i-label']);
		label.wordwap = true;
	}
	
	/**
	 * Стиль горизонтального скроллбара по-умолчанию
	 */
	private function setDefaultHorizontalScrollbarStyle(renderer:IScrollBar) : Void {
		
		var renderer:ScrollBar = cast renderer;
		renderer.snapTo(IceControl.SNAP_TO_SELF, IceControl.SNAP_TO_CONTENT);
		renderer.addClass(['i-scrollbar-horizontal-track']);
		renderer.minThumbSize = 16;
		renderer.offsetRatioFunction = function(ownerSize:Float, contentSize:Float, ratio:Float) : Float {
			return -Math.abs(ownerSize / contentSize) * ratio;
		}
		
		var thumbTween:IAnimatable = null;
		
		renderer.contentStyleFactory = function(content:IceControl) : Void {
			content.snapTo(IceControl.SNAP_TO_CONTENT, IceControl.SNAP_TO_CONTENT);
		}
		renderer.thumbStyleFactory = function(thumb:ScrollBarThumb) : Void {
			thumb.snapTo(IceControl.SNAP_TO_CONTENT, IceControl.SNAP_TO_CONTENT);
			thumb.interactive = false;
			thumb.height = 8;
			thumb.addClass(['i-scrollbar-horizontal-thumb']);
		}
		renderer.upStyleFactory = function(renderer:IScrollBar) : Void {
			if (thumbTween != null) {
				Ice.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.height != 8)
				 thumbTween = cast Ice.animator.tween(renderer.thumb, .1, {height:8});
			renderer.thumb.removeClass(['i-scrollbar-horizontal-thumb-down-state', 'i-scrollbar-horizontal-thumb-hover-state', 'i-scrollbar-horizontal-thumb-disabled-state']);
			renderer.thumb.addClass(['i-scrollbar-horizontal-thumb-up-state']);
		}
		renderer.downStyleFactory = function(renderer:IScrollBar) : Void {
			if (thumbTween != null) {
				Ice.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.height != 16)
				 thumbTween = cast Ice.animator.tween(renderer.thumb, .1, {height:16});
			renderer.thumb.removeClass(['i-scrollbar-horizontal-thumb-up-state', 'i-scrollbar-horizontal-thumb-hover-state', 'i-scrollbar-horizontal-thumb-disabled-state']);
			renderer.thumb.addClass(['i-scrollbar-horizontal-thumb-down-state']);
		}
		renderer.hoverStyleFactory = function(renderer:IScrollBar) : Void {
			if (thumbTween != null) {
				Ice.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.height != 16)
				 thumbTween = cast Ice.animator.tween(renderer.thumb, .1, {height:16});
			renderer.thumb.removeClass(['i-scrollbar-horizontal-thumb-up-state', 'i-scrollbar-horizontal-thumb-down-state', 'i-scrollbar-horizontal-thumb-disabled-state']);
			renderer.thumb.addClass(['i-scrollbar-horizontal-thumb-hover-state']);
		}
		renderer.disabledStyleFactory = function(renderer:IScrollBar) : Void {
			if (thumbTween != null) {
				Ice.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.height != 8)
				 thumbTween = cast Ice.animator.tween(renderer.thumb, .1, {height:8});
			renderer.thumb.removeClass(['i-scrollbar-horizontal-thumb-up-state', 'i-scrollbar-horizontal-thumb-down-state', 'i-scrollbar-horizontal-thumb-hover-state']);
			renderer.thumb.addClass(['i-scrollbar-horizontal-thumb-disabled-state']);
		}
	}
	
	/**
	 * Стиль вертикального скроллбара по-умолчанию
	 */
	private function setDefaultVerticalScrollbarStyle(renderer:IScrollBar) : Void {
		
		var renderer:ScrollBar = cast renderer;
		
		renderer.addClass(['i-scrollbar-vertical-track']);
		renderer.snapTo(IceControl.SNAP_TO_CONTENT, IceControl.SNAP_TO_SELF);
		renderer.minThumbSize = 16;
		renderer.offsetRatioFunction = function(ownerSize:Float, contentSize:Float, ratio:Float) : Float {
			return -Math.abs(ownerSize / contentSize) * ratio;
		}
		
		var thumbTween:IAnimatable = null;
		
		renderer.contentStyleFactory = function(content:IceControl) : Void {
			content.snapTo(IceControl.SNAP_TO_CONTENT, IceControl.SNAP_TO_CONTENT);
		}
		renderer.thumbStyleFactory = function(thumb:ScrollBarThumb) : Void {
			thumb.snapTo(IceControl.SNAP_TO_CONTENT, IceControl.SNAP_TO_CONTENT);
			thumb.interactive = false;
			thumb.addClass(['i-scrollbar-vertical-thumb']);
			thumb.width = 8;
		}
		renderer.upStyleFactory = function(renderer:IScrollBar) : Void {
			if (thumbTween != null) {
				Ice.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.width != 8)
				 thumbTween = cast Ice.animator.tween(renderer.thumb, .1, {width:8});
			renderer.thumb.removeClass(['i-scrollbar-vertical-thumb-down-state', 'i-scrollbar-vertical-thumb-hover-state', 'i-scrollbar-vertical-thumb-disabled-state']);
			renderer.thumb.addClass(['i-scrollbar-vertical-thumb-up-state']);
		}
		renderer.downStyleFactory = function(renderer:IScrollBar) : Void {
			if (thumbTween != null) {
				Ice.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.width != 16)
				 thumbTween = cast Ice.animator.tween(renderer.thumb, .1, {width:16});
			renderer.thumb.removeClass(['i-scrollbar-vertical-thumb-up-state', 'i-scrollbar-vertical-thumb-hover-state', 'i-scrollbar-vertical-thumb-disabled-state']);
			renderer.thumb.addClass(['i-scrollbar-vertical-thumb-down-state']);
		}
		renderer.hoverStyleFactory = function(renderer:IScrollBar) : Void {
			if (thumbTween != null) {
				Ice.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.width != 16)
				 thumbTween = cast Ice.animator.tween(renderer.thumb, .1, {width:16});
			renderer.thumb.removeClass(['i-scrollbar-vertical-thumb-up-state', 'i-scrollbar-vertical-thumb-down-state', 'i-scrollbar-vertical-thumb-disabled-state']);
			renderer.thumb.addClass(['i-scrollbar-vertical-thumb-hover-state']);
		}
		renderer.disabledStyleFactory = function(renderer:IScrollBar) : Void {
			if (thumbTween != null) {
				Ice.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.width != 8)
				 thumbTween = cast Ice.animator.tween(renderer.thumb, .1, {width:8});
			renderer.thumb.removeClass(['i-scrollbar-vertical-thumb-up-state', 'i-scrollbar-vertical-thumb-down-state', 'i-scrollbar-vertical-thumb-hover-state']);
			renderer.thumb.addClass(['i-scrollbar-vertical-thumb-disabled-state']);
		}
	}
	
	/**
	 * Стиль скроллплейна по-умолчанию
	 */
	private function setDefaultScrollPlaneStyle(renderer:Scroller) : Void {
		renderer.addClass(['i-scroller']);
		renderer.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_PARENT);
		
		renderer.contentStyleFactory = function(content:IceControl) : Void {
			content.snapTo(IceControl.SNAP_TO_CONTENT, IceControl.SNAP_TO_CONTENT);
			var vLayout:VerticalLayout = new VerticalLayout();
			vLayout.paddingLeft = 20;
			vLayout.paddingRight = 20;
			vLayout.paddingTop = 20;
			vLayout.paddingBottom = 20;
			vLayout.gap = 10;
			content.layout = vLayout;
		}
		
		renderer.delayedBuilderStyleFactory = function(delayedBuilder:DelayedBuilder) : Void {
			delayedBuilder.delay = .01;
			delayedBuilder.postFactory = function(object:DisplayObject) : Void {
				object.addClass(['i-delayed-builder']);
			}
		}
	}
}