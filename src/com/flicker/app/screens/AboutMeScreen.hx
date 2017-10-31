package com.flicker.app.screens;

import haxe.Constraints.Function;

import com.flicker.layout.RockRowsLayout;
import com.flicker.controls.super.FlickerControl;
import com.flicker.display.DisplayObject;
import com.flicker.layout.HorizontalLayout;
import com.flicker.layout.VerticalLayout;
import com.flicker.animation.Transitions;
import com.flicker.controls.ScrollPlane;
import com.flicker.controls.ScrollPlane;
import com.flicker.data.ElementData;
import com.flicker.controls.Screen;
import com.flicker.controls.Button;
import com.flicker.controls.Image;
import com.flicker.events.Event;
import com.flicker.core.Flicker;
import com.flicker.app.theme.AppTheme;
import com.flicker.controls.ScrollBar;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class AboutMeScreen extends Screen
{
	public static inline var DEFAULT_STYLE:String = 'default-about-me-screen-style';
	
	private var _planeStyleFactory:Function;
	public var planeStyleFactory(get, set) : Function;
	private function set_planeStyleFactory(v:Function) : Function {
		if (_planeStyleFactory != v) {
			_planeStyleFactory = v;
			if (_plane != null)
				_plane.styleFactory = v;
		}
		return get_planeStyleFactory();
	}
	private function get_planeStyleFactory() : Function {
		return _planeStyleFactory;
	}
	
	private var _plane:ScrollPlane;
	
	public var data:Dynamic;
	
	public function new() 
	{
		super(new ElementData({'name':'AboutMe'}));
	}
	
	override public function initialize():Void 
	{
		_plane = new ScrollPlane();
		_plane.styleFactory = _planeStyleFactory;
		addChild(_plane);
		
		if (data != null && data.topContent != null) {
			var items:Array<FlickerControl> = Flicker.serializer.serialize(cast data.topContent);
			for (item in items) {
				_plane.addDelayedItemFactory(function() : DisplayObject {
					return _plane.addItem(item);
				});
			}
		}
		
		/*var container:IceControl = new IceControl();
		var containerLayout:RockRowsLayout = new RockRowsLayout();
		containerLayout.defaultVerticalRatio = 0.826;
		containerLayout.columnsCountFactory = function(width:Float, height:Float) : Int {
			if (width < 900)
				return 1;
			return 2;
		}
		container.layout = containerLayout;
		var txtAboutMe:IceControl = new IceControl();
		txtAboutMe.innerHTML = '<div class="about-me__container">'
							 + '<h3 class="i-h">ДИЗАЙНЕР/\nfrontend РАЗРАБОТЧИК</h3>'
							 + '</div>';
		var imgMe:Image = new Image();
		imgMe.src = 'assets/me.png';
		container.addChild(txtAboutMe);
		container.addChild(imgMe);
		_plane.addItem(container);*/
		/*var layout:VerticalLayout = new VerticalLayout();
			layout.horizontalAlign = FluidRowsLayout.HORIZONTAL_ALIGN_LEFT;
			layout.verticalAlign = FluidRowsLayout.VERTICAL_ALIGN_MIDDLE;
			plane.layout = layout;*/
		/*var fLayout:FitLayout = new FitLayout();
		fLayout.snapToStage(true, true);
		plane.layout = fLayout;
		addChild(plane);*/
		
	/*	var title:Label = new Label();
		title.styleName = AppTheme.LARGE_TITLE;
		title.text = 'CODER / DESIGNER';
		plane.addItem(title);
		
		var articleHeader:ArticleHeader = new ArticleHeader();
		articleHeader.src = {
			text:'РЕЗЮМЕ'
		};
		plane.addItem(articleHeader);
		
		var article = new Article();
		article.src = {
			caption:'Lorem ipsum dolor sit amet, consectetur adipisicing',
			content:'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim ed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cuLorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim ed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.'
		};
		plane.addItem(article);*/
		/*
		for (i in  0...30) {
			var factory:Function = function() : DisplayObject {
				var content:IceControl = new IceControl();
				content.autosize = IceControl.AUTO_SIZE_CONTENT;
				content.layout = new HorizontalLayout();
				var button:Button = new Button();
				button.styleName = 'animated-button';
				button.label = 'Button_Button_' + i;
				var img:Image = new Image();
				img.src = 'assets/plane.png';
				img.style = {'image-rendering':'pixelated'};
				content.addChild(button);
				content.addChild(img);
				return plane.addItem(content);
			}
			plane.addItemFactory(factory);
		}
		var _horizontalScrollbar:ScrollBar = new ScrollBar(new ElementData({'name':'scrollbar-horizontal'}));
		_horizontalScrollbar.styleName = ScrollBar.DEFAULT_HORIZONTAL_SCROLLBAR_STYLE;
		_horizontalScrollbar.width = 900;
		plane.addItem(_horizontalScrollbar);
		*/
		styleName = DEFAULT_STYLE;
		super.initialize();
	}
	
	/*private override function transitionInStart() : Void {
		plane.delayRender();
	}*/
	
	public override function dispose() : Void {
		data = null;
		_planeStyleFactory = null;
		if (_plane != null) {
			_plane.removeFromParent();
			_plane = null;
		}
		super.dispose();
	}
}