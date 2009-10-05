package flare.query;

	/**
	 * Aggregate operator for computing the sum of a set of values.
	 */
	class Sum extends AggregateExpression
	{
		private var _sum:Number;
		
		/**
		 * Creates a new Sum operator.
		 * @param input the sub-expression of which to compute the sum
		 */
		public function new(input:Dynamic) {
			super(input);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function reset():Void
		{
			_sum = 0;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function eval(?o:Dynamic=null):Dynamic
		{
			return _sum;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function aggregate(value:Dynamic):Void
		{
			var x:Int = Number(_expr.eval(value));
			if (!isNaN(x)) {
				_sum += x;
			}
		}
		
	} // end of class Sum
