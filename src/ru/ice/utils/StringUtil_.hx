package ru.ice.utils;
/**
 * ...
 * @author Evgenii Grebennikov
 */
class StringUtil
{
	public static function formatString(format:String, args:Array<Dynamic>):String
	{
		/*for (i in 0...args.length)
		{
			var r:EReg = new EReg("\\{" + i + "\\}", "g");
			format = r.replace(format, Std.string (args[i]));
		}
		*/
		return format;
	}
}