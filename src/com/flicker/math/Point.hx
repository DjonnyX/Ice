package com.flicker.math;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Point 
{
	/**
	 * Устанавливает/возвращает координату по оси x
	 */
	public var x(get, set):Float;
	//@:getter(x)
	private function get_x():Float {
		return _x;
	}
	//@:setter(x)
	private function set_x(v:Float):Float {
		if (v != null)
			_x = v;
		return get_x();
	}
	private var _x:Float;
	
	/**
	 * Устанавливает/возвращает координату по оси y
	 */
	public var y(get, set):Float;
	//@:getter(y)
	private function get_y():Float {
		return _y;
	}
	//@:setter(x)
	private function set_y(v:Float):Float {
		if (v != null)
			_y = v;
		return get_y();
	}
	private var _y:Float;
	
	public function new(x:Float = 0, y:Float = 0) 
	{
		move(x, y);
	}
	
	/**
	 * 
	 * @param	x{Float}
	 * @param	y{Float}
	 * @return	{Point}
	 */
	public function move(x:Float, y:Float) : Point
	{
		_x = x;
		_y = y;
		return this;
	}
	
	public function clone() : Point {
		return new Point(_x, _y);
	}

	public function add(point : Point, isClone:Bool = true) : Point {
		if (point == null) {
			#if debug
				trace('Parameter "point" is not defined.');
			#end
			return null;
		}
		if (!isClone) {
			_x += point._x;
			_y += point._y;
			return this;
		}
		return new Point(x + point.x, y + point.y);
	}

	public function deduct(point : Point, isClone:Bool = true) : Point {
		if (point == null) {
			#if debug
				trace('Parameter "point" is not defined.');
			#end
			return null;
		}
		if (!isClone) {
			_x -= point._x;
			_y -= point._y;
			return this;
		}
		return new Point(x - point.x, y - point.y);
	}
	
	public function measureDistance(point:Point, xAxis:Bool = true, yAxis:Bool = true) : Float {
		var a:Float = Math.max(x, point.x) - Math.min(x, point.x);
		var b:Float = Math.max(y, point.y) - Math.min(y, point.y);
		if (xAxis && yAxis)
			return Math.sqrt(Math.pow(a, 2) + Math.pow(b, 2));
		else if (xAxis)
			return a;
		else if (yAxis)
			return b;
		return 0;
	}
	
	public function comparePoint(point:Point) : Bool {
		return _x == point._x && _y == point._y;
	}
	
	public function empty() : Void {
		_x = _y = 0;
	}
}