package ru.ice.controls;

import ru.ice.controls.super.BaseIceObject;
import ru.ice.controls.super.InteractiveObject;
import ru.ice.data.ElementData;
import ru.ice.events.Event;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Screen extends BaseIceObject
{
	public var id(default, null):String;
	public var index(default, null):Int;
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'screen'});
		super(elementData);
		autosize = BaseIceObject.AUTO_SIZE_STAGE;
		addEventListener(Event.TRANSITION_IN_START, transitionInStart);
		addEventListener(Event.TRANSITION_IN_COMPLETE, transitionInComplete);
		addEventListener(Event.TRANSITION_OUT_START, transitionOutStart);
		addEventListener(Event.TRANSITION_OUT_COMPLETE, transitionOutComplete);
	}
	
	private function transitionInStart() : Void {}
	
	private function transitionInComplete() : Void {}
	
	private function transitionOutStart() : Void {}
	
	private function transitionOutComplete() : Void {}
	
	public function setId(id:String) : Void
	{
		this.id = id;
	}
	
	public function setIndex(index:Int) : Void
	{
		this.index = index;
	}
	
	public override function resize(data:Dynamic = null) : Void
	{
		super.resize(data);
	}
	
	public override function dispose() : Void
	{
		super.dispose();
	}
}
