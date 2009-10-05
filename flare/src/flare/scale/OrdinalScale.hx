package flare.scale;

	import flash.utils.Dictionary;
	import flare.util.Arrays;
	
	/**
	 * Scale for ordered sequential data. This supports both numeric and
	 * non-numeric data, and simply places each element in sequence using
	 * the ordering found in the input data array.
	 */
	class OrdinalScale extends Scale
	{
		public var length(getLength, null) : Int
		;
		public var max(getMax, null) : Dynamic ;
		public var min(getMin, null) : Dynamic ;
		public var ordinals(getOrdinals, setOrdinals) : Array<Dynamic>;
		public var scaleType(getScaleType, null) : String ;
		private var _ordinals:Array<Dynamic>;
		private var _lookup:Dictionary;

		/**
		 * Creates a new OrdinalScale.
		 * @param ordinals an ordered array of data values to include in the
		 *  scale
		 * @param flush the flush flag for scale padding
		 * @param copy flag indicating if a copy of the input data array should
		 *  be made. True by default.
		 * @param labelFormat the formatting pattern for value labels
		 */
		public function new(?ordinals:Array<Dynamic>=null, ?flush:Bool=false,
			?copy:Bool=true, ?labelFormat:String=null)
        {
        	_ordinals = (ordinals==null ? new Array() :
        				 copy ? Arrays.copy(ordinals) : ordinals);
            buildLookup();
            _flush = flush;
            _format = labelFormat;
        }
        
        /** @inheritDoc */
		public override function getScaleType():String {
			return ScaleType.ORDINAL;
		}
        
        /** @inheritDoc */
        public override function clone() : Scale
        {
        	return new OrdinalScale(_ordinals, _flush, true, _format);
        }
        
		// -- Properties ------------------------------------------------------

		/** The number of distinct values in this scale. */
		public function getLength():Int
		{
			return _ordinals.length;
		}

		/** The ordered data array defining this scale. */
		public function getOrdinals():Array<Dynamic>
		{
			return _ordinals;
		}
		public function setOrdinals(val:Array<Dynamic>):Array<Dynamic>
		{
			_ordinals = val; buildLookup();
			return val;
		}

		/**
		 * Builds a lookup table for mapping values to their indices.
		 */
		public function buildLookup():Void
        {
        	_lookup = new Dictionary();
            for (var i:UInt = 0; i < _ordinals.length; ++i)
                _lookup[ordinals[i]] = i;
        }
		
		/** @inheritDoc */
		public override function getMin():Dynamic { return _ordinals[0]; }
		
		/** @inheritDoc */
		public override function getMax():Dynamic { return _ordinals[_ordinals.length-1]; }
		
		// -- Scale Methods ---------------------------------------------------
		
		/**
		 * Returns the index of the input value in the ordinal array
		 * @param value the value to lookup
		 * @return the index of the input value. If the value is not contained
		 *  in the ordinal array, this method returns -1.
		 */
		public function index(value:Dynamic):Int
		{
			var idx:Dynamic = _lookup[value];
			return (idx==undefined ? -1 : int(idx));
		}
		
		/** @inheritDoc */
		public override function interpolate(value:Dynamic):Number
		{
			if (_ordinals==null || _ordinals.length==0) return 0.5;
			
			if (_flush) {
				return Number(_lookup[value]) / (_ordinals.length-1);
			} else {
				return (0.5 + _lookup[value]) / _ordinals.length;
			}
		}
		
		/** @inheritDoc */
		public override function lookup(f:Number):Dynamic
		{
			if (_flush) {
				return _ordinals[int(Math.round(f*(_ordinals.length-1)))];
			} else {
				f = Math.max(0, Math.min(1, f*_ordinals.length - 0.5));
				return _ordinals[int(Math.round(f))];
			}
		}
		
		/** @inheritDoc */
		public override function values(?num:Int=-1):Array<Dynamic>
		{
			var a:Array<Dynamic> = new Array();
			var stride:Int = num<0 ? 1 
				: Math.max(1, Math.floor(_ordinals.length / num));
			var i:UInt = 0;
			while (i < _ordinals.length) {
				a.push(_ordinals[i]);
				i += stride;
			}
			return a;
		}

	} // end of class OrdinalScale
