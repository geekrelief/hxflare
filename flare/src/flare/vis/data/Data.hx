package flare.vis.data;

	import flare.data.DataField;
	import flare.data.DataSchema;
	import flare.data.DataSet;
	import flare.util.Arrays;
	import flare.util.Property;
	import flare.util.Sort;
	import flare.vis.events.DataEvent;
	
	import flash.events.EventDispatcher;
	
	/*[Event(name="add",    type="flare.vis.events.DataEvent")]*/
	/*[Event(name="remove", type="flare.vis.events.DataEvent")]*/
	
	/**
	 * Data structure for managing a collection of visual data objects. The
	 * Data class manages both unstructured data and data organized in a
	 * general graph (or network structure), maintaining collections of both
	 * nodes and edges. Collections of data sprites are maintained by
	 * <code>DataList</code> instances. The individual data lists provide
	 * methods for accessing, manipulating, sorting, and generating statistics
	 * about the visual data objects.
	 * 
	 * <p>In addition to the required <code>nodes</code> and <code>edges</code>
	 * lists, clients can add new custom lists (for example, to manage a
	 * selected subset of the data) by using the <code>addGroup</code> method
	 * and then accessing the list with the <code>group</code> method.
	 * Individual data groups can be directly processed by many of the
	 * visualization operators in the <code>flare.vis.operator</code> package.
	 * </p>
	 * 
	 * <p>While Data objects maintain a collection of visual DataSprites,
	 * they are not themselves visual object containers. Instead a Data
	 * instance is used as input to a <code>Visualization</code> that
	 * is responsible for processing the DataSprite instances and adding
	 * them to the Flash display list.</p>
	 * 
	 * <p>The data class also manages the automatic generation of spanning
	 * trees over a graph when needed for tree-based operations (such as tree
	 * layout algorithms). This implemented by a
	 * <code>flare.analytics.graph.SpanningTree</code> operator which can be
	 * parameterized using the <code>treePolicy</code>,
	 * <code>treeEdgeWeight</code>, and <code>root</code> properties of this
	 * class. Alternatively, clients can create their own spanning trees as
	 * a <code>Tree</code instance and set this as the spanning tree.</p>
	 * 
	 * @see flare.vis.data.DataList
	 * @see flare.analytics.graph.SpanningTree
	 */
	class Data extends EventDispatcher
	{
		public var edges(getEdges, null) : DataList ;
		public var length(getLength, null) : Int ;
		public var nodes(getNodes, null) : DataList ;
		/** Constant indicating the nodes in a Data object. */
		inline public static var NODES:String = "nodes";
		/** Constant indicating the edges in a Data object. */
		inline public static var EDGES:String = "edges";
		
		/** Internal list of NodeSprites. */
		public var _nodes:DataList ;
		/** Internal list of EdgeSprites. */
		public var _edges:DataList ;
		/** Internal set of data groups. */
		public var _groups:Dynamic;
		
		/** The total number of items (nodes and edges) in the data. */
		public function getLength():Int { return _nodes.length + _edges.length; }
		
		/** The collection of NodeSprites. */
		public function getNodes():DataList { return _nodes; }
		/** The collection of EdgeSprites. */
		public function getEdges():DataList { return _edges; }
		
		/** The default directedness of new edges. */
		public var directedEdges:Bool;
		
		
		// -- Methods ---------------------------------------------------------

		/**
		 * Creates a new Data instance.
		 * @param directedEdges the default directedness of new edges
		 */
		public function new(?directedEdges:Bool=false) {
			
			_nodes = new DataList(NODES);
			_edges = new DataList(EDGES);
			this.directedEdges = directedEdges;
			_groups = { nodes: _nodes, edges: _edges };
			
			// add listeners to enforce type and connectivity constraints
			_nodes.addEventListener(DataEvent.ADD, onAddNode);
			_nodes.addEventListener(DataEvent.REMOVE, onRemoveNode);
			_edges.addEventListener(DataEvent.ADD, onAddEdge);
			_edges.addEventListener(DataEvent.REMOVE, onRemoveEdge);
		}
		
		/**
		 * Creates a new Data instance from an array of tuples. The object in
		 * the array will become the data objects for NodeSprites.
		 * @param a an Array of data objects
		 * @return a new Data instance, with NodeSprites populated with the
		 *  input data.
		 */
		public static function fromArray(a:Array<Dynamic>):Data {
			var d:Data = new Data();
			for each (var tuple:Dynamic in a) {
				d.addNode(tuple);
			}
			return d;
		}
		
		/**
		 * Creates a new Data instance from a data set.
		 * @param ds a DataSet to visualize. For example, this data set may be
		 *  loaded using a data converter in the flare.data library.
		 * @return a new Data instance, with NodeSprites and EdgeSprites
		 *  populated with the input data.
		 */
		public static function fromDataSet(ds:DataSet):Data {			
			var d:Data = new Data(), i:Int;
			var schema:DataSchema, f:DataField;
			
			// copy node data defaults
			if ((schema = ds.nodes.schema)) {
				for (i in 0...schema.numFields) {
					f = schema.getFieldAt(i);
					if (f.defaultValue)
						d.nodes.setDefault("data."+f.name, f.defaultValue);
				}
			}
			// add node data
			for each (var tuple:Dynamic in ds.nodes.data) {
				d.addNode(tuple);
			}
			// exit if there is no edge data
			if (!ds.edges) return d;
				
			var nodes:DataList = d.nodes, map:Dynamic = {};
			var id:String = "id"; // TODO: generalize these fields?
			var src:String = "source";
			var trg:String = "target";
			var dir:String = "directed";
			
			// build node map
			for (i in 0...nodes.length) {
				map[nodes[i].data[id]] = nodes[i];
			}
			
			// copy edge data defaults
			if ((schema = ds.edges.schema)) {
				for (i in 0...schema.numFields) {
					f = schema.getFieldAt(i);
					if (f.defaultValue)
						d.edges.setDefault("data."+f.name, f.defaultValue);
				}
				if ((f = schema.getFieldByName(dir))) {
					d.directedEdges = Boolean(f.defaultValue);
				}
			}
			// add edge data
			for each (tuple in ds.edges.data) {
				var n1:NodeSprite = map[tuple[src]];
				if (!n1) throw new Error("Missing node id="+tuple[src]);
				var n2:NodeSprite = map[tuple[trg]];
				if (!n2) throw new Error("Missing node id="+tuple[trg]);
				d.addEdgeFor(n1, n2, tuple[dir], tuple);
			}
			
			return d;
		}		
		
		// -- Group Management ---------------------------------
		
		/**
		 * Adds a new data group. If a group of the same name already exists,
		 * it will be replaced, except for the groups "nodes" and "edges",
		 * which can not be replaced. 
		 * @param name the name of the group to add
		 * @param group the data list to add, if null a new,
		 *  empty <code>DataList</code> instance will be created.
		 * @return the added data group
		 */
		public function addGroup(name:String, ?group:DataList=null):DataList
		{
			if (name=="nodes" || name=="edges") {
				throw new ArgumentError("Illegal group name. "
					+ "\"nodes\" and \"edges\" are reserved names.");
			}
			if (group==null) group = new DataList(name);
			_groups[name] = group;
			return group;
		}
		
		/**
		 * Removes a data group. An error will be thrown if the caller
		 * attempts to remove the groups "nodes" or "edges". 
		 * @param name the name of the group to remove
		 * @return the removed data group
		 */
		public function removeGroup(name:String):DataList
		{
			if (name=="nodes" || name=="edges") {
				throw new ArgumentError("Illegal group name. "
					+ "\"nodes\" and \"edges\" are reserved names.");
			}
			var group:DataList = _groups[name];
			if (group) delete _groups[name];
			return group;
		}
		
		/**
		 * Retrieves the data group with the given name. 
		 * @param name the name of the group
		 * @return the data group
		 */
		public function group(name:String):DataList
		{
			return cast( _groups[name], DataList);
		}
		
		// -- Containment --------------------------------------
		
		/**
		 * Indicates if this Data object contains the input DataSprite.
		 * @param d the DataSprite to check for containment
		 * @return true if the sprite is in this data collection, false
		 *  otherwise.
		 */
		public function contains(d:DataSprite):Bool
		{
			return (_nodes.contains(d) || _edges.contains(d));
		}
		
		// -- Add ----------------------------------------------
		
		/**
		 * Adds a node to this data collection.
		 * @param d either a data tuple or NodeSprite object. If the input is
		 *  a non-null data tuple, this will become the new node's
		 *  <code>data</code> property. If the input is a NodeSprite, it will
		 *  be directly added to the collection.
		 * @return the newly added NodeSprite
		 */
		public function addNode(?d:Dynamic=null):NodeSprite
		{
			var ns:NodeSprite = NodeSprite(Std.is( d, NodeSprite) ? d : newNode(d));
			_nodes.add(ns);
			return ns;
		}
		
		/**
		 * Add an edge to this data set. The input must be of type EdgeSprite,
		 * and must have both source and target nodes that are already in
		 * this data set. If any of these conditions are not met, this method
		 * will return null. Note that no exception will be thrown on failures.
		 * @param e the EdgeSprite to add
		 * @return the newly added EdgeSprite
		 */
		public function addEdge(e:EdgeSprite):EdgeSprite
		{
			return EdgeSprite(_edges.add(e));
		}
		
		/**
		 * Generates edges for this data collection that connect the nodes
		 * according to the input properties. The nodes are sorted by the
		 * sort argument and grouped by the group-by argument. All nodes
		 * with the same group are sequentially connected to each other in
		 * sorted order by new edges. This method is useful for generating
		 * line charts from a plot of nodes.
		 * <p>If an edge already exists between nodes, by default this method
		 * will not add a new edge. Use the <code>ignoreExistingEdges</code>
		 * argument to change this behavior. </p>
		 * 
		 * @param sortBy the criteria for sorting the nodes, using the format
		 *  of <code>flare.util.Sort</code>. The input can either be a string
		 *  with a single property name, or an array of property names.  Items
		 *  are sorted in ascending order by default, prefix a property name
		 *  with a "-" (minus) character to sort in descending order.
		 * @param groupBy the criteria for grouping the nodes, using the format
		 *  of <code>flare.util.Sort</code>. The input can either be a string
		 *  with a single property name, or an array of property names. Items
		 *  are sorted in ascending order by default, prefix a property name
		 *  with a "-" (minus) character to sort in descending order.
		 * @param ignoreExistingEdges if false (the default), this method will
		 *  not create a new edge if one already exists between two nodes. If
		 *  true, new edges will be created regardless.
		 */
		public function createEdges(sortBy:*=null, groupBy:*=null,
			ignoreExistingEdges:Boolean=false):void
		{
			// create arrays and sort criteria
			var a:Array<Dynamic> ;
			var g:Array<Dynamic> ;
			var len:Int ;
			if (sortBy is Array) {
				var s:Array<Dynamic> ;
				for (var i:UInt; i<s.length; ++i)
					g.push(s[i]);
			} else {
				g.push(sortBy);
			