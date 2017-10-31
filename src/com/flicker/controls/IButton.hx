package com.flicker.controls;

import haxe.Constraints.Function;

import js.html.Element;

import com.flicker.controls.super.IBaseStatesControl;

/**
 * @author Evgenii Grebennikov
 */
interface IButton extends IBaseStatesControl
{
	public var labelStyleFactory(get, set) : Function;
	public var iconStyleFactory(get, set) : Function;
	public var label(get, set) : String;
	public var icon(get, set) : Array<String>;
	public var labelElement(get, never) : Element;
	public var iconElement(get, never) : Element;
}