package flare.query;

	/**
	 * Expression operator that computes the exclusive-or ("xor") of
	 * sub-expression clauses.
	 */
	class Xor extends CompositeExpression
	{
		/**
		 * Creates a new Xor operator.
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
			return cloneHelper(new Xor());
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
			if (_children.length == 0) return false;
			
			var b:Bool = _children[0].predicate(o);
			for (i in 1..._children.length) {
				b = (b != Expression(_children[i]).predicate(o));
			}
			return b;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function toString():String
		{
			return _children.length==0 ? "FALSE" : super.getString("XOR");
		}
		
	} // end of class Xor
