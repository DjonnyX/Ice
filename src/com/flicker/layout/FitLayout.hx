package com.flicker.layout;

import com.flicker.layout.BaseLayout;
import com.flicker.math.Rectangle;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class FitLayout extends BaseLayout
{
	private var _snapWidthToStage:Bool = false;
	public var snapWidthToStage(get, set) : Bool;
	private function get_snapWidthToStage() : Bool {
		return _snapWidthToStage;
	}
	private function set_snapWidthToStage(v:Bool) : Bool {
		if (_snapWidthToStage != v) {
			if (_snapWidthToContent && v)
				_snapWidthToContent = false;
			_snapWidthToStage = v;
			if (_owner != null)
				update();
		}
		return _snapWidthToStage;
	}
	
	private var _snapHeightToStage:Bool = false;
	public var snapHeightToStage(get, set) : Bool;
	private function get_snapHeightToStage() : Bool {
		return _snapHeightToStage;
	}
	private function set_snapHeightToStage(v:Bool) : Bool {
		if (_snapHeightToStage != v) {
			if (_snapHeightToContent && v)
				_snapHeightToContent = false;
			_snapHeightToStage = v;
			if (_owner != null)
				update();
		}
		return _snapHeightToStage;
	}
	
	public function snapToStage(?hSnap:Bool, ?vSnap:Bool) : Void {
		if (hSnap != null && vSnap != null && _snapWidthToStage != hSnap && _snapHeightToStage != vSnap) {
			if (hSnap != null && _snapWidthToContent && hSnap)
				_snapWidthToContent = false;
			if (vSnap != null && _snapHeightToContent && vSnap)
				_snapHeightToContent = false;
			_snapWidthToStage = hSnap;
			_snapHeightToStage = vSnap;
			if (_owner != null)
				update();
		} else if (hSnap != null && _snapWidthToStage != hSnap) {
			if (_snapWidthToContent && hSnap)
				_snapWidthToContent = false;
			_snapWidthToStage = hSnap;
			if (_owner != null)
				update();
		} else if (vSnap != null && _snapHeightToStage != vSnap) {
			if (_snapHeightToContent && vSnap)
				_snapHeightToContent = false;
			_snapHeightToStage = vSnap;
			if (_owner != null)
				update();
		}
	}
	
	private var _snapWidthToContent:Bool = false;
	public var snapWidthToContent(get, set) : Bool;
	private function get_snapWidthToContent() : Bool {
		return _snapWidthToContent;
	}
	private function set_snapWidthToContent(v:Bool) : Bool {
		if (_snapWidthToContent != v) {
			if (_snapWidthToStage && v)
				_snapWidthToStage = false;
			_snapWidthToContent = v;
			if (_owner != null)
				update();
		}
		return _snapWidthToContent;
	}
	
	private var _snapHeightToContent:Bool = false;
	public var snapHeightToContent(get, set) : Bool;
	private function get_snapHeightToContent() : Bool {
		return _snapHeightToContent;
	}
	private function set_snapHeightToContent(v:Bool) : Bool {
		if (_snapHeightToContent != v) {
			if (_snapHeightToStage && v)
				_snapHeightToStage = false;
			_snapHeightToContent = v;
			if (_owner != null)
				update();
		}
		return _snapHeightToContent;
	}
	
	public function snapToContent(?hSnap:Bool, ?vSnap:Bool) : Void {
		if (hSnap != null && vSnap != null && _snapWidthToContent != hSnap && _snapHeightToContent != vSnap) {
			if (hSnap != null && _snapWidthToStage && hSnap)
				_snapWidthToStage = false;
			if (vSnap != null && _snapHeightToStage && vSnap)
				_snapHeightToStage = false;
			_snapWidthToContent = hSnap;
			_snapHeightToContent = vSnap;
			if (_owner != null)
				update();
		} else if (hSnap != null && _snapWidthToContent != hSnap) {
			if (_snapWidthToStage && hSnap)
				_snapWidthToStage = false;
			_snapWidthToContent = hSnap;
			if (_owner != null)
				update();
		} else if (vSnap != null && _snapHeightToContent != vSnap) {
			if (_snapHeightToStage && vSnap)
				_snapHeightToStage = false;
			_snapHeightToContent = vSnap;
			if (_owner != null)
				update();
		}
	}
	
	public function new() {
		super();
	}
	
	public override function update(width:Float = 0, height:Float = 0) : Rectangle
	{
		if (_owner == null || !_owner.isInitialized)
			return _bound;
		
		if (_needSort)
			sort();
		
		var w:Float = width > 0 ? width : _owner._width;
		var h:Float = height > 0 ? height : _owner._height;
		
		#if debug
			trace('update layout');
		#end
		
		_bound.setSize(_owner.width, _owner.height);
		
		if (_snapWidthToStage && _snapHeightToStage) {
			_bound.setSize(_owner.parent.width - _paddingLeft - _paddingRight, _owner.parent.height - _paddingTop - _paddingBottom);
		} else if (_snapWidthToStage) {
			_bound.width = _owner.parent.width - _paddingLeft - _paddingRight;
		} else if (_snapHeightToStage) {
			_bound.height = _owner.parent.height - _paddingTop - _paddingBottom;
		}
		
		if (_snapWidthToContent && _snapHeightToContent) {
			var b:Rectangle = _owner.bound;
			_bound.setSize(b.width + _paddingLeft + _paddingRight, b.height + _paddingTop + _paddingBottom);
		} else if (_snapWidthToContent) {
			_bound.width = _owner.totalContentWidth + _paddingLeft + _paddingRight;
		} else if (_snapHeightToContent) {
			_bound.height = _owner.totalContentHeight + _paddingTop + _paddingBottom;
		}
		
		if (_owner._width != _bound.width || _owner._height != _bound.height)
			_owner.setSize(_bound.width, _bound.height);
		
		if (_postLayout != null) {
			_bound = _postLayout.update();
			_owner.setSize(_bound.width, _bound.height);
		}
		return _bound;
	}
}