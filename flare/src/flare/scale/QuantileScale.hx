package flare.scale;

	import flare.util.Maths;
	import flare.util.Strings;
	
	/**
	 * Scale that organizes data into discrete bins by quantiles.
	 * For example, the quantile scale can be used to create a discrete size
	 * encoding by statistically dividing the data into bins. Quantiles are
	 * computed using the <code>flare.util.Maths.quantile</code> method.
	 * 
	 * @see flare.util.Maths#quantile
	 */
	class QuantileScale extends Scale
	{
		public var flush(getFlush, setFlush) : Bool;
		public var max(getMax, null) : Dynamic ;
		public var min(getMin, null) : Dynamic ;
		public var scaleType(getScaleType, null) : String ;
		private var _quantiles:Array<Dynamic>;
		
		/** @inheritDoc */
		public override function getFlush():Bool { return true; }
		public override function setFlush(val:Bool):Bool { /* nothing */ 	return val; /* nothing */}
		
		/** @inheritDoc */
		public override function getMin():Dynamic { return _quantiles[0]; }
		
		/** @inheritDoc */
		public override function getMax():Dynamic { return _quantiles[_quantiles.length-1]; }
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new QuantileScale.
		 * @param n the number of quantiles desired
		 * @param values the data values to organized into quantiles
		 * @param sorted flag indicating if the input values array is
		 *  already pre-sorted
		 * @param labelFormat the formatting pattern for value labels
		 */
		public function new(n:Int, values:Array<Dynamic>,
			?sorted:Bool=false, ?labelFormat:String=Strings.DEFAULT_NUMBER)
		{
			_quantiles = (n<0 ? values : Maths.quantile(n, values, !sorted));
			this.labelFormat = labelFormat;
		}
		
		/** @inheritDoc */
		public override function getScaleType():String {
			return ScaleType.QUANTILE;
		}
		
		/** @inheritDoc */
		public override function clone():Scale
		{
			return new QuantileScale(-1, _quantiles, false, _format);
		}
		
		/** @inheritDoc */
		public override function interpolate(value:Dynamic):Number
		{
			return Maths.invQuantileInterp(Number(value), _quantiles);
		}
		
		/** @inheritDoc */
		public override function lookup(f:Number):Dynamic
		{
			return Maths.quantileInterp(f, _quantiles);
		}
		
		/** @inheritDoc */
		public override function values(?num:Int=-1):/*Number*/Array<Dynamic>
		{
			var a:Array<Dynamic> = new Array();
			var stride:Int = num<0 ? 1 : 
				int(Math.max(1, Math.floor(_quantiles.length/num)));
			var i:UInt=0;
			while (i<_quantiles.length) {
				a.push(_quantiles[i]);
				i += stride;
			}
			return a;
		}
		
	} // end of class QuantileScale
