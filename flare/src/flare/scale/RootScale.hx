package flare.scale;

	import flare.util.Maths;
	import flare.util.Strings;
	
	/**
	 * Scale that performs a root transformation of the data. This could be a
	 * square root or any arbitrary power.
	 */
	class RootScale extends QuantitativeScale
	{
		public var power(getPower, setPower) : Number;
		public var scaleType(getScaleType, null) : String ;
		private var _pow:Int ;
		
		/** The power of the root transform. A value of 2 indicates a square
		 *  root, 3 a cubic root, etc. */
		public function getPower():Number { return _pow; }
		public function setPower(p:Number):Number { _pow = p; 	return p;}
		
		/**
		 * Creates a new RootScale.
		 * @param min the minimum data value
		 * @param max the maximum data value
		 * @param base the number base to use
		 * @param flush the flush flag for scale padding
		 * @param labelFormat the formatting pattern for value labels
		 */
		public function new(?min:Int=0, ?max:Int=0, ?base:Int=10,
								  ?flush:Bool=false, ?pow:Int=2,
								  ?labelFormat:String=Strings.DEFAULT_NUMBER)
		{
			
			_pow = 2;
			super(min, max, base, flush, labelFormat);
			_pow = pow;
		}
		
		/** @inheritDoc */
		public override function getScaleType():String {
			return ScaleType.ROOT;
		}
		
		/** @inheritDoc */
		public override function clone():Scale {
			return new RootScale(_dmin, _dmax, _base, _flush, _pow, _format);
		}
		
		/** @inheritDoc */
		public override function interp(val:Number):Number {
			if (_pow==2) return Maths.invSqrtInterp(val, _smin, _smax);
			return Maths.invRootInterp(val, _smin, _smax, _pow);
		}
		
		/** @inheritDoc */
		public override function lookup(f:Number):Dynamic {
			if (_pow==2) return Maths.sqrtInterp(f, _smin, _smax);
			return Maths.rootInterp(f, _smin, _smax, _pow);
		}
		
	} // end of class RootScale
