package flare.query;

	/**
	 * Aggregate operator for computing variance or standard deviation.
	 */
	class Variance extends AggregateExpression
	{
		/** Flag indicating the population variance or deviation. */
		inline public static var POPULATION:Int = 0;
		/** Flag indicating the sample variance or deviation. */
		inline public static var SAMPLE:Int     = 2;
		/** Flag indicating the variance should be computed. */
		inline public static var VARIANCE:Int   = 0;
		/** Flag indicating the standard deviation should be computed. */
		inline public static var DEVIATION:Int  = 1;
		
		private var _type:Int;
		private var _sum:Number;
		private var _accum:Number;
		private var _count:Number;
		
		/**
		 * Creates a new Variance operator. By default, the population variance
		 * is computed. Use the type flags to change this. For example, the type
		 * argument <code>Variance.SAMPLE | Variance.DEVIATION</code> results in
		 * the sample standard deviation being computed.
		 * @param input the sub-expression of which to compute variance
		 * @param type the type of variance or deviation to compute
		 */
		public function new(input:Dynamic, ?type:Int=0) {
			super(input);
			_type = type;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function reset():Void
		{
			_sum = 0;
			_accum = 0;
			_count = 0;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function eval(?o:Dynamic=null):Dynamic
		{
			var n:Int = _count - (_type & SAMPLE ? 1 : 0);
			var v:Int = _sum / n;
			v = v*v + _accum / n;
			return (_type & DEVIATION ? Math.sqrt(v) : v);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function aggregate(value:Dynamic):Void
		{
			var x:Int = Number(_expr.eval(value));
			if (!isNaN(x)) {
				_sum += x;
				_accum += x*x;
				_count += 1;
			}
		}
		
	} // end of class Variance
