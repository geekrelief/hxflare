package flare.scale;

	import flare.util.Strings;
	
	import mx.core.IMXMLObject;
	
	/**
	 * Base class for all data scale types.
	 */
	class Scale implements IMXMLObject
	{
		public var flush(getFlush, setFlush) : Bool;
		public var labelFormat(getLabelFormat, setLabelFormat) : String;
		public var max(getMax, setMax) : Dynamic;
		public var min(getMin, setMin) : Dynamic;
		public var scaleType(getScaleType, null) : String
		;
		/** Flag indicating if the scale bounds should be flush with the data.
		 *  False by default, thereby allowing some padding space on the end
		 *  of the scale. */
		public var _flush:Bool ;
		/** Formatting pattern for formatting labels for scale values.
		 *  @see flare.util.Strings#format */
		public var _format:String ;

		/**
		 * Flag indicating if the scale bounds should be flush with the data.
		 * If true, the scale should be flush with the data range, such that
		 * the min and max values should sit directly on the extremes of the
		 * scale. If false, the scale should be padded as needed to make the
		 * scale more readable and human-friendly.
		 */
		public function getFlush():Bool { return _flush; }
		public function setFlush(val:Bool):Bool { _flush = val; 	return val;}

		/**
		 * Formatting pattern for formatting labels for scale values.
		 * For details about the various formatting patterns, see the
		 * documentation for the <code>Strings.format</code> method.
		 * @see flare.util.String#format
		 */
		public function getLabelFormat():String
		{
			return _format==null ? null : _format.substring(3,_format.length-1);
		}
		public function setLabelFormat(fmt:String):String
		{
			_format = (fmt==null ? fmt : "{0:"+fmt+"}");
			return fmt;
		}
		
		/** A string indicating the type of scale this is. */
		public function getScaleType():String
		{
			return ScaleType.UNKNOWN;
		}
		
		/** The minimum data value backing this scale. Note that the actual
		 *  minimum scale value may be lower if the scale is not flush. */
		public function getMin():Dynamic
		{
			throw new Error("Unsupported property");
		}
		public function setMin(o:Dynamic):Dynamic
		{
			throw new Error("Unsupported property");
			return o;
		}
		
		/** The maximum data value backing this scale. Note that the actual
		 *  maximum scale value may be higher if the scale is not flush. */
		public function getMax():Dynamic
		{
			throw new Error("Unsupported property");
		}
		public function setMax(o:Dynamic):Dynamic
		{
			throw new Error("Unsupported property");
			return o;
		}
		
		/**
		 * Returns a cloned copy of the scale.
		 * @return a cloned scale.
		 */
		public function clone() : Scale
		{
			return null;
		}
		
		/**
		 * Returns an interpolation fraction indicating the position of the input
		 * value within the scale range.
		 * @param value a data value for which to return an interpolation
		 *  fraction along the data scale
		 * @return the interpolation fraction of the value in the data scale
		 */
		public function interpolate(value:Dynamic) : Number
		{
			return 0;
		}

		/**
		 * Returns a string label representing a value in this scale.
		 * The labelFormat property determines how the value will be formatted.
		 * @param value the data value to get the string label for
		 * @return a string label for the value
		 */
		public function label(value:Dynamic) : String
		{
			if (_format == null) {
				return value==null ? "" : value.toString();
			} else {
				return Strings.format(_format, value);
			}
		}

		/**
		 * Performs a reverse lookup, returning an object value corresponding
		 * to a interpolation fraction along the scale range.
		 * @param f the interpolation fraction
		 * @return the scale value at the interpolation fraction. May return
		 *  null if no value corresponds to the input fraction.
		 */
		public function lookup(f:Number) : Dynamic
		{
			return null;
		}

		/**
		 * Returns a set of label values for this scale.
		 * @param num a desired target number of labels. This parameter is
		 *  handled idiosyncratically by different scale sub-classes.
		 * @return an array of label values for the scale
		 */ 
		public function values(?num:Int=-1) : Array<Dynamic>
		{
			return null;
		}
		
		// -- MXML ------------------------------------------------------------
		
		/** @private */
		public function initialized(document:Dynamic, id:String):Void
		{
			// do nothing
		}
		
	} // end of class Scale
