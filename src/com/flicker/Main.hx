package com.flicker;

import com.flicker.app.core.AppSerializer;
import com.flicker.core.Flicker;
import com.flicker.app.App;

/**
 * ...
 * @author Evgenii Grebennikov
 */
class Main 
{
	static function main() 
	{
		var flickerUI:Flicker = new Flicker(new App(), 'ice', null, new AppSerializer());
		//iceUI.useStats = true;
	}
}