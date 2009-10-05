package flare.vis.legend;

	import flare.display.RectSprite;
	import flare.display.TextSprite;
	import flare.scale.IScaleMap;
	import flare.scale.Scale;
	import flare.util.Colors;
	import flare.util.Orientation;
	import flare.util.Stats;
	import flare.util.palette.ColorPalette;
	
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;

	/**
	 * A range in a continuous legend, consisting of a continuous
	 * visual scale and value labels. Legend ranges use a
	 * <code>ColorPalette</code> instance for creating a gradient of
	 * color values. If the <code>stats</code> property
	 * is set with the <code>Stats</code> object for a backing data
	 * variable, a histogram of values will also be drawn in the legend
	 * range. To draw only a histogram, set the <code>palette</code>
	 * property to null.
	 */
	class LegendRange extends RectSprite implements IScaleMap
	{
		public var borderColor(getBorderColor, setBorderColor) : UInt;
		public var bounds(getBounds, null) : Rectangle ;
		public var dataField(getDataField, null) : String ;
		public var histogramColor(getHistogramColor, setHistogramColor) : UInt;
		public var labelTextFormat(getLabelTextFormat, setLabelTextFormat) : TextFormat;
		public var labelTextMode(getLabelTextMode, setLabelTextMode) : Int;
		public var labels(getLabels, null) : Sprite ;
		public var margin(getMargin, setMargin) : Number;
		public var orientation(getOrientation, setOrientation) : String;
		public var rangeSize(getRangeSize, setRangeSize) : Number;
		public var stats(getStats, setStats) : Stats;
		public var x1(getX1, null) : Number ;
		public var x2(getX2, null) : Number ;
		public var y1(getY1, null) : Number ;
		public var y2(getY2, null) : Number ;
		private var _dataField:String;
		private var _scale:Scale;
		private var _stats:Stats;
		private var _palette:ColorPalette;
		private var _matrix:Matrix ;
		private var _margin:Int ;
		
		private var _labels:Sprite;
		private var _fmt:TextFormat;
		private var _labelMode:Int ;
		
		private var _range:Shape;
		private var _rs:Int ;
		private var _borderColor:UInt ;
		private var _histogramColor:UInt ;
		
		private var _orient:String;
		private var _vert:Bool;
		private var _rev:Bool;
		
		/** The data field described by this legend range. */
		public function getDataField():String { return _dataField; }
		
		/** Sprite containing the range's labels. */
		public function getLabels():Sprite { return _labels; }
		
		/** Stats object describing the data range. */
		public function getStats():Stats { return _stats; }
		public function setStats(s:Stats):Stats { _stats = s; dirty(); 	return s;}
		
		/** Text format (font, size, style) of legend range labels. */
		public function getLabelTextFormat():TextFormat { return _fmt; }
		public function setLabelTextFormat(fmt:TextFormat):TextFormat {
			_fmt = fmt; dirty();
			return fmt;
		}
		
		/** TextFormat (font, size, style) of legend range labels. */
		public function getLabelTextMode():Int { return _labelMode; }
		public function setLabelTextMode(mode:Int):Int {
			_labelMode = mode; dirty();
			return mode;
		}
		
		/** Margin value for padding within the legend item. */
		public function getMargin():Number { return _margin; }
		public function setMargin(m:Number):Number {
			_margin = m; dirty();
			return m;
		}
		
		/** The size of the range, this is either the width or height of
		 *  the range, depending on the current orientation. */
		public function getRangeSize():Number { return _rs; }
		public function setRangeSize(s:Number):Number { _rs = s; 	return s;}
		
		/** The color of the legend range border. */
		public function getBorderColor():UInt { return _borderColor; }
		public function setBorderColor(c:UInt):UInt {
			if (c != _borderColor) { _borderColor = c; dirty(); }
			return c;
		}
		
		/** The color of bars in a generated histogram. */
		public function getHistogramColor():UInt { return _histogramColor; }
		public function setHistogramColor(c:UInt):UInt {
			if (c == _histogramColor) return;
			_histogramColor = c;
			if (_stats) dirty();
			return c;
		}
		
		/** The desired orientation of this legend range. */
		public function getOrientation():String { return _orient; }
		public function setOrientation(o:String):String {
			_orient = o;
			_vert = Orientation.isVertical(o);
			_rev = o==Orientation.RIGHT_TO_LEFT || o==Orientation.BOTTOM_TO_TOP;
			dirty();
			return o;
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new LegendRange.
		 * @param dataField the data field described by this range
		 * @param palette the color palette for the data field
		 * @param scale the Scale instance mapping the data field to a visual
		 *  variable
		 */
		public function new(dataField:String, scale:Scale,
			?palette:ColorPalette=null,
			?orientation:String=Orientation.LEFT_TO_RIGHT)
		{
			
			_matrix = new Matrix();
			_margin = 5;
			_labelMode = TextSprite.BITMAP;
			_rs = 20;
			_borderColor = 0xcccccc;
			_histogramColor = 0x888888;
			_dataField = dataField;
			_palette = palette;
			_scale = scale;
			this.orientation = orientation;
			addChild(_range = new Shape());
			addChild(_labels = new Sprite());
			_range.cacheAsBitmap = true;
		}
		
		// --------------------------------------------------------------------
		// Lookup
		
		/** @inheritDoc */
		public function getX1():Number {
			return _vert || !_rev ? _margin : _w-_margin;
		}
		/** @inheritDoc */
		public function getX2():Number {
			return _vert ? _margin+_rs : (_rev ? _margin : _w-_margin);
		}
		/** @inheritDoc */
		public function getY1():Number {
			return _vert && !_rev ? _h-_margin : _margin;
		}
		/** @inheritDoc */
		public function getY2():Number {
			return _vert ? (_rev ? _h-_margin : _margin) : _margin+_rs;
		}
		
		private var _bounds:Rectangle ;
				
		/**
		 * Bounds for the visual range portion of this legend range.
		 * @return the bounds of the range display
		 */
		public function getBounds():Rectangle {
			_bounds.x = x1;
			_bounds.y = y1;
			_bounds.width = x2 - x1;
			_bounds.height = y2 - y1;
			return _bounds;
		}
		
		/** @inheritDoc */
		public function value(x:Number, y:Number, ?stayInBounds:Bool=true):Dynamic
        {
        	var f:Number;
        	if (_vert) {
        		f = (y-_margin) / (_h - 2*_margin);
        	} else {
        	 	f = (x-_margin) / (_w - 2*_margin);
        	}
        	// correct bounds
        	if (stayInBounds) {
        		if (f < 0) f = 0;
        		if (f > 1) f = 1;
        	}
        	if (_rev) f = 1-f;
        	// lookup and return value
        	return _scale.lookup(f);
        }
        
        /** @inheritDoc */
        public function X(val:Dynamic):Number
        {
        	return x1 + (_vert ? 0 : _scale.interpolate(val) * (x2 - x1));
        }
        
        /** @inheritDoc */
        public function Y(val:Dynamic):Number
        {
        	return y1 + (_vert ? _scale.interpolate(val) * (y2-y1) : y1);
        }
		
		// --------------------------------------------------------------------
		// Layout and Render
		
		/**
		 * Update the labels shown by this legend range.
		 */
		public function updateLabels():Void
		{
			var pts:Array<Dynamic> = _palette==null ? [0,1] : _palette.keyframes;
			var n:UInt = pts.length;
			
			// filter for the needed number of labels
			var i:UInt=_labels.numChildren;
			while (i<n) {
				_labels.addChild(new TextSprite());
				++i;
			}
			i=_labels.numChildren;
			while (--i>=n) {
				_labels.removeChildAt(i);
				;
			}
			// update and layout the labels
			for (i in 0...n) {
				var ts:TextSprite = TextSprite(_labels.getChildAt(i));
				var val:Dynamic = _scale.lookup(pts[i]);
				// set format
				if (_fmt != null) ts.applyFormat(_fmt);
				ts.textMode = _labelMode;
				// set text
				ts.text = _scale.label(val);
				// set text label alignment
				var j:UInt = _vert==_rev ? i : n-i-1;
				ts.horizontalAnchor = _vert || j==0 ? TextSprite.LEFT :
					j==n-1 ? TextSprite.RIGHT : TextSprite.CENTER;
				ts.verticalAnchor = !_vert || j==0 ? TextSprite.TOP :
					j==n-1 ? TextSprite.BOTTOM : TextSprite.MIDDLE;
				// set position
				ts.x = _vert ? x2 : X(val);
				ts.y = _vert ? Y(val) : y2;
				var offset:Int = ts.height / 5;
				if (_vert) {
					ts.x += offset;
					ts.y += j==0 ? -offset/2 : (j==n-1 ? offset : 0);
				} else if (j==n-1) {
					ts.x += offset/2;
				}
				ts.render();
			}
			// TODO adjust visibility based on overlap?
		}
		
		/** @inheritDoc */
		public override function render():Void
		{
			updateLabels();
			
			var w:Int = _vert ? _rs : _w - 2*_margin;
			var h:Int = _vert ? _h - 2*_margin : _rs;
			_range.x = _margin;
			_range.y = _margin;
			_h = _vert ? _h : 2*margin + h + _labels.height;
			
			_range.graphics.clear();
			
			if (_palette != null)
				drawPalette(w, h);
			if (_stats != null)
				drawHistogram(w, h);
			
			_range.graphics.lineStyle(0, _borderColor);
			_range.graphics.drawRect(0, 0, w, h);
		}
		
		/**
		 * Draws a histogram of data values in the range dispay.
		 * @param w the width of the range display
		 * @param h the height of the range display
		 */
		public function drawHistogram(w:Number, h:Number):Void
		{
			var values:Array<Dynamic> = _stats.values;
			var ib:Int = int(_vert ? h/2 : w/2);
			var pb:Int = (_vert ? h : w) / ib;
			var d:Int = _vert ? w : h;
			var i:Int, f:Number;
			
			var counts:Array<Dynamic> = new Array(ib);
			for (i=0; i<counts.length; ++i) counts[i] = 0;
			
			for (i in 0...values.length) {
				f = _scale.interpolate(values[i]);
				var idx:Int = int(Math.round(f*(ib-1)));
				counts[idx]++;
			}
			
			var max:Int = 0;
			for (i in 0...counts.length) {
				if (counts[i] > max) max = counts[i];
			}
			max = d / (1.1*max);
			
			var g:Graphics = _range.graphics;
			g.beginFill(_histogramColor, _palette ? 0.5 : 1);
			for (i in 0...ib) {
				var j:Int = _vert==_rev ? i : ib-i-1;
				if (_vert)
					g.drawRect(w, h*i/ib, -max*counts[j], pb);
				else
					g.drawRect(w*i/ib, h, pb, -max*counts[j]);
			}
			g.endFill();
		}
		
		/**
		 * Draws a continuous color range in the range display.
		 * @param w the width of the range display
		 * @param h the height of the range display
		 */
		public function drawPalette(w:Number, h:Number):Void
		{
			// build gradient paint parameters
			var N:Int = _palette.keyframes.length;
			var colors:Array<Dynamic> = new Array(N);
			var alphas:Array<Dynamic> = new Array(N);
			var ratios:Array<Dynamic> = new Array(N);
			for (i in 0...N) {
				var c:UInt = _palette.getColor(_palette.keyframes[i]);
				colors[i] = 0x00ffffff & c;
				alphas[i] = Colors.a(c) / 255;
				ratios[i] = int(255 * _palette.keyframes[i]);
			}
			var rot:Int = _vert ? (_rev ? 1 : -1) * Math.PI/2
								   : (_rev ? Math.PI : 0);
			_matrix.createGradientBox(w, h, rot);
			
			// paint the color palette
			var g:Graphics = _range.graphics;
			g.beginGradientFill(GradientType.LINEAR,
				colors, alphas, ratios, _matrix);
			g.drawRect(0, 0, w, h);
			g.endFill();
		}
		
	} // end of class LegendRange