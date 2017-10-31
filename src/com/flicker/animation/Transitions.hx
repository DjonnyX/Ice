package com.flicker.animation;
/**
 * ...
 * @author Evgenii Grebennikov
 */
class Transitions
{        
    public static inline var LINEAR:String = "linear";
    public static inline var EASE_IN:String = "easeIn";
    public static inline var EASE_OUT:String = "easeOut";
    public static inline var EASE_IN_OUT:String = "easeInOut";
    public static inline var EASE_OUT_IN:String = "easeOutIn";        
    public static inline var EASE_IN_BACK:String = "easeInBack";
    public static inline var EASE_OUT_BACK:String = "easeOutBack";
    public static inline var EASE_IN_OUT_BACK:String = "easeInOutBack";
    public static inline var EASE_OUT_IN_BACK:String = "easeOutInBack";
    public static inline var EASE_IN_ELASTIC:String = "easeInElastic";
    public static inline var EASE_OUT_ELASTIC:String = "easeOutElastic";
    public static inline var EASE_IN_OUT_ELASTIC:String = "easeInOutElastic";
    public static inline var EASE_OUT_IN_ELASTIC:String = "easeOutInElastic";  
    public static inline var EASE_IN_BOUNCE:String = "easeInBounce";
    public static inline var EASE_OUT_BOUNCE:String = "easeOutBounce";
    public static inline var EASE_IN_OUT_BOUNCE:String = "easeInOutBounce";
    public static inline var EASE_OUT_IN_BOUNCE:String = "easeOutInBounce";
    
    private static var transitions:Map<String, Float->Float>;
    
    public static function getTransition(name:String):Float->Float
    {
        if (transitions == null)
			registerDefaults();
        return transitions[name];
    }
    
    public static function register(name:String, func:Float->Float):Void
    {
        if (transitions == null)
			registerDefaults();
        transitions[name] = func;
    }
    
    private static function registerDefaults():Void
    {
        transitions = new Map<String, Float->Float>();
        
        register(LINEAR, linear);
        register(EASE_IN, easeIn);
        register(EASE_OUT, easeOut);
        register(EASE_IN_OUT, easeInOut);
        register(EASE_OUT_IN, easeOutIn);
        register(EASE_IN_BACK, easeInBack);
        register(EASE_OUT_BACK, easeOutBack);
        register(EASE_IN_OUT_BACK, easeInOutBack);
        register(EASE_OUT_IN_BACK, easeOutInBack);
        register(EASE_IN_ELASTIC, easeInElastic);
        register(EASE_OUT_ELASTIC, easeOutElastic);
        register(EASE_IN_OUT_ELASTIC, easeInOutElastic);
        register(EASE_OUT_IN_ELASTIC, easeOutInElastic);
        register(EASE_IN_BOUNCE, easeInBounce);
        register(EASE_OUT_BOUNCE, easeOutBounce);
        register(EASE_IN_OUT_BOUNCE, easeInOutBounce);
        register(EASE_OUT_IN_BOUNCE, easeOutInBounce);
    }         
    
    private static function linear(ratio:Float):Float
    {
        return ratio;
    }
    
    private static function easeIn(ratio:Float):Float
    {
        return ratio * ratio * ratio;
    }    
    
    private static function easeOut(ratio:Float):Float
    {
        var invRatio:Float = ratio - 1.0;
        return invRatio * invRatio * invRatio + 1;
    }        
    
    private static function easeInOut(ratio:Float):Float
    {
        return easeCombined(easeIn, easeOut, ratio);
    }   
    
    private static function easeOutIn(ratio:Float):Float
    {
        return easeCombined(easeOut, easeIn, ratio);
    }
    
    private static function easeInBack(ratio:Float):Float
    {
        var s:Float = 1.70158;
        return Math.pow(ratio, 2) * ((s + 1.0)*ratio - s);
    }
    
    private static function easeOutBack(ratio:Float):Float
    {
        var invRatio:Float = ratio - 1.0;            
        var s:Float = 1.70158;
        return Math.pow(invRatio, 2) * ((s + 1.0)*invRatio + s) + 1.0;
    }
    
    private static function easeInOutBack(ratio:Float):Float
    {
        return easeCombined(easeInBack, easeOutBack, ratio);
    }   
    
    private static function easeOutInBack(ratio:Float):Float
    {
        return easeCombined(easeOutBack, easeInBack, ratio);
    }        
    
    private static function easeInElastic(ratio:Float):Float
    {
        if (ratio == 0 || ratio == 1) return ratio;
        else
        {
            var p:Float = 0.3;
            var s:Float = p/4.0;
            var invRatio:Float = ratio - 1;
            return -1.0 * Math.pow(2.0, 10.0*invRatio) * Math.sin((invRatio-s)*(2.0*Math.PI)/p);                
        }            
    }
    
    private static function easeOutElastic(ratio:Float):Float
    {
        if (ratio == 0 || ratio == 1) return ratio;
        else
        {
            var p:Float = 0.3;
            var s:Float = p/4.0;                
            return Math.pow(2.0, -10.0*ratio) * Math.sin((ratio-s)*(2.0*Math.PI)/p) + 1;                
        }            
    }
    
    private static function easeInOutElastic(ratio:Float):Float
    {
        return easeCombined(easeInElastic, easeOutElastic, ratio);
    }   
    
    private static function easeOutInElastic(ratio:Float):Float
    {
        return easeCombined(easeOutElastic, easeInElastic, ratio);
    }
    
    private static function easeInBounce(ratio:Float):Float
    {
        return 1.0 - easeOutBounce(1.0 - ratio);
    }
    
    private static function easeOutBounce(ratio:Float):Float
    {
        var s:Float = 7.5625;
        var p:Float = 2.75;
        var l:Float;
        if (ratio < (1.0/p))
        {
            l = s * Math.pow(ratio, 2);
        }
        else
        {
            if (ratio < (2.0/p))
            {
                ratio -= 1.5/p;
                l = s * Math.pow(ratio, 2) + 0.75;
            }
            else
            {
                if (ratio < 2.5/p)
                {
                    ratio -= 2.25/p;
                    l = s * Math.pow(ratio, 2) + 0.9375;
                }
                else
                {
                    ratio -= 2.625/p;
                    l =  s * Math.pow(ratio, 2) + 0.984375;
                }
            }
        }
        return l;
    }
    
    private static function easeInOutBounce(ratio:Float):Float
    {
        return easeCombined(easeInBounce, easeOutBounce, ratio);
    }   
    
    private static function easeOutInBounce(ratio:Float):Float
    {
        return easeCombined(easeOutBounce, easeInBounce, ratio);
    }
    
    public static function easeCombined(startFunc:Float->Float, endFunc:Float->Float, ratio:Float):Float
    {
        if (ratio < 0.5) return 0.5 * startFunc(ratio*2.0);
        else             return 0.5 * endFunc((ratio-0.5)*2.0) + 0.5;
    }
}