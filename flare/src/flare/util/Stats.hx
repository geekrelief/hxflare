package flare.util;

	import flash.utils.Dictionary;
	import flare.util.Arrays;
	import flare.util.Property;
	
	/**
	 * Utility class for computing statistics for a collection of values.
	 */
	class Stats
	{
		public var average(getAverage, null) : Number ;
		public var count(getCount, null) : Number ;
		public var dataType(getDataType, null) : Int ;
		public var distinct(getDistinct, null) : Number ;
		public var distinctValues(getDistinctValues, null) : Array<Dynamic> ;
		public var maxDate(getMaxDate, null) : Date ;
		public var maxObject(getMaxObject, null) : Dynamic ;
		public var maximum(getMaximum, null) : Number ;
		public var minDate(getMinDate, null) : Date ;
		public var minObject(getMinObject, null) : Dynamic ;
		public var minimum(getMinimum, null) : Number ;
		public var stddev(getStddev, null) : Number ;
		public var stderr(getStderr, null) : Number ;
		public var sum(getSum, null) : Number ;
		public var values(getValues, null) : Array<Dynamic> ;
		/** Constant indicating numerical values. */
		inline public static var NUMBER:Int = 0;
		/** Constant indicating date/time values. */
		inline public static var DATE:Int   = 1;
		/** Constant indicating arbitrary object values. */
		inline public static var OBJECT:Int = 2;
		
		private var _type:Int ;
		private var _comp:Dynamic ;
		
		private var _num:Int ;
		private var _distinct:Int ;
		private var _elm:Array<Dynamic> ;
		
		private var _minObject:Dynamic ;
		private var _maxObject:Dynamic ;
		
		private var _min:Int ;
		private var _max:Int ;
		private var _sum:Int ;
		private var _stdev:Int ;
		
		/** The data type of the collection, one of NUMBER, DATE, or OBJECT. */
		public function getDataType():Int { return _type; }
		/** A sorted array of all the values. */
		public function getValues():Array<Dynamic> { return _elm; }
		/** A sorted array of all unique values in the collection. */
		public function getDistinctValues():Array<Dynamic> {
			// get array with only unique items
			var dists:Array<Dynamic> = [];
			if (_elm==null || _elm.length == 0) return dists;
			dists.push(_elm[0]);
			for (i in 1..._num) {
				if (!equal(_elm[i], dists[j])) {
					dists.push(_elm[i]); ++j;
				}
			}
			return dists;
		}
		/** The minimum value (for numerical data). */
		public function getMinimum():Number { return _min; }
		/** The maximum value (for numerical data). */
		public function getMaximum():Number { return _max; }
		/** The sum of all the values (for numerical data). */
		public function getSum():Number { return _sum; }
		/** The average of all the values (for numerical data). */
		public function getAverage():Number { return _sum / _num; }
		/** The standard deviation of all the values (for numerical data). */
		public function getStddev():Number { return _stdev; }
		/** The standard error of all the values (for numerical data). */
		public function getStderr():Number { return stddev / Math.sqrt(_num); }
		/** The total number of values. */
		public function getCount():Number { return _num; }
		/** The total number of distinct values. */
		public function getDistinct():Number { return _distinct; }
		
		/** The minimum value (for date/time values). */
		public function getMinDate():Date { return cast( _minObject, Date); }
		/** The maximum value (for date/time values). */
		public function getMaxDate():Date { return cast( _maxObject, Date); }
		
		/** The minimum value (for arbitrary objects). */
		public function getMinObject():Dynamic { return _minObject; }
		/** The maximum value (for arbitrary objects). */
		public function getMaxObject():Dynamic { return _maxObject; }
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new Stats instance using the given input data. If the
		 * field argument is null, it is assumed that the input data array
		 * directly contains the values to analyze. If the field argument is
		 * non-null, values will be extracted from the objects in the input
		 * array using the specified property name.
		 * @param data an input data array. The data to analyze may be
		 *  contained directly in the array, or may be properties of the
		 *  objects contained in the array.
		 * @param field a property name. This property will be used to extract
		 *  data values from the objects in the data array. If null, the
		 *  objects in the data array will be used directly.
		 * @param comparator the comparator function to use to sort the data.
		 *  If null, the natural sort order will be used.
		 * @param copy flag indicating if the input data array should be
		 *  copied to a new array. This flag only applied when the field
		 *  argument is null. In false, the input data array will be sorted.
		 *  If true, the array will be copied before being sorted. The default
		 *  behavior is to make a copy.
		 */
		public function new(data:Array<Dynamic>, ?field:String=null,
							  ?comparator:Dynamic=null, ?copy:Bool=true)
		{
			
			_type = -1;
			_comp = null;
			_num = 0;
			_distinct = 0;
			_elm = null;
			_minObject = null;
			_maxObject = null;
			_min = Number.MAX_VALUE;
			_max = Number.MIN_VALUE;
			_sum = 0;
			_stdev = 0;
			_comp = comparator;
			init(data, field, copy);
		}
		
		private function init(data:Array<Dynamic>, field:String, copy:Bool):Void
		{
			// INVARIANT: properties must be set to default values
			// TODO: how to handle null values?
						
			// collect all values into element array
			_num = data.length; if (_num==0) return;
			_elm = (field==null ? (copy ? Arrays.copy(data) : data)
								: new Array(_num));
			if (field != null) {
				var p:Property = Property._S_(field);
				for (i in 0..._num) {
					_elm[i] = p.getValue(data[i]);
				}
			}
			
			// determine data type
			for (i in 0..._num) {
				var v:Dynamic = _elm[i], type:Int;
				type = Std.is( v, Date) ? DATE : (Std.is( v, Number) ? NUMBER : OBJECT);

				if (_type == -1) {
					_type = type; // seed type
				} else if (type != _type) {
					_type = OBJECT; // punt if no match
					break;
				}
			}
			
			// sort data values
			var opt:Int = (_type==OBJECT ? 0 : Array.NUMERIC);
			if (_comp==null) _elm.sort(opt); else _elm.sort(_comp, opt);
			
			// count unique values
			_distinct = 1; var j:UInt = 0;
			for (i in 1..._num) {
				if (!equal(_elm[i], _elm[j])) { ++_distinct; j=i;	}
			}
			
			// populate stats
			var N:Int = _num-1;
			if (_type == NUMBER)
			{
				_min = cast( (_minObject = _elm[0]), Number);
				_max = cast( (_maxObject = _elm[N]), Number);
				
				var ss:Int = 0, x:Number;
				for each (x in _elm) {
					_sum += x;
					ss += x*x;
				}
				_stdev = Math.sqrt(ss/_num - average*average);
			}
			else
			{
				_minObject = _elm[0];
				_maxObject = _elm[N];
			}
		}
		
		/**
		 * Tests for equality between two values. This method is necessary
		 * because the <code>==</code> operator checks object equality and
		 * not value equality for <code>Date</code> instances.
		 * @param a the first object to compare
		 * @param b the second object to compare
		 * @returns true if the object values are equal, false otherwise
		 */
		public static function equal(a:Dynamic, b:Dynamic):Bool
		{
			if (Std.is( a, Date) && Std.is( b, Date)) {
				return (cast( a, Date)).time == (cast( b, Date)).time;
			} else {
				return a == b;
			}
		}
		
	} // end of class Stats
