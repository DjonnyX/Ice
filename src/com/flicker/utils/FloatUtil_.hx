package com.flicker.utils;

/**
 * ...
 * @author test
 */
class FloatUtil 
{
	public static function sign(x:Float):Float {
		return x > 0 ? 1 : x < 0 ? -1 : Math.NaN;
	}
}