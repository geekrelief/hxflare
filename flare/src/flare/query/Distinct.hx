package flare.query;

	/**
	 * Aggregate (group-by) operator for counting the number of distinct
	 * values in a set of values.
	 */
	class Distinct extends AggregateExpression
	{
		private var _map:Dynamic;
		private var _count:Int;
		
		/**
		 * Creates a new Distinct operator
		 * @param input the sub-expression of which to compute the distinct
		 *  values
		 */
		public function new(input:Dynamic) {
			super(input);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function reset():Void
		{
			_map = {};
			_count = 0;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function eval(?o:Dynamic=null):Dynamic
		{
			return _count;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function aggregate(value:Dynamic):Void
		{
			value = _expr.eval(value);
			if (_map[value] == undefined) {
				_count++;
				_map[value] = 1;
			}
		}
		
	} // end of class Distinct
