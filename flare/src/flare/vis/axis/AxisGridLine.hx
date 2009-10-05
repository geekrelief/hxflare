package flare.vis.axis;

	import flare.display.LineSprite;

	/**
	 * Axis grid line in an axis display.
	 */
	class AxisGridLine extends LineSprite
	{
		public var ordinal(getOrdinal, setOrdinal) : Int;
		public var value(getValue, setValue) : Dynamic;
		private var _ordinal:Int;
		private var _value:Dynamic;

		/** The ordinal index of this grid line in the list of grid lines. */
		public function getOrdinal():Int { return _ordinal; }
		public function setOrdinal(ord:Int):Int { _ordinal = ord; 	return ord;}
		
		/** The data value represented by this axis grid line. */
		public function getValue():Dynamic { return _value; }
		public function setValue(value:Dynamic):Dynamic { _value = value; 	return value;}
		
	} // end of class AxisGridLine
