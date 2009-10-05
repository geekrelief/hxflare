package flare.vis.operator;

	import flare.animate.Transitioner;
	import flare.util.Arrays;
	import flare.vis.data.Data;
	
	/**
	 * A SortOperator sorts a data group. This can be used to sort
	 * elements prior to running a subsequent operation such as layout.
	 * @see flare.util.Sort
	 */
	class SortOperator extends Operator
	{
		public var criteria(getCriteria, setCriteria) : Dynamic;
		/** The data group to sort. */
		public var group:String;
		
		/** The sorting criteria. Sort criteria are expressed as an
		 *  array of property names to sort on. These properties are accessed
		 *  by sorting functions using the <code>Property</code> class.
		 *  The default is to sort in ascending order. If the field name
		 *  includes a "-" (negative sign) prefix, that variable will instead
		 *  be sorted in descending order. */
		public function getCriteria():Dynamic { return Arrays.copy(_crit); }
		public function setCriteria(crit:Dynamic):Dynamic {
			if (Std.is( crit, String)) {
				_crit = [crit];
			} else if (Std.is( crit, Array)) {
				_crit = Arrays.copy(cast( crit, Array));
			} else {
				throw new ArgumentError("Invalid Sort specification type. " +
					"Input must be either a String or Array");
			}
			return crit;
		}
		private var _crit:Array<Dynamic>;
		
		/**
		 * Creates a new SortOperator.
		 * @param group the data group to sort
		 * @param criteria the sorting criteria. Sort criteria are expressed as
		 *  an array of property names to sort on. These properties are
		 *  accessed by sorting functions using the <code>Property</code>
		 *  class. The default is to sort in ascending order. If the field name
		 *  includes a "-" (negative sign) prefix, that variable will instead
		 *  be sorted in descending order.
		 */
		public function new(?group:String=Data.NODES, criteria:Array<Dynamic>)
		{
			this.group = group;
			this.criteria = criteria;
		}
		
		/** @inheritDoc */
		public override function operate(?t:Transitioner=null):Void
		{
			visualization.data.group(group).sortBy(_crit);
		}
		
	} // end of class SortOperator
