package com.flicker.controls.super;

import com.flicker.controls.IButton;

/**
 * @author Evgenii Grebennikov
 */
interface IBaseListItemControl extends IButton
{
	public var index(get, set) : Int;
	public var selected(get, set) : Bool;
	public var data(get, set) : Dynamic;
	public function select() : Void;
	public function deselect() : Void;
}