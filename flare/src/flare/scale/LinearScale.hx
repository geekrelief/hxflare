package flare.scale;

	import flare.util.Maths;
	import flare.util.Strings;
	
	/**
	 * Scale that spaces values linearly along the scale range. This is the
	 * default scale for numeric types.
	 */
	class LinearScale extends QuantitativeScale
	{
		public var scaleType(getScaleType, null) : String ;
		/**
		 * Creates a new LinearScale.
		 * @param min the minimum data value
		 * @param max the maximum data value
		 * @param base the number base to use
		 * @param flush the flush flag for scale padding
		 * @param labelFormat the formatting pattern for value labels
		 */
		public function new(?min:Int=0, ?max:Int=0, ?base:Int=10,
			?flush:Bool=false, ?labelFormat:String=Strings.DEFAULT_NUMBER)
		{
			super(min, max, base, flush, labelFormat);
		}
		
		/** @inheritDoc */
		public override function getScaleType():String {
			return ScaleType.LINEAR;
		}
		
		/** @inheritDoc */
		public override function clone():Scale {
			return new LinearScale(_dmin, _dmax, _base, _flush, _format);
		}
		
		/** @inheritDoc */
		public override function interp(val:Number):Number {
			return Maths.invLinearInterp(val, _smin, _smax);
		}
		
		/** @inheritDoc */
		public override function lookup(f:Number):Dynamic {
			return Maths.linearInterp(f, _smin, _smax);
		}
		
	} // end of class LinearScale
