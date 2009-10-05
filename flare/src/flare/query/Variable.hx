package flare.query;

	import flare.util.Property;
	
	/**
	 * Expression operator that retrieves a value from an object property.
	 * Uses a <code>flare.util.Property</code> instance to access the value.
	 * @see flare.util.Property
	 */
	class Variable extends Expression
	{
		public var name(getName, setName) : String;
		/** @private */
		public var _prop:Property;
		
		/** The name of the variable property. */
		public function getName():String { return _prop.name; }
		public function setName(f:String):String {
			_prop = Property._S_(f);
			return f;
		}
		
		/**
		 * Creates a new Variable operator.
		 * @param name the name of the variable property
		 */
		public function new(name:String) {
			this.name = name;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function clone():Expression
		{
			return new Variable(_prop.name);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function eval(?o:Dynamic=null):Dynamic
		{
			return _prop.getValue(o);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function toString():String
		{
			return "`"+_prop.name+"`";
		}
		
	} // end of class Variable
