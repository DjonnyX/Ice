package ru.ice.layout.params;

import ru.ice.layout.ILayout;

/**
 * @author Evgenii Grebennikov
 */
interface ILayoutParams
{
	public var layout(get, set):ILayout;
	private function update():Void;
	public function dispose():Void;
}