package ru.ice.theme;

/*import js.Browser;
import js.html.CSSRule;
import js.html.CSSRuleList;*/
import js.html.Element;
/*import js.html.HTMLCollection;
import js.html.StyleSheet;
import js.html.StyleSheetList;
import js.html.CSS;*/

import ru.ice.controls.Button;
import ru.ice.controls.super.BaseStatesControl;
import ru.ice.controls.super.IBaseStatesControl;

import haxe.Constraints.Function;

import ru.ice.theme.ThemeStyleProvider;
/**
 * ...
 * @author Evgenii Grebennikov
 */
class BaseTheme 
{
	//private var styles:Map<String, CSSRule>;
	
	public function new() {
		//initializeStyles();
	}
	
	public function setStyle<T>(type:T, name:String, func:Function) : Void {
		ThemeStyleProvider.setStyleFactory(type, name, func);
	}
	
	public function getStyle<T>(type:T, name:String) : Function {
		return ThemeStyleProvider.getStyleFactoryFor(type, name);
	}
	
	public function initializeStyles() : Void {
		/*var css:String = '';
		var style:StyleSheetList = Browser.document.styleSheets;
		for (i in 0 ... style.length) {
			var styleSheet:Dynamic = Browser.document.styleSheets.item(i);
			var cssRules:CSSRuleList = styleSheet.cssRules;
			for (j in 0 ... cssRules.length) {
				var cssRule:CSSRule = cssRules.item(j);
				css += cssRule.cssText;
			}
		}*/
	}
	
	private function setDefaultButtonStates(renderer:IBaseStatesControl, useLabel:Bool = false, useIcon:Bool = false) : Void {
		var upState:Function = function(element:Element) : Void {
			element.classList.remove(BaseStatesControl.STATE_DOWN, BaseStatesControl.STATE_DOWN_SELECTED, BaseStatesControl.STATE_HOVER, BaseStatesControl.STATE_HOVER_SELECTED, BaseStatesControl.STATE_SELECT, BaseStatesControl.STATE_DISABLED);
			element.classList.add(BaseStatesControl.STATE_UP);
		}
		var downState:Function = function(element:Element) : Void {
			element.classList.remove(BaseStatesControl.STATE_UP, BaseStatesControl.STATE_DOWN_SELECTED, BaseStatesControl.STATE_HOVER, BaseStatesControl.STATE_HOVER_SELECTED, BaseStatesControl.STATE_SELECT, BaseStatesControl.STATE_DISABLED);
			element.classList.add(BaseStatesControl.STATE_DOWN);
		}
		var downSelectedState:Function = function(element:Element) : Void {
			element.classList.remove(BaseStatesControl.STATE_UP, BaseStatesControl.STATE_DOWN, BaseStatesControl.STATE_HOVER, BaseStatesControl.STATE_HOVER_SELECTED, BaseStatesControl.STATE_SELECT, BaseStatesControl.STATE_DISABLED);
			element.classList.add(BaseStatesControl.STATE_DOWN_SELECTED);
		}
		var hoverState:Function = function(element:Element) : Void {
			element.classList.remove(BaseStatesControl.STATE_UP, BaseStatesControl.STATE_DOWN, BaseStatesControl.STATE_DOWN_SELECTED, BaseStatesControl.STATE_HOVER_SELECTED, BaseStatesControl.STATE_SELECT, BaseStatesControl.STATE_DISABLED);
			element.classList.add(BaseStatesControl.STATE_HOVER);
		}
		var hoverSelectedState:Function = function(element:Element) : Void {
			element.classList.remove(BaseStatesControl.STATE_UP, BaseStatesControl.STATE_DOWN, BaseStatesControl.STATE_DOWN_SELECTED, BaseStatesControl.STATE_HOVER, BaseStatesControl.STATE_SELECT, BaseStatesControl.STATE_DISABLED);
			element.classList.add(BaseStatesControl.STATE_HOVER_SELECTED);
		}
		var selectState:Function = function(element:Element) : Void {
			element.classList.remove(BaseStatesControl.STATE_UP, BaseStatesControl.STATE_DOWN, BaseStatesControl.STATE_DOWN_SELECTED, BaseStatesControl.STATE_HOVER, BaseStatesControl.STATE_HOVER_SELECTED, BaseStatesControl.STATE_DISABLED);
			element.classList.add(BaseStatesControl.STATE_SELECT);
		}
		var disabledState:Function = function(element:Element) : Void {
			element.classList.remove(BaseStatesControl.STATE_UP, BaseStatesControl.STATE_DOWN, BaseStatesControl.STATE_DOWN_SELECTED, BaseStatesControl.STATE_HOVER, BaseStatesControl.STATE_HOVER_SELECTED, BaseStatesControl.STATE_SELECT);
			element.classList.add(BaseStatesControl.STATE_DISABLED);
		}
	
		renderer.upStyleFactory = function(button:Button) : Void {
			if (useLabel) button.labelStyleFactory = upState;
			if (useIcon) button.iconStyleFactory = upState;
			upState(cast button.element);
		}
		renderer.downStyleFactory = function(button:Button) : Void {
			if (useLabel) button.labelStyleFactory = downState;
			if (useIcon) button.iconStyleFactory = downState;
			downState(cast button.element);
		}
		renderer.downSelectStyleFactory = function(button:Button) : Void {
			if (useLabel) button.labelStyleFactory = downSelectedState;
			if (useIcon) button.iconStyleFactory = downSelectedState;
			downSelectedState(cast button.element);
		}
		renderer.hoverStyleFactory = function(button:Button) : Void {
			if (useLabel) button.labelStyleFactory = hoverState;
			if (useIcon) button.iconStyleFactory = hoverState;
			hoverState(cast button.element);
		}
		renderer.hoverSelectStyleFactory = function(button:Button) : Void {
			if (useLabel) button.labelStyleFactory = hoverSelectedState;
			if (useIcon) button.iconStyleFactory = hoverSelectedState;
			hoverSelectedState(cast button.element);
		}
		renderer.selectStyleFactory = function(button:Button) : Void {
			if (useLabel) button.labelStyleFactory = selectState;
			if (useIcon) button.iconStyleFactory = selectState;
			selectState(cast button.element);
		}
		renderer.disabledStyleFactory = function(button:Button) : Void {
			if (useLabel) button.labelStyleFactory = disabledState;
			if (useIcon) button.iconStyleFactory = disabledState;
			disabledState(cast button.element);
		}
	}
}