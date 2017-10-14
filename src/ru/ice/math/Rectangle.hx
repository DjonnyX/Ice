package ru.ice.math;

import ru.ice.math.Point;
/**
 * ...
 * @author Evgenii Grebennikov
 */
class Rectangle extends Point
{
	private var _width:Float;
	public var width(get, set):Float;
	private function get_width():Float {
		return _width;
	}
	private function set_width(v:Float):Float {
		if (v != null)
			_width = v;
		return get_width();
	}
	
	private var _height:Float;
	public var height(get, set):Float;
	private function get_height():Float {
		return _height;
	}
	private function set_height(v:Float):Float {
		if (v != null)
			_height = v;
		return get_height();
	}
	
	public var position(get, never):Point;
	private function get_position():Point {
		return super.clone();
	}
	
	public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0) 
	{
		super(x, y);
		setSize(width, height);
	}
	
	public function setSize(width:Float, height:Float) : Rectangle
	{
		_width = width;
		_height = height;
		return this;
	}
	
	public function copy(rect:Rectangle) : Rectangle
	{
		setSize(rect._width, rect._height);
		move(rect._x, rect._y);
		return this;
	}
	
	public function compare(rect:Rectangle) : Bool {
		return _x == rect._x && _y == rect._y && _width == rect._width && _height == rect._height;
	}
	
	public override function clone() : Rectangle
	{
		return new Rectangle(_x, _y, _width, _height);
	}
	
	public function empty() : Void
	{
		move(0, 0);
		setSize(0, 0);
	}
}