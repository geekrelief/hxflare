package flare.scale;

	import flare.util.Maths;
	import flare.util.Strings;
	
	/**
	 * Base class for representing quantitative numerical data scales.
	 */
	class QuantitativeScale extends Scale
	{
		public var base(getBase, setBase) : Number;
		public var dataMax(getDataMax, setDataMax) : Number;
		public var dataMin(getDataMin, setDataMin) : Number;
		public var flush(null, setFlush) : Bool;
		public var max(getMax, setMax) : Dynamic;
		public var min(getMin, setMin) : Dynamic;
		public var scaleMax(getScaleMax, null) : Number
		;
		public var scaleMin(getScaleMin, null) : Number
		;
		/** The minimum data value. */
		public var _dmin:Number;
		/** The maximum data value. */
		public var _dmax:Number;
		/** The minimum value of the scale range. */
		public var _smin:Number;
		/** The maximum value of the scale range. */
		public var _smax:Number;
		/** The number base of the scale. */
		public var _base:Number;

		/**
		 * Creates a new QuantitativeScale.
		 * @param min the minimum data value
		 * @param max the maximum data value
		 * @param base the number base to use
		 * @param flush the flush flag for scale padding
		 * @param labelFormat the formatting pattern for value labels
		 */
		public function new(?min:Int=0, ?max:Int=0, ?base:Int=10,
			?flush:Bool=false, ?labelFormat:String=Strings.DEFAULT_NUMBER)
		{
			this.base = base;
			this.dataMin = min;
			this.dataMax = max;
			this.flush = flush;
			this.labelFormat = labelFormat;
		}

		/** @inheritDoc */
		public override function clone() : Scale
		{
			throw new Error("This is an abstract class");
		}

		// -- Properties ------------------------------------------------------
		
		/** @inheritDoc */
		public override function setFlush(val:Bool):Bool
		{
			_flush = val; updateScale();
			return val;
		}
		
		/** @inheritDoc */
		public override function getMin():Dynamic { return dataMin; }
		public override function setMin(o:Dynamic):Dynamic { dataMin = Number(o); 	return o;}
		
		/** @inheritDoc */
		public override function getMax():Dynamic { return dataMax; }
		public override function setMax(o:Dynamic):Dynamic { dataMax = Number(o); 	return o;}
		
		/** The minimum data value. This property is the same as the
		 *  <code>minimum</code> property, but properly typed. */
		public function getDataMin():Number
		{
			return _dmin;
		}
		public function setDataMin(val:Number):Number
		{
			_dmin = val; updateScale();
			return val;
		}

		/** The maximum data value. This property is the same as the
		 *  <code>maximum</code> property, but properly typed. */
		public function getDataMax():Number
		{
			return _dmax;
		}
		public function setDataMax(val:Number):Number
		{
			_dmax = val; updateScale();
			return val;
		}
		
		/** The minimum value of the scale range. */
		public function getScaleMin():Number
		{
			return _smin;
		}
		
		/** The maximum value of the scale range. */
		public function getScaleMax():Number
		{
			return _smax;
		}
		
		/** The number base used by the scale.
		 *  By default, base 10 numbers are assumed. */
		public function getBase():Number
		{
			return _base;
		}
		public function setBase(val:Number):Number
		{
			_base = val;
			return val;
		}
		
		// -- Scale Methods ---------------------------------------------------

		/**
		 * Updates the scale range after a change to the data range.
		 */
		public function updateScale():Void
		{
			if (!_flush) {
                var step:Int = getStep(_dmin, _dmax);
                _smin = Math.floor(_dmin / step) * step;
                _smax = Math.ceil(_dmax / step) * step;
            } else {
                _smin = _dmin;
                _smax = _dmax;
            }
		}

		/**
		 * Returns the default step value between label values. The step is
		 * computed according to the current number base.
		 * @param min the minimum scale value
		 * @param max the maximum scale value
		 * @return the default step value between label values
		 */
		public function getStep(min:Number, max:Number):Number
		{
			var range:Int = max - min;
			var exp:Int = Math.round(Maths.log(range, _base)) - 1;
			return Math.pow(base, exp);
		}
		
		/** @inheritDoc */
		public override function lookup(f:Number):Dynamic
		{
			return null;
		}
		
		/** @inheritDoc */
		public override function interpolate(value:Dynamic):Number
		{
			return interp(Number(value));
		}

		/**
		 * Returns the interpolation fraction for the given input number.
		 * @param val the input number
		 * @return the interpolation fraction for the input value
		 */
		public function interp(val:Number):Number
		{
			return -1;
		}
		
		/** @inheritDoc */
		public override function values(?num:Int=-1):/*Number*/Array<Dynamic>
		{
			var a:Array<Dynamic> = new Array();
			var range:Int = _smax - _smin;

			if (range == 0) {
				a.push(_smin);
			} else {
				var step:Int = getStep(_smin, _smax);
				var stride:Int = num<0 ? 1 : Math.max(1, Math.floor(range/(step*num)));
				var x:Int = _smin;
				while (x <= _smax) {
					a.push(x);
					x += stride*step;
				}
			}
			return a;
		}

	} // end of class QuantitativeScale
