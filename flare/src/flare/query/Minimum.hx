package flare.query;

	/**
	 * Aggregate operator for computing the minimum of a set of values.
	 */
	class Minimum extends AggregateExpression
	{
		private var _value:Dynamic ;
		
		/**
		 * Creates a new Minimum operator
		 * @param input the sub-expression of which to compute the minimum
		 */
		public function new(input:Dynamic) {
			
			_value = null;
			super(input);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function eval(?o:Dynamic=null):Dynamic
		{
			return _value;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function reset():Void
		{
			_value = null;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function aggregate(value:Dynamic):Void
		{
			value = _expr.eval(value);
			if (_value == null || value < _value) {
				_value = value;
			}
		}
		
	} // end of class Minimum
