package flare.scale;

	import flare.util.Dates;
	import flare.util.Maths;
	
	/**
	 * Scale for timelines represented using <code>Date</code> values. This
	 * scale represents a linear, quantitative time line. The class attempts
	 * to automatically configure date value labels based on the time span
	 * between the earliest and latest date in the scale. The label formatting
	 * pattern can also be manually set using the <code>labelFormat</code>
	 * property.
	 */
	class TimeScale extends Scale
	{
		public var dataMax(getDataMax, setDataMax) : Date;
		public var dataMin(getDataMin, setDataMin) : Date;
		public var flush(null, setFlush) : Bool;
		public var labelFormat(getLabelFormat, setLabelFormat) : String;
		public var max(getMax, setMax) : Dynamic;
		public var min(getMin, setMin) : Dynamic;
		public var scaleMax(getScaleMax, null) : Date
		;
		public var scaleMin(getScaleMin, null) : Date
		;
		public var scaleType(getScaleType, null) : String ;
		private var _dmin:Date ;
		private var _dmax:Date ;
		private var _smin:Date;
		private var _smax:Date;
		private var _autofmt:Bool ;
		
		/**
		 * Creates a new TimeScale.
		 * @param min the minimum (earliest) date value
		 * @param max the maximum (latest) date value
		 * @param flush the flush flag for scale padding
		 * @param labelFormat the formatting pattern for value labels
		 */
		public function new(?min:Date=null, ?max:Date=null,
			?flush:Bool=false, ?labelFormat:String=null)
		{
			
			_dmin = new Date(0);
			_dmax = new Date(0);
			_autofmt = true;
			if (min) this.dataMin = min;
			if (max) this.dataMax = max;
			this.flush = flush;
			this.labelFormat = labelFormat;
		}
		
		/** @inheritDoc */
		public override function getScaleType():String {
			return ScaleType.TIME;
		}
		
		/** @inheritDoc */
		public override function clone():Scale {
			return new TimeScale(_dmin, _dmax, _flush, _format);
		}
		
		// -- Properties ------------------------------------------------------
		
		/** @inheritDoc */
		public override function setFlush(val:Bool):Bool
		{
			_flush = val; updateScale();
			return val;
		}
		
		/** @inheritDoc */
		public override function getLabelFormat():String
		{
			return (_autofmt ? null : super.labelFormat);
		}
		
		public override function setLabelFormat(fmt:String):String
		{
			if (fmt != null) {
				super.labelFormat = fmt;
				_autofmt = false;
			} else {
				_autofmt = true;
				updateScale();
			}
			return fmt;
		}
		
		/** @inheritDoc */
		public override function getMin():Dynamic { return dataMin; }
		public override function setMin(o:Dynamic):Dynamic { dataMin = cast( o, Date); 	return o;}
		
		/** @inheritDoc */
		public override function getMax():Dynamic { return dataMax; }
		public override function setMax(o:Dynamic):Dynamic { dataMax = cast( o, Date); 	return o;}
		
		/** The minimum (earliest) Date value in the underlying data.
		 *  This property is the same as the <code>minimum</code>
		 *  property, but properly typed. */
		public function getDataMin():Date
		{
			return _dmin;
		}
		public function setDataMin(val:Date):Date
		{
			_dmin = val; updateScale();
			return val;
		}

		/** The maximum (latest) Date value in the underlying data.
		 *  This property is the same as the <code>maximum</code>
		 *  property, but properly typed. */
		public function getDataMax():Date
		{
			return _dmax;
		}
		public function setDataMax(val:Date):Date
		{
			_dmax = val; updateScale();
			return val;
		}
		
		/** The minimum (earliest) Date value in the scale. */
		public function getScaleMin():Date
		{
			return _smin;
		}
		
		/** The maximum (latest) Date value in the underlying data. */
		public function getScaleMax():Date
		{
			return _smax;
		}
		
		// -- Scale Methods ---------------------------------------------------
		
		/** @inheritDoc */
		public override function interpolate(value:Dynamic):Number
		{
			var t:Int = Std.is( value, Date) ? (cast( value, Date)).time : Number(value);
			return Maths.invLinearInterp(t, _smin.time, _smax.time);
		}
		
		/** @inheritDoc */
		public override function lookup(f:Number):Dynamic
		{
			var t:Int = Math.round(Maths.linearInterp(f, _smin.time, _smax.time));
			return new Date(t);
		}
		
		/**
		 * Updates the scale range when the data range is changed.
		 */
		public function updateScale():Void
		{
			var span:Int = Dates.timeSpan(_dmin, _dmax);
			if (_flush) {
				_smin = _dmin;
				_smax = _dmax;
			} else {
				_smin = Dates.roundTime(_dmin, span, false);
				_smax = Dates.roundTime(_dmax, span, true);
			}
			if (_autofmt) {
				super.labelFormat = formatString(span);
			}
		}
		
		/**
		 * Determines the format string to be used based on a measure of
		 * the time span covered by this scale.
		 * @param span the time span covered by this scale. Should use the
		 *  format of the <code>flare.util.Dates</code> class.
		 * @return the label formatting pattern
		 */
		public function formatString(span:Int):String
		{
			if (span >= Dates.YEARS) {
				return "yyyy";
			} else if (span == Dates.MONTHS) {
				return "MMM";
			} else if (span == Dates.DAYS) {
				return "d";
			} else if (span == Dates.HOURS) {
				return "h:mmt";
			} else if (span == Dates.MINUTES) {
				return "h:mmt";
			} else if (span == Dates.SECONDS) {
				return "h:mm:ss";
			} else {
				return "s.fff";
			}
		}
		
		/** @inheritDoc */
		public override function values(?num:Int=-1):Array<Dynamic>
		{   
            var a:Array<Dynamic> = new Array();
            var span:Int = Dates.timeSpan(_dmin, _dmax);
            var step:Int = Dates.timeStep(span);
			var max:Int = _smax.time;
            var d:Date = _flush ? Dates.roundTime(scaleMin, span, true) : scaleMin;

            if (span < Dates.MONTHS) {
            	var x:Int = _smin.time;
            	while (x <= max) {
            		a.push(new Date(x));
            		x += step;
            	}
            } else if (span == Dates.MONTHS) {
            	;
            	while (d.time <= max) {
            		a.push(d);
            		d = Dates.addMonths(d,1);
            	}
            } else {
            	var y:Int = int(step);
            	;
            	while (d.time <= max) {
            		a.push(d);
            		d = Dates.addYears(d,y);
            	}
            }
			return a;
		}
		
	} // end of class TimeScale
