package ru.ice.app.theme;

import haxe.Constraints.Function;
import ru.ice.animation.Transitions;
import ru.ice.app.controls.SimplePreloader;

import ru.ice.app.App;
import ru.ice.app.controls.MenuPanel;
import ru.ice.app.controls.gallery.RockGalleryItemRenderer;
import ru.ice.controls.Header;
import ru.ice.controls.Image;
import ru.ice.controls.ScreenNavigator;
import ru.ice.controls.IScrollBar;
import ru.ice.controls.ScrollBar;
import ru.ice.controls.ScrollBarWithContainer;
import ru.ice.controls.ScrollPlane;
import ru.ice.controls.Scroller;
import ru.ice.controls.TabBar;
import ru.ice.controls.itemRenderer.TabBarItemRenderer;
import ru.ice.controls.super.BaseListItemControl;
import ru.ice.controls.super.BaseStatesControl;
import ru.ice.controls.super.IceControl;
import ru.ice.events.Event;
import ru.ice.events.FingerEvent;
import ru.ice.events.WheelScrollEvent;
import ru.ice.layout.FitLayout;
import ru.ice.layout.FluidRowsLayout;
import ru.ice.layout.HorizontalLayout;
import ru.ice.layout.RockRowsLayout;
import ru.ice.layout.VerticalLayout;
import ru.ice.controls.Screen;
import ru.ice.controls.Label;
import ru.ice.data.ElementData;
import ru.ice.layout.params.HorizontalLayoutParams;
import ru.ice.layout.params.VerticalLayoutParams;
import ru.ice.theme.Theme;
import ru.ice.controls.DelayedBuilder;
import ru.ice.display.DisplayObject;
import ru.ice.controls.Button;
import ru.ice.app.screens.PortfolioProjectScreen;
import ru.ice.app.screens.PortfolioGalleryScreen;
import ru.ice.app.screens.PortfolioScreen;
import ru.ice.app.screens.AboutMeScreen;
import ru.ice.app.controls.ArticleFluidContainer;
import ru.ice.app.controls.ArticleHeader;
import ru.ice.app.controls.Article;
import ru.ice.animation.IAnimatable;
import ru.ice.core.Ice;
import ru.ice.utils.MathUtil;
import ru.ice.display.Stage;
import ru.ice.app.controls.gallery.RockGalleryGroup;

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
	
	public function new() 
	{
		super();
	}
	
	private override function setStyles() : Void {
		super.setStyles();
		
		setStyle(Button, 'animated-button', setAnimatedButtonStyle);
		
		setStyle(App, App.DEFAULT_STYLE, setAppStyle);
		
		setStyle(AboutMeScreen, AboutMeScreen.DEFAULT_STYLE, setAboutMeScreenStyle);
		setStyle(PortfolioScreen, PortfolioScreen.DEFAULT_STYLE, setPortfolioScreenStyle);
		setStyle(RockGalleryGroup, RockGalleryGroup.DEFAULT_STYLE, setDefaultRockGalleryGroupStyle);
		setStyle(RockGalleryIRScreen, RockGalleryIRScreen.DEFAULT_STYLE, setDefaultRockGalleryIRScreenStyle);
		setStyle(PortfolioGalleryScreen, PortfolioGalleryScreen.DEFAULT_STYLE, setPortfolioGalleryScreenStyle);
		setStyle(PortfolioProjectScreen, PortfolioProjectScreen.DEFAULT_STYLE, setPortfolioProjectScreenStyle);
		setStyle(RockGalleryItemRenderer, RockGalleryItemRenderer.DEFAULT_STYLE, setDefaultRockGalleryItemRendererStyle);
	}
	
	private function setAppTabBarItemRendererStyle(renderer:TabBarItemRenderer) : Void {
		renderer.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_PARENT);
		renderer.buttonFactory = function(renderer:Button) : Void {
			renderer.style = {'z-index':TABBAR_DEPTH};
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
		};
	}
	
	private function setAppMenuPanelTabBarItemRendererStyle(renderer:TabBarItemRenderer) : Void {
		renderer.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_SELF);
		renderer.height = 64;
		renderer.buttonFactory = function(renderer:Button) : Void {
			renderer.style = {'z-index':TABBAR_DEPTH};
			renderer.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_PARENT);
			var hLayout:HorizontalLayout = new HorizontalLayout();
			hLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_FIT;
			hLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_JUSTIFY;
			hLayout.paddingLeft = 20;
			hLayout.paddingRight = 0;
			renderer.layout = hLayout;
			renderer.addClass(['mp-tabbar-button']);
			renderer.setPivot('center', 'center');
			renderer.labelInitializedStyleFactory = function(label:Label) : Void {
				label.snapTo(IceControl.SNAP_TO_CONTENT, IceControl.SNAP_TO_CONTENT);
				label.addClass(['mp-tabbar-button-label']);
				label.wordwap = true;
			}
			renderer.iconInitializedStyleFactory = function(icon:Label) : Void {
				icon.addClass(['mp-item-renderer-icon']);
				var hLayoutParams:HorizontalLayoutParams = new HorizontalLayoutParams();
				hLayoutParams.fitWidth = HorizontalLayoutParams.NO_FIT;
				icon.layoutParams = hLayoutParams;
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
				button.labelStyleFactory = button.iconStyleFactory = function(label:Label) : Void {
					label.removeClass(['mp-tabbar-button-label-down', 'mp-tabbar-button-label-hover', 'mp-tabbar-button-label-select', 'mp-tabbar-button-label-disabled']);
					label.addClass(['mp-tabbar-button-label-up']);
				}
				button.removeClass(['mp-tabbar-button-down', 'mp-tabbar-button-hover', 'mp-tabbar-button-select', 'mp-tabbar-button-disabled']);
				button.addClass(['mp-tabbar-button-up']);
			}
			renderer.downStyleFactory = function(button:Button) : Void {
				button.labelStyleFactory = button.iconStyleFactory = function(label:Label) : Void {
					label.removeClass(['mp-tabbar-button-label-up', 'mp-tabbar-button-label-hover', 'mp-tabbar-button-label-select', 'mp-tabbar-button-label-disabled']);
					label.addClass(['mp-tabbar-button-label-down']);
				}
				button.removeClass(['mp-tabbar-button-up', 'mp-tabbar-button-hover', 'mp-tabbar-button-select', 'mp-tabbar-button-disabled']);
				button.addClass(['mp-tabbar-button-down']);
			}
			renderer.hoverStyleFactory = function(button:Button) : Void {
				button.labelStyleFactory = button.iconStyleFactory = function(label:Label) : Void {
					label.removeClass(['mp-tabbar-button-label-up', 'mp-tabbar-button-label-down', 'mp-tabbar-button-label-select', 'mp-tabbar-button-label-disabled']);
					label.addClass(['mp-tabbar-button-label-hover']);
				}
				button.removeClass(['mp-tabbar-button-up', 'mp-tabbar-button-down', 'mp-tabbar-button-select', 'mp-tabbar-button-disabled']);
				button.addClass(['mp-tabbar-button-hover']);
			}
			renderer.selectStyleFactory = function(button:Button) : Void {
				button.labelStyleFactory = button.iconStyleFactory = function(label:Label) : Void {
					label.removeClass(['mp-tabbar-button-label-up', 'mp-tabbar-button-label-down', 'mp-tabbar-button-label-hover', 'mp-tabbar-button-label-disabled']);
					label.addClass(['mp-tabbar-button-label-select']);
				}
				button.removeClass(['mp-tabbar-button-up', 'mp-tabbar-button-down', 'mp-tabbar-button-hover', 'mp-tabbar-button-disabled']);
				button.addClass(['mp-tabbar-button-select']);
			}
			renderer.disabledStyleFactory = function(button:Button) : Void {
				button.labelStyleFactory = button.iconStyleFactory = function(label:Label) : Void {
					label.removeClass(['mp-tabbar-button-label-up', 'mp-tabbar-button-label-down', 'mp-tabbar-button-label-hover', 'mp-tabbar-button-label-select']);
					label.addClass(['mp-tabbar-button-label-disabled']);
				}
				button.removeClass(['mp-tabbar-button-up', 'mp-tabbar-button-down', 'mp-tabbar-button-hover', 'mp-tabbar-button-select']);
				button.addClass(['mp-tabbar-button-disabled']);
			}
		};
	}
	
	private function setAppStyle(app:App) : Void {
		app.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_PARENT);
		
		var vLayout:VerticalLayout = new VerticalLayout();
		vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
		vLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_FIT;
		app.layout = vLayout;
		
		app.maxWidthForCompact = 700;
		
		var minMenuWidth:Int = 60;
		
		app.menuContainerStyleFactory = function(container:IceControl) : Void {
			var hLayout:HorizontalLayout = new HorizontalLayout();
			hLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_FIT;
			hLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_JUSTIFY;
			container.layout = hLayout;
		}
		app.contentContainerStyleFactory = function(container:IceControl) : Void {
			var vLayout:VerticalLayout = new VerticalLayout();
			vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
			vLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_FIT;
			container.layout = vLayout;
		}
		app.menuStubStyleFactory = function(menuStub:IceControl) : Void {
			menuStub.snapTo(IceControl.SNAP_NONE, IceControl.SNAP_NONE);
			
			menuStub.width = minMenuWidth;
			
			var hLayoutParams:HorizontalLayoutParams = new HorizontalLayoutParams();
			hLayoutParams.fitWidth = HorizontalLayoutParams.NO_FIT;
			menuStub.layoutParams = hLayoutParams;
		}
		app.menuPanelStyleFactory = function(menuPanel:MenuPanel) : Void {
			menuPanel.snapTo(IceControl.SNAP_NONE, IceControl.SNAP_TO_PARENT);
			menuPanel.width = 200;
			menuPanel.addClass(['menu-panel']);
			menuPanel.includeInLayout = false;
			menuPanel.x = -minMenuWidth;
			
			var menuPanelTween:IAnimatable = null;
			
			menuPanel.upStyleFactory = function(button:Button) : Void {
				if (menuPanelTween != null) {
					Ice.animator.remove(menuPanelTween);
					menuPanelTween = null;
				}
				if (button.x != -button.width)
					menuPanelTween = cast Ice.animator.tween(button, .3, {x:-button.width, transition:Transitions.EASE_OUT});
			}
			menuPanel.hoverStyleFactory = function(button:Button) : Void {
				if (menuPanelTween != null) {
					Ice.animator.remove(menuPanelTween);
					menuPanelTween = null;
				}
				if (button.x != -minMenuWidth)
					menuPanelTween = cast Ice.animator.tween(button, .3, {x:-minMenuWidth, transition:Transitions.EASE_OUT});
			}
			
			var vLayout:VerticalLayout = new VerticalLayout();
			vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
			vLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			vLayout.paddingRight = 0;
			menuPanel.layout = vLayout;
			
			menuPanel.tabBarStyleFactory = function(tabbar:TabBar) : Void {
				tabbar.style = {'z-index':TABBAR_DEPTH};
				tabbar.itemFactory = function(data:Dynamic) : BaseListItemControl {
					var item:TabBarItemRenderer = new TabBarItemRenderer();
					setAppMenuPanelTabBarItemRendererStyle(item);
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
			navigator.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_SELF);
		}
		app.tabBarStyleFactory = function(tabbar:TabBar) : Void {
			tabbar.style = {'z-index':TABBAR_DEPTH};
			tabbar.addClass(['i-tabbar']);
			tabbar.itemFactory = function(data:Dynamic) : BaseListItemControl {
				var item:TabBarItemRenderer = new TabBarItemRenderer();
				item.style = {'z-index':TABBAR_DEPTH};
				setAppTabBarItemRendererStyle(item);
				item.data = data;
				return cast item;
			}
			var hLayout:HorizontalLayout = new HorizontalLayout();
			hLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_FIT;
			hLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_JUSTIFY;
			hLayout.paddingLeft = hLayout.paddingRight = 10;
			tabbar.layout = hLayout;
			
			var vLayoutParams:VerticalLayoutParams = new VerticalLayoutParams();
			vLayoutParams.fitHeight = VerticalLayoutParams.NO_FIT;
			tabbar.layoutParams = vLayoutParams;
			tabbar.height = 60;
		}
		app.footerStyleFactory = function(footer:Header) : Void {
			footer.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_SELF);
			footer.height = 50;
			var vLayout:VerticalLayout = new VerticalLayout();
			vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
			vLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_JUSTIFY;
			//vLayout.padding = 10;
			footer.layout = vLayout;
			footer.isClipped = true;
			footer.addClass(['footer']);
			footer.containerStyleFactory = function(container:IceControl) : Void {
				container.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_PARENT);
				container.isClipped = true;
				var vLayout:VerticalLayout = new VerticalLayout();
				vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
				vLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_MIDDLE;
				vLayout.snapToStageWidth = true;
				vLayout.snapToStageHeight = true;
				container.layout = vLayout;
			}
			footer.titleStyleFactory = function(title:IceControl) : Void {
				title.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_HTML_CONTENT);
				title.addClass(['container']);
			}
			
			var vLayoutParams:VerticalLayoutParams = new VerticalLayoutParams();
			vLayoutParams.fitHeight = VerticalLayoutParams.NO_FIT;
			footer.layoutParams = vLayoutParams;
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
		plane.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_PARENT);
		plane.horizontalScrollPolicy = ScrollPlane.SCROLL_POLICY_OFF;
		plane.verticalScrollPolicy = ScrollPlane.SCROLL_POLICY_AUTO;
		plane.horizontalScrollBarStyleFactory = setHorizontalScrollbarStyle;
		plane.verticalScrollBarStyleFactory = setVerticalScrollbarStyle;
		plane.contentStyleFactory = function(content:IceControl) : Void {
			content.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_CONTENT);
			var vLayout:VerticalLayout = new VerticalLayout();
			vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
			vLayout.paddingLeft = 30;
			vLayout.paddingRight = 30;
			vLayout.paddingTop = 30;
			vLayout.paddingBottom = 30;
			vLayout.verticalGap = 40;
			content.layout = vLayout;
		}
		plane.barrierStyleFactory = function(barrier:Barrier) : Void {
			barrier.emitResizeEvents = false;
			barrier.barrierColor = 'rgb(220,220,220)';
			barrier.maxTension = 54;
		}
		plane.delayedBuilderStyleFactory = function(delayedBuilder:DelayedBuilder) : Void {
			delayedBuilder.delay = .001;
			delayedBuilder.transitionFactory = function(object:DisplayObject) : Void {
				object.addClass(['i-delayed-builder']);
			}
		}
		plane.enableBarriers = true;
	}
	
	private function setDefaultRockGalleryGroupStyle(renderer:RockGalleryGroup) : Void {
		renderer.snapTo(IceControl.SNAP_TO_SELF, IceControl.SNAP_TO_CONTENT);
		var vLayout:VerticalLayout = new VerticalLayout();
		vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
		vLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
		vLayout.snapToStageWidth = true;
		vLayout.paddingLeft = 0;
		vLayout.paddingRight = 0;
		renderer.layout = vLayout;
		
		renderer.headerStyleFactory = function(header:IceControl) : Void {
			header.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_HTML_CONTENT);
		}
		renderer.galleryStyleFactory = function(gallery:IceControl) : Void {
			gallery.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_SELF);
			gallery.delayedBuilderStyleFactory = function(delayedBuilder:DelayedBuilder) : Void {
				delayedBuilder.delay = .001;
				delayedBuilder.transitionFactory = function(object:DisplayObject) : Void {
					object.addClass(['i-delayed-builder']);
				}
			}
			var rLayout:RockRowsLayout = new RockRowsLayout();
			rLayout.paggination = RockRowsLayout.PAGGINATION_VERTICAL;
			rLayout.horizontalAlign = RockRowsLayout.HORIZONTAL_ALIGN_JUSTIFY;
			rLayout.paddingLeft = 0;
			rLayout.paddingRight = 0;
			rLayout.paddingTop = 0;
			rLayout.paddingBottom = 0;
			rLayout.gap = 4;
			gallery.layout = rLayout;
		}
	}
	
	private function setDefaultRockGalleryIRScreenStyle(renderer:RockGalleryIRScreen) : Void {
		renderer.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_PARENT);
		var hLayout:HorizontalLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_FIT;
		hLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_JUSTIFY;
		hLayout.ignoreX = hLayout.ignoreY = true;
		renderer.layout = hLayout;
		renderer.isClipped = true;
		renderer.emitResizeEvents = false;
		renderer.imageStyleFactory = function(image:Image) : Void {
			image.snapTo(IceControl.SNAP_TO_CONTENT, IceControl.SNAP_TO_CONTENT);
			image.emitResizeEvents = false;
			image.proportional = true;
			image.stretchType = Image.FROM_MAX_RECT;
			image.alignCenter = true;
		}
		renderer.preloaderStyleFactory = function(preloader:SimplePreloader) : Void {
			preloader.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_PARENT);
			preloader.pContainer.classList.add('c-simple-preloader');
			preloader.img.classList.add('simple-preloader');
			preloader.img.src = 'assets/preloader_d_s.gif';
		}
	}
	
	private function setDefaultRockGalleryItemRendererStyle(renderer:RockGalleryItemRenderer) : Void {
		var index:Int = renderer.parent.getChildIndex(renderer);
		renderer.style = {'z-index':index};
		renderer.isClipped = true;
		renderer.snapTo(IceControl.SNAP_TO_SELF, IceControl.SNAP_TO_SELF);
		var hLayout:HorizontalLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_JUSTIFY;
		hLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_JUSTIFY;
		hLayout.ignoreX = hLayout.ignoreY = true;
		renderer.layout = hLayout;
		renderer.addClass(['rock-item-renderer']);
		renderer.setPivot('center', 'center');
		hLayout.snapToStageHeight = hLayout.snapToStageWidth = true;
		renderer.headerStyleFactory = function(header:Header) : Void {
			header.addClass(['rock-item-header']);
			header.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_PARENT);
			header.isClipped = true;
		}
		renderer.navigatorStyleFactory = function(navigator:ScreenNavigator) : Void {
			navigator.snapTo(IceControl.SNAP_TO_SELF, IceControl.SNAP_TO_SELF);
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
	
	private function setAnimatedButtonStyle(renderer:Button) : Void {
		//var index:Int = renderer.parent.getChildIndex(renderer);
		//renderer.style = {'z-index':index};
		renderer.snapTo(IceControl.SNAP_TO_SELF, IceControl.SNAP_TO_SELF);
		var hLayout:HorizontalLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_FIT;
		hLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_JUSTIFY;
		hLayout.paddingLeft = 10;
		hLayout.paddingRight = 10;
		renderer.layout = hLayout;
		renderer.addClass(['i-animated-button']);
		renderer.setPivot('center', 'center');
		var btnTween:IAnimatable = null;
		renderer.labelInitializedStyleFactory = function(label:Label) : Void {
			label.addClass(['i-animated-button-label']);
			label.wordwap = true;
		}
		renderer.contentBoxStyleFactory = function(box:IceControl) : Void {
			box.snapTo(IceControl.SNAP_TO_SELF, IceControl.SNAP_TO_SELF);
			var hLayout:HorizontalLayout = new HorizontalLayout();
			hLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_JUSTIFY;
			hLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			hLayout.snapToStageHeight = true;
			box.layout = hLayout;
		}
		renderer.upStyleFactory = function(button:Button) : Void {
			//renderer.style = {'z-index':index};
			if (btnTween != null) {
				Ice.animator.remove(btnTween);
				btnTween = null;
			}
			if (button.scaleX != 1 || button.scaleY != 1)
				 btnTween = cast Ice.animator.tween(button, .1, {scaleX:1, scaleY:1});
			button.removeClass(['i-animated-button-down', 'i-animated-button-hover', 'i-animated-button-select', 'i-animated-button-disabled']);
			button.addClass(['i-animated-button-up']);
		}
		renderer.downStyleFactory = function(button:Button) : Void {
			//renderer.style = {'z-index':0};
			if (btnTween != null) {
				Ice.animator.remove(btnTween);
				btnTween = null;
			}
			if (button.scaleX != 0.985 || button.scaleY != 0.985)
				 btnTween = cast Ice.animator.tween(button, .1, {scaleX:0.985, scaleY:0.985});
			button.removeClass(['i-animated-button-up', 'i-animated-button-hover', 'i-animated-button-select', 'i-animated-button-disabled']);
			button.addClass(['i-animated-button-down']);
		}
		renderer.hoverStyleFactory = function(button:Button) : Void {
			//renderer.style = {'z-index':renderer.parent.children.length};
			if (btnTween != null) {
				Ice.animator.remove(btnTween);
				btnTween = null;
			}
			if (button.scaleX != 1.015 || button.scaleY != 1.015)
				 btnTween = cast Ice.animator.tween(button, .1, {scaleX:1.015, scaleY:1.015});
			button.removeClass(['i-animated-button-up', 'i-animated-button-down', 'i-animated-button-select', 'i-animated-button-disabled']);
			button.addClass(['i-animated-button-hover']);
		}
		renderer.selectStyleFactory = function(button:Button) : Void {
			//renderer.style = {'z-index':index};
			if (btnTween != null) {
				Ice.animator.remove(btnTween);
				btnTween = null;
			}
			if (button.scaleX != 1 || button.scaleY != 1)
				 btnTween = cast Ice.animator.tween(button, .1, {scaleX:1, scaleY:1});
			button.removeClass(['i-animated-button-up', 'i-animated-button-down', 'i-animated-button-hover', 'i-animated-button-disabled']);
			button.addClass(['i-animated-button-select']);
		}
		renderer.disabledStyleFactory = function(button:Button) : Void {
			//renderer.style = {'z-index':index};
			if (btnTween != null) {
				Ice.animator.remove(btnTween);
				btnTween = null;
			}
			if (button.scaleX != 1 || button.scaleY != 1)
				 btnTween = cast Ice.animator.tween(button, .1, {scaleX:1, scaleY:1});
			button.removeClass(['i-animated-button-up', 'i-animated-button-down', 'i-animated-button-hover', 'i-animated-button-select']);
			button.addClass(['i-animated-button-disabled']);
		}
	}
	
	/**
	 * Стиль горизонтального скроллбара по-умолчанию
	 */
	private function setHorizontalScrollbarStyle(renderer:IScrollBar) : Void {
		var scrollBarContainer:ScrollBarWithContainer = cast renderer;
		scrollBarContainer.style = {'z-index':SCROLL_CONTAINER_DEPTH};
		scrollBarContainer.snapTo(IceControl.SNAP_TO_SELF, IceControl.SNAP_TO_CONTENT);
		scrollBarContainer.addClass(['app-scrollbar-horizontal-container']);
		
		var renderer:ScrollBar = scrollBarContainer.scrollBar;
		renderer.ratio = .5;
		renderer.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_CONTENT);
		renderer.addClass(['i-scrollbar-horizontal-track']);
		renderer.minThumbSize = 12;
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
			thumb.height = 4;
			thumb.addClass(['i-scrollbar-horizontal-thumb']);
		}
		renderer.upStyleFactory = function(renderer:IScrollBar) : Void {
			if (thumbTween != null) {
				Ice.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.height != 4)
				 thumbTween = cast Ice.animator.tween(renderer.thumb, .1, {height:4});
			renderer.thumb.removeClass(['i-scrollbar-horizontal-thumb-down-state', 'i-scrollbar-horizontal-thumb-hover-state', 'i-scrollbar-horizontal-thumb-disabled-state']);
			renderer.thumb.addClass(['i-scrollbar-horizontal-thumb-up-state']);
			
			scrollBarContainer.removeClass(['i-scrollbar-horizontal-container-hover']);
			if (!scrollBarContainer.hasClass(['i-scrollbar-horizontal-container-up'])) 
				scrollBarContainer.addClass(['i-scrollbar-horizontal-container-up']);
		}
		renderer.downStyleFactory = function(renderer:IScrollBar) : Void {
			if (thumbTween != null) {
				Ice.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.height != 12)
				 thumbTween = cast Ice.animator.tween(renderer.thumb, .1, {height:12});
			renderer.thumb.removeClass(['i-scrollbar-horizontal-thumb-up-state', 'i-scrollbar-horizontal-thumb-hover-state', 'i-scrollbar-horizontal-thumb-disabled-state']);
			renderer.thumb.addClass(['i-scrollbar-horizontal-thumb-down-state']);
			
			scrollBarContainer.removeClass(['i-scrollbar-horizontal-container-up']);
			if (!scrollBarContainer.hasClass(['i-scrollbar-horizontal-container-hover'])) 
				scrollBarContainer.addClass(['i-scrollbar-horizontal-container-hover']);
		}
		renderer.hoverStyleFactory = function(renderer:IScrollBar) : Void {
			if (thumbTween != null) {
				Ice.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.height != 12)
				 thumbTween = cast Ice.animator.tween(renderer.thumb, .1, {height:12});
			renderer.thumb.removeClass(['i-scrollbar-horizontal-thumb-up-state', 'i-scrollbar-horizontal-thumb-down-state', 'i-scrollbar-horizontal-thumb-disabled-state']);
			renderer.thumb.addClass(['i-scrollbar-horizontal-thumb-hover-state']);
			
			scrollBarContainer.removeClass(['i-scrollbar-horizontal-container-up']);
			if (!scrollBarContainer.hasClass(['i-scrollbar-horizontal-container-hover'])) 
				scrollBarContainer.addClass(['i-scrollbar-horizontal-container-hover']);
		}
		renderer.disabledStyleFactory = function(renderer:IScrollBar) : Void {
			if (thumbTween != null) {
				Ice.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.height != 4)
				 thumbTween = cast Ice.animator.tween(renderer.thumb, .1, {height:4});
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
		scrollBarContainer.snapTo(IceControl.SNAP_TO_CONTENT, IceControl.SNAP_TO_SELF);
		scrollBarContainer.addClass(['app-scrollbar-vertical-container']);
		
		var vLayout:VerticalLayout = new VerticalLayout();
		vLayout.ignoreY = true;
		vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
		vLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_FIT;
		//vLayout.snapToStageWidth = true;
		vLayout.padding = 4;
		scrollBarContainer.layout = vLayout;
		
		var renderer:ScrollBar = scrollBarContainer.scrollBar;
		renderer.snapTo(IceControl.SNAP_TO_CONTENT, IceControl.SNAP_TO_PARENT);
		renderer.addClass(['i-scrollbar-vertical-track']);
		renderer.minThumbSize = 12;
		renderer.x = 4;
		renderer.y = 4;
		renderer.ratio = .5;
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
			thumb.width = 4;
		}
		renderer.upStyleFactory = function(renderer:IScrollBar) : Void {
			if (thumbTween != null) {
				Ice.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.width != 4)
				 thumbTween = cast Ice.animator.tween(renderer.thumb, .1, {width:4});
			renderer.thumb.removeClass(['i-scrollbar-vertical-thumb-down-state', 'i-scrollbar-vertical-thumb-hover-state', 'i-scrollbar-vertical-thumb-disabled-state']);
			renderer.thumb.addClass(['i-scrollbar-vertical-thumb-up-state']);
			
			scrollBarContainer.removeClass(['i-scrollbar-vertical-container-hover']);
			if (!scrollBarContainer.hasClass(['i-scrollbar-vertical-container-up'])) 
				scrollBarContainer.addClass(['i-scrollbar-vertical-container-up']);
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
			
			scrollBarContainer.removeClass(['i-scrollbar-vertical-container-up']);
			if (!scrollBarContainer.hasClass(['i-scrollbar-vertical-container-hover'])) 
				scrollBarContainer.addClass(['i-scrollbar-vertical-container-hover']);
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
			
			scrollBarContainer.removeClass(['i-scrollbar-vertical-container-up']);
			if (!scrollBarContainer.hasClass(['i-scrollbar-vertical-container-hover'])) 
				scrollBarContainer.addClass(['i-scrollbar-vertical-container-hover']);
		}
		renderer.disabledStyleFactory = function(renderer:IScrollBar) : Void {
			if (thumbTween != null) {
				Ice.animator.remove(thumbTween);
				thumbTween = null;
			}
			if (renderer.thumb.width != 4)
				 thumbTween = cast Ice.animator.tween(renderer.thumb, .1, {width:4});
			renderer.thumb.removeClass(['i-scrollbar-vertical-thumb-up-state', 'i-scrollbar-vertical-thumb-down-state', 'i-scrollbar-vertical-thumb-hover-state']);
			renderer.thumb.addClass(['i-scrollbar-vertical-thumb-disabled-state']);
			
			scrollBarContainer.removeClass(['i-scrollbar-vertical-container-hover']);
			if (!scrollBarContainer.hasClass(['i-scrollbar-vertical-container-up'])) 
				scrollBarContainer.addClass(['i-scrollbar-vertical-container-up']);
		}
	}
	
	private function setPortfolioGalleryScreenStyle(screen:PortfolioGalleryScreen) : Void {
		screen.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_PARENT);
		screen.planeStyleFactory = setPortfolioScreenScrollPlaneStyle;
	}
	
	private function setPortfolioProjectScreenStyle(screen:PortfolioProjectScreen) : Void {
		var vLayout:VerticalLayout = new VerticalLayout();
		vLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_FIT;
		vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
		screen.layout = vLayout;
		screen.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_PARENT);
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
			
			plane.contentStyleFactory = function(content:IceControl) : Void {
				content.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_CONTENT);
				var vLayout:VerticalLayout = new VerticalLayout();
				vLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_JUSTIFY;
				vLayout.paddingLeft = 30;
				vLayout.paddingRight = 30;
				vLayout.paddingTop = 64;
				vLayout.paddingBottom = 30;
				vLayout.verticalGap = 40;
				content.layout = vLayout;
			}
			plane.verticalScrollbarOffsetBottom = 0;
			plane.verticalScrollbarOffsetTop = 0;// 64;
			
			plane.barrierStyleFactory = function(barrier:Barrier) : Void {
				barrier.emitResizeEvents = false;
				barrier.barrierTopColor = 'rgb(0,0,0)';
				barrier.barrierBottomColor = 'rgb(220,220,220)';
				barrier.maxTension = 54;
			}
		}
		
		screen.headerStyleFactory = function(header:IceControl) : Void {
			header.includeInLayout = false;
			header.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_SELF);
			header.addClass(['app-portfolio-project-header']);
			header.isClipped = true;
			var vLayoutParams:VerticalLayoutParams = new VerticalLayoutParams();
			vLayoutParams.fitHeight = VerticalLayoutParams.NO_FIT;
			header.layoutParams = vLayoutParams;
			header.height = 64;
		}
		
		screen.contentStyleFactory = function(content:IceControl) : Void {
			content.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_HTML_CONTENT);
		}
		
		screen.backButtonStyleFactory = function(button:Button) : Void {
			setAnimatedButtonStyle(button);
			button.includeInLayout = false;
			button.height = 54;
			button.width = 54;
			button.x = 10;
			button.y = 5;
			button.icon = ['icon-arrow-left-24', 'back-button-icon'];
		}
	}
	
	private function setPortfolioScreenStyle(screen:PortfolioScreen) : Void {
		screen.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_PARENT);
		screen.navigatorStyleFactory = function(navigator:ScreenNavigator) : Void {
			navigator.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_PARENT);
		}
	}
	
	
	private function setAboutMeScreenStyle(screen:AboutMeScreen) : Void {
		screen.snapTo(IceControl.SNAP_TO_PARENT, IceControl.SNAP_TO_PARENT);
		screen.planeStyleFactory = setPortfolioScreenScrollPlaneStyle;
	}
}