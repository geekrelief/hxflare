package flare.query;
	
	/**
	 * Expression operator that computes the logical "and" of sub-expression
	 * clauses.
	 */
	class And extends CompositeExpression
	{
		/**
		 * Creates a new And operator.
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
			return cloneHelper(new And());
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
			if (_children.length==0) return false;
			
			for each (var e:Expression in _children) {
				if (!e.eval(o)) return false;
			}
			return true;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function toString():String
		{
			return _children.length==0 ? "FALSE" : super.getString("AND");
		}
		
	} // end of class And
