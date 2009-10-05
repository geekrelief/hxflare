package flare.util.math;

	import flash.utils.Dictionary;
	
	/**
	 * A matrix of numbers implemented using a hashtable of values.
	 */
	class SparseMatrix implements IMatrix
	{
		public var cols(getCols, null) : Int ;
		public var nnz(getNnz, null) : Int ;
		public var rows(getRows, null) : Int ;
		public var sum(getSum, null) : Number ;
		public var sumsq(getSumsq, null) : Number ;
		private var _r:Int;
		private var _c:Int;
		private var _nnz:Int;
		private var _v:Dictionary;
		
		/** @inheritDoc */
		public function getRows():Int { return _r; }
		/** @inheritDoc */
		public function getCols():Int { return _c; }
		/** @inheritDoc */
		public function getNnz():Int {
			var count:Int = 0;
			for (var key:String in _v)
				++count;
			return count;
		}
		/** @inheritDoc */
		public function getSum():Number {
			var sum:Int = 0;
			for (var key:String in _v)
				sum += _v[key];
			return sum;
		}
		/** @inheritDoc */
		public function getSumsq():Number {
			var sumsq:Int = 0, v:Number;
			for (var key:String in _v) {
				v = _v[key];
				sumsq += v*v;
			}
			return sumsq;
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new SparseMatrix with the given size. 
		 * @param rows the number of rows
		 * @param cols the number of columns
		 */
		public function new(rows:Int, cols:Int) {
			init(rows, cols);
		}
		
		/** @inheritDoc */
		public function clone():IMatrix {
			var m:SparseMatrix = new SparseMatrix(_r, _c);
			for (var key:String in _v)
				m._v[key] = _v[key];
			return m;
		}
		
		/** @inheritDoc */
		public function like(rows:Int, cols:Int):IMatrix {
			return new SparseMatrix(rows, cols);
		}
		
		/** @inheritDoc */
		public function init(rows:Int, cols:Int):Void {
			_r = rows;
			_c = cols;
			_nnz = 0;
			_v = new Dictionary();
		}
		
		/** @inheritDoc */
		public function get(i:int, j:int):Number {
			var v:Dynamic ;
			return (v ? Number(v) : 0);
		}
		
		/** @inheritDoc */
		public function set(i:int, j:int, v:Number):Number {
			var key:int = i*_c + j;
			if (v==0) {
				delete _v[key];
			