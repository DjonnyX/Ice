package ru.ice.app.controls;

import ru.ice.controls.super.IceControl;

/**
 * ...
 * @author test
 */
class ArticleFluidContainer extends IceControl 
{
	public static inline var DEFAULT_STYLE:String = 'article-fluid-container-style';
	public function new() 
	{
		super();
		styleName = DEFAULT_STYLE;
	}
}