package com.flicker.motion.super;

import com.flicker.controls.ScreenNavigator;
import com.flicker.controls.Screen;
import com.flicker.motion.Slide;
/**
 * ...
 * @author e.grebennikov
 */
class TransitionManager extends BaseTransitionManager
{
	public static inline var COLORFADE : String = 'COLORFADE';
	public static inline var COVER : String = 'COVER';
	public static inline var CUBE : String = 'CUBE';
	public static inline var FADE : String = 'FADE';
	public static inline var FLIP : String = 'FLIP';
	public static inline var REVEAL : String = 'REVEAL';
	public static inline var SLIDE : String = 'SLIDE';
	public static inline var WIPE : String = 'WIPE';
	public static inline var IRIS : String = 'IRIS';
	
	public static inline var EASE_IN : String = 'easeIn';
	public static inline var EASE_IN_BACK : String = 'easeInBack';
	public static inline var EASE_IN_BOUNCE : String = 'easeInBounce';
	public static inline var EASE_IN_ELASTIC : String = 'easeInElastic';
	public static inline var EASE_IN_OUT : String = 'easeInOut';
	public static inline var EASE_IN_OUT_BACK : String = 'easeInOutBack';
	public static inline var EASE_IN_OUT_BOUNCE : String = 'easeInOutBounce';
	public static inline var EASE_IN_OUT_ELASTIC : String = 'easeInOutElastic';
	public static inline var EASE_OUT : String = 'easeOut';
	public static inline var EASE_OUT_BACK : String = 'easeOutBack';
	public static inline var EASE_OUT_BOUNCE : String = 'easeOutBounce';
	public static inline var EASE_OUT_ELASTIC : String = 'easeOutElastic';
	public static inline var EASE_OUT_IN : String = 'easeOutIn';
	public static inline var EASE_OUT_IN_BACK : String = 'easeOutInBack';
	public static inline var EASE_OUT_IN_BOUNCE : String = 'easeOutInBounce';
	public static inline var EASE_OUT_IN_ELASTIC : String = 'easeOutInElastic';
	public static inline var LINEAR : String = 'linear';
	
	public static inline var UP : String = 'UP';
	public static inline var DOWN : String = 'DOWN';
	public static inline var LEFT : String = 'LEFT';
	public static inline var RIGHT : String = 'RIGHT'
	public static inline var IN : String = 'IN';
	public static inline var OUT : String = 'OUT';
	public static inline var CROSSFADE : String = 'CROSSFADE';
	public static inline var BLACKTOBLACK : String = 'BLACKTOBLACK';
	public static inline var TOWHITE : String = 'TOWHITE';
	public static inline var TOCOLOR : String = 'TOCOLOR';
	public static inline var IRIS_OPEN : String = 'IRIS_OPEN';
	
	public static function getInvertMethod(type:String = '', method:String = '') : String
	{
		var invertMethod:String = method;
		var method:String = method.toUpperCase();
		switch (type.toUpperCase())
		{
			case COLORFADE:colorFadeMotionMethod(method);
			case COVER:coverMotionMethod(method);
			case CUBE:cubeMotionMethod(method);
			case FADE:fadeMotionMethod(method);
			case FLIP:flipMotionMethod(method);
			case REVEAL:revealMotionMethod(method);
			case SLIDE:slideMotionMethod(method);
			case WIPE:wipeMotionMethod(method);
			case IRIS:irisMotionMethod(method);
		}
		function slideMotionMethod(method:String) : String
		{
			switch (method)
			{
				case UP:invertMethod = DOWN;
				case DOWN:invertMethod = UP;
				case LEFT:invertMethod = RIGHT;
				case RIGHT:invertMethod = LEFT;
			}
			return invertMethod;
		}
		
		function wipeMotionMethod(method:String) : String
		{
			switch (method)
			{
				case UP:invertMethod = DOWN;
				case DOWN:invertMethod = UP;
				case LEFT:invertMethod = RIGHT;
				case RIGHT:invertMethod = LEFT;
			}
			return invertMethod;
		}
		
		function irisMotionMethod(method:String) : String
		{
			switch (method)
			{
				case IRIS_OPEN:invertMethod = IRIS_OPEN;
			}
			return invertMethod;
		}
		
		function revealMotionMethod(method:String) : String
		{
			switch (method)
			{
				case UP:invertMethod = DOWN;
				case DOWN:invertMethod = UP;
				case LEFT:invertMethod = RIGHT;
				case RIGHT:invertMethod = LEFT;
			}
			return invertMethod;
		}
		
		function flipMotionMethod(method:String) : String
		{
			switch (method)
			{
				case UP:invertMethod = DOWN;
				case DOWN:invertMethod = UP;
				case LEFT:invertMethod = RIGHT;
				case RIGHT:invertMethod = LEFT;
			}
			return invertMethod;
		}
		
		function fadeMotionMethod(method:String) : String
		{
			switch (method)
			{
				case IN:invertMethod = OUT;
				case OUT:invertMethod = IN;
			}
			return invertMethod;
		}
		
		function cubeMotionMethod(method:String) : String
		{
			switch (method)
			{
				case UP:invertMethod = DOWN;
				case DOWN:invertMethod = UP;
				case LEFT:invertMethod = RIGHT;
				case RIGHT:invertMethod = LEFT;
			}
			return invertMethod;
		}
		
		function coverMotionMethod(method:String) : String
		{
			switch (method)
			{
				case UP:invertMethod = DOWN;
				case DOWN:invertMethod = UP;
				case LEFT:invertMethod = RIGHT;
				case RIGHT:invertMethod = LEFT;
			}
			return invertMethod;
		}
		
		function colorFadeMotionMethod(method:String) : String
		{
			return invertMethod;
		}
		return invertMethod;
	}
	
	public static function getTransition(type:String = '', duration:Float = .6, ease:String = 'easeOut', method:String = '', delay:Float = .2, color:UInt = 0x0) : Dynamic
	{
		var motionMethod : Function;
		var __duration:Number = _duration;
		var __color:uint = _color;
		var __delay:Number = _delay;
		var __ease : String = _ease;
		var __method : String = 'none';
		var __type : String = 'none';
		switch (_ease.toUpperCase())
		{
			case Transitions.EASE_IN.toUpperCase():
				__ease = Transitions.EASE_IN;
			break;
			case Transitions.EASE_IN_BACK.toUpperCase():
				__ease = Transitions.EASE_IN_BACK;
			break;
			case Transitions.EASE_IN_BOUNCE.toUpperCase():
				__ease = Transitions.EASE_IN_BOUNCE;
			break;
			case Transitions.EASE_IN_ELASTIC.toUpperCase():
				__ease = Transitions.EASE_IN_ELASTIC;
			break;
			case Transitions.EASE_IN_OUT.toUpperCase():
				__ease = Transitions.EASE_IN_OUT;
			break;
			case Transitions.EASE_IN_OUT_BACK.toUpperCase():
				__ease = Transitions.EASE_IN_OUT_BACK;
			break;
			case Transitions.EASE_IN_OUT_BOUNCE.toUpperCase():
				__ease = Transitions.EASE_IN_OUT_BOUNCE;
			break;
			case Transitions.EASE_IN_OUT_ELASTIC.toUpperCase():
				__ease = Transitions.EASE_IN_OUT_ELASTIC;
			break;
			case Transitions.EASE_OUT.toUpperCase():
				__ease = Transitions.EASE_OUT;
			break;
			case Transitions.EASE_OUT_BACK.toUpperCase():
				__ease = Transitions.EASE_OUT_BACK;
			break;
			case Transitions.EASE_OUT_BOUNCE.toUpperCase():
				__ease = Transitions.EASE_OUT_BOUNCE;
			break;
			case Transitions.EASE_OUT_ELASTIC.toUpperCase():
				__ease = Transitions.EASE_OUT_ELASTIC;
			break;
			case Transitions.EASE_OUT_IN.toUpperCase():
				__ease = Transitions.EASE_OUT_IN;
			break;
			case Transitions.EASE_OUT_IN_BACK.toUpperCase():
				__ease = Transitions.EASE_OUT_IN_BACK;
			break;
			case Transitions.EASE_OUT_IN_BOUNCE.toUpperCase():
				__ease = Transitions.EASE_OUT_IN_BOUNCE;
			break;
			case Transitions.EASE_OUT_IN_ELASTIC.toUpperCase():
				__ease = Transitions.EASE_OUT_IN_ELASTIC;
			break;
			case Transitions.LINEAR.toUpperCase():
				__ease = Transitions.LINEAR;
			break;
			default:
				__ease = Transitions.EASE_OUT;
			break;
		}
		__type = _type.toUpperCase();
		__method = _method.toUpperCase();
		switch (__type)
		{
			case COLORFADE:colorFadeMotionMethod(__method);break;
			case COVER:coverMotionMethod(__method);break;
			case CUBE:cubeMotionMethod(__method);break;
			case FADE:fadeMotionMethod(__method);break;
			case FLIP:flipMotionMethod(__method);break;
			case REVEAL:revealMotionMethod(__method);break;
			case SLIDE:slideMotionMethod(__method);break;
			case WIPE:wipeMotionMethod(__method);break;
			case IRIS:irisMotionMethod(__method);break;
			default:motionMethod = null;__type = null;break;
		}
		function slideMotionMethod(_method:String) : void
		{
			switch (_method)
			{
				case UP:motionMethod = Slide.createSlideUpTransition;break;
				case DOWN:motionMethod = Slide.createSlideDownTransition;break;
				case LEFT:motionMethod = Slide.createSlideLeftTransition;break;
				case RIGHT:motionMethod = Slide.createSlideRightTransition;break;
				default:motionMethod = Slide.createSlideUpTransition;break;
			}
		}
		
		function wipeMotionMethod(_method:String) : void
		{
			switch (_method)
			{
				case UP:motionMethod = Wipe.createWipeUpTransition;break;
				case DOWN:motionMethod = Wipe.createWipeDownTransition;break;
				case LEFT:motionMethod = Wipe.createWipeLeftTransition;break;
				case RIGHT:motionMethod = Wipe.createWipeRightTransition;break;
				default:motionMethod = Wipe.createWipeUpTransition;break;
			}
		}
		
		function irisMotionMethod(_method:String) : void
		{
			switch (_method)
			{
				case IRIS_OPEN:motionMethod = Iris.createIrisOpenTransition;break;
				default:motionMethod = Iris.createIrisOpenTransition;break;
			}
		}
		
		function revealMotionMethod(_method:String) : void
		{
			switch (_method)
			{
				case UP:motionMethod = Reveal.createRevealUpTransition;break;
				case DOWN:motionMethod = Reveal.createRevealDownTransition;break;
				case LEFT:motionMethod = Reveal.createRevealLeftTransition;break;
				case RIGHT:motionMethod = Reveal.createRevealRightTransition;break;
				default:motionMethod = Reveal.createRevealUpTransition;break;
			}
		}
		
		function flipMotionMethod(_method:String) : void
		{
			switch (_method)
			{
				case UP:motionMethod = Flip.createFlipUpTransition;break;
				case DOWN:motionMethod = Flip.createFlipDownTransition;break;
				case LEFT:motionMethod = Flip.createFlipLeftTransition;break;
				case RIGHT:motionMethod = Flip.createFlipRightTransition;break;
				default:motionMethod = Flip.createFlipUpTransition;break;
			}
		}
		
		function fadeMotionMethod(_method:String) : void
		{
			switch (_method)
			{
				case IN:motionMethod = Fade.createFadeInTransition;break;
				case OUT:motionMethod = Fade.createFadeOutTransition;break;
				case CROSSFADE:motionMethod = Fade.createCrossfadeTransition;break;
				default:motionMethod = Fade.createFadeInTransition;break;
			}
		}
		
		function cubeMotionMethod(_method:String) : void
		{
			switch (_method)
			{
				case UP:motionMethod = Cube.createCubeUpTransition;break;
				case DOWN:motionMethod = Cube.createCubeDownTransition;break;
				case LEFT:motionMethod = Cube.createCubeLeftTransition;break;
				case RIGHT:motionMethod = Cube.createCubeRightTransition;break;
				default:motionMethod = Cube.createCubeUpTransition;break;
			}
		}
		
		function coverMotionMethod(_method:String) : void
		{
			switch (_method)
			{
				case UP:motionMethod = Cover.createCoverUpTransition;break;
				case DOWN:motionMethod = Cover.createCoverDownTransition;break;
				case LEFT:motionMethod = Cover.createCoverLeftTransition;break;
				case RIGHT:motionMethod = Cover.createCoverRightTransition;break;
				default:motionMethod = Cover.createCoverUpTransition;break;
			}
		}
		
		function colorFadeMotionMethod(_method:String) : void
		{
			switch (_method)
			{
				case BLACKTOBLACK:motionMethod = ColorFade.createBlackFadeToBlackTransition;break;
				case TOWHITE:motionMethod = ColorFade.createWhiteFadeTransition;break;
				case TOCOLOR:motionMethod = ColorFade.createColorFadeTransition;break;
				default:motionMethod = ColorFade.createBlackFadeToBlackTransition;break;
			}
		}
		var transition:Function;
		if (motionMethod !== null) {
			switch (__type) {
				case COLORFADE:
					switch (__method) {
						case TOCOLOR:
							transition = motionMethod(__color, __duration, __ease, {delay: __delay});
							break;
						default:
							transition = motionMethod(__duration, __ease, {delay: __delay});
							break;
					}
				break;
				default:
					transition = motionMethod(__duration, __ease, {delay: __delay});
				break;
			}
		}
		return transition;
	}
}