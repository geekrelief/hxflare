package flare.query;
	
	/**
	 * Expression operator that tests if a value is within a given range.
	 * Implemented as an <code>And</code> of <code>Comparison</code>
	 * expressions.
	 */
	class Range extends And
	{
		public var max(getMax, setMax) : Dynamic;
		public var min(getMin, setMin) : Dynamic;
		public var val(getVal, setVal) : Dynamic;
		/** Sub-expression for the minimum value of the range. */
		public function getMin():Dynamic { return _children[0].left; }
		public function setMin(e:Dynamic):Dynamic {
			_children[0].left = Expression.expr(e);
			return e;
		}
		
		/** Sub-expression for the maximum value of the range. */
		public function getMax():Dynamic { return _children[1].right; }
		public function setMax(e:Dynamic):Dynamic {
			_children[1].right = Expression.expr(e);
			return e;
		}
		
		/** Sub-expression for the value to test for range inclusion. */
		public function getVal():Dynamic { return _children[0].right; }
		public function setVal(e:Dynamic):Dynamic {
			var expr:Expression = Expression.expr(e);
			_children[0].right = expr;
			_children[1].left = expr;
			return e;
		}
		
		/**
		 * Create a new Range operator.
		 * @param min sub-expression for the minimum value of the range
		 * @param max sub-expression for the maximum value of the range
		 * @param val sub-expression for the value to test for range inclusion
		 */
		public function new(min:Dynamic, max:Dynamic, val:Dynamic)
		{
			addChild(new Comparison(Comparison.LTEQ, min, val));
			addChild(new Comparison(Comparison.LTEQ, val, max));
		}
		
		/**
		 * @inheritDoc
		 */
		public override function clone():Expression
		{
			return new Range(min.clone(), max.clone(), val.clone());
		}
		
	} // end of class RangePredicate
