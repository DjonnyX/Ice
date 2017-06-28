package ru.ice;

import ru.ice.app.core.AppSerializer;
import ru.ice.core.Ice;
import ru.ice.app.App;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Main 
{
	static function main() 
	{
		var iceUI:Ice = new Ice(new App(), 'stage', null, new AppSerializer());
		//iceUI.useStats = true;
	}
}