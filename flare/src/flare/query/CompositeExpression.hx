package flare.query;

	import flash.utils.ByteArray;
	
	/**
	 * Base class for expressions with an arbitrary number of sub-expressions.
	 */
	class CompositeExpression extends Expression
	{
		public var numChildren(getNumChildren, null) : Int ;
		/** Array of sub-expressions. */
		public var _children:Array<Dynamic>;
		
		/**
		 * @inheritDoc
		 */
		public override function getNumChildren():Int {
			return _children.length;
		}
		
		/**
		 * Creates a new CompositeExpression.
		 * @param items either a single sub-expression or an array of
		 *  sub-expressions
		 */
		public function new(?items:Dynamic=null) {
			if (Std.is( items, Array)) {
				setChildren(cast( items, Array));
			} else if (Std.is( items, Expression)) {
				_children = new Array();
				addChild(cast( items, Expression));
			} else if (items == null) {
				_children = new Array();
			} else {
				throw new ArgumentError(
					"Input must be an expression or array of expressions");
			}
		}
		
		/**
		 * Helper routine that clones this composite's sub-expressions.
		 * @param ce the cloned composite expression
		 * @return the input expression
		 */
		public function cloneHelper(ce:CompositeExpression):Expression
		{
			for (i in 0..._children.length) {
				ce.addChild(Expression(_children[i]).clone());
			}
			return ce;
		}
		
		/**
		 * Sets the sub-expressions of this composite
		 * @param array an array of sub-expressions
		 */
		public function setChildren(array:Array<Dynamic>):Void
		{
			_children = new Array();
			for each (var e:Dynamic in array) {
				_children.push(Expression.expr(e));
			}
		}
		
		/**
		 * Adds an additional sub-expression to this composite.
		 * @param expr the sub-expression to add.
		 */
		public function addChild(expr:Expression):Void
		{
			_children.push(expr);
		}
		
		/**
		 * Removes a sub-expression from this composite.
		 * @param expr the sub-epxressions to remove
		 * @return true if the expression was found and removed, false
		 *  otherwise
		 */
		public function removeChild(expr:Expression):Bool
		{
			var idx:Int = _children.indexOf(expr);
			if (idx >= 0) {
				_children.splice(idx, 1);
				return true;
			} else {
				return false;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public override function getChildAt(idx:Int):Expression
		{
			return _children[idx];
		}
		
		/**
		 * @inheritDoc
		 */
		public override function setChildAt(idx:Int, expr:Expression):Bool
		{
			if (idx>=0 && idx<_children.length) {
				_children[idx] = expr;
				return true;
			}
			return false;
		}
		
		/**
		 * Removes all sub-expressions from this composite.
		 */
		public function removeAllChildren():Void
		{
			while (_children.length > 0) _children.pop();
		}
		
		/**
		 * Returns a string representation of this composite's sub-expressions.
		 * @param op a string describing the sub-class operator (null by
		 *  default). If non-null, the operator string will be interspersed
		 *  between sub-expression values in the output string.
		 * @return the requested string
		 */
		public function getString(?op:String=null):String
		{	        
	        var b:ByteArray = new ByteArray();
	        b.writeUTFBytes('(');
			for (i in 0..._children.length) {
				if (i > 0) {
					if (op == null) {
						b.writeUTFBytes(', ');
					} else {
						b.writeUTFBytes(' ');
						b.writeUTFBytes(op);
						b.writeUTFBytes(' ');
					}
				}
				b.writeUTFBytes(_children[i].toString());
			}
			b.writeUTFBytes(')');	        

			b.position = 0;
	        return b.readUTFBytes(b.length);
		}
		
	} // end of class CompositeExpression
