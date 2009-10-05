package flare.util;

	/**
	 * Constants defining layout orientations.
	 */
	class Orientation
	{
		/** Constant indicating a left-to-right layout orientation. */
		inline public static var LEFT_TO_RIGHT:String = "leftToRight";
		/** Constant indicating a right-to-left layout orientation. */
		inline public static var RIGHT_TO_LEFT:String = "rightToLeft";
		/** Constant indicating a top-to-bottom layout orientation. */
		inline public static var TOP_TO_BOTTOM:String = "topToBottom";
		/** Constant indicating a bottom-to-top layout orientation. */
		inline public static var BOTTOM_TO_TOP:String = "bottomToTop";
		
		/**
		 * This is an abstract class and can not be instantiated.
		 */
		public function new() {
			throw new Error("This is an abstract class.");
		}

		/**
		 * Returns true if the input string indicates a vertical orientation.
		 * @param an orientation string
		 * @return true if the input string indicates a vertical orientation
		 */
		public static function isVertical(orient:String):Bool
		{
			return (orient==TOP_TO_BOTTOM || orient==BOTTOM_TO_TOP);
		}
		
		/**
		 * Returns true if the input string indicates a horizontal orientation.
		 * @param an orientation string
		 * @return true if the input string indicates a horizontal orientation
		 */
		public static function isHorizontal(orient:String):Bool
		{
			return (orient==LEFT_TO_RIGHT || orient==RIGHT_TO_LEFT);
		}

	} // end of class Orientation
