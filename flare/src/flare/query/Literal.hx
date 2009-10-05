package flare.query;
	
	/**
	 * Expression operator for a literal value.
	 */
	class Literal extends Expression
	{
		public var value(getValue, setValue) : Dynamic;
		/** The boolean true literal. */
		inline public static var TRUE:Literal = new Literal(true);
		/** The boolean false literal. */
		inline public static var FALSE:Literal = new Literal(false);
		
		private var _value:Dynamic ;
		
		/** The literal value of this expression. */
		public function getValue():Dynamic { return _value; }
		public function setValue(val:Dynamic):Dynamic { _value = val; 	return val;}
		
		/**
		 * Creates a new Literal instance.
		 * @param val the literal value
		 */
		public function new(?val:Dynamic=null) {
			
			_value = null;
			_value = val;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function clone():Expression
		{
			return new Literal(_value);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function predicate(o:Dynamic):Bool
		{
			return Boolean(_value);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function eval(?o:Dynamic=null):Dynamic
		{
			return _value;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function toString():String
		{
			return String(_value);
		}
		
	} // end of class Literal
