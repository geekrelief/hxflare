package flare.util;

	import flash.display.DisplayObjectContainer;
		
	/**
	 * Utility class for sorting and creating sorting functions. This class
	 * provides a static <code>_S_()</code> method for creating sorting
	 * comparison functions from sort criteria. Instances of this class can be
	 * used to encapsulate a set of sort criteria and retrieve a corresponding
	 * sorting function.
	 * 
	 * <p>Sort criteria are generally expressed as an array of property names
	 * to sort on. These properties are accessed by sorting functions using the
	 * <code>Property</code> class. Sort criteria are expressed as an
	 * array of property names to sort on. These properties are accessed
	 * by sorting functions using the <code>Property</code> class.
	 * The default is to sort in ascending order. If the field name
	 * includes a "-" (negative sign) prefix, that variable will instead
	 * be sorted in descending order.
	 * </p>
	 */
	class Sort
	{
		public var comparator(getComparator, null) : Dynamic ;
		public var criteria(getCriteria, setCriteria) : Dynamic;
		/** Prefix indicating an ascending sort order. */
		inline public static var ASC:Int = '+'.charCodeAt(0);
		/** Prefix indicating a descending sort order. */
		inline public static var DSC:Int = '-'.charCodeAt(0);
		
		private var _comp:Dynamic;
		private var _crit:Array<Dynamic>;
		
		/** Gets the sorting comparison function for this Sort instance. */
		public function getComparator():Dynamic { return _comp; }
		
		/** The sorting criteria. Sort criteria are expressed as an
		 *  array of property names to sort on. These properties are accessed
		 *  by sorting functions using the <code>Property</code> class.
		 *  The default is to sort in ascending order. If the field name
		 *  includes a "-" (negative sign) prefix, that variable will instead
		 *  be sorted in descending order. */
		public function getCriteria():Dynamic { return Arrays.copy(_crit); }
		public function setCriteria(crit:Dynamic):Dynamic {
			if (Std.is( crit, String)) {
				_crit = [crit];
			} else if (Std.is( crit, Array)) {
				_crit = Arrays.copy(cast( crit, Array));
			} else {
				throw new ArgumentError("Invalid Sort specification type. " +
					"Input must be either a String or Array");
			}
			_comp = _S_(_crit);
			return crit;
		}
		
		/**
		 * Creates a new Sort instance to encapsulate sorting criteria.
		 * @param crit the sorting criteria. Sort criteria are expressed as an
		 *  array of property names to sort on. These properties are accessed
		 *  by sorting functions using the <code>Property</code> class.
		 *  The default is to sort in ascending order. If the field name
		 *  includes a "-" (negative sign) prefix, that variable will instead
		 *  be sorted in descending order.
		 */
		public function new(crit:Dynamic) {
			this.criteria = crit;
		}
		
		/**
		 * Sorts the input array according to the sort criteria.
		 * @param list an array to sort
		 */
		public function sort(list:Array<Dynamic>):Void
		{
			mergeSort(list, comparator, 0, list.length-1);
		}
		
		// --------------------------------------------------------------------
		// Static Methods
		
		/**
		 * Default comparator function that compares two values based on blind
		 *  application of the less-than and greater-than operators.
		 * @param a the first value to compare
		 * @param b the second value to compare
		 * @return -1 if a < b, 1 if a > b, 0 otherwise.
		 */
		public static function defaultComparator(a:Dynamic, b:Dynamic):Int {
			return a>b ? 1 : a<b ? -1 : 0;
		}
		
		private static function getComparator(cmp:Dynamic):Dynamic
		{
			var c:Dynamic;
			if (Std.is( cmp, Function)) {
				c = cast( cmp, Function);
			} else if (Std.is( cmp, Array)) {
				c = _S_(cast( cmp, Array));
			} else if (cmp == null) {
				c = defaultComparator;
			} else {
				throw new ArgumentError("Unknown parameter type: "+cmp);	
			}
			return c;
		}
		
		/**
		 * Creates a comparator function using the specification given
		 * by the input arguments. The resulting sorting function can be used
		 * to sort objects based on their properties.
		 * @param a A multi-parameter list or a single array containing a set
		 * of data field names to sort on, in priority order. The default is
		 * to sort in ascending order. If the field name includes a "-"
		 * (negative sign) prefix, that variable will instead be sorted in
		 * descending order.
		 * @return a comparison function for use in sorting objects.
		 */
		public static function _S_(a:Array<Dynamic>):Dynamic
		{
			if (a && a.length > 0 && Std.is( a[0], Array)) a = a[0];
			if (a==null || a.length < 1)
				throw new ArgumentError("Bad input.");

			if (a.length == 1) {
				return sortOn(a[0]);
			} else {
				var sorts:Array<Dynamic> = [];
				for each (var field:String in a) {
					sorts.push(sortOn(field));
				}
				return multisort(sorts);
			}
		}
		
		private static function multisort(f:Array<Dynamic>):Dynamic
		{
			return function(a:Dynamic, b:Dynamic):Int {
				var c:Int;
				for (i in 0...f.length) {
					if ((c = f[i](a, b)) != 0) return c;
				}
				return 0;
			}
		}
		
		private static function sortOn(field:String):Dynamic
		{
			var c:Int = field.charCodeAt(0);
			var asc:Bool = (c==ASC || c!=DSC);
			if (c==ASC || c==DSC) field = field.substring(1);
			var p:Property = Property._S_(field);
			return function(a:Dynamic, b:Dynamic):Int {
				var da:Dynamic = p.getValue(a);
				var db:Dynamic = p.getValue(b);
				return (asc?1:-1)*(da > db ? 1 : da < db ? -1 : 0);
			}
		}

		// --------------------------------------------------------------------

		inline private static var SORT_THRESHOLD:Int = 16;

		private static function insertionSort(a:Array<Dynamic>, cmp:Dynamic, p:Int, r:Int):Void
		{
			var i:Int, j:Int, key:Dynamic;
	        j = p+1;
	        while (j<=r) {
	        	key = a[j];
	            i = j - 1;
	            while (i >= p && cmp(a[i], key) > 0) {
	                a[i+1] = a[i];
	                i--;
	            }
	            a[i+1] = key;
	        	++j;
	        }
    	}
    	
    	private static function mergeSort(a:Array<Dynamic>, cmp:Dynamic, p:Int, r:Int):Void
    	{
	        if (p >= r) {
	            return;
	        }
	        if (r-p+1 < SORT_THRESHOLD) {
	            insertionSort(a, cmp, p, r);
	        } else {
	            var q:Int = (p+r)/2;
	            mergeSort(a, cmp, p, q);
	            mergeSort(a, cmp, q+1, r);
	            merge(a, cmp, p, q, r);
	        }
    	}

	    private static function merge(a:Array<Dynamic>, cmp:Dynamic, p:Int, q:Int, r:Int):Void
	    {
	    	var t:Array<Dynamic> = new Array(r-p+1);
	    	var i:Int, p1:Int = p, p2:Int = q+1;
	    	
	        for (i=0; p1<=q && p2<=r; ++i)
	        	t[i] = cmp(a[p2], a[p1]) > 0 ? a[p1++] : a[p2++];
	        for (; p1<=q; ++p1, ++i)
	            t[i] = a[p1];
	        for (; p2<=r; ++p2, ++i)
	            t[i] = a[p2];
	        for (i=0, p1=p; i<t.length; ++i, ++p1)
	            a[p1] = t[i];
	    }

	} // end of class Sort
