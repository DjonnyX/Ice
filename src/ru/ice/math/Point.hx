package ru.ice.math;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Point 
{
	private var _x:Float;
	public var x(get, set):Float;
	private function get_x():Float {
		return _x;
	}
	private function set_x(v:Float):Float {
		if (v != null)
			_x = v;
		return get_x();
	}
	
	private var _y:Float;
	public var y(get, set):Float;
	private function get_y():Float {
		return _y;
	}
	private function set_y(v:Float):Float {
		if (v != null)
			_y = v;
		return get_y();
	}
	
	public function new(x:Float = 0, y:Float = 0) 
	{
		move(x, y);
	}
	
	public function move(x:Float, y:Float) : Point
	{
		this.x = Math.isNaN(x) ? 0 : x;
		this.y = Math.isNaN(y) ? 0 : y;
		return this;
	}
	
	public function clone() : Point {
		return new Point(x, y);
	}

	public function add(point : Point, isClone:Bool = true) : Point {
		if (point == null) {
			#if debug
				trace('Parameter "point" is not defined.');
			#end
			return null;
		}
		if (!isClone) {
			x += point.x;
			y += point.y;
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
			x -= point.x;
			y -= point.y;
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
	
	public function compare(point:Point) : Bool {
		return x == point.x && y == point.y;
	}
	
	public function empty() : Void
	{
		move(0, 0);
	}
}