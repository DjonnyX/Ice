package ru.ice;

import ru.ice.app.App;
import ru.ice.core.Ice;
/**
 * ...
 * @author Evgenii Grebennikov
 */
class Main 
{
	static function main() 
	{
		var iceUI:Ice = new Ice(new App());
		//iceUI.useStats = true;
	}
}