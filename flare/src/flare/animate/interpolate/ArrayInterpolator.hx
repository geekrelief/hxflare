package flare.animate.interpolate;

	import flare.util.Arrays;
	
	/**
	 * Interpolator for numeric <code>Array</code> values. Each value
	 * contained in the array should be a numeric (<code>Number</code> or
	 * <code>int</code>) value.
	 */
	class ArrayInterpolator extends Interpolator
	{
		private var _start:Array<Dynamic>;
		private var _end:Array<Dynamic>;
		private var _cur:Array<Dynamic>;
		
		/**
		 * Creates a new ArrayInterpolator.
		 * @param target the object whose property is being interpolated
		 * @param property the property to interpolate
		 * @param start the starting array of values to interpolate from
		 * @param end the target array to interpolate to. This should be an
		 *  array of numerical values.
		 */
		public function new(target:Dynamic, property:String,
		                                  start:Dynamic, end:Dynamic)
		{
			super(target, property, start, end);
		}
		
		/**
		 * Initializes this interpolator.
		 * @param start the starting value of the interpolation
		 * @param end the target value of the interpolation
		 */
		public override function init(start:Dynamic, end:Dynamic) : Void
		{
			_end = cast( end, Array);
			if (!end) throw new Error("Target array is null!");
			if (_start && _start.length != _end.length) _start = null;
			_start = Arrays.copy(cast( start, Array), _start);
			
			if (_start.length != _end.length)
				throw new Error("Array dimensions don't match");
				
			var cur:Array<Dynamic> = cast( _prop.getValue(_target), Array);
			if (cur == end) cur = null;
			_cur = Arrays.copy(_start, cur);
		}
		
		/**
		 * Calculate and set an interpolated property value.
		 * @param f the interpolation fraction (typically between 0 and 1)
		 */
		public override function interpolate(f:Number) : Void
		{
			for (i in 0..._cur.length) {
				_cur[i] = _start[i] + f*(_end[i] - _start[i]);
			}
			_prop.setValue(_target, _cur);
		}
		
	} // end of class ArrayInterpolator
