package flare.vis.data;

	import flare.display.DirtySprite;
	import flare.util.Colors;
	import flare.vis.data.render.IRenderer;
	import flare.vis.data.render.ShapeRenderer;

	/**
	 * Base class for display objects that represent visualized data.
	 * DataSprites support a number of visual properties beyond those provided
	 * by normal sprites. These include properties for colors, shape, size,
	 * setting the position in polar coordinates (<code>angle</code> and
	 * <code>radius</code>), and others.
	 * 
	 * <p>The actual appearance of DataSprite instances are determined using
	 * pluggable renderers that draw graphical content for the sprite. These
	 * renderers can be changed at runtime to dynamically control appearances.
	 * Furthermore, since these are sprites, they can contain arbitrary display
	 * objects as children on the display list, including entire nested
	 * visualizations.</p>
	 * 
	 * <p>DataSprites provides two additional properties worth noting. First,
	 * the <code>data</code> property references an object containing backing
	 * data to be visualized. This data object is typically the data record
	 * (or tuple) this DataSprite visually represents, and its values are often
	 * used to determined visual encodings. Second, the <code>props</code>
	 * objects is a dynamic object provided for attaching arbitrary properties
	 * to a DataSprite instance. For example, some layout algorithms require
	 * additional parameters on a per-item basis and store these values in the
	 * <code>props</code> property.</p>
	 */
	class DataSprite extends DirtySprite
	{
		public var data(getData, setData) : Dynamic;
		public var fillAlpha(getFillAlpha, setFillAlpha) : Number;
		public var fillColor(getFillColor, setFillColor) : UInt;
		public var fillHue(getFillHue, setFillHue) : Number;
		public var fillSaturation(getFillSaturation, setFillSaturation) : Number;
		public var fillValue(getFillValue, setFillValue) : Number;
		public var fixed(getFixed, null) : Bool ;
		public var h(getH, setH) : Number;
		public var lineAlpha(getLineAlpha, setLineAlpha) : Number;
		public var lineColor(getLineColor, setLineColor) : UInt;
		public var lineHue(getLineHue, setLineHue) : Number;
		public var lineSaturation(getLineSaturation, setLineSaturation) : Number;
		public var lineValue(getLineValue, setLineValue) : Number;
		public var lineWidth(getLineWidth, setLineWidth) : Number;
		public var points(getPoints, setPoints) : Array<Dynamic>;
		public var props(getProps, setProps) : Dynamic;
		public var renderer(getRenderer, setRenderer) : IRenderer;
		public var shape(getShape, setShape) : String;
		public var size(getSize, setSize) : Number;
		public var u(getU, setU) : Number;
		public var v(getV, setV) : Number;
		public var w(getW, setW) : Number;
		// -- Properties ------------------------------------------------------
		
		/** The renderer for drawing this DataSprite. */
		public var _renderer:IRenderer ;
		/** Object storing backing data values. */
		public var _data:Dynamic ;
		/** Object for attaching additional properties to this sprite. */
		public var _prop:Dynamic ;
		
		/** Fixed flag to prevent this sprite from being re-positioned. */
		public var _fixed:Int ;
		/** The fill color for this data sprite. This value is specified as an
		 *  unsigned integer representing an ARGB color. Notice that this
		 *  includes the alpha channel in the color value. */
		public var _fillColor:UInt ;
		/** The line color for this data sprite. This value is specified as an
		 *  unsigned integer representing an ARGB color. Notice that this
		 *  includes the alpha channel in the color value. */
		public var _lineColor:UInt ;
		/** The line width for this data sprite. */
		public var _lineWidth:Int ;

		/** Optional array of x,y values for specifying arbitrary shapes. */
		public var _points:Array<Dynamic>;
		/** Code indicating the shape value of this data sprite. */
		public var _shape:String ;
		/** The size value of this data sprite (1 by default). */
		public var _size:Int ;
		
		/** Auxiliary property often used as a width parameter. */
		public var _w:Int ;
		/** Auxiliary property often used as a height parameter. */
		public var _h:Int ;
		/** Auxiliary property often used as a shape parameter. */
		public var _u:Int ;
		/** Auxiliary property often used as a shape parameter. */
		public var _v:Int ;
		
		// -- General Properties -------------------------------
		
		/** The renderer for drawing this DataSprite. */
		public function getRenderer():IRenderer { return _renderer; }
		public function setRenderer(r:IRenderer):IRenderer { _renderer = r; dirty(); 	return r;}
		
		/** Object storing backing data values. */
		public function getData():Dynamic { return _data; }
		public function setData(d:Dynamic):Dynamic { _data = d; 	return d;}
		
		/** Object for attaching additional properties to this sprite. */
		public function getProps():Dynamic { return _prop; }
		public function setProps(p:Dynamic):Dynamic { _prop = p; _prop.self = this; 	return p;}
		
		// -- Interaction Properties ---------------------------
		
		/** Fixed flag to prevent this sprite from being re-positioned. */
		public function getFixed():Bool { return _fixed > 0; }
		/**
		 * Increments the fixed counter. If the fixed counter is greater than
		 * zero, the data sprite should be fixed. A counter is used so that if
		 * different components both adjust the fixed settings, they won't
		 * overwrite each other.
		 * @param num the amount to increment the counter by (default 1)
		 */
		public function fix(?num:UInt=1):Void { _fixed += num; }
		/**
		 * Decrements the fixed counter. If the fixed counter is greater than
		 * zero, the data sprite should be fixed. A counter is used so that if
		 * different components both adjust the fixed settings, they won't
		 * overwrite each other. This method does not allow the fixed counter
		 * to go below zero.
		 * @param num the amount to decrement the counter by (default 1)
		 */
		public function unfix(?num:UInt=1):Void { _fixed = Math.max(0, _fixed-num); }
		 
		// -- Visual Properties --------------------------------

		/** Auxiliary property often used as a shape parameter. */
		public function getU():Number { return _u; }
		public function setU(u:Number):Number { _u = u; dirty(); 	return u;}
		
		/** Auxiliary property often used as a shape parameter. */
		public function getV():Number { return _v; }
		public function setV(v:Number):Number { _v = v; dirty(); 	return v;}
		
		/** Auxiliary property often used as a width parameter. */
		public function getW():Number { return _w; }
		public function setW(v:Number):Number { _w = v; dirty(); 	return v;}
		
		/** Auxiliary property often used as a height parameter. */
		public function getH():Number { return _h; }
		public function setH(v:Number):Number { _h = v; dirty(); 	return v;}
		
		/** The fill color for this data sprite. This value is specified as an
		 *  unsigned integer representing an ARGB color. Notice that this
		 *  includes the alpha channel in the color value. */
		public function getFillColor():UInt { return _fillColor; }
		public function setFillColor(c:UInt):UInt { _fillColor = c; dirty();		return c;}
		/** The alpha channel (a value between 0 and 1) for the fill color. */
		public function getFillAlpha():Number { return Colors.a(_fillColor) / 255; }
		public function setFillAlpha(a:Number):Number {
			_fillColor = Colors.setAlpha(_fillColor, uint(255*a)%256);
			dirty();
			return a;
		}
		/** The hue component of the fill color in HSV color space. */
		public function getFillHue():Number { return Colors.hue(_fillColor); }
		public function setFillHue(h:Number):Number {
			_fillColor = Colors.hsv(h, Colors.saturation(_fillColor),
				Colors.value(_fillColor), Colors.a(_fillColor));
			dirty();
			return h;
		}
		/** The saturation component of the fill color in HSV color space. */
		public function getFillSaturation():Number { return Colors.saturation(_fillColor); }
		public function setFillSaturation(s:Number):Number {
			_fillColor = Colors.hsv(Colors.hue(_fillColor), s,
				Colors.value(_fillColor), Colors.a(_fillColor));
			dirty();
			return s;
		}
		/** The value (brightness) component of the fill color in HSV color space. */
		public function getFillValue():Number { return Colors.value(_fillColor); }
		public function setFillValue(v:Number):Number {
			_fillColor = Colors.hsv(Colors.hue(_fillColor),
				Colors.saturation(_fillColor), v, Colors.a(_fillColor));
			dirty();
			return v;
		}
				
		/** The line color for this data sprite. This value is specified as an
		 *  unsigned integer representing an ARGB color. Notice that this
		 *  includes the alpha channel in the color value. */
		public function getLineColor():UInt { return _lineColor; }
		public function setLineColor(c:UInt):UInt { _lineColor = c; dirty(); 	return c;}
		/** The alpha channel (a value between 0 and 1) for the line color. */
		public function getLineAlpha():Number { return Colors.a(_lineColor) / 255; }
		public function setLineAlpha(a:Number):Number {
			_lineColor = Colors.setAlpha(_lineColor, uint(255*a)%256);
			dirty();
			return a;
		}
		/** The hue component of the line color in HSV color space. */
		public function getLineHue():Number { return Colors.hue(_lineColor); }
		public function setLineHue(h:Number):Number {
			_lineColor = Colors.hsv(h, Colors.saturation(_lineColor),
				Colors.value(_lineColor), Colors.a(_lineColor));
			dirty();
			return h;
		}
		/** The saturation component of the line color in HSV color space. */
		public function getLineSaturation():Number { return Colors.saturation(_lineColor); }
		public function setLineSaturation(s:Number):Number {
			_lineColor = Colors.hsv(Colors.hue(_lineColor), s,
				Colors.value(_lineColor), Colors.a(_lineColor));
			dirty();
			return s;
		}
		/** The value (brightness) component of the line color in HSV color space. */
		public function getLineValue():Number { return Colors.value(_lineColor); }
		public function setLineValue(v:Number):Number {
			_lineColor = Colors.hsv(Colors.hue(_lineColor),
				Colors.saturation(_lineColor), v, Colors.a(_lineColor));
			dirty();
			return v;
		}
		
		/** The line width for this data sprite. */
		public function getLineWidth():Number { return _lineWidth; }
		public function setLineWidth(w:Number):Number { _lineWidth = w; dirty(); 	return w;}

		/** The size value of this data sprite (1 by default). */
		public function getSize():Number { return _size; }
		public function setSize(s:Number):Number { _size = s; dirty(); 	return s;}

		/** Name of the shape value of this data sprite. 
		 *  @see flare.vis.util.Shapes */
		public function getShape():String { return _shape; }
		public function setShape(s:String):String { _shape = s; dirty(); 	return s;}
		
		/** Optional array of x,y values for specifying arbitrary shapes. */
		public function getPoints():Array<Dynamic> { return _points; }
		public function setPoints(p:Array<Dynamic>):Array<Dynamic> { _points = p; dirty(); 	return p;}
		
		// -- Methods ---------------------------------------------------------

		/**
		 * Creates a new DataSprite.
		 */		
		public function new() {
			
			_renderer = ShapeRenderer.instance;
			_data = {};
			_prop = {};
			_fixed = 0;
			_fillColor = 0xffcccccc;
			_lineColor = 0xff000000;
			_lineWidth = 0;
			_shape = "circle";
			_size = 1;
			_w = 0;
			_h = 0;
			_u = 0;
			_v = 0;
			super();
			_prop.self = this;
		}
		
		/** @inheritDoc */
		public override function render() : Void
		{
			if (_renderer != null) {
				_renderer.render(this);
			} else {
				this.graphics.clear();
			}
		}

	} // end of class DataSprite
