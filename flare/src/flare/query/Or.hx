package flare.query;

	/**
	 * Expression operator that computes the logical "or" of sub-expression
	 * clauses.
	 */
	class Or extends CompositeExpression
	{
		/**
		 * Creates a new Or operator.
		 * @param clauses the sub-expression clauses
		 */
		public function new(clauses:Array<Dynamic>) {
			super(clauses);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function clone():Expression
		{
			return cloneHelper(new Or());
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
			for each (var e:Expression in _children) {
				if (e.eval(o)) return true;
			}
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function toString():String
		{
			return _children.length==0 ? "FALSE" : super.getString("OR");
		}
		
	} // end of class Or
