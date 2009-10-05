package flare.util.math;

	/**
	 * A matrix of numbers implemented using an array of values.
	 */
	class DenseMatrix implements IMatrix
	{
		public var cols(getCols, null) : Int ;
		public var nnz(getNnz, null) : Int ;
		public var rows(getRows, null) : Int ;
		public var sum(getSum, null) : Number ;
		public var sumsq(getSumsq, null) : Number ;
		public var values(getValues, null) : Array<Dynamic> ;
		private var _r:Int;
		private var _c:Int;
		private var _v:Array<Dynamic>;
		
		/** The underlying array of values */
		public function getValues():Array<Dynamic> { return _v; }
		/** @inheritDoc */
		public function getRows():Int { return _r; }
		/** @inheritDoc */
		public function getCols():Int { return _c; }
		/** @inheritDoc */
		public function getNnz():Int {
			var nz:Int = 0;
			for (i in 0..._v.length) {
				if (_v[i] != 0) ++nz;
			}
			return nz;
		}
		/** @inheritDoc */
		public function getSum():Number {
			var sum:Int = 0;
			for (var i:UInt=0; i<_v.length; ++i)
				sum += _v[i];
			return sum;
		}
		/** @inheritDoc */
		public function getSumsq():Number {
			var sumsq:Int = 0;
			for (var i:UInt=0; i<_v.length; ++i)
				sumsq += _v[i]*_v[i];
			return sumsq;
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new DenseMatrix with the given size. 
		 * @param rows the number of rows
		 * @param cols the number of columns
		 */
		public function new(rows:Int, cols:Int) {
			init(rows, cols);
		}
		
		/** @inheritDoc */
		public function clone():IMatrix {
			var m:DenseMatrix = new DenseMatrix(_r, _c);
			var v:Array<Dynamic> = m.values;
			for (i in 0..._v.length) {
				v[i] = _v[i];
			}
			return m;
		}
		
		/** @inheritDoc */
		public function like(rows:Int, cols:Int):IMatrix {
			return new DenseMatrix(rows, cols);
		}
		
		/** @inheritDoc */
		public function init(rows:Int, cols:Int):Void {
			_r = rows;
			_c = cols;
			_v = new Array(_r * _c);
			for (var i:UInt=0; i<_v.length; ++i) _v[i]=0;
		}
		
		/** @inheritDoc */
		public function get(i:int, j:int):Number {
			return _v[i*_c + j];
		}
		
		/** @inheritDoc */
		public function set(i:int, j:int, v:Number):Number {
			_v[i*_c + j] = v;
			return v;
		