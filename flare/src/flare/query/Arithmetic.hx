package flare.query;

	/**
	 * Expression operator for arithmetic operations. Performs addition,
	 * subtraction, multiplication, or division of sub-expression values.
	 */
	class Arithmetic extends BinaryExpression
	{
		public var operatorString(getOperatorString, null) : String
		;
		/** Indicates an addition operation. */
	    inline public static var ADD:Int = 0;
	    /** Indicates a subtraction operation. */
	    inline public static var SUB:Int = 1;
	    /** Indicates a multiplication operation. */
	    inline public static var MUL:Int = 2;
	    /** Indicates a division operation. */
	    inline public static var DIV:Int = 3;
	    /** Indicates a modulo operation. */
	    inline public static var MOD:Int = 4;
		
		/** Returns a string representation of the arithmetic operator. */
		public override function getOperatorString():String
		{
        	switch (_op) {
	        	case ADD: return '+';
	        	case SUB: return '-';
	        	case MUL: return '*';
	        	case DIV: return '/';
	        	case MOD: return '%';
	        	default: return '?';
	        }
		}
		
		/**
	     * Create a new Arithmetic expression.
	     * @param operation the operation to perform
	     * @param left the left sub-expression
	     * @param right the right sub-expression
	     */
	    public function new(op:Int, left:Dynamic, right:Dynamic)
	    {
	        super(op, ADD, MOD, left, right);
	    }
		
		/**
		 * @inheritDoc
		 */
		public override function clone():Expression
		{
			return new Arithmetic(_op, _left.clone(), _right.clone());
		}
		
		/**
		 * @inheritDoc
		 */
		public override function eval(?o:Dynamic=null):Dynamic
		{
			var x:Int = Number(_left.eval(o));
			var y:Int = Number(_right.eval(o));
			
	        // compute return value
	        switch (_op) {
	        	case ADD: return x+y;
	        	case SUB: return x-y;
	        	case MUL: return x*y;
	        	case DIV: return x/y;
	        	case MOD: return x%y;
	        }
	        throw new Error("Unknown operation type: "+_op);
		}
		
		// -- Static constructors ---------------------------------------------
		
		/**
		 * Creates a new Arithmetic operator for adding two numbers.
		 * @param left the left-hand input expression
		 * @param right the right-hand input expression
		 * @return the new Arithmetic operator
		 */
		public static function Add(left:Dynamic, right:Dynamic):Arithmetic
		{
			return new Arithmetic(ADD, left, right);
		}
		
		/**
		 * Creates a new Arithmetic operator for subtracting one number
		 *  from another.
		 * @param left the left-hand input expression
		 * @param right the right-hand input expression
		 * @return the new Arithmetic operator
		 */
		public static function Subtract(left:Dynamic, right:Dynamic):Arithmetic
		{
			return new Arithmetic(SUB, left, right);
		}
		
		/**
		 * Creates a new Arithmetic operator for multiplying two numbers.
		 * @param left the left-hand input expression
		 * @param right the right-hand input expression
		 * @return the new Arithmetic operator
		 */
		public static function Multiply(left:Dynamic, right:Dynamic):Arithmetic
		{
			return new Arithmetic(MUL, left, right);
		}
		
		/**
		 * Creates a new Arithmetic operator for dividing one number
		 *  by another.
		 * @param left the left-hand input expression
		 * @param right the right-hand input expression
		 * @return the new Arithmetic operator
		 */
		public static function Divide(left:Dynamic, right:Dynamic):Arithmetic
		{
			return new Arithmetic(DIV, left, right);
		}
		
		/**
		 * Creates a new Arithmetic operator for computing the modulo
		 *  (remainder) of a number.
		 * @param left the left-hand input expression
		 * @param right the right-hand input expression
		 * @return the new Arithmetic operator
		 */
		public static function Mod(left:Dynamic, right:Dynamic):Arithmetic
		{
			return new Arithmetic(MOD, left, right);
		}
		
	} // end of class Arithmetic
