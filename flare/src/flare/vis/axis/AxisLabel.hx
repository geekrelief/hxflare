package flare.vis.axis;

	import flare.display.TextSprite;
	
	/**
	 * Axis label in an axis display.
	 */
	class AxisLabel extends TextSprite
	{
		public var ordinal(getOrdinal, setOrdinal) : Int;
		public var value(getValue, setValue) : Dynamic;
		private var _ordinal:Int;
		private var _value:Dynamic;

		/** The ordinal index of this axis label in the list of labels. */
		public function getOrdinal():Int { return _ordinal; }
		public function setOrdinal(ord:Int):Int { _ordinal = ord; 	return ord;}
		
		/** The data value represented by this axis label. */
		public function getValue():Dynamic { return _value; }
		public function setValue(value:Dynamic):Dynamic { _value = value; 	return value;}
		
	} // end of class AxisLabel
