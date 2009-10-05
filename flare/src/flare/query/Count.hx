package flare.query;

	/**
	 * Aggregate operator for counting the number of items in a set of values.
	 */
	class Count extends AggregateExpression
	{
		private var _count:Int;
		
		/**
		 * Creates a new Count operator
		 * @param input the sub-expression of which to count the value
		 */
		public function new(input:Dynamic) {
			super(input);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function reset():Void
		{
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
			if (_expr.eval(value) != null) {
				_count++;
			}
		}
		
	} // end of class Count
