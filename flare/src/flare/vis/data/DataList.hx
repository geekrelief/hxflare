package flare.vis.data;

	import flare.animate.Transitioner;
	import flare.util.Arrays;
	import flare.util.Filter;
	import flare.util.IEvaluable;
	import flare.util.Property;
	import flare.util.Sort;
	import flare.util.Stats;
	import flare.util.math.DenseMatrix;
	import flare.util.math.IMatrix;
	import flare.vis.events.DataEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.flash_proxy;
	import flash.utils.Dictionary;
	import flash.utils.Proxy;

	/*[Event(name="add",    type="flare.vis.events.DataEvent")]*/
	/*[Event(name="remove", type="flare.vis.events.DataEvent")]*/

	/**
	 * Data structure for a collection of <code>DataSprite</code> instances.
	 * Items contained in this list can be accessed using array notation
	 * (<code>[]</code>), iterated over using the <code>for each</code>
	 * construct, or can be processed by passing a visitor function to the
	 * <code>visit</code> method.
	 * 
	 * <p>Data lists provide methods for sorting elements both in a one-time
	 * and persistent fashion, for setting the properties of contained
	 * items in a batch-processing style (see the <code>setProperty</code>
	 * and <code>setProperties</code> methods), and for computing and
	 * caching summary statistics of data variables (see the
	 * <code>stats</code> method.</p>
	 * 
	 * <p>Data lists also support listeners for add and remove events. These
	 * events are fired <em>before</em> the add or remove is executed. These
	 * data events can be canceled by calling <code>preventDefault()</code>
	 * on the <code>DataEvent</code> object, thereby preventing the add or
	 * remove from being performed. Using this mechanism, clients can add
	 * custom constraints on the contents of a data list by adding new
	 * listeners that monitor add and remove events and cancel them when
	 * desired.</p>
	 */
	class DataList extends Proxy implements IEventDispatcher
	{
		public var length(getLength, null) : Int ;
		public var list(getList, null) : Array<Dynamic> ;
		public var name(getName, null) : String ;
		public var sort(getSort, setSort) : Dynamic;
		private var _dispatch:EventDispatcher ;
		
		/** Hashed set of items in the data list. */
		private var _map:Dictionary ;
		/** Array of items in the data set. */
		private var _list:Array<Dynamic> ;
		/** Default property values to be applied to new items. */
		private var _defs:Dynamic ;
		/** Cache of Stats objects for item properties. */
		private var _stats:Dynamic ;
		/** The underlying array storing the list. */
		private function getList():Array<Dynamic> { return _list; }
		
		/** The name of this data list. */
		public function getName():String { return _name; }
		private var _name:String;
		
		/** Internal count of visitors traversing the current list. */
		private var _visiting:Int ;
		private var _sort:Sort;
		
		/** The number of items contained in this list. */
		public function getLength():Int { return _list.length; }
		
		/** A standing sort criteria for items in the list. */
		public function getSort():Dynamic { return _sort; }
		public function setSort(s:Dynamic):Dynamic {
			_sort = s==null ? s : (Std.is( s, Sort) ? Sort(s) : new Sort(s));
			if (_sort != null) _sort.sort(_list);
			return s;
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new DataList instance. 
		 * @param editable indicates if this list should be publicly editable.
		 */
		public function new(name:String) {
			
			_dispatch = new EventDispatcher();
			_map = new Dictionary();
			_list = [];
			_defs = null;
			_stats = {};
			_visiting = 0;
			_name = name;
		}
		
		// -- Basic Operations: Contains, Add, Remove, Clear ------------------
		
		/**
		 * Indicates if the given object is contained in this list.
		 * @param d the object to check for containment
		 * @return true if the list contains the object, false otherwise.
		 */
		public function contains(d:DataSprite):Bool
		{
			return (_map[d] != undefined);
		}
		
		/**
		 * Add a DataSprite to the list.
		 * @param d the DataSprite to add
		 * @return the added DataSprite, or null if the add failed
		 */
		public function add(d:DataSprite):DataSprite
		{
			if (!fireEvent(DataEvent.ADD, d))
				return null;
			
			_map[d] = _list.length;
			_stats = {};
			if (_sort != null) {
				var idx:Int = Arrays.binarySearch(_list, d, null,
				                                  _sort.comparator);
				_list.splice(-(idx+1), 0, d);
			} else {
				_list.push(d);
			}
			return d;
		}
		
		/**
		 * Remove a data sprite from the list.
		 * @param ds the DataSprite to remove
		 * @return true if the object was found and removed, false otherwise
		 */
		public function remove(d:DataSprite):Bool
		{
			if (_map[d] == undefined) return false;
			if (!fireEvent(DataEvent.REMOVE, d))
				return false;
			if (_visiting > 0) {
				// if called from a visitor, use a copy-on-write strategy
				_list = Arrays.copy(_list);
				_visiting = 0; // reset the visitor count
			}
			Arrays.remove(_list, d);
			delete _map[d];
			_stats = {};	
			return true;
		}
		
		/**
		 * Remove a DataSprite from the list.
		 * @param idx the index of the DataSprite to remove
		 * @return the removed DataSprite
		 */
		public function removeAt(idx:Int):DataSprite
		{
			var d:DataSprite = _list[idx];
			if (d == null || !fireEvent(DataEvent.REMOVE, d))
				return null;
			
			Arrays.removeAt(_list, idx);
			if (d != null) {
				delete _map[d];
				_stats = {};
			}
			return d;
		}
		
		/**
		 * Remove all DataSprites from this list.
		 */
		public function clear():Bool
		{
			if (_list.length == 0) return true;
			if (!fireEvent(DataEvent.REMOVE, _list))
				return false;
			_map = new Dictionary();
			_list = [];
			_stats = {};
			return true;
		}
		
		// -- Data Representations --------------------------------------------
		
		/**
		 * Returns an array of data objects for each item in this data list.
		 * Data objects are retrieved from the "data" property for each item.
		 * @return an array of data objects for items in this data list
		 */
		public function toDataArray():Array<Dynamic>
		{
			var a:Array<Dynamic> = new Array(_list.length);
			for (i in 0...a.length) {
				a[i] = _list[i].data;
			}
			return a;
		}
		
		/**
		 * Creates a new adjacency matrix representing the connections between
		 * items in this DataList. This method should only be applied when the
		 * items contained in this list are <code>NodeSprite</code> instances.
		 * The method takes an optional function to compute edge weights.
		 * @param w the edge weight function. This function should take an
		 *  <code>EdgeSprite</code> as input and return a <code>Number</code>.
		 * @param mat a matrix instance in which to store the adjacency matrix
		 *  values. If this value is null, a new <code>DenseMatrix</code> will
		 *  be constructed.
		 * @return the adjacency matrix
		 */
		public function adjacencyMatrix(?w:Dynamic=null,
			?mat:IMatrix=null):IMatrix
		{
			var N:Int = length, k:Int = 0;
			
			// build dictionary of nodes
			var idx:Dictionary = new Dictionary();
			for (k in 0...N) {
				if (!(Std.is( _list[k], NodeSprite)))
					throw new Error("Only NodeSprites can be used to " + 
							"create an adjacency matrix.");
				idx[_list[k]] = k;
			}
			
			// initialize matrix
			if (mat) {
				mat.init(N, N)
			} else {
				mat = new DenseMatrix(N, N);
			}
			
			// build adjacency matrix
			for each (var n:NodeSprite in _list) {
				var i:Int = idx[n];
				n.visitEdges(function(e:EdgeSprite):Void {
					if (idx[e.target] == undefined) return;
					var j:Int = idx[e.target];
					var v:Int = w==null ? 1 : w(e);
					mat.set(i,j,v); mat.set(j,i,v);
				}, NodeSprite.OUT_LINKS);
			}
			return mat;
		}
		
		/**
		 * Creates a new distance matrix based on a distance function.
		 * @param d the distance function. This should take two
		 *  <code>DataSprite</code> instances and return a <code>Number</code>
		 * @param mat a matrix instance in which to store the adjacency matrix
		 *  values. If this value is null, a new <code>DenseMatrix</code> will
		 *  be constructed.
		 * @return the distance matrix
		 */
		public function distanceMatrix(d:Dynamic, ?mat:IMatrix=null):IMatrix
		{
			var N:Int = length, i:UInt, j:UInt;
			
			if (mat) {
				mat.init(N, N);
			} else {
				mat = new DenseMatrix(N, N);
			}
			for (i in 0...N) {
				for (j in 1...N) {
					var v:Int = d(_list[i], _list[j]);
					mat.set(i,j,v); mat.set(j,i,v);
				}
			}
			return mat;
		}
		

		// -- Sort ------------------------------------------------------------
		
		/**
		 * Sort DataSprites according to their properties. This method performs
		 * a one-time sorting. To establish a consistent sort order robust over
		 * the addition of new items, use the <code>sort</code> property.
		 * @param args the sort arguments.
		 * 	If a String is provided, the data will be sorted in ascending order
		 *   according to the data field named by the string.
		 *  If an Array is provided, the data will be sorted according to the
		 *   fields in the array. In addition, field names can optionally
		 *   be followed by a boolean value. If true, the data is sorted in
		 *   ascending order (the default). If false, the data is sorted in
		 *   descending order.
		 */
		public function sortBy(args:Array<Dynamic>):Void
		{
			if (args.length == 0) return;
			if (Std.is( args[0], Array)) args = args[0];
			
			var f:Dynamic = Sort._S_(args);
			_list.sort(f);
		}

		// -- Visitation ------------------------------------------------------
		
		/**
		 * Iterates over the contents of the list, invoking a visitor function
		 * on each element of the list. If the visitor function returns a
		 * Boolean true value, the iteration will stop with an early exit.
		 * @param visitor the visitor function to be invoked on each item
		 * @param filter an optional boolean-valued function indicating which
		 *  items should be visited
		 * @param reverse optional flag indicating if the list should be
		 *  visited in reverse order
		 * @return true if the visitation was interrupted with an early exit
		 */		
		public function visit(visitor:Function, filter:*=null,
			reverse:Boolean=false):Boolean
		{
			_visiting++; // mark a visit in process
			var a:Array<Dynamic> ; // use our own reference to the list
			var i:UInt, b:Bool ;
			var f:Dynamic ;
			
			if (reverse && f==null) {
				for (i=a.length; --i>=0;)
					if (visitor(a[i]) as Boolean) {
						b = true; break;
					}
			