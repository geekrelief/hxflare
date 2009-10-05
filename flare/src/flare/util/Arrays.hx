package flare.util;

	/**
	 * Utility methods for working with arrays.
	 */
	class Arrays
	{
		inline public static var EMPTY:Array<Dynamic> = new Array(0);
		
		/**
		 * Constructor, throws an error if called, as this is an abstract class.
		 */
		public function new() {
			throw new ArgumentError("This is an abstract class.");
		}
		
		/**
		 * Returns the maximum value in an array. Comparison is determined
		 * using the greater-than operator against arbitrary types.
		 * @param a the array
		 * @param p an optional property from which to extract the value.
		 *  If this is null, the immediate contents of the array are compared.
		 * @return the maximum value
		 */
		public static function max(a:Array<Dynamic>, ?p:Property=null):Number
		{
			var x:Int = Number.MIN_VALUE;
			if (p) {
				var v:Number;
				for (i in 0...a.length) {
					v = p.getValue(a[i]);
					if (v > x) x = v;
				}
			} else {
				for (i in 0...a.length) {
					if (a[i] > x) x = a[i];
				}
			}
			return x;
		}
		
		/**
		 * Returns the index of a maximum value in an array. Comparison is
		 * determined using the greater-than operator against arbitrary types.
		 * @param a the array
		 * @param p an optional property from which to extract the value.
		 *  If this is null, the immediate contents of the array are compared.
		 * @return the index of a maximum value
		 */
		public static function maxIndex(a:Array<Dynamic>, ?p:Property=null):Number
		{
			var x:Int = Number.MIN_VALUE;
			var idx:Int = -1;
			
			if (p) {
				var v:Number;
				for (i in 0...a.length) {
					v = p.getValue(a[i]);
					if (v > x) { x = v; idx = i; }
				}
			} else {
				for (i in 0...a.length) {
					if (a[i] > x) { x = a[i]; idx = i; }
				}
			}
			return idx;
		}
		
		/**
		 * Returns the minimum value in an array. Comparison is determined
		 * using the less-than operator against arbitrary types.
		 * @param a the array
		 * @param p an optional property from which to extract the value.
		 *  If this is null, the immediate contents of the array are compared.
		 * @return the minimum value
		 */
		public static function min(a:Array<Dynamic>, ?p:Property=null):Number
		{
			var x:Int = Number.MAX_VALUE;
			if (p) {
				var v:Number;
				for (i in 0...a.length) {
					v = p.getValue(a[i]);
					if (v < x) x = v;
				}
			} else {
				for (i in 0...a.length) {
					if (a[i] < x) x = a[i];
				}
			}
			return x;
		}
		
		/**
		 * Returns the index of a minimum value in an array. Comparison is
		 * determined using the less-than operator against arbitrary types.
		 * @param a the array
		 * @param p an optional property from which to extract the value.
		 *  If this is null, the immediate contents of the array are compared.
		 * @return the index of a minimum value
		 */
		public static function minIndex(a:Array<Dynamic>, ?p:Property=null):Number
		{
			var x:Int = Number.MAX_VALUE, idx:Int = -1;
			if (p) {
				var v:Number;
				for (i in 0...a.length) {
					v = p.getValue(a[i]);
					if (v < x) { x = v; idx = i; }
				}
			} else {
				for (i in 0...a.length) {
					if (a[i] < x) { x = a[i]; idx = i; }
				}
			}
			return idx;
		}
		
		/**
		 * Fills an array with a given value.
		 * @param a the array
		 * @param o the value with which to fill the array
		 */
		public static function fill(a:Array<Dynamic>, o:Dynamic) : Void
		{
			for (i in 0...a.length) {
				a[i] = o;
			}
		}
		
		/**
		 * Makes a copy of an array or copies the contents of one array to
		 * another.
		 * @param a the array to copy
		 * @param b the array to copy values to. If null, a new array is
		 *  created.
		 * @param a0 the starting index from which to copy values
		 *  of the input array
		 * @param b0 the starting index at which to write value into the
		 *  output array
		 * @param len the number of values to copy
		 * @return the target array containing the copied values
		 */
		public static function copy(a:Array<Dynamic>, ?b:Array<Dynamic>=null, ?a0:Int=0, ?b0:Int=0, ?len:Int=-1) : Array<Dynamic> {
			len = (len < 0 ? a.length : len);
			if (b==null) {
				b = new Array(b0+len);
			} else {
				while (b.length < b0+len) b.push(null);
			}

			for (i in 0...len) {
				b[b0+i] = a[a0+i];
			}
			return b;
		}
		
		/**
		 * Clears an array instance, removing all values.
		 * @param a the array to clear
		 */
		public static function clear(a:Array<Dynamic>):Void
		{
			while (a.length > 0) a.pop();
		}
				
		/**
		 * Removes an element from an array. Only the first instance of the
		 * value is removed.
		 * @param a the array
		 * @param o the value to remove
		 * @return the index location at which the removed element was found,
		 * negative if the value was not found.
		 */
		public static function remove(a:Array<Dynamic>, o:Dynamic) : Int {
			var idx:Int = a.indexOf(o);
			if (idx == a.length-1) {
				a.pop();
			} else if (idx >= 0) {
				a.splice(idx, 1);
			}
			return idx;
		}
		
		/**
		 * Removes the array element at the given index.
		 * @param a the array
		 * @param idx the index at which to remove an element
		 * @return the removed element
		 */
		public static function removeAt(a:Array<Dynamic>, idx:UInt) : Dynamic {
			if (idx == a.length-1) {
				return a.pop();
			} else {
				var x:Dynamic = a[idx];
				a.splice(idx,1);
				return x;
			}
		}
		
		/**
		 * Performs a binary search over the input array for the given key
		 * value, optionally using a provided property to extract from array
		 * items and a custom comparison function.
		 * @param a the array to search over
		 * @param key the key value to search for
		 * @param prop the property to retrieve from objecs in the array. If null
		 *  (the default) the array values will be used directly.
		 * @param cmp an optional comparison function
		 * @return the index of the given key if it exists in the array,
         *  otherwise -1 times the index value at the insertion point that
         *  would be used if the key were added to the array.
         */
		public static function binarySearch(a:Array<Dynamic>, key:Dynamic,
			?prop:String=null, ?cmp:Dynamic=null) : Int
		{
			var p:Property = prop ? Property._S_(prop) : null;
			if (cmp == null)
				cmp = function(a:Dynamic,b:Dynamic):Int {return a>b ? 1 : a<b ? -1 : 0;}
			
			var x1:Int = 0, x2:Int = a.length, i:Int = (x2>>1);
        	while (x1 < x2) {
        		var c:Int = cmp(p ? p.getValue(a[i]) : a[i], key);
        		if (c == 0) {
                	return i;
            	} else if (c < 0) {
                	x1 = i + 1;
            	} else {
                	x2 = i;
            	}
            	i = x1 + ((x2 - x1)>>1);
        	}
        	return -1*(i+1);
		}
		
		/**
		 * Sets a named property value for items stored in an array.
		 * The value can take a number of forms:
		 * <ul>
		 *  <li>If the value is a <code>Function</code>, it will be evaluated
		 *      for each element and the result will be used as the property
		 *      value for that element.</li>
		 *  <li>If the value is an <code>IEvaluable</code> instance, it will be
		 *      evaluated for each element and the result will be used as the
		 *      property value for that element.</li>
		 *  <li>In all other cases, the property value will be treated as a
		 *      literal and assigned for all elements.</li>
		 * </ul>
		 * @param list the array to set property values for
		 * @param name the name of the property to set
		 * @param value the value of the property to set
		 * @param filter a filter function determining which items
		 *  in the array should be processed
		 * @param p an optional <code>IValueProxy</code> for setting the values
		 */
		public static function setProperty(a:Array<Dynamic>,
			name:String, value:Dynamic, filter:Dynamic, ?p:IValueProxy=null):Void
		{
			if (p == null) p = Property.proxy;
			var v:Dynamic = Std.is( value, Function) ? cast( value, Function) :
				Std.is( value, IEvaluable) ? IEvaluable(value).eval : null;
			for each (var o:Dynamic in a) if (filter==null || filter(o))
				p.setValue(o, name, v!=null ? v(p._S_(o)) : value);
		}

	} // end of class Arrays
