package flare.query;

	/**
	 * Base class for binary expression operators.
	 */
	class BinaryExpression extends Expression
	{
		public var left(getLeft, setLeft) : Dynamic;
		public var numChildren(getNumChildren, null) : Int ;
		public var operator(getOperator, setOperator) : Int;
		public var operatorString(getOperatorString, null) : String ;
		public var right(getRight, setRight) : Dynamic;
		/** Code indicating the operation perfomed by this instance. */
		public var _op:Int;
		/** The left-hand-side sub-expression. */
		public var _left:Expression;
		/** The right-hand-side sub-expression. */
		public var _right:Expression;
		
		/** Code indicating the operation performed by this instance. */
		public function getOperator():Int { return _op; }
		public function setOperator(op:Int):Int { _op = op; 	return op;}
		/** String representation of the operation performed by this
		 *  instance. */
		public function getOperatorString():String { return null; }
		
		/** The left-hand-side sub-expression. */
		public function getLeft():Dynamic { return _left; }
		public function setLeft(l:Dynamic):Dynamic {
			_left = Expression.expr(l);
			return l;
		}
		
		/** The right-hand-side sub-expression. */
		public function getRight():Dynamic { return _right; }
		public function setRight(r:Dynamic):Dynamic {
			_right = Expression.expr(r);
			return r;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function getNumChildren():Int {
			return 2;
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new BinaryExpression.
		 * @param op the operation code
		 * @param minOp the minimum legal operation code
		 * @param maxOp the maximum legal operation code
		 * @param left the left-hand-side sub-expression
		 * @param right the right-hand-side sub-expression
		 */
		public function new(op:Int, minOp:Int, maxOp:Int,
            left:Dynamic, right:Dynamic)
	    {
	        // operation check
	        if (op < minOp || op > maxOp) {
	            throw new ArgumentError("Unknown operation type: " + op);
	        }
	        // null check
	        if (left == null || right == null) {
	            throw new ArgumentError("Expressions must be non-null.");
	        }
	        _op = op;
	        this.left = left;
	        this.right = right;
	    }
	    
	    /**
		 * @inheritDoc
		 */
	    public override function getChildAt(idx:Int):Expression
	    {
	    	switch (idx) {
	    		case 0: return _left;
	    		case 1: return _right;
	    		default: return null;
	    	}
	    }
	    
	    /**
		 * @inheritDoc
		 */
	    public override function setChildAt(idx:Int, expr:Expression):Bool
	    {
	    	switch (idx) {
	    		case 0: _left = expr;  return true;
	    		case 1: _right = expr; return true;
	    		default: return false;
	    	}
	    }
	    
	    /**
		 * @inheritDoc
		 */
	    public override function toString():String
	    {
	        return '(' + _left.toString() +' '
	                   +  operatorString  +' '
	        		   + _right.toString()+')';
	    }

	} // end of class BinaryExpression
