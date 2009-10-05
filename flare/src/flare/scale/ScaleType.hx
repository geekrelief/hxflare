package flare.scale;

	/**
	 * Constants defining known scale types, such as linear, log, and
	 * date/time scales.
	 */
	class ScaleType
	{
		/** Constant indicating an unknown scale. */
		inline public static var UNKNOWN:String = "unknown";
		/** Constant indicating a categorical scale. */
		inline public static var CATEGORIES:String = "categories";
		/** Constant indicating an ordinal scale. */
		inline public static var ORDINAL:String = "ordinal";
		/** Constant indicating a linear numeric scale. */
		inline public static var LINEAR:String = "linear";
		/** Constant indicating a root-transformed numeric scale. */
		inline public static var ROOT:String = "root";
		/** Constant indicating a log-transformed numeric scale. */
		inline public static var LOG:String = "log";
		/** Constant indicating a quantile scale. */
		inline public static var QUANTILE:String = "quantile";
		/** Constant indicating a date/time scale. */
		inline public static var TIME:String = "time";
		
		/**
		 * Constructor, throws an error if called, as this is an abstract class.
		 */
		public function new() {
			throw new Error("This is an abstract class.");
		}
		
		/**
		 * Tests if a given scale type indicates an ordinal scale 
		 * @param type the scale type
		 * @return true if the type indicates an ordinal scale, false otherwise
		 */
		public static function isOrdinal(type:String):Bool
		{
			return type==ORDINAL || type==CATEGORIES;
		}
		
		/**
		 * Tests if a given scale type indicates a quantitative scale 
		 * @param type the scale type
		 * @return true if the type indicates a quantitative scale,
		 *  false otherwise
		 */
		public static function isQuantitative(type:String):Bool
		{
			return type==LINEAR || type==ROOT || type==LOG;
		}
		
	} // end of class ScaleType
