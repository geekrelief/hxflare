package flare.query;
	
	/**
	 * Expression operator that returns the logical "not" of a sub-expression.
	 */
	class Not extends Expression
	{
		public var clause(getClause, setClause) : Dynamic;
		public var numChildren(getNumChildren, null) : Int ;
		private var _clause:Expression;
		
		/** The sub-expression clause to negate. */
		public function getClause():Dynamic { return _clause; }
		public function setClause(e:Dynamic):Dynamic { _clause = Expression.expr(e); 	return e;}
		
		/**
		 * @inheritDoc
		 */
		public override function getNumChildren():Int { return 1; }
		
		/**
		 * Creates a new Not operator.
		 * @param clause the sub-expression clause to negate
		 */
		public function new(clause:Dynamic) {
			_clause = Expression.expr(clause);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function clone():Expression
		{
			return new Not(_clause.clone());
		}
		
		/**
		 * @inheritDoc
		 */
		public override function eval(?o:Dynamic=null):Dynamic
		{
			return predicate(o);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function predicate(o:Dynamic):Bool
		{
			return !_clause.eval(o);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function getChildAt(idx:Int):Expression
		{
			return (idx==0 ? _clause : null);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function setChildAt(idx:Int, expr:Expression):Bool
		{
			if (idx == 0) {
				_clause = expr;
				return true;
			}
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function toString():String
		{
			return "NOT " + _clause.toString();
		}
		
	} // end of class Not
