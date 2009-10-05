package flare.vis.data.render;
	
	/**
	 * Utility class defining arrow types for directed edges.
	 */
	class ArrowType
	{
		/** Indicates that no arrows should be drawn. */
		inline public static var NONE:String = "none";
		/** Indicates that a closed triangular arrow head should be drawn. */
		inline public static var TRIANGLE:String = "triangle";
		/** Indicates that two lines should be used to draw the arrow head. */
		inline public static var LINES:String = "lines";
		
		/**
		 * This constructor will throw an error, as this is an abstract class. 
		 */
		public function new()
		{
			throw new Error("This is an abstract class.");
		}

	} // end of class ArrowType
