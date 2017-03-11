package ru.ice.utils;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class ArrayUtil 
{
	public static function setLength<T>(array:Array<T>, length:Int) : Array<T>
	{
		if (array != null) {
			while (array.length > length) {
				var a:T = array.pop();
				a = null;
			}
		}
		return array;
	}
	
	public static function fromArray<T>(array:Array<T>, length:Int) : Array<T>
	{
		var a:Array<T> = [];
		for (i in array) {
			a.push(i);
		}
		return a;
	}
}