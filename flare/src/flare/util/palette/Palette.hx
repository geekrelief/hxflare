package flare.util.palette;

	import mx.core.IMXMLObject;
	
	/**
	 * Base class for palettes, such as color and size palettes, that map from
	 * interpolated scale values into visual properties
	 */
	class Palette implements IMXMLObject
	{
		public var size(getSize, null) : Int ;
		public var values(getValues, setValues) : Array<Dynamic>;
		/** Array of palette values. */
		public var _values:Array<Dynamic>;
		
		/** The number of values in the palette. */
		public function getSize():Int { return _values==null ? 0 : _values.length; }
		/** Array of palette values. */
		public function getValues():Array<Dynamic> { return _values; }
		public function setValues(a:Array<Dynamic>):Array<Dynamic> { _values = a; 	return a;}
		
		/**
		 * Retrieves the palette value corresponding to the input interpolation
		 * fraction.
		 * @param f an interpolation fraction
		 * @return the palette value corresponding to the input fraction
		 */
		public function getValue(f:Number):Dynamic
		{
			if (_values==null || _values.length==0)
				return 0;
			return _values[uint(Math.round(f*(_values.length-1)))];
		}
		
		// -- MXML ------------------------------------------------------------
		
		/** @private */
		public function initialized(document:Dynamic, id:String):Void
		{
			// do nothing
		}
		
	} // end of class Palette
