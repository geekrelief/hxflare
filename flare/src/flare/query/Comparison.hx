package flare.query;

	/**
	 * Expression operator for comparing sub-expression values. Performs
	 * equals, not equals, less-than, greater-than, less-than-or-equal, or
	 * greater-than-or-equal comparison.
	 */
	class Comparison extends BinaryExpression
	{
		public var comparator(getComparator, setComparator) : Dynamic;
		public var operatorString(getOperatorString, null) : String
		;
		/** Indicates a less-than comparison. */
	    inline public static var LT:Int   = 0;
    	/** Indicates a greater-than comparison. */
    	inline public static var GT:Int   = 1;
    	/** Indicates a equals comparison. */
    	inline public static var EQ:Int   = 2;
    	/** Indicates a not-equals comparison. */
    	inline public static var NEQ:Int  = 3;
    	/** Indicates a less-than-or-equals comparison. */
    	inline public static var LTEQ:Int = 4;
    	/** Indicates a greater-than-or-equals comparison. */
    	inline public static var GTEQ:Int = 5;

		private var _cmp:Dynamic ;
		
		/** Comparison function for custom ordering criteria. */
		public function getComparator():Dynamic { return _cmp; }
		public function setComparator(f:Dynamic):Dynamic { _cmp = f; 	return f;}
		
		/** Returns a string representation of the arithmetic operator. */
		public override function getOperatorString():String
		{
	        switch (_op) {
	        	case LT:	return "<";
	        	case GT:	return ">";
	        	case EQ:	return "=";
	        	case NEQ:	return "!=";
	        	case LTEQ:	return "<=";
	        	case GTEQ:	return ">=";
	        	default: 	return "?";
	        }
	    }
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new Comparison operator.
		 * @param left the left-hand-side sub-expression to compare
		 * @param right the right-hand-side sub-expression to compare
		 * @param comparator a function to use for comparison (null by default)
		 */
		public function Comparison(op:int=2, left:*="",
			right:*="", comparator:Function=null)
		{
			super(op, LT, GTEQ, left, right);
			_cmp = comparator;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function clone():Expression
		{
			return new Comparison(_op, _left.clone(), _right.clone(), _cmp);
		