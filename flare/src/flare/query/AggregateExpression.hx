package flare.query;

	/**
	 * Base class representing an aggregate query operator.
	 */
	class AggregateExpression extends Expression
	{
		public var input(getInput, setInput) : Dynamic;
		public var numChildren(getNumChildren, null) : Int ;
		/** The sub-expression to aggregate. */
		public var _expr:Expression;
		
		/** The sub-expression to aggregate. */
		public function getInput():Dynamic { return _expr; }
		public function setInput(e:Dynamic):Dynamic {
			_expr = Expression.expr(e);
			return e;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function getNumChildren():Int {
			return 1;
		}
		
		/**
		 * Creates a new AggregateExpression.
		 * @param input the sub-expression to aggregate.
		 */
		public function new(input:Dynamic) {
			this.input = input;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function getChildAt(idx:Int):Expression
	    {
	    	return idx==0 ? _expr : null;
	    }
	    
	    /**
		 * @inheritDoc
		 */
	    public override function setChildAt(idx:Int, expr:Expression):Bool
	    {
	    	if (idx == 0) {
	    		_expr = expr;
	    		return true;
	    	}
	    	return false;
	    }
	    
	    // --------------------------------------------------------------------
	    
	    /**
	     * Resets the aggregation computation.
	     */ 
	    public function reset():Void
		{
			// subclasses override this
		}
		
		/**
		 * Increments the aggregation computation to include the input value.
		 * @param value a value to include within the aggregation.
		 */
		public function aggregate(value:Dynamic):Void
		{
			// subclasses override this
		}
	    
	} // end of class AggregateExpression
