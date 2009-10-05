package flare.util;
		
	/**
	 * Utility class for accessing arbitrary property chains, allowing
	 * nested property expressions (e.g., <code>x.a.b.c</code> or 
	 * <code>x.a[1]</code>). To reduce initialization times, this class also
	 * maintains a static cache of all Property instances created using the
	 * static <code>_S_()</code> method.
	 */
	class Property implements IEvaluable, IPredicate
	{
		public var name(getName, null) : String ;
		public var proxy(getProxy, null) : IValueProxy ;
		private static var DELIMITER:Dynamic = ~/[\.|\[(.*)\]]/;
		
		private static var __cache:Dynamic = {};
		private static var __stack:Array<Dynamic> = [];
		private static var __proxy:IValueProxy;

		/**
		 * Requests a Property instance for the given property name. This is a
		 * factory method that caches and reuses property instances, saving
		 * memory and construction time. This method is the preferred way of
		 * getting a property and should be used instead of the constructor.
		 * @param name the name of the property
		 * @return the requested property instance
		 */
		public static function _S_(name:String):Property
		{
			if (name == null) return null;
			var p:Property = __cache[name];
			if (p == null) {
				p = new Property(name);
				__cache[name] = p;
			}
			return p;
		}
		
		/**
		 * Clears the cache of created Property instances
		 */
		public static function clearCache():Void
		{
			__cache = {};
		}

		/** A minimal <code>IValueProxy</code> instance that gets and sets
		 *  property values through <code>Property</code> instances. */
		public static function getProxy():IValueProxy {
			if (__proxy == null) __proxy = new PropertyProxy();
			return __proxy;
		}
		
		// --------------------------------------------------------------------
		
		private var _field:String;
		private var _chain:Array<Dynamic>;
		
		/** The property name string. */
		public function getName():String { return _field; }
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new Property, in most cases the static <code>_S_</code>
		 * method should be used instead of this constructor.
		 * @param name the property name string
		 */
		public function new(name:String) {
			if (name == null) {
				throw new ArgumentError("Not a valid property name: "+name);
			}
			
			_field = name;
			_chain = null;
			
			if (_field != null) {
				var parts:Array<Dynamic> = _field.split(DELIMITER);
				if (parts.length > 1) {
					_chain = [];
					for (i in 0...parts.length) {
						if (parts[i].length > 0)
							_chain.push(parts[i]);
					}
				}
			}
		}
		
		/**
		 * Gets the value of this property for the input object.
		 * @param x the object to retrieve the property value for
		 * @return the property value
		 */
		public function getValue(x:Dynamic):Dynamic
		{
			if (x == null) {
				return null;
			} else if (_chain == null) {
				return x[_field];
			} else {
				for (i in 0..._chain.length) {
					x = x[_chain[i]];
				}
				return x;
			}
		}
		
		/**
		 * Gets the value of this property for the input object; this
		 * is the same as <code>getValue</code>, but provided in order to
		 * implement the <code>IEvaluable</code> interface.
		 * @param x the object to retrieve the property value for
		 * @return the property value
		 */
		public function eval(?x:Dynamic=null):Dynamic
		{
			if (x == null) {
				return null;
			} else if (_chain == null) {
				return x[_field];
			} else {
				for (i in 0..._chain.length) {
					x = x[_chain[i]];
				}
				return x;
			}
		}
		
		/**
		 * Gets the value of this property and casts the result to a
		 * Boolean value.
		 * @param x the object to retrieve the property value for
		 * @return the property value as a Boolean
		 */
		public function predicate(x:Dynamic):Bool
		{
			return Boolean(eval(x));
		}
		
		/**
		 * Sets the value of this property for the input object. If the reset
		 * flag is true, all properties along a property chain will be updated.
		 * Otherwise, only the last property in the chain is updated.
		 * @param x the object to set the property value for
		 * @param val the value to set
		 */
		public function setValue(x:Dynamic, val:Dynamic):Void
		{
			if (_chain == null) {
				x[_field] = val;
			} else {
				__stack.push(x);
				for (i in 0..._chain.length-1) {
					__stack.push(x = x[_chain[i]]);	
				}
				
				var p:Dynamic = __stack.pop();
				p[_chain[i]] = val;
				
				i=_chain.length-1;
				while (--i >= 0) {
					x = p;
					p = __stack.pop();
					try {
						p[_chain[i]] = x;
					} catch (err:Error) {}
					;
				}
			}
		}
		
		/**
		 * Deletes a dynamically-bound property from an object.
		 * @param x the object from which to delete the property
		 */
		public function deleteValue(x:Dynamic):Void
		{
			if (_chain == null) {
				delete x[_field];
			} else {
				for (i in 0..._chain.length-1) {
					x = x[_chain[i]];
				}
				delete x[_chain[i]];
			}
		}
		
	} // end of class Property
