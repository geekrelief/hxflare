package flare.query;

	/**
	 * Expression operator for an if statement that performs conditional
	 * execution.
	 */
	class If extends Expression
	{
		public var els(getEls, setEls) : Dynamic;
		public var numChildren(getNumChildren, null) : Int ;
		public var test(getTest, setTest) : Dynamic;
		public var then(getThen, setThen) : Dynamic;
		private var _test:Expression;
    	private var _then:Expression;
    	private var _else:Expression;
	    
	    /** The conditional clause of the if statement. */
	    public function getTest():Dynamic { return _test; }
	    public function setTest(e:Dynamic):Dynamic {
	    	_test = Expression.expr(e);
	    	return e;
	    }
	    
	    /** Sub-expression evaluated if the test condition is true. */
	    public function getThen():Dynamic { return _then; }
	    public function setThen(e:Dynamic):Dynamic {
	    	_then = Expression.expr(e);
	    	return e;
	    }
	    
	    /** Sub-expression evaluated if the test condition is false. */
	    public function getEls():Dynamic { return _else; }
	    public function setEls(e:Dynamic):Dynamic {
	    	_else = Expression.expr(e);
	    	return e;
	    }
	    
	    /**
		 * @inheritDoc
		 */
	    public override function getNumChildren():Int { return 3; }
	    
	    // --------------------------------------------------------------------
	    
	    /**
	     * Create a new IfExpression.
	     * @param test the test expression for the if statement
	     * @param thenExpr the expression to evaluate if the test predicate
	     * evaluates to true
	     * @param elseExpr the expression to evaluate if the test predicate
	     * evaluates to false
	     */
	    public function new(test:Dynamic, thenExpr:Dynamic, elseExpr:Dynamic)
	    {
	        this.test = test;
	        this.then = thenExpr;
	        this.els = elseExpr;
	    }
	    
	    /**
		 * @inheritDoc
		 */
	    public override function clone():Expression
		{
			return new If(_test.clone(), _then.clone(), _else.clone());
		}
	    
	    /**
		 * @inheritDoc
		 */
	    public override function eval(?o:Dynamic=null):Dynamic
		{
			return (_test.predicate(o) ? _then : _else).eval(o);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function getChildAt(idx:Int):Expression
		{
			switch (idx) {
				case 0: return _test;
				case 1: return _then;
				case 2: return _else;
				default: return null;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public override function setChildAt(idx:Int, expr:Expression):Bool
		{
			switch (idx) {
				case 0: _test = expr; return true;
				case 1: _then = expr; return true;
				case 2: _else = expr; return true;
				default: return false;
			}
		}
		
		/**
		 * @inheritDoc
		 */
	    public override function toString():String
	    {
	        return "IF " + _test.toString()
	            + " THEN " + _then.toString()
	            + " ELSE " + _else.toString();
	    }
		
	} // end of class If
