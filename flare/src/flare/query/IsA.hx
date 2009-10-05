package flare.query;

	/**
	 * Expression operator that type checks a sub-expression.
	 */
	class IsA extends Expression
	{
		public var clause(getClause, setClause) : Dynamic;
		public var numChildren(getNumChildren, null) : Int ;
		public var type(getType, null) : Class ;
		private var _type:Class;
		private var _clause:Expression;
		
		/** The class type to check for. */
		public function getType():Class { return _type; }
		
		/** The sub-expression clause to type check. */
		public function getClause():Dynamic { return _clause; }
		public function setClause(e:Dynamic):Dynamic {
			_clause = e==null ? null : Expression.expr(e);
			return e;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function getNumChildren():Int { return _clause ? 1 : 0; }
		
		/**
		 * Creates a new IsA operator. 
		 * @param type the class type to check for
		 * @param clause the sub-expression clause to type check. If null,
		 *  the input object (rather than a sub-property or expression result)
		 *  will be type checked.
		 */
		public function IsA(type:Class, clause:*=null) {
			_type = type;
			this.clause = clause;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function clone():Expression
		{
			return new IsA(_type, _clause.clone());
		