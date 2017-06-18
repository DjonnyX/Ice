package ru.ice.core;

import ru.ice.data.ElementData;
import ru.ice.display.Sprite;
/**
 * ...
 * @author Evgenii Grebennikov
 */
class FpsStats extends Sprite
{
	private static inline var TOTAL_FRAMES:Float = 20;
	private var _frameCount:Float = 0;
	private var _sumFps:Float = 0;
	private var _fps:Float = 0;
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null) {
			elementData = new ElementData({
				'name':'fps'
			});
		} else 
			elementData.name = 'fps';
		super(elementData, true);
	}
	
	public override function update() : Void
	{
		_sumFps += 1 / stage.realPassedTime;
		_frameCount ++;
		if (_frameCount > TOTAL_FRAMES) {
			_fps = _sumFps / _frameCount;
			element.innerHTML = Std.string(Math.round(_fps * 10) / 10);
			_frameCount = _sumFps = 0;
		}
	}
}