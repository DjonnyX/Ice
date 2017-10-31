package com.flicker.app.theme;

import haxe.Constraints.Function;
import js.html.Element;
import com.flicker.controls.HtmlContainer;
import com.flicker.controls.itemRenderer.FilterItemRenderer;

import com.flicker.controls.ButtonsGroup;
import com.flicker.controls.FilterGroup;
import com.flicker.controls.itemRenderer.ToggleItemRenderer;

import com.flicker.animation.Transitions;
import com.flicker.controls.SimplePreloader;
import com.flicker.app.App;
import com.flicker.app.controls.MenuPanel;
import com.flicker.app.controls.gallery.RockGalleryItemRenderer;
import com.flicker.controls.Image;
import com.flicker.controls.ScreenNavigator;
import com.flicker.controls.IScrollBar;
import com.flicker.controls.ScrollBar;
import com.flicker.controls.ScrollBarWithContainer;
import com.flicker.controls.ScrollPlane;
import com.flicker.controls.Scroller;
import com.flicker.controls.TabBar;
import com.flicker.controls.itemRenderer.TabBarItemRenderer;
import com.flicker.controls.super.IBaseListItemControl;
import com.flicker.controls.super.BaseStatesControl;
import com.flicker.controls.super.FlickerControl;
import com.flicker.events.Event;
import com.flicker.events.FingerEvent;
import com.flicker.events.WheelScrollEvent;
import com.flicker.layout.FitLayout;
import com.flicker.layout.HorizontalLayout;
import com.flicker.layout.RockRowsLayout;
import com.flicker.layout.VerticalLayout;
import com.flicker.controls.Screen;
import com.flicker.data.ElementData;
import com.flicker.layout.params.HorizontalLayoutParams;
import com.flicker.layout.params.VerticalLayoutParams;
import com.flicker.theme.Theme;
import com.flicker.controls.DelayedBuilder;
import com.flicker.display.DisplayObject;
import com.flicker.controls.Button;
import com.flicker.app.screens.PortfolioProjectScreen;
import com.flicker.app.screens.PortfolioGalleryScreen;
import com.flicker.app.screens.PortfolioScreen;
import com.flicker.app.screens.AboutMeScreen;
import com.flicker.app.screens.ContactsScreen;
import com.flicker.animation.IAnimatable;
import com.flicker.core.Flicker;
import com.flicker.utils.MathUtil;
import com.flicker.display.Stage;
import com.flicker.controls.PreloadedImage;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class AppTheme extends Theme
{
	public static inline var LARGE_TITLE:String = 'large-title';
	public static inline var ARTICLE_HEADER:String = 'article-header';
	
	public static inline var MAX_DEPTH_FOR_CONTENT:Int = 9999;
	public static inline var SCROLL_CONTAINER_DEPTH:Int = 10000;
	public static inline var TABBAR_DEPTH:Int = 100001;
	
	public static inline var GALLERY_MIN_RIGHT_OFFSET:Float = 14;
	public static inline var GALLERY_MAX_RIGHT_OFFSET:Float = 44;
	
	public static inline var GALLERY_MIN_LEFT_OFFSET:Float = 24;
	public static inline var GALLERY_MAX_LEFT_OFFSET:Float = 158;
	
	public function new() 
	{
		super();
	}
	
	private override function setStyles() : Void {
		super.setStyles();
		
		setStyle(Button, 'animated-button', setFloatButtonStyle);
		
		setStyle(App, App.DEFAULT_STYLE, setAppStyle);
		
		
		setStyle(FlickerControl, 'portfolio-project-header', setPortfolioProjectHeaderStyle);
		setStyle(FlickerControl, 'portfolio-project-paragraph', setPortfolioProjectParagraphStyle);
		setStyle(FlickerControl, 'portfolio-project-image-container', setPortfolioProjectImageContainerStyle);
		
		setStyle(AboutMeScreen, AboutMeScreen.DEFAULT_STYLE, setAboutMeScreenStyle);
		setStyle(ContactsScreen, ContactsScreen.DEFAULT_STYLE, setContactsScreenStyle);
		setStyle(PortfolioScreen, PortfolioScreen.DEFAULT_STYLE, setPortfolioScreenStyle);
		setStyle(RockGalleryIRScreen, RockGalleryIRScreen.DEFAULT_STYLE, setDefaultRockGalleryIRScreenStyle);
		
		setStyle(PreloadedImage, PreloadedImage.DEFAULT_STYLE, setDefaultPreloadedImageStyle);
		
		setStyle(PortfolioGalleryScreen, PortfolioGalleryScreen.DEFAULT_STYLE, setPortfolioGalleryScreenStyle);
		setStyle(PortfolioProjectScreen, PortfolioProjectScreen.DEFAULT_STYLE, setPortfolioProjectScreenStyle);
		setStyle(RockGalleryItemRenderer, RockGalleryItemRenderer.DEFAULT_STYLE, setDefaultRockGalleryItemRendererStyle);
	}
	
	private function setPortfolioProjectHeaderStyle(renderer:FlickerControl) : Void {
		renderer.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_HTML_CONTENT);
		renderer.isClipped = true;
		renderer.addClass(['rg-header-title']);
	}
	
	private function setPortfolioProjectParagraphStyle(renderer:FlickerControl) : Void {
		renderer.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_HTML_CONTENT);
		renderer.isClipped = true;
		renderer.addClass(['rg-header-message', 'rg-p']);
	}
	
	private function setPortfolioProjectImageContainerStyle(renderer:FlickerControl) : Void {
		renderer.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_CONTENT);
		var hLayout:VerticalLayout = new VerticalLayout();
		hLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
		hLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
		hLayout.paddingBottom = -40;
		renderer.layout = hLayout;
	}
	
	private function setAppStyle(app:App) : Void {
		app.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_PARENT);
		
		var vLayout:VerticalLayout = new VerticalLayout();
		vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
		vLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_FIT;
		app.layout = vLayout;
		
		app.maxWidthForCompact = 700;
		
		var minMenuWidth:Int = 60;
		
		app.menuContainerStyleFactory = function(container:FlickerControl) : Void {
			var hLayout:HorizontalLayout = new HorizontalLayout();
			hLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_FIT;
			hLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_JUSTIFY;
			container.layout = hLayout;
		}
		app.contentContainerStyleFactory = function(container:FlickerControl) : Void {
			var vLayout:VerticalLayout = new VerticalLayout();
			vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
			vLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_FIT;
			container.layout = vLayout;
		}
		app.menuStubStyleFactory = function(menuStub:FlickerControl) : Void {
			menuStub.snapTo(FlickerControl.SNAP_NONE, FlickerControl.SNAP_NONE);
			
			menuStub.width = minMenuWidth;
			
			var hLayoutParams:HorizontalLayoutParams = new HorizontalLayoutParams();
			hLayoutParams.fitWidth = HorizontalLayoutParams.NO_FIT;
			menuStub.layoutParams = hLayoutParams;
		}
		app.menuPanelStyleFactory = function(menuPanel:MenuPanel) : Void {
			menuPanel.snapTo(FlickerControl.SNAP_NONE, FlickerControl.SNAP_TO_PARENT);
			menuPanel.width = 200;
			menuPanel.addClass(['menu-panel']);
			menuPanel.includeInLayout = false;
			menuPanel.x = -minMenuWidth;
			
			var menuPanelTween:IAnimatable = null;
			
			menuPanel.upStyleFactory = function(button:Button) : Void {
				if (menuPanelTween != null) {
					Flicker.animator.remove(menuPanelTween);
					menuPanelTween = null;
				}
				if (button.x != -button.width)
					menuPanelTween = cast Flicker.animator.tween(button, .3, {x:-button.width, transition:Transitions.EASE_OUT});
			}
			menuPanel.hoverStyleFactory = function(button:Button) : Void {
				if (menuPanelTween != null) {
					Flicker.animator.remove(menuPanelTween);
					menuPanelTween = null;
				}
				if (button.x != -minMenuWidth)
					menuPanelTween = cast Flicker.animator.tween(button, .3, {x:-minMenuWidth, transition:Transitions.EASE_OUT});
			}
			
			var vLayout:VerticalLayout = new VerticalLayout();
			vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
			vLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			vLayout.paddingRight = 0;
			menuPanel.layout = vLayout;
			
			menuPanel.tabBarStyleFactory = function(tabbar:TabBar) : Void {
				tabbar.emitResizeEvents = false;
				tabbar.style = {'z-index':TABBAR_DEPTH};
				tabbar.addClass(['menu-panel__tabbar']);
				tabbar.itemFactory = function(data:Dynamic) : IBaseListItemControl {
					var item:TabBarItemRenderer = new TabBarItemRenderer();
					item.snapTo(FlickerControl.SNAP_TO_SELF, FlickerControl.SNAP_TO_SELF);
					item.height = 64;
					item.style = {'z-index':TABBAR_DEPTH};
					item.addClass(['menu-panel-button']);
					var labelElement:Element = item.labelElement;
					labelElement.classList.add('label');
					var iconElement:Element = item.iconElement;
					iconElement.classList.add('icon');
					setDefaultButtonStates(item, true);
					
					item.data = data;
					return cast item;
				}
				var hLayout:VerticalLayout = new VerticalLayout();
				hLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
				hLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
				tabbar.layout = hLayout;
			}
		}
		app.navigatorStyleFactory = function(navigator:ScreenNavigator) : Void {
			navigator.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_SELF);
			navigator.addClass(['main-navigator']);
			var hLayoutParams:VerticalLayoutParams = new VerticalLayoutParams();
			hLayoutParams.ignoreY = true;
			navigator.layoutParams = hLayoutParams;
		}
		app.tabBarStyleFactory = function(tabbar:TabBar) : Void {
			tabbar.emitResizeEvents = false;
			tabbar.style = {'z-index':TABBAR_DEPTH};
			tabbar.addClass(['i-tabbar']);
			tabbar.itemFactory = function(data:Dynamic) : IBaseListItemControl {
				var item:TabBarItemRenderer = new TabBarItemRenderer();
				item.snapTo(FlickerControl.SNAP_TO_SELF, FlickerControl.SNAP_TO_PARENT);
				item.style = {'z-index':TABBAR_DEPTH};
				item.addClass(['tabbar-button']);
				var labelElement:Element = item.labelElement;
				labelElement.classList.add('label');
				setDefaultButtonStates(item, true);
				
				item.data = data;
				return cast item;
			}
			var hLayout:HorizontalLayout = new HorizontalLayout();
			hLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_FIT;
			hLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_JUSTIFY;
			hLayout.paddingLeft = hLayout.paddingRight = 0;
			tabbar.layout = hLayout;
			
			var vLayoutParams:VerticalLayoutParams = new VerticalLayoutParams();
			vLayoutParams.fitHeight = VerticalLayoutParams.NO_FIT;
			tabbar.layoutParams = vLayoutParams;
			tabbar.height = 64;
		}
	}
	
	private function setPortfolioScreenScrollPlaneStyle(plane:ScrollPlane) : Void {
		plane.horizontalScrollBarFactory = function() : IScrollBar {
			return new ScrollBarWithContainer('sb-', 'scrollbar-', 'scrollbar-', 'horizontal');
		}
		plane.verticalScrollBarFactory = function() : IScrollBar {
			return new ScrollBarWithContainer('sb-', 'scrollbar-', 'scrollbar-', 'vertical');
		}
		plane.addClass(['i-scroller']);
		plane.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_PARENT);
		plane.horizontalScrollPolicy = ScrollPlane.SCROLL_POLICY_OFF;
		plane.verticalScrollPolicy = ScrollPlane.SCROLL_POLICY_AUTO;
		plane.horizontalScrollBarStyleFactory = setHorizontalScrollbarStyle;
		plane.verticalScrollBarStyleFactory = setVerticalScrollbarStyle;
		plane.contentStyleFactory = function(content:FlickerControl) : Void {
			content.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_CONTENT);
			var vLayout:VerticalLayout = new VerticalLayout();
			vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
			vLayout.paddingLeft = -1;
			vLayout.paddingTop = -1;
			vLayout.paddingBottom = 1;
			vLayout.paddingRight = 0;
			vLayout.verticalGap = 1;
			content.layout = vLayout;
		}
		plane.barrierStyleFactory = function(barrier:Barrier) : Void {
			barrier.emitResizeEvents = false;
			barrier.barrierColor = 'rgb(240,240,240)';
			barrier.maxTension = 54;
		}
		/*plane.delayedBuilderStyleFactory = function(delayedBuilder:DelayedBuilder) : Void {
			delayedBuilder.delay = 0;// .001;
			delayedBuilder.postFactory = function(object:IceControl) : Void {
				object.addClass(['i-delayed-builder']);
			}
		}*/
		plane.enableBarriers = true;
	}
	
	private function setDefaultRockGalleryIRScreenStyle(renderer:RockGalleryIRScreen) : Void {
		renderer.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_PARENT);
		var hLayout:HorizontalLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_FIT;
		hLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_JUSTIFY;
		hLayout.ignoreX = hLayout.ignoreY = true;
		renderer.layout = hLayout;
		renderer.isClipped = true;
		renderer.emitResizeEvents = false;
		renderer.imageStyleFactory = function(renderer:PreloadedImage) : Void {
			renderer.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_CONTENT);
			var vLayout:HorizontalLayout = new HorizontalLayout();
			vLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_JUSTIFY;
			vLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_JUSTIFY;
			vLayout.ignoreX = vLayout.ignoreY = true;
			renderer.layout = vLayout;
			renderer.emitResizeEvents = false;
			renderer.imageStyleFactory = function(image:Image) : Void {
				image.snapTo(FlickerControl.SNAP_TO_CONTENT, FlickerControl.SNAP_TO_CONTENT);
				//image.emitResizeEvents = false;
				image.proportional = true;
				image.stretchType = Image.FROM_MAX_RECT;
			}
			renderer.preloaderStyleFactory = function(preloader:SimplePreloader) : Void {
				preloader.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_PARENT);
				preloader.includeInLayout = false;
				//preloader.emitResizeEvents = false;
				preloader.pContainer.classList.add('c-simple-preloader');
				preloader.img.classList.add('simple-preloader');
				preloader.img.src = 'assets/preloader_d_s.gif';
			}
		}
	}
	
	private function setDefaultPreloadedImageStyle(renderer:PreloadedImage) : Void {
		renderer.snapTo(FlickerControl.SNAP_TO_SELF, FlickerControl.SNAP_TO_CONTENT);
		var vLayout:HorizontalLayout = new HorizontalLayout();
		vLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_JUSTIFY;
		vLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_JUSTIFY;
		vLayout.ignoreX = vLayout.ignoreY = true;
		renderer.layout = vLayout;
		renderer.emitResizeEvents = false;
		renderer.imageStyleFactory = function(image:Image) : Void {
			image.snapTo(FlickerControl.SNAP_TO_CONTENT, FlickerControl.SNAP_TO_CONTENT);
			//image.emitResizeEvents = true;
			image.proportional = true;
			image.stretchType = Image.FROM_MAX_RECT;
		}
		renderer.preloaderStyleFactory = function(preloader:SimplePreloader) : Void {
			preloader.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_PARENT);
			preloader.includeInLayout = false;
			//preloader.emitResizeEvents = true;
			preloader.pContainer.classList.add('c-simple-preloader');
			preloader.img.classList.add('simple-preloader');
			preloader.img.src = 'assets/preloader_d_s.gif';
		}
	}
	
	private function setDefaultRockGalleryItemRendererStyle(renderer:RockGalleryItemRenderer) : Void {
		var index:Int = renderer.parent.getChildIndex(renderer);
		renderer.style = {'z-index':index};
		renderer.isClipped = true;
		renderer.snapTo(FlickerControl.SNAP_TO_SELF, FlickerControl.SNAP_TO_SELF);
		var hLayout:HorizontalLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_JUSTIFY;
		hLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_JUSTIFY;
		hLayout.ignoreX = hLayout.ignoreY = true;
		renderer.layout = hLayout;
		hLayout.snapToStageHeight = hLayout.snapToStageWidth = true;
		
		renderer.firstUpdateFactory = function(renderer:RockGalleryItemRenderer) : Void {
			renderer.addClass(['rock-item-renderer-anim']);
		}
		
		renderer.headerStyleFactory = function(header:HtmlContainer) : Void {
			header.addClass(['rg-item-header__container']);
			header.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_PARENT);
			header.isClipped = true;
			header.includeInLayout = false;
			header.emitResizeEvents = false;
		}
		renderer.navigatorStyleFactory = function(navigator:ScreenNavigator) : Void {
			navigator.snapTo(FlickerControl.SNAP_TO_SELF, FlickerControl.SNAP_TO_SELF);
			navigator.emitResizeEvents = false;
		}
		renderer.upStyleFactory = function(state:RockGalleryItemRenderer) : Void {
			state.removeClass(['rock-item-renderer-down', 'rock-item-renderer-hover', 'rock-item-renderer-select', 'rock-item-renderer-disabled']);
			state.addClass(['rock-item-renderer-up']);
		}
		renderer.downStyleFactory = function(state:RockGalleryItemRenderer) : Void {
			state.removeClass(['rock-item-renderer-up', 'rock-item-renderer-hover', 'rock-item-renderer-select', 'rock-item-renderer-disabled']);
			state.addClass(['rock-item-renderer-down']);
		}
		renderer.hoverStyleFactory = function(state:RockGalleryItemRenderer) : Void {
			state.removeClass(['rock-item-renderer-up', 'rock-item-renderer-down', 'rock-item-renderer-select', 'rock-item-renderer-disabled']);
			state.addClass(['rock-item-renderer-hover']);
		}
		renderer.selectStyleFactory = function(state:RockGalleryItemRenderer) : Void {
			state.removeClass(['rock-item-renderer-up', 'rock-item-renderer-down', 'rock-item-renderer-hover', 'rock-item-renderer-disabled']);
			state.addClass(['rock-item-renderer-select']);
		}
		renderer.disabledStyleFactory = function(state:RockGalleryItemRenderer) : Void {
			state.removeClass(['rock-item-renderer-up', 'rock-item-renderer-down', 'rock-item-renderer-hover', 'rock-item-renderer-select']);
			state.addClass(['rock-item-renderer-disabled']);
		}
	}
	
	private function setFloatButtonStyle(renderer:Button) : Void {
		renderer.snapTo(FlickerControl.SNAP_TO_SELF, FlickerControl.SNAP_TO_SELF);
		renderer.addClass(['float-button']);
		var labelElement:Element = renderer.labelElement;
		if (labelElement != null)
			labelElement.classList.add('label');
		var iconElement:Element = renderer.iconElement;
		if (iconElement != null)
			iconElement.classList.add('icon');
		setDefaultButtonStates(renderer, true, true);
	}
	
	/**
	 * Стиль горизонтального скроллбара по-умолчанию
	 */
	private function setHorizontalScrollbarStyle(renderer:IScrollBar) : Void {
		var scrollBarContainer:ScrollBarWithContainer = cast renderer;
		scrollBarContainer.style = {'z-index':SCROLL_CONTAINER_DEPTH};
		scrollBarContainer.snapTo(FlickerControl.SNAP_TO_SELF, FlickerControl.SNAP_TO_CONTENT);
		scrollBarContainer.addClass(['app-scrollbar-horizontal-container']);
		
		var renderer:ScrollBar = scrollBarContainer.scrollBar;
		renderer.ratio = .5;
		renderer.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_CONTENT);
		renderer.addClass(['i-scrollbar-horizontal-track']);
		renderer.minThumbSize = 12;
		renderer.offsetRatioFunction = function(ownerSize:Float, contentSize:Float, ratio:Float) : Float {
			return -Math.abs(ownerSize / contentSize) * ratio;
		}
		
		var thumbTween:IAnimatable = null;
		
		renderer.contentStyleFactory = function(content:FlickerControl) : Void {
			content.snapTo(FlickerControl.SNAP_TO_CONTENT, FlickerControl.SNAP_TO_CONTENT);
		}
		renderer.thumbStyleFactory = function(thumb:ScrollBarThumb) : Void {
			thumb.snapTo(FlickerControl.SNAP_TO_CONTENT, FlickerControl.SNAP_TO_CONTENT);
			thumb.interactive = false;
			thumb.height = 4;
			thumb.addClass(['i-scrollbar-horizontal-thumb']);
		}
		renderer.upStyleFactory = function(renderer:IScrollBar) : Void {
			if (thumbTween != null) {
				Flicker.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.height != 4)
				 thumbTween = cast Flicker.animator.tween(renderer.thumb, .1, {height:4});
			renderer.thumb.removeClass(['i-scrollbar-horizontal-thumb-down-state', 'i-scrollbar-horizontal-thumb-hover-state', 'i-scrollbar-horizontal-thumb-disabled-state']);
			renderer.thumb.addClass(['i-scrollbar-horizontal-thumb-up-state']);
			
			scrollBarContainer.removeClass(['i-scrollbar-horizontal-container-hover']);
			if (!scrollBarContainer.hasClass(['i-scrollbar-horizontal-container-up'])) 
				scrollBarContainer.addClass(['i-scrollbar-horizontal-container-up']);
		}
		renderer.downStyleFactory = function(renderer:IScrollBar) : Void {
			if (thumbTween != null) {
				Flicker.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.height != 12)
				 thumbTween = cast Flicker.animator.tween(renderer.thumb, .1, {height:12});
			renderer.thumb.removeClass(['i-scrollbar-horizontal-thumb-up-state', 'i-scrollbar-horizontal-thumb-hover-state', 'i-scrollbar-horizontal-thumb-disabled-state']);
			renderer.thumb.addClass(['i-scrollbar-horizontal-thumb-down-state']);
			
			scrollBarContainer.removeClass(['i-scrollbar-horizontal-container-up']);
			if (!scrollBarContainer.hasClass(['i-scrollbar-horizontal-container-hover'])) 
				scrollBarContainer.addClass(['i-scrollbar-horizontal-container-hover']);
		}
		renderer.hoverStyleFactory = function(renderer:IScrollBar) : Void {
			if (thumbTween != null) {
				Flicker.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.height != 12)
				 thumbTween = cast Flicker.animator.tween(renderer.thumb, .1, {height:12});
			renderer.thumb.removeClass(['i-scrollbar-horizontal-thumb-up-state', 'i-scrollbar-horizontal-thumb-down-state', 'i-scrollbar-horizontal-thumb-disabled-state']);
			renderer.thumb.addClass(['i-scrollbar-horizontal-thumb-hover-state']);
			
			scrollBarContainer.removeClass(['i-scrollbar-horizontal-container-up']);
			if (!scrollBarContainer.hasClass(['i-scrollbar-horizontal-container-hover'])) 
				scrollBarContainer.addClass(['i-scrollbar-horizontal-container-hover']);
		}
		renderer.disabledStyleFactory = function(renderer:IScrollBar) : Void {
			if (thumbTween != null) {
				Flicker.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.height != 4)
				 thumbTween = cast Flicker.animator.tween(renderer.thumb, .1, {height:4});
			renderer.thumb.removeClass(['i-scrollbar-horizontal-thumb-up-state', 'i-scrollbar-horizontal-thumb-down-state', 'i-scrollbar-horizontal-thumb-hover-state']);
			renderer.thumb.addClass(['i-scrollbar-horizontal-thumb-disabled-state']);
			
			scrollBarContainer.removeClass(['i-scrollbar-horizontal-container-hover']);
			if (!scrollBarContainer.hasClass(['i-scrollbar-horizontal-container-up'])) 
				scrollBarContainer.addClass(['i-scrollbar-horizontal-container-up']);
		}
	}
	
	/**
	 * Стиль вертикального скроллбара по-умолчанию
	 */
	private function setVerticalScrollbarStyle(renderer:IScrollBar) : Void {
		var scrollBarContainer:ScrollBarWithContainer = cast renderer;
		scrollBarContainer.style = {'z-index':SCROLL_CONTAINER_DEPTH};
		scrollBarContainer.snapTo(FlickerControl.SNAP_TO_CONTENT, FlickerControl.SNAP_TO_SELF);
		scrollBarContainer.addClass(['app-scrollbar-vertical-container']);
		
		var vLayout:VerticalLayout = new VerticalLayout();
		vLayout.ignoreY = true;
		vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
		vLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_FIT;
		vLayout.paddingLeft = vLayout.paddingTop = vLayout.paddingBottom = 4;
		vLayout.paddingRight = 2;
		scrollBarContainer.layout = vLayout;
		
		var renderer:ScrollBar = scrollBarContainer.scrollBar;
		renderer.snapTo(FlickerControl.SNAP_TO_CONTENT, FlickerControl.SNAP_TO_PARENT);
		renderer.addClass(['i-scrollbar-vertical-track']);
		renderer.minThumbSize = 12;
		renderer.x = 4;
		renderer.y = 4;
		renderer.ratio = .5;
		renderer.offsetRatioFunction = function(ownerSize:Float, contentSize:Float, ratio:Float) : Float {
			return -Math.abs(ownerSize / contentSize) * ratio;
		}
		
		var thumbTween:IAnimatable = null, layoutTween:IAnimatable;
		
		renderer.contentStyleFactory = function(content:FlickerControl) : Void {
			content.snapTo(FlickerControl.SNAP_TO_CONTENT, FlickerControl.SNAP_TO_CONTENT);
		}
		renderer.thumbStyleFactory = function(thumb:ScrollBarThumb) : Void {
			thumb.snapTo(FlickerControl.SNAP_TO_CONTENT, FlickerControl.SNAP_TO_CONTENT);
			thumb.interactive = false;
			thumb.addClass(['i-scrollbar-vertical-thumb']);
			thumb.width = 4;
		}
		renderer.upStyleFactory = function(renderer:IScrollBar) : Void {
			if (thumbTween != null) {
				Flicker.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (layoutTween != null) {
				Flicker.animator.remove(layoutTween);
				layoutTween = null;
			}
			if (renderer.thumb.width != 4)
				 thumbTween = cast Flicker.animator.tween(renderer.thumb, .1, {width:4});
			if (vLayout.paddingRight != 2)
				 layoutTween = cast Flicker.animator.tween(vLayout, .1, {paddingRight:2});
			renderer.thumb.removeClass(['i-scrollbar-vertical-thumb-down-state', 'i-scrollbar-vertical-thumb-hover-state', 'i-scrollbar-vertical-thumb-disabled-state']);
			renderer.thumb.addClass(['i-scrollbar-vertical-thumb-up-state']);
			
			scrollBarContainer.removeClass(['i-scrollbar-vertical-container-hover']);
			if (!scrollBarContainer.hasClass(['i-scrollbar-vertical-container-up'])) 
				scrollBarContainer.addClass(['i-scrollbar-vertical-container-up']);
		}
		renderer.downStyleFactory = function(renderer:IScrollBar) : Void {
			if (thumbTween != null) {
				Flicker.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (layoutTween != null) {
				Flicker.animator.remove(layoutTween);
				layoutTween = null;
			}
			if (renderer.thumb.width != 16)
				 thumbTween = cast Flicker.animator.tween(renderer.thumb, .1, {width:16});
			if (vLayout.paddingRight != 4)
				 layoutTween = cast Flicker.animator.tween(vLayout, .1, {paddingRight:4});
			renderer.thumb.removeClass(['i-scrollbar-vertical-thumb-up-state', 'i-scrollbar-vertical-thumb-hover-state', 'i-scrollbar-vertical-thumb-disabled-state']);
			renderer.thumb.addClass(['i-scrollbar-vertical-thumb-down-state']);
			
			scrollBarContainer.removeClass(['i-scrollbar-vertical-container-up']);
			if (!scrollBarContainer.hasClass(['i-scrollbar-vertical-container-hover'])) 
				scrollBarContainer.addClass(['i-scrollbar-vertical-container-hover']);
		}
		renderer.hoverStyleFactory = function(renderer:IScrollBar) : Void {
			if (thumbTween != null) {
				Flicker.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (layoutTween != null) {
				Flicker.animator.remove(layoutTween);
				layoutTween = null;
			}
			if (renderer.thumb.width != 16)
				 thumbTween = cast Flicker.animator.tween(renderer.thumb, .1, {width:16});
			if (vLayout.paddingRight != 4)
				 layoutTween = cast Flicker.animator.tween(vLayout, .1, {paddingRight:4});
			renderer.thumb.removeClass(['i-scrollbar-vertical-thumb-up-state', 'i-scrollbar-vertical-thumb-down-state', 'i-scrollbar-vertical-thumb-disabled-state']);
			renderer.thumb.addClass(['i-scrollbar-vertical-thumb-hover-state']);
			
			scrollBarContainer.removeClass(['i-scrollbar-vertical-container-up']);
			if (!scrollBarContainer.hasClass(['i-scrollbar-vertical-container-hover'])) 
				scrollBarContainer.addClass(['i-scrollbar-vertical-container-hover']);
		}
		renderer.disabledStyleFactory = function(renderer:IScrollBar) : Void {
			if (thumbTween != null) {
				Flicker.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (layoutTween != null) {
				Flicker.animator.remove(layoutTween);
				layoutTween = null;
			}
			if (renderer.thumb.width != 4)
				 thumbTween = cast Flicker.animator.tween(renderer.thumb, .1, {width:4});
			if (vLayout.paddingRight != 2)
				 layoutTween = cast Flicker.animator.tween(vLayout, .1, {paddingRight:2});
			renderer.thumb.removeClass(['i-scrollbar-vertical-thumb-up-state', 'i-scrollbar-vertical-thumb-down-state', 'i-scrollbar-vertical-thumb-hover-state']);
			renderer.thumb.addClass(['i-scrollbar-vertical-thumb-disabled-state']);
			
			scrollBarContainer.removeClass(['i-scrollbar-vertical-container-hover']);
			if (!scrollBarContainer.hasClass(['i-scrollbar-vertical-container-up'])) 
				scrollBarContainer.addClass(['i-scrollbar-vertical-container-up']);
		}
	}
	
	private function setPortfolioGalleryScreenStyle(screen:PortfolioGalleryScreen) : Void {
		screen.minRightOffset = GALLERY_MIN_RIGHT_OFFSET;
		screen.maxRightOffset = GALLERY_MAX_RIGHT_OFFSET;
		screen.minLeftOffset = GALLERY_MIN_LEFT_OFFSET;
		screen.maxLeftOffset = GALLERY_MAX_LEFT_OFFSET;
		screen.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_PARENT);
		screen.planeStyleFactory = setPortfolioGalleryScreenScrollPlaneStyle;
		var vLayout = new VerticalLayout();
		vLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
		vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
		vLayout.ignoreX = true;
		screen.layout = vLayout;
		screen.filterGroupStyleFactory = function(filter:FilterGroup) : Void {
			filter.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_SELF);
			filter.addClass(['filter']);
			filter.includeInLayout = false;
			filter.emitResizeEvents = false;
			var hLayout:HorizontalLayout = new HorizontalLayout();
			hLayout.maxWidth = 800;
			hLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_FIT;
			hLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_TOP;
			hLayout.paddingRight = GALLERY_MIN_RIGHT_OFFSET;
			hLayout.gap = -1;
			filter.layout = hLayout;
			filter.containerStyleFactory = function(container:FlickerControl) : Void {
				container.emitResizeEvents = false;
				container.style = {'z-index':10};
				container.snapTo(FlickerControl.SNAP_TO_SELF, FlickerControl.SNAP_TO_CONTENT);
				var hLayout1:HorizontalLayout = new HorizontalLayout();
				hLayout1.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_FIT;
				hLayout1.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_JUSTIFY;
				hLayout1.ignoreX = true;
				container.layout = hLayout1;
				container.isClipped = true;
			}
			filter.buttonsGroupStyleFactory = function(buttonsGroup:ButtonsGroup) : Void {
				buttonsGroup.emitResizeEvents = false;
				buttonsGroup.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_CONTENT);
				buttonsGroup.y = 54;
				buttonsGroup.addClass(['filter-group']);
				buttonsGroup.itemFactory = function() : IBaseListItemControl {
					var item:FilterItemRenderer = new FilterItemRenderer();
					item.emitResizeEvents = false;
					item.snapTo(FlickerControl.SNAP_TO_SELF, FlickerControl.SNAP_TO_PARENT);
					item.addClass(['filter-button']);
					var labelElement:Element = item.labelElement;
					labelElement.classList.add('label');
					setDefaultButtonStates(item, true);
					return cast item;
				}
				var hLayout:HorizontalLayout = new HorizontalLayout();
				hLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_FIT;
				hLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_JUSTIFY;
				hLayout.padding = hLayout.gap = 0;
				buttonsGroup.layout = hLayout;
				var hLayoutParams:HorizontalLayoutParams = new HorizontalLayoutParams();
				hLayoutParams.fitWidth = HorizontalLayoutParams.NO_FIT;
				buttonsGroup.layoutParams = hLayoutParams;
			}
			filter.openButtonStyleFactory = function(button:Button) : Void {
				setFloatButtonStyle(button);
				button.style = {'z-index':10};
				button.setPivot('left', 'top');
				button.height = 54;
				button.width = 54;
				button.icon = ['icon-arrow_back', 'back-button-icon'];
				var hLayoutParams:HorizontalLayoutParams = new HorizontalLayoutParams();
				hLayoutParams.fitWidth = HorizontalLayoutParams.NO_FIT;
				button.layoutParams = hLayoutParams;
			}
			filter.height = 54;
		}
	}
	
	private function setPortfolioGalleryScreenScrollPlaneStyle(plane:ScrollPlane) : Void {
		plane.horizontalScrollBarFactory = function() : IScrollBar {
			return new ScrollBarWithContainer('sb-', 'scrollbar-', 'scrollbar-', 'horizontal');
		}
		plane.verticalScrollBarFactory = function() : IScrollBar {
			return new ScrollBarWithContainer('sb-', 'scrollbar-', 'scrollbar-', 'vertical');
		}
		plane.addClass(['i-scroller']);
		plane.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_PARENT);
		plane.horizontalScrollPolicy = ScrollPlane.SCROLL_POLICY_OFF;
		plane.verticalScrollPolicy = ScrollPlane.SCROLL_POLICY_AUTO;
		plane.horizontalScrollBarStyleFactory = setHorizontalScrollbarStyle;
		plane.verticalScrollBarStyleFactory = setVerticalScrollbarStyle;
		plane.contentStyleFactory = function(content:FlickerControl) : Void {
			content.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_CONTENT);
			var rLayout:RockRowsLayout = new RockRowsLayout();
			rLayout.paggination = RockRowsLayout.PAGGINATION_VERTICAL;
			rLayout.horizontalAlign = RockRowsLayout.HORIZONTAL_ALIGN_JUSTIFY;
			rLayout.paddingLeft = 0;
			rLayout.paddingRight = 0;
			rLayout.paddingTop = 0;
			rLayout.paddingBottom = 0;
			rLayout.gap = 1;
			content.layout = rLayout;
		}
		plane.barrierStyleFactory = function(barrier:Barrier) : Void {
			barrier.emitResizeEvents = false;
			barrier.barrierColor = 'rgb(240,240,240)';
			barrier.maxTension = 54;
		}
		plane.delayedBuilderStyleFactory = function(delayedBuilder:DelayedBuilder) : Void {
			delayedBuilder.delay = 0.001;
			delayedBuilder.postFactory = function(object:FlickerControl) : Void {
				object.addClass(['i-delayed-builder']);
			}
		}
		plane.enableBarriers = true;
	}
	
	private function setPortfolioProjectScreenStyle(screen:PortfolioProjectScreen) : Void {
		var vLayout:VerticalLayout = new VerticalLayout();
		vLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
		vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
		screen.layout = vLayout;
		screen.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_PARENT);
		screen.planeStyleFactory = function(plane:ScrollPlane) : Void {
			setPortfolioScreenScrollPlaneStyle(plane);
			
			plane.horizontalScrollBarStyleFactory = function(renderer:IScrollBar) : Void {
				setHorizontalScrollbarStyle(renderer);
				renderer.style = {'z-index':99999999999999999};
			}
			plane.verticalScrollBarStyleFactory = function(renderer:IScrollBar) : Void {
				setVerticalScrollbarStyle(renderer);
				renderer.style = {'z-index':99999999999999999};
			}
			
			plane.contentStyleFactory = function(content:FlickerControl) : Void {
				content.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_CONTENT);
				var vLayout:VerticalLayout = new VerticalLayout();
				vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
				vLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
				vLayout.paddingLeft = 30;
				vLayout.paddingRight = 30;
				vLayout.paddingTop = 20;
				vLayout.paddingBottom = 30;
				vLayout.verticalGap = 40;
				content.layout = vLayout;
			}
			plane.verticalScrollbarOffsetBottom = 0;
			plane.verticalScrollbarOffsetTop = 0;// 64;
			
			plane.barrierStyleFactory = function(barrier:Barrier) : Void {
				barrier.emitResizeEvents = false;
				barrier.barrierTopColor = 'rgb(240,240,240)';
				barrier.barrierBottomColor = 'rgb(240,240,240)';
				barrier.maxTension = 54;
			}
		}
		
		screen.contentStyleFactory = function(content:FlickerControl) : Void {
			content.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_CONTENT);
		}
		
		screen.backButtonStyleFactory = function(button:Button) : Void {
			setFloatButtonStyle(button);
			button.addClass(['project-screen__back-button']);
			button.includeInLayout = false;
			button.height = 54;
			button.width = 54;
			button.x = 0;
			button.y = 0;
			button.icon = ['icon-arrow_back', 'back-button-icon'];
		}
	}
	
	private function setPortfolioScreenStyle(screen:PortfolioScreen) : Void {
		screen.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_PARENT);
		screen.navigatorStyleFactory = function(navigator:ScreenNavigator) : Void {
			navigator.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_PARENT);
		}
	}
	
	private function setAboutMeScreenStyle(screen:AboutMeScreen) : Void {
		screen.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_PARENT);
		screen.planeStyleFactory = function(_plane:ScrollPlane) : Void {
			setPortfolioScreenScrollPlaneStyle(_plane);
			_plane.contentStyleFactory = function(content:FlickerControl) : Void {
				content.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_CONTENT);
				var vLayout:VerticalLayout = new VerticalLayout();
				vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
				vLayout.paddingLeft = vLayout.paddingTop = vLayout.paddingBottom = 20;
				vLayout.paddingRight = 20;
				vLayout.verticalGap = 1;
				content.layout = vLayout;
			}
		}
	}
	
	private function setContactsScreenStyle(screen:ContactsScreen) : Void {
		screen.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_PARENT);
		screen.planeStyleFactory = function(_plane:ScrollPlane) : Void {
			setPortfolioScreenScrollPlaneStyle(_plane);
			_plane.contentStyleFactory = function(content:FlickerControl) : Void {
				content.snapTo(FlickerControl.SNAP_TO_PARENT, FlickerControl.SNAP_TO_CONTENT);
				var vLayout:VerticalLayout = new VerticalLayout();
				vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
				vLayout.paddingLeft = vLayout.paddingTop = vLayout.paddingBottom = 20;
				vLayout.paddingRight = 20;
				vLayout.verticalGap = 1;
				content.layout = vLayout;
			}
		}
	}
}