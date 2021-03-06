package com.flicker.data;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class ElementData 
{
	public var name:String = 'div';
	public var interactive:Bool = true;
	public var disableInput:Bool = false;
	public var style:Dynamic = null;
	public var classes:Array<String> = null;
	public var id:String = null;
	public var isSvg:Bool = false;
	
	public function new(data:Dynamic) 
	{
		fromData(data);
	}
	
	public function fromData(data:Dynamic) : Void
	{
		for (n in Reflect.fields(data)) {
			if (Reflect.hasField(this, n)) {
				Reflect.setProperty(this, n, Reflect.getProperty(data, n));
			}
		}
	}
	
	public function setStyle(data:Dynamic) : Void
	{
		if (style == null)
			style = {};
		for (n in Reflect.fields(data)) {
			Reflect.setProperty(style, n, Reflect.getProperty(data, n));
		}
	}
	
	public function addClass(args:Array<String>) : Void {
		if (classes == null)
			classes = [];
		if (args.length == 1 && Std.is(args[0], Array)) {
			var a:Array<Dynamic> = cast args[0];
			for (className in a) {
				var c:String = cast className;
				if (classes.indexOf(c) < 0) {
					classes.push(c);
				}
			}
		} else {
			for (className in args) {
				var c:String = cast className;
				if (classes.indexOf(c) < 0) {
					classes.push(c);
				}
			}
		}
	}
}