package ru.ice.controls;

import ru.ice.controls.super.IceControl;
import ru.ice.controls.super.InteractiveControl;
import ru.ice.data.ElementData;
import ru.ice.events.Event;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Screen extends IceControl
{
	public static inline var DEFAULT_STYLE:String = 'default-screen-style';
	
	public var id(default, null):String;
	public var index(default, null):Int;
	
	public function new(?elementData:ElementData) 
	{
		if (elementData == null)
			elementData = new ElementData({'name':'s'});
		super(elementData);
		addEventListener(Event.TRANSITION_IN_START, transitionInStart);
		addEventListener(Event.TRANSITION_IN_COMPLETE, transitionInComplete);
		addEventListener(Event.TRANSITION_OUT_START, transitionOutStart);
		addEventListener(Event.TRANSITION_OUT_COMPLETE, transitionOutComplete);
		styleName = DEFAULT_STYLE;
	}
	
	private function transitionInStart(e:Event) : Void {
		e.stopImmediatePropagation();
	}
	
	private function transitionInComplete(e:Event) : Void {
		e.stopImmediatePropagation();
	}
	
	private function transitionOutStart(e:Event) : Void {
		e.stopImmediatePropagation();
	}
	
	private function transitionOutComplete(e:Event) : Void {
		e.stopImmediatePropagation();
	}
	
	public function setId(id:String) : Void
	{
		this.id = id;
	}
	
	public function setIndex(index:Int) : Void
	{
		this.index = index;
	}
	
	public override function resize(?data:ResizeData) : Void
	{
		super.resize(data);
	}
	
	public override function dispose() : Void
	{
		removeEventListener(Event.TRANSITION_IN_START, transitionInStart);
		removeEventListener(Event.TRANSITION_IN_COMPLETE, transitionInComplete);
		removeEventListener(Event.TRANSITION_OUT_START, transitionOutStart);
		removeEventListener(Event.TRANSITION_OUT_COMPLETE, transitionOutComplete);
		super.dispose();
	}
}
