package flare.util.palette;

	/**
	 * Palette for size values represeneted as scale factors. The SizePalette
	 * class distinguishes between 1D and 2D scale factors, with a square
	 * root being applied to 2D scale factors to ensure that area scales
	 * linearly with the size value.
	 */
	class SizePalette extends Palette
	{
		public var is2D(getIs2D, setIs2D) : Bool;
		public var maximumSize(getMaximumSize, setMaximumSize) : Number;
		public var minimumSize(getMinimumSize, setMinimumSize) : Number;
		private var _minSize:Int ;
		private var _range:Int ;
		private var _is2D:Bool ;
		
		/** The minimum scale factor in this size palette. */
		public function getMinimumSize():Number { return _minSize; }
		public function setMinimumSize(s:Number):Number {
			_range += s - _minSize; _minSize = s;
			return s;
		}
		
		/** the maximum scale factor in this size palette. */
		public function getMaximumSize():Number { return _minSize + _range; }
		public function setMaximumSize(s:Number):Number { _range = s - _minSize; 	return s;}
		
		/** Flag indicating if this size palette is for 2D shapes. */
		public function getIs2D():Bool { return _is2D; }
		public function setIs2D(b:Bool):Bool { _is2D = b; 	return b;}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new SizePalette.
		 * @param minSize the minimum scale factor in the palette
		 * @param maxSize the maximum scale factor in the palette
		 * @param is2D flag indicating if the size values are for a 2D shape,
		 *  true by default
		 */		
		public function new(?minSize:Int=1, ?maxSize:Int=6, ?is2D:Bool=true)
		{
			
			_minSize = 1;
			_range = 6;
			_is2D = true;
			_minSize = minSize;
			_range = maxSize - minSize;
			_is2D = is2D;
		}
		
		/** @inheritDoc */
		public override function getValue(f:Number):Dynamic
		{
			return getSize(f);
		}
		
		/**
		 * Retrieves the size value corresponding to the input interpolation
		 * fraction. If the <code>is2D</code> flag is true, the square root
		 * of the size value is returned.
		 * @param f an interpolation fraction
		 * @return the size value corresponding to the input fraction
		 */
		public function getSize(v:Number):Number
		{
			var s:Number;
			if (_values == null) {
				s = _minSize + v * _range;
			} else {
				s = _values[uint(Math.round(v*(_values.length-1)))];
			}
			return _is2D ? Math.sqrt(s) : s;
		}
		
	} // end of class SizePalette
