package flare.util;
	
	/**
	 * Utility methods for working with colors.
	 */
	class Colors
	{
		public var desaturationMatrix(getDesaturationMatrix, null) : Array<Dynamic> ;
		/**
		 * Constructor, throws an error if called, as this is an abstract class.
		 */
		public function new() {
			throw new Error("This is an abstract class.");
		}
				
		/**
		 * Returns the alpha component of a color value
		 * @param c the color value
		 * @return the alpha component
		 */
		public static function a(c:UInt):UInt
		{
			return (c >> 24) & 0xFF;
		}
		
		/**
		 * Returns the red component of a color value
		 * @param c the color value
		 * @return the red component
		 */
		public static function r(c:UInt):UInt
		{
			return (c >> 16) & 0xFF;
		}
		
		/**
		 * Returns the green component of a color value
		 * @param c the color value
		 * @return the green component
		 */
		public static function g(c:UInt):UInt
		{
			return (c >> 8) & 0xFF;
		}
		
		/**
		 * Returns the blue component of a color value
		 * @param c the color value
		 * @return the blue component
		 */
		public static function b(c:UInt):UInt
		{
			return (c & 0xFF);
		}
		
		/**
		 * Returns a grayscale color value with the given brightness
		 * @param v the brightness component (0-255)
		 * @param a the alpha component (0-255, 255 by default)
		 * @return the color value
		 */
		public static function gray(v:UInt, ?a:UInt=255):UInt
		{
			return ((a & 0xFF) << 24) | ((v & 0xFF) << 16) |
				   ((v & 0xFF) <<  8) |  (v & 0xFF);
		}
		
		/**
		 * Returns a color value with the given red, green, blue, and alpha
		 * components
		 * @param r the red component (0-255)
		 * @param g the green component (0-255)
		 * @param b the blue component (0-255)
		 * @param a the alpha component (0-255, 255 by default)
		 * @return the color value
		 * 
		 */
		public static function rgba(r:UInt, g:UInt, b:UInt, ?a:UInt=255):UInt
		{
			return ((a & 0xFF) << 24) | ((r & 0xFF) << 16) |
				   ((g & 0xFF) <<  8) |  (b & 0xFF);
		}
		
		/**
		 * Returns a color value by updating the alpha component of another
		 * color value.
		 * @param c a color value
		 * @param a the desired alpha component (0-255)
		 * @return a color value with adjusted alpha component
		 */
		public static function setAlpha(c:UInt, a:UInt):UInt
		{
			return ((a & 0xFF) << 24) | (c & 0x00FFFFFF);
		}
		
		/**
		 * Returns the RGB color value for a color specified in HSV (hue,
		 * saturation, value) color space.
		 * @param h the hue, a value between 0 and 1
		 * @param s the saturation, a value between 0 and 1
		 * @param v the value (brighntess), a value between 0 and 1
		 * @param a the (optional) alpha value, an integer between 0 and 255
		 *  (255 is the default)
		 * @return the corresponding RGB color value
		 */
		public static function hsv(h:Number, s:Number, v:Number, ?a:UInt=255):UInt
		{
			var r:UInt=0, g:UInt=0, b:UInt=0;
            if (s == 0) {
                r = g = b = uint(v * 255 + .5);
            } else {
            	var i:Float = (h - Math.floor(h)) * 6.0;
                var f:Int = i - Math.floor(i);
                var p:Int = v * (1 - s);
                var q:Int = v * (1 - s * f);
                var t:Int = v * (1 - (s * (1 - f)));
                switch (int(i))
                {
                    case 0:
                        r = uint(v * 255 + .5);
                        g = uint(t * 255 + .5);
                        b = uint(p * 255 + .5);
                        break;
                    case 1:
                        r = uint(q * 255 + .5);
                        g = uint(v * 255 + .5);
                        b = uint(p * 255 + .5);
                        break;
                    case 2:
                        r = uint(p * 255 + .5);
                        g = uint(v * 255 + .5);
                        b = uint(t * 255 + .5);
                        break;
                    case 3:
                        r = uint(p * 255 + .5);
                        g = uint(q * 255 + .5);
                        b = uint(v * 255 + .5);
                        break;
                    case 4:
                        r = uint(t * 255 + .5);
                        g = uint(p * 255 + .5);
                        b = uint(v * 255 + .5);
                        break;
                    case 5:
                        r = uint(v * 255 + .5);
                        g = uint(p * 255 + .5);
                        b = uint(q * 255 + .5);
                        break;
                }
            }
            return rgba(r, g, b, a);
		}
		
		/**
		 * Returns the hue component of an ARGB color. 
		 * @param c the input color
		 * @return the hue component of the color is HSV color space as a
		 *  number between 0 and 1
		 */
		public static function hue(c:UInt):Number
        {
			var r:UInt, g:UInt, b:UInt, cmax:UInt, cmin:UInt;
			var h:Number, range:Number;
			
			r = (c >> 16) & 0xFF;
			g = (c >> 8) & 0xFF;
			b = (c & 0xFF);
			cmax = (r > g) ? r : g; if (b > cmax) cmax = b;
            cmin = (r < g) ? r : g; if (b < cmin) cmin = b;
            range = Number(cmax - cmin);

            if (range == 0) {
                h = 0;
            } else {
            	var rc:Int = Number(cmax - r) / range;
                var gc:Int = Number(cmax - g) / range;
                var bc:Int = Number(cmax - b) / range;
                if (r == cmax)
                    h = bc - gc;
                else if (g == cmax)
                    h = 2.0 + rc - bc;
                else
                    h = 4.0 + gc - rc;
                	h = h / 6.0;
                if (h < 0)
                    h = h + 1.0;
            }
            return h;
        }
        
        /**
		 * Returns the saturation component of an ARGB color. 
		 * @param c the input color
		 * @return the saturation of the color is HSV color space as a
		 *  number between 0 and 1
		 */
        public static function saturation(c:UInt):Number
        {
        	var r:UInt, g:UInt, b:UInt, cmax:UInt, cmin:UInt;
			r = (c >> 16) & 0xFF;
			g = (c >> 8) & 0xFF;
			b = (c & 0xFF);
			cmax = (r > g) ? r : g; if (b > cmax) cmax = b;
			if (cmax==0) return 0;
            cmin = (r < g) ? r : g; if (b < cmin) cmin = b;
            return Number(cmax-cmin) / cmax;
        }
        
        /**
		 * Returns the value (brightness) component of an ARGB color. 
		 * @param c the input color
		 * @return the value component of the color is HSV color space as a
		 *  number between 0 and 1
		 */
        public static function value(c:UInt):Number
        {
        	var r:UInt, g:UInt, b:UInt, cmax:UInt;
			r = (c >> 16) & 0xFF;
			g = (c >> 8) & 0xFF;
			b = (c & 0xFF);
			cmax = (r > g) ? r : g; if (b > cmax) cmax = b;
            return cmax / 255.0;
        }
		
		/**
	     * Interpolate between two color values by the given mixing proportion.
	     * A mixing fraction of 0 will result in c1, a value of 1.0 will result
	     * in c2, and value of 0.5 will result in the color mid-way between the
	     * two in RGB color space.
	     * @param c1 the starting color
	     * @param c2 the target color
	     * @param f a fraction between 0 and 1 controlling the interpolation
	     * @return the interpolated color
	     */
		public static function interpolate(c1:UInt, c2:UInt, f:Number):UInt
		{
			var t:UInt;
			return rgba(
				(t=r(c1)) + f*(r(c2)-t),
				(t=g(c1)) + f*(g(c2)-t),
				(t=b(c1)) + f*(b(c2)-t),
				(t=a(c1)) + f*(a(c2)-t)
			);
		}
    
	    /**
	     * Get a darker shade of an input color.
	     * @param c a color value
	     * @return a darkened color value
	     */
	    public static function darker(c:UInt, ?s:Int=1):UInt
	    {
	    	s = Math.pow(0.7, s);
	        return rgba(Math.max(0, int(s*r(c))),
	                    Math.max(0, int(s*g(c))),
	                    Math.max(0, int(s*b(c))),
	                    a(c));
	    }
	
	    /**
	     * Get a brighter shade of an input color.
	     * @param c a color value
	     * @return a brighter color value
	     */
	    public static function brighter(c:UInt, ?s:Int=1):UInt
	    {
	    	var cr:UInt, cg:UInt, cb:UInt, i:UInt;
	    	s = Math.pow(0.7, s);
	    	
	        cr = r(c), cg = g(c), cb = b(c);
	        i = 30;
	        if (cr == 0 && cg == 0 && cb == 0) {
	           return rgba(i, i, i, a(c));
	        }
	        if ( cr > 0 && cr < i ) cr = i;
	        if ( cg > 0 && cg < i ) cg = i;
	        if ( cb > 0 && cb < i ) cb = i;
	
	        return rgba(Math.min(255, (int)(cr/s)),
	                    Math.min(255, (int)(cg/s)),
	                    Math.min(255, (int)(cb/s)),
	                    a(c));
	    }
	    
	    /**
	     * Get a desaturated shade of an input color.
	     * @param c a color value
	     * @return a desaturated color value
	     */
	    public static function desaturate(c:UInt):UInt
	    {
	        var a:UInt = c & 0xff000000;
	        var cr:Int = Number(r(c));
	        var cg:Int = Number(g(c));
	        var cb:Int = Number(b(c));
	
	        cr *= 0.2125; // red band weight
	        cg *= 0.7154; // green band weight
	        cb *= 0.0721; // blue band weight
	
	        var gray:UInt = uint(Math.min(int(cr+cg+cb),0xff)) & 0xff;
	        return a | (gray << 16) | (gray << 8) | gray;
	    }
	    
	    /**
	     * A color transform matrix that desaturates colors to corresponding
	     * grayscale values. Can be used with the
	     * <code>flash.filters.ColorMatrixFilter</code> class.
	     */
	    public static function getDesaturationMatrix():Array<Dynamic> {
	    	return [0.2125, 0.7154, 0.0721, 0, 0,
	    			0.2125, 0.7154, 0.0721, 0, 0,
	    			0.2125, 0.7154, 0.0721, 0, 0,
	    			     0,      0,      0, 1, 0];
	    }
	    
	} // end of class Colors
