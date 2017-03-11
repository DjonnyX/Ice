package ru.ice.theme;

import js.Browser;
import js.html.CSSRule;
import js.html.CSSRuleList;
import js.html.HTMLCollection;
import js.html.StyleSheet;
import js.html.StyleSheetList;
import js.html.CSS;

import haxe.Constraints.Function;

import ru.ice.theme.ThemeStyleProvider;
/**
 * ...
 * @author Evgenii Grebennikov
 */
class BaseTheme 
{
	private var styles:Map<String, CSSRule>;
	
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
}