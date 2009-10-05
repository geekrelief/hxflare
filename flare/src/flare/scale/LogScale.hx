package flare.scale;

	import flare.util.Maths;
	import flare.util.Strings;
	
	/**
	 * Scale that performs a log transformation of the data. The base of the
	 * logarithm is determined by the <code>base</code> property.
	 */
	class LogScale extends QuantitativeScale
	{
		public var scaleType(getScaleType, null) : String ;
		private var _zero:Bool ;
		
		/**
		 * Creates a new LogScale.
		 * @param min the minimum data value
		 * @param max the maximum data value
		 * @param base the number base to use
		 * @param flush the flush flag for scale padding
		 * @param labelFormat the formatting pattern for value labels
		 */
		public function new(?min:Int=0, ?max:Int=0, ?base:Int=10,
			?flush:Bool=false, ?labelFormat:String=Strings.DEFAULT_NUMBER)
		{
			
			_zero = false;
			super(min, max, base, flush, labelFormat);
		}
		
		/** @inheritDoc */
		public override function getScaleType():String {
			return ScaleType.ROOT;
		}
		
		/** @inheritDoc */
		public override function clone():Scale {
			return new LogScale(_dmin, _dmax, _base, _flush, _format);
		}
		
		/** @inheritDoc */
		public override function interp(val:Number):Number {
			if (_zero) {
				return Maths.invAdjLogInterp(val, _smin, _smax, _base);
			} else {
				return Maths.invLogInterp(val, _smin, _smax, _base);
			}
		}
		
		/** @inheritDoc */
		public override function lookup(f:Number):Dynamic
		{
			if (_zero) {
				return Maths.adjLogInterp(f, _smin, _smax, _base);
			} else {
				return Maths.logInterp(f, _smin, _smax, _base);
			}
		}
		
		/** @inheritDoc */
		public override function updateScale():Void
		{
			_zero = (_dmin < 0 && _dmax > 0);
			if (!_flush) {
				_smin = Maths.logFloor(_dmin, _base);
				_smax = Maths.logCeil(_dmax, _base);
				
				if (_zero) {
					if (Math.abs(_dmin) < _base) _smin = Math.floor(_dmin);
					if (Math.abs(_dmax) < _base) _smax = Math.ceil(_dmax);	
				}
			} else {
				_smin = _dmin;
				_smax = _dmax;
			}	
		}
		
		private function log(x:Number):Number {
			if (_zero) {
				// distorts the scale to accomodate zero
				return Maths.adjLog(x, _base);
			} else {
				// uses a zero-symmetric logarithmic scale
				return Maths.symLog(x, _base);
			}
		}
		
		/** @inheritDoc */
		public override function values(?num:Int=-1):Array<Dynamic>
		{
			var vals:Array<Dynamic> = new Array();
			
			var beg:Int = int(Math.round(log(_smin)));
			var end:Int = int(Math.round(log(_smax)));
			
			if (beg == end && beg > 0 && Math.pow(10, beg) > _smin) {
            	--beg; // decrement to generate more values
   			}
   			
            var i:Int, j:Int, b:Number, v:Int = _zero?-1:1;
            i = beg;
	           while (i <= end)
            {
	           	if (i==0 && v<=0) { vals.push(v); vals.push(0); }
	           	v = _zero && i<0 ? -Math.pow(_base,-i) : Math.pow(_base,i);
	           	b = _zero && i<0 ? Math.pow(_base,-i-1) : v;
	            	
	           	for (j in 1..._base) {
	           		if (v > _smax) return vals;
	           		vals.push(v);
	           	}
            	++i;
	           }
            return vals;
        }
		
	} // end of class LogScale
