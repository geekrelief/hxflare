package flare.query;

	/**
	 * Aggregate operator for computing the average of a set of values.
	 */
	class Average extends AggregateExpression
	{
		public var _sum:Number;
		public var _count:Number;
		
		/**
		 * Creates a new Average operator
		 * @param input the sub-expression of which to compute the average
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
			_count = 0;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function eval(?o:Dynamic=null):Dynamic
		{
			return _sum / _count;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function aggregate(value:Dynamic):Void
		{
			var x:Int = Number(_expr.eval(value));
			if (!isNaN(x)) {
				_sum += x;
				_count += 1;
			}
		}
		
	} // end of class Average
