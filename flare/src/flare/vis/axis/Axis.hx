package flare.vis.axis;

	import flare.animate.Transitioner;
	import flare.display.TextSprite;
	import flare.scale.IScaleMap;
	import flare.scale.LinearScale;
	import flare.scale.Scale;
	import flare.scale.ScaleType;
	import flare.util.Arrays;
	import flare.util.Stats;
	import flare.util.Strings;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;

	/**
	 * A metric data axis consisting of axis labels and gridlines.
	 * 
	 * <p>Axis labels can be configured both in terms of text formatting,
	 * orientation, and position. Use the <code>labelOffsetX</code> or
	 * <code>labelOffsetY</code> property to adjust label positioning. For
	 * example, <code>labelOffsetX = -10;</code> places the anchor point for
	 * the label ten pixels to the left of the data bounds, whereas
	 * <code>labelOffsetX = 10;</code> will place the point 10 pixels to the
	 * right of the data bounds. One could simultaneously adjust the
	 * <code>horizontalAnchor</code> property to align the labels as desired.
	 * </p>
	 * 
	 * <p>Similarly, axis gridlines can also be configured. The
	 * <code>lineCapX1</code>, <code>lineCapX2</code>, <code>lineCapY1</code>,
	 * and <code>lineCapY2</code> properties determine by how much the
	 * grid lines should exceed the data bounds. For example,
	 * <code>lineCapX1 = 5</code> causes the grid line to extend an extra
	 * 5 pixels to the left. Each of these values should be greater than or
	 * equal to zero.</p>
	 */
	class Axis extends Sprite implements IScaleMap
	{
		public var gridLines(getGridLines, null) : Sprite ;
		public var horizontalAnchor(getHorizontalAnchor, setHorizontalAnchor) : Int;
		public var labelAngle(getLabelAngle, setLabelAngle) : Number;
		public var labelColor(getLabelColor, setLabelColor) : UInt;
		public var labelFormat(getLabelFormat, setLabelFormat) : String;
		public var labelTextFormat(getLabelTextFormat, setLabelTextFormat) : TextFormat;
		public var labelTextMode(getLabelTextMode, setLabelTextMode) : Int;
		public var labels(getLabels, null) : Sprite ;
		public var lineColor(getLineColor, setLineColor) : UInt;
		public var lineWidth(getLineWidth, setLineWidth) : Number;
		public var numLabels(getNumLabels, setNumLabels) : Int;
		public var originX(getOriginX, null) : Number ;
		public var originY(getOriginY, null) : Number ;
		public var verticalAnchor(getVerticalAnchor, setVerticalAnchor) : Int;
		public var x1(getX1, setX1) : Number;
		public var x2(getX2, setX2) : Number;
		public var y1(getY1, setY1) : Number;
		public var y2(getY2, setY2) : Number;
		// children indices
		inline private static var LABELS:UInt = 1;
        inline private static var GRIDLINES:UInt = 0;
		
		// axis scale
		private var _prevScale:Scale;
		// axis settings
		private var _xa:Int, _ya:Int;   // start of the axis
		private var _xb:Int, _yb:Int;   // end of the axis
		private var _xaP:Int, _yaP:Int; // previous start of the axis
		private var _xbP:Int, _ybP:Int; // previous end of the axis
		private var _xd:Int, _yd:Int;             // axis directions (1 or -1)
		private var _xlo:Number, _ylo:Number;     // label offsets
		// gridline settings
		private var _lineColor:UInt ;
		private var _lineWidth:Int ;
		// label settings
		private var _numLabels:Int ;
		private var _anchorH:Int ;
		private var _anchorV:Int ;
		private var _labelAngle:Int ;
		private var _labelColor:UInt ;
		private var _labelFormat:String ;
		private var _labelTextMode:Int ;
		private var _labelTextFormat:TextFormat ;
		// temporary variables
		private var _point:Point ;
		
		// -- Properties ------------------------------------------------------
		
		/** Sprite containing the axis labels. */
		public function getLabels():Sprite { return cast( getChildAt(LABELS), Sprite); }
		/** Sprite containing the axis grid lines. */
		public function getGridLines():Sprite { return cast( getChildAt(GRIDLINES), Sprite); }
		
		/** @inheritDoc */
		public function getX1():Number { return _xa; }
		public function setX1(x:Number):Number { _xa = x; 	return x;}
		
		/** @inheritDoc */
		public function getY1():Number { return _ya; }
		public function setY1(y:Number):Number { _ya = y; 	return y;}
		
		/** @inheritDoc */
		public function getX2():Number { return _xb; }
		public function setX2(x:Number):Number { _xb = x; 	return x;}
		
		/** @inheritDoc */
		public function getY2():Number { return _yb; }
		public function setY2(y:Number):Number { _yb = y; 	return y;}

		/** The Scale used to map values to this axis. */
		public var axisScale:Scale;
		
		/** Flag indicating if axis labels should be shown. */
		public var showLabels:Bool ;
		
		/** Flag indicating if labels should be removed in case of overlap. */
		public var fixLabelOverlap:Bool ;
		
		/** Flag indicating if axis grid lines should be shown. */
		public var showLines:Bool ;
		
		/** X length of axis gridlines. */
		public var lineLengthX:Int ;
		
		/** Y length of axis gridlines. */
		public var lineLengthY:Int ;	
			
		/** X offset for axis gridlines at the lower end of the axis. */
		public var lineCapX1:Int ;
		
		/** X offset for axis gridlines at the upper end of the axis. */
		public var lineCapX2:Int ;
		
		/** Y offset for axis gridlines at the lower end of the axis. */
		public var lineCapY1:Int ;
		
		/** Y offset for axis gridlines at the upper end of the axis. */
		public var lineCapY2:Int ;
		
		/** X-dimension offset value for axis labels. If negative or zero, this
		 *  value indicates how much to offset to the left of the data bounds.
		 *  If positive, the offset is made to the right of the data bounds. */
		public var labelOffsetX:Int ;	
			
		/** Y-dimension offset value for axis labels. If negative or zero, this
		 *  value indicates how much to offset above the data bounds.
		 *  If positive, the offset is made beneath the data bounds.*/
		public var labelOffsetY:Int ;
		
		/** The line color of axis grid lines. */
		public function getLineColor():UInt { return _lineColor; }
		public function setLineColor(c:UInt):UInt { _lineColor = c; updateGridLines(); 	return c;}
		
		/** The line width of axis grid lines. */
		public function getLineWidth():Number { return _lineWidth; }
		public function setLineWidth(w:Number):Number { _lineWidth = w; updateGridLines(); 	return w;}
		
		/** The color of axis label text. */
		public function getLabelColor():UInt { return _labelColor; }
		public function setLabelColor(c:UInt):UInt { _labelColor = c; updateLabels(); 	return c;}
		
		/** The angle (orientation) of axis label text. */
		public function getLabelAngle():Number { return _labelAngle; }
		public function setLabelAngle(a:Number):Number { _labelAngle = a; updateLabels(); 	return a;}
		
		/** TextFormat (font, size, style) for axis label text. */
		public function getLabelTextFormat():TextFormat { return _labelTextFormat; }
		public function setLabelTextFormat(f:TextFormat):TextFormat { _labelTextFormat = f; updateLabels(); 	return f;}
		
		/** The text rendering mode to use for label TextSprites.
		 *  @see flare.display.TextSprite. */
		public function getLabelTextMode():Int { return _labelTextMode; }
		public function setLabelTextMode(m:Int):Int { _labelTextMode = m; updateLabels(); 	return m;}
		
		/** String formatting pattern used for axis labels, overwrites any
		 *  formatting pattern used by the <code>axisScale</code>. If null,
		 *  the formatting pattern for the <code>axisScale</code> is used. */
		public function getLabelFormat():String {
			return _labelFormat==null ? null 
					: _labelFormat.substring(3, _labelFormat.length-1);
		}
		public function setLabelFormat(fmt:String):String {
			_labelFormat = "{0:"+fmt+"}"; updateLabels();
			return fmt;
		}
		
		/** The number of labels and gridlines to generate by default. If this
		 *  number is zero or less (default -1), the number of labels will be
		 *  automatically determined from the current scale and size. */
		public function getNumLabels():Int {
			// if set positive, return number
			if (_numLabels > 0) return _numLabels;
			// if ordinal return all labels
			if (ScaleType.isOrdinal(axisScale.scaleType)) return -1;
			// otherwise determine based on axis size (random hack...)
			var lx:Int = _xb-_xa; if (lx<0) lx = -lx;
			var ly:Int = _yb-_ya; if (ly<0) ly = -ly;
			lx = (lx > ly ? lx : ly);
			return lx > 200 ? 10 : lx < 20 ? 1 : int(lx/20);
		}
		public function setNumLabels(n:Int):Int { _numLabels = n; 	return n;}
		
		/** The horizontal anchor point for axis labels.
		 *  @see flare.display.TextSprite. */
		public function getHorizontalAnchor():Int { return _anchorH; }
		public function setHorizontalAnchor(a:Int):Int { _anchorH = a; updateLabels(); 	return a;}
		
		/** The vertical anchor point for axis labels.
		 *  @see flare.display.TextSprite. */
		public function getVerticalAnchor():Int { return _anchorV; }
		public function setVerticalAnchor(a:Int):Int { _anchorV = a; updateLabels(); 	return a;}		
		
		/** The x-coordinate of the axis origin. */
		public function getOriginX():Number {
			return (ScaleType.isQuantitative(axisScale.scaleType) ? X(0) : x1);
		}
		/** The y-coordinate of the axis origin. */
		public function getOriginY():Number {
			return (ScaleType.isQuantitative(axisScale.scaleType) ? Y(0) : y1);
		}
		
		// -- Initialization --------------------------------------------------
		
		/**
		 * Creates a new Axis.
		 * @param axisScale the axis scale to use. If null, a linear scale
		 *  is assumed.
		 */
		public function new(?axisScale:Scale=null)
        {
            
            _xa =0;
            _ya =0;
            _xb =0;
            _yb =0;
            _xaP =0;
            _yaP =0;
            _xbP =0;
            _ybP =0;
            _lineColor = 0xd8d8d8;
            _lineWidth = 0;
            _numLabels = -1;
            _anchorH = TextSprite.LEFT;
            _anchorV = TextSprite.TOP;
            _labelAngle = 0;
            _labelColor = 0;
            _labelFormat = null;
            _labelTextMode = TextSprite.BITMAP;
            _labelTextFormat = new TextFormat("Arial",12,0);
            _point = new Point();
            showLabels = true;
            fixLabelOverlap = true;
            showLines = true;
            lineLengthX = 0;
            lineLengthY = 0;
            lineCapX1 = 0;
            lineCapX2 = 0;
            lineCapY1 = 0;
            lineCapY2 = 0;
            labelOffsetX = 0;
            labelOffsetY = 0;
            this.axisScale = axisScale ? axisScale : new LinearScale();
            _prevScale = this.axisScale;
            initializeChildren();
        }

		/**
		 * Initializes the child container sprites for labels and grid lines.
		 */
        public function initializeChildren():Void
        {
            addChild(new Sprite()); // add gridlines
            addChild(new Sprite()); // add labels
        }
		
		// -- Updates ---------------------------------------------------------
		
		/**
		 * Updates this axis, performing filtering and layout as needed.
		 * @param trans a Transitioner for collecting value updates
		 * @return the input transitioner.
		 */
		public function update(trans:Transitioner):Transitioner
        {
        	var t:Transitioner = (trans!=null ? trans : Transitioner.DEFAULT);
        	
        	// compute directions and offsets
        	_xd  = lineLengthX < 0 ? -1 : 1;
        	_yd  = lineLengthY < 0 ? -1 : 1;
        	_xlo =  _xd*labelOffsetX + (labelOffsetX>0 ? lineLengthX : 0);
        	_ylo = -_yd*labelOffsetY + (labelOffsetY<0 ? lineLengthY : 0);
        	
        	// run updates
            filter(t);
            layout(t);
            updateLabels(); // TODO run through transitioner?
            updateGridLines(); // TODO run through transitioner?
            return trans;
        }
		
		// -- Lookups ---------------------------------------------------------
		
		/**
		 * Returns the horizontal offset along the axis for the input value.
		 * @param value an input data value
		 * @return the horizontal offset along the axis corresponding to the
		 *  input value. This is the x-position minus <code>x1</code>.
		 */
		public function offsetX(value:Dynamic):Number
        {
        	return axisScale.interpolate(value) * (_xb - _xa);
        }
        
        /**
		 * Returns the vertical offset along the axis for the input value.
		 * @param value an input data value
		 * @return the vertical offset along the axis corresponding to the
		 *  input value. This is the y-position minus <code>y1</code>.
		 */
        public function offsetY(value:Dynamic):Number
        {
        	return axisScale.interpolate(value) * (_yb - _ya);
        }

		/** @inheritDoc */
		public function X(value:Dynamic):Number
        {
        	return _xa + offsetX(value);
        }
        
        /** @inheritDoc */
        public function Y(value:Dynamic):Number
        {
        	return _ya + offsetY(value);
        }
        
        /** @inheritDoc */
        public function value(x:Number, y:Number, ?stayInBounds:Bool=true):Dynamic
        {
        	// project the input point onto the axis line
        	// (P-A).(B-A) / |B-A|^2 == fractional projection onto axis line
        	var dx:Int = (_xb-_xa);
        	var dy:Int = (_yb-_ya);
        	var f:Int = ((x-_xa)*dx + (y-_ya)*dy) / (dx*dx + dy*dy);
        	// correct bounds, if desired
        	if (stayInBounds) {
        		if (f < 0) f = 0;
        		if (f > 1) f = 1;
        	}
        	// lookup and return value
        	return axisScale.lookup(f);
        }
		
		/**
		 * Clears the previous axis scale used, if cached.
		 */
		public function clearPreviousScale():Void
		{
			_prevScale = axisScale;
		}
		
		// -- Filter ----------------------------------------------------------
		
		/**
		 * Performs filtering, determining which axis labels and grid lines
		 * should be visible.
		 * @param trans a Transitioner for collecting value updates.
		 */
		public function filter(trans:Transitioner) : Void
		{
			var ordinal:UInt = 0, i:UInt, idx:Int = -1, val:Dynamic;
			var label:AxisLabel = null;
			var gline:AxisGridLine = null;
			var nl:UInt = labels.numChildren;
			var ng:UInt = gridLines.numChildren;
			
			var keepLabels:Array<Dynamic> = new Array(nl);
			var keepLines:Array<Dynamic> = new Array(ng);
			var values:Array<Dynamic> = axisScale.values(numLabels);
			
			if (showLabels) { // process labels
				for (i in 0...values.length) {
					val = values[i];
					if ((idx = findLabel(val, nl)) < 0) {
						label = createLabel(val);
					} else {
						label = cast( labels.getChildAt(idx), AxisLabel);
						keepLabels[idx] = true;
					}
					label.ordinal = ordinal++;
				}
			}
			if (showLines) { // process gridlines
				for (i in 0...values.length) {
					val = values[i];
					if ((idx = findGridLine(val, ng)) < 0) {
						gline = createGridLine(val);
					} else {
						gline = cast( gridLines.getChildAt(idx), AxisGridLine);
						keepLines[idx] = true;
					}
					gline.ordinal = ordinal++;
				}
			}
			markRemovals(trans, keepLabels, labels);
			markRemovals(trans, keepLines, gridLines);
		}
		
		/**
		 * Marks all items slated for removal from this axis.
		 * @param trans a Transitioner for collecting value updates.
		 * @param keep a Boolean array indicating which items to keep
		 * @param con a container Sprite whose contents should be marked
		 *  for removal
		 */
		public function markRemovals(trans:Transitioner, keep:Array<Dynamic>, con:Sprite) : Void
		{
			var i:UInt = keep.length;
			while (--i >= 0) {
				if (!keep[i]) trans.removeChild(con.getChildAt(i));
				;
			}
		}
		
		// -- Layout ----------------------------------------------------------
		
		/**
		 * Performs layout, setting the position of labels and grid lines.
		 * @param trans a Transitioner for collecting value updates.
		 */
		public function layout(trans:Transitioner) : Void
		{
			var i:UInt, label:AxisLabel, gline:AxisGridLine, p:Point;
			var _lab:Sprite = this.labels;
			var _gls:Sprite = this.gridLines;
			var o:Dynamic;
			
			// layout labels
			for (i in 0..._lab.numChildren) {
				label = cast( _lab.getChildAt(i), AxisLabel);
				p = positionLabel(label, axisScale);
				
				o = trans._S_(label);
				o.x = p.x;
				o.y = p.y;
				o.alpha = trans.willRemove(label) ? 0 : 1;
			}
			// fix label overlap
			if (fixLabelOverlap) fixOverlap(trans);
			// layout gridlines
			for (i in 0..._gls.numChildren) {
				gline = cast( _gls.getChildAt(i), AxisGridLine);
				p = positionGridLine(gline, axisScale);
				
				o = trans._S_(gline);
				o.x1 = p.x;
				o.y1 = p.y;
				o.x2 = p.x + lineLengthX + _xd*(lineCapX1+lineCapX2);
				o.y2 = p.y + lineLengthY + _yd*(lineCapY1+lineCapY2);
				o.alpha = trans.willRemove(gline) ? 0 : 1;
			}
			// update previous scale
			_prevScale = axisScale.clone(); // clone scale
			_xaP = _xa; _yaP = _ya; _xbP = _xb; _ybP = _yb;
		}
		
		// -- Label Overlap ---------------------------------------------------
		
		/**
		 * Eliminates overlap between labels along an axis. 
		 * @param trans a transitioner, potentially storing label positions
		 */		
		public function fixOverlap(trans:Transitioner):Void
		{
			var labs:Array<Dynamic> = [], d:DisplayObject, i:Int;
			// collect and sort labels
			for (i in 0...labels.numChildren) {
				var s:AxisLabel = AxisLabel(labels.getChildAt(i));
				if (!trans.willRemove(s)) labs.push(s);
			}
			if (labs.length == 0) return;
			labs.sortOn("ordinal", Array.NUMERIC);
			
			// stores the labels to remove
			var rem:Dictionary = new Dictionary();
			
			if (axisScale.scaleType == ScaleType.LOG) {
				fixLogOverlap(labs, rem, trans, axisScale);
			}
			
			// maintain min and max if we get down to two
			i = labs.length;
			var min:Dynamic = labs[0];
			var max:Dynamic = labs[i-1];
			var mid:Dynamic = (i&1) ? labs[(i>>1)] : null;

			// fix overlap with an iterative optimization
			// remove every other label with each iteration
			while (hasOverlap(labs, trans)) {
				// reduce labels
				i = labs.length;
				if (mid && i>3 && i<8) { // use min, med, max if we can
					for each (d in labs) rem[d] = d;
					if (rem[min]) delete rem[min];
					if (rem[max]) delete rem[max];
					if (rem[mid]) delete rem[mid];
					labs = [min, mid, max];
				}
				else if (i < 4) { // use min and max if we're down to two
					if (rem[min]) delete rem[min];
					if (rem[max]) delete rem[max];
					for each (d in labs) {
						if (d != min && d != max) rem[d] = d;
					}
					break;
				}
				else { // else remove every odd element
					i = i - (i&1 ? 2 : 1);
					;
					while (i>0) {
						rem[labs[i]] = labs[i];
						labs.splice(i, 1); // remove from array
						i-=2;
					}
				}
			}
			
			// remove the deleted labels
			for each (d in rem) {
				trans._S_(d).alpha = 0;
				trans.removeChild(d, true);
			}
		}
		
		private static function fixLogOverlap(labs:Array<Dynamic>, rem:Dictionary,
			trans:Transitioner, scale:Scale):Void
		{
				var base:Int = int(Object(scale).base), i:Int, j:Int, zidx:Int;
				if (!hasOverlap(labs, trans)) return;
				
				// find zero
				zidx = Arrays.binarySearch(labs, 0, "value");
				var neg:Bool = Number(scale.min) < 0;
				var pos:Bool = Number(scale.max) > 0;
				
				// if includes negative, traverse backwards from zero/end
				if (neg) {
					i = (zidx<0 ? labs.length : zidx) - (pos ? 1 : 2);
					j=pos?1:2;
					while (i>=0) {
						if (j == base) {
							j = 1;
						} else {
							rem[labs[i]] = labs[i];
							labs.splice(i, 1); --zidx;
						}
						++j, --i;
					}
				}
				// if includes positive, traverse forwards from zero/start
				if (pos) {
					i = (zidx<0 ? 0 : zidx+1) + (neg ? 0 : 1);
					for (j in 1...labs.length) {
						if (j == base) {
							j = 1; ++i;
						} else {
							rem[labs[i]] = labs[i];
							labs.splice(i, 1);
						}
					}
				}
		}
		
		private static function hasOverlap(labs:Array<Dynamic>, trans:Transitioner):Bool
		{
			var d:DisplayObject = labs[0], e:DisplayObject;
			for (i in 1...labs.length) {
				if (overlaps(trans, d, (e=labs[i]))) return true;
				d = e;
			}
			return false;
		}
		
		/**
		 * Indicates if two display objects overlap, sensitive to any target
		 * values stored in a transitioner.
		 * @param trans a Transitioner, potentially with target values
		 * @param l1 a display object
		 * @param l2 a display object
		 * @return true if the objects overlap (considering values in the
		 *  transitioner, if appropriate), false otherwise
		 */
		private static function overlaps(trans:Transitioner,
			l1:DisplayObject, l2:DisplayObject):Bool
		{
			if (trans.immediate) return l1.hitTestObject(l2);
			// get original co-ordinates
			var xa:Int = l1.x, ya:Int = l1.y;
			var xb:Int = l2.x, yb:Int = l2.y;
			var o:Dynamic;
			// set to target co-ordinates
			o = trans._S_(l1); l1.x = o.x; l1.y = o.y;
			o = trans._S_(l2); l2.x = o.x; l2.y = o.y;
			// compute overlap
			var b:Bool = l1.hitTestObject(l2);
			// reset to original coordinates
			l1.x = xa; l1.y = ya; l2.x = xb; l2.y = yb;
			return b;
		}
		
		// -- Axis Label Helpers ----------------------------------------------
		
		/**
		 * Creates a new axis label.
		 * @param val the value to create the label for
		 * @return an AxisLabel
		 */		
		public function createLabel(val:Dynamic) : AxisLabel
		{
			var label:AxisLabel = new AxisLabel();
			var f:Int = _prevScale.interpolate(val);
			label.alpha = 0;
			label.value = val;
			label.x = _xlo + _xaP + f*(_xbP - _xaP);
			label.y = _ylo + _yaP + f*(_ybP - _yaP);
			updateLabel(label);
			labels.addChild(label);
			return label;
		}
		
		/**
		 * Computes the position of an axis label.
		 * @param label the axis label to layout
		 * @param scale the scale used to map values to the axis
		 * @return a Point with x,y coordinates for the axis label
		 */
		public function positionLabel(label:AxisLabel, scale:Scale) : Point
		{
			var f:Int = scale.interpolate(label.value);
			_point.x = _xlo + _xa + f*(_xb-_xa);
			_point.y = _ylo + _ya + f*(_yb-_ya);
			return _point;
		}
		
		/**
		 * Updates an axis label's settings
		 * @param label the label to update
		 */		
		public function updateLabel(label:AxisLabel) : Void
		{
			label.textFormat = _labelTextFormat;
			label.horizontalAnchor = _anchorH;
			label.verticalAnchor = _anchorV;
			label.rotation = (180/Math.PI) * _labelAngle;
			label.textMode = _labelTextMode;
			label.text = _labelFormat==null ? axisScale.label(label.value)
					   : Strings.format(_labelFormat, label.value);
		}
		
		/**
		 * Updates all axis labels.
		 */		
		public function updateLabels() : Void
		{
			var _labels:Sprite = this.labels;
			for (i in 0..._labels.numChildren) {
				updateLabel(cast( _labels.getChildAt(i), AxisLabel));
			}
		}
		
		/**
		 * Returns the index of a label in the label's container sprite for a
		 * given data value.
		 * @param val the data value to find
		 * @param len the number of labels to check
		 * @return the index of a label with matching value, or -1 if no label
		 *  was found
		 */		
		public function findLabel(val:Dynamic, len:UInt) : Int
		{
			var _labels:Sprite = this.labels;
			for (i in 0...len) {
				// TODO: make this robust to repeated values
				if (Stats.equal((cast( _labels.getChildAt(i), AxisLabel)).value, val)) {
					return i;
				}
			}
			return -1;
		}
		
		// -- Axis GridLine Helpers -------------------------------------------
		
		/**
		 * Creates a new axis grid line.
		 * @param val the value to create the grid lines for
		 * @return an AxisGridLine
		 */	
		public function createGridLine(val:Dynamic) : AxisGridLine
		{
			var gline:AxisGridLine = new AxisGridLine();
			var f:Int = _prevScale.interpolate(val);
			gline.alpha = 0;
			gline.value = val;
			gline.x1 = _xaP + f*(_xbP-_xaP) - _xd*lineCapX1;
			gline.y1 = _yaP + f*(_ybP-_yaP) - _yd*lineCapY1;
			gline.x2 = gline.x1 + lineLengthX + _xd*(lineCapX1 + lineCapX2)
			gline.y2 = gline.y1 + lineLengthY + _yd*(lineCapY1 + lineCapY2);
			updateGridLine(gline);
			gridLines.addChild(gline);
			return gline;
		}
		
		/**
		 * Computes the position of an axis grid line.
		 * @param gline the axis grid line to layout
		 * @param scale the scale used to map values to the axis
		 * @return a Point with x,y coordinates for the axis grid line
		 */
		public function positionGridLine(gline:AxisGridLine, scale:Scale) : Point
		{
			var f:Int = scale.interpolate(gline.value);
			_point.x = _xa + f*(_xb-_xa) - _xd*lineCapX1;
			_point.y = _ya + f*(_yb-_ya) - _yd*lineCapY1;
			return _point;
		}
		
		/**
		 * Updates an axis grid line's settings
		 * @param gline the grid line to update
		 */
		public function updateGridLine(gline:AxisGridLine) : Void
		{
			gline.lineColor = _lineColor;
			gline.lineWidth = _lineWidth;
		}
		
		/**
		 * Updates all grid lines.
		 */
		public function updateGridLines() : Void
		{
			var _glines:Sprite = this.gridLines;
			for (i in 0..._glines.numChildren) {
				updateGridLine(cast( _glines.getChildAt(i), AxisGridLine));
			}
		}
		
		/**
		 * Returns the index of a grid lines in the line's container sprite
		 * for a given data value.
		 * @param val the data value to find
		 * @param len the number of grid lines to check
		 * @return the index of a grid line with matching value, or -1 if no
		 *  grid line was found
		 */	
		public function findGridLine(val:Dynamic, len:UInt) : Int
		{
			var _glines:Sprite = this.gridLines;
			for (i in 0...len) {
				// TODO: make this robust to repeated values
				if (Stats.equal((cast( _glines.getChildAt(i), AxisGridLine)).value, val)) {
					return i;
				}
			}
			return -1;
		}
		
	} // end of class Axis
