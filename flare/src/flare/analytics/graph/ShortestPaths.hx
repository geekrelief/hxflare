package flare.analytics.graph;

	import flare.animate.Transitioner;
	import flare.util.Property;
	import flare.util.heap.FibonacciHeap;
	import flare.util.heap.HeapNode;
	import flare.vis.data.Data;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.Operator;
	
	/**
	 * Calculates the shortest paths to a source node using Dijkstra's algorithm.
	 * Nodes are annotated with both the total distance and their incoming edge
	 * along the shortest path.
	 */
	class ShortestPaths extends Operator
	{
		public var distanceField(getDistanceField, setDistanceField) : String;
		public var edgeWeight(getEdgeWeight, setEdgeWeight) : Dynamic;
		public var incomingField(getIncomingField, setIncomingField) : String;
		public var onpathField(getOnpathField, setOnpathField) : String;
		private var _d:Property ;
		private var _p:Property ;
		private var _e:Property ;
		private var _w:Dynamic ;
		
		/** The source node from which to compute the shortest paths. */
		public var source:NodeSprite;
		
		/** A function determining edge weights used in the shortest path
		 *  calculation. When setting this value, one can pass in either a
		 *  Function, which should take an EdgeSprite as input and return a
		 *  Number as output, or a String, in which case the string will be
		 *  used as a property name from which to retrieve the edge weight
		 *  value from an EdgeSprite instance. If the value is null (the
		 *  default) all edges will be assumed to have weight 1.
		 *  
		 *  <p><b>NOTE:</b> Edge weights must be greater than or equal to zero!
		 *  </p> */
		public function getEdgeWeight():Dynamic { return _w; }
		public function setEdgeWeight(w:Dynamic):Dynamic {
			if (w==null) {
				_w = null;
			} else if (Std.is( w, String)) {
				_w = Property._S_(String(w)).getValue;
			} else if (Std.is( w, Function)) {
				_w = w;
			} else {
				throw new Error("Unrecognized edgeWeight value. " +
					"The value should be a Function or String.");
			}
			return w;
		}
		
		/** The property in which to store the link distance. This property
		 *  is used to annotate nodes with the minimum link distance to one of
		 *  the source nodes. The default value is "props.distance". */
		public function getDistanceField():String { return _d.name; }
		public function setDistanceField(f:String):String { _d = Property._S_(f); 	return f;}
		
		/** The property in which to store incoming edges along a shortest
		 *  path. This property is used to annotate nodes with the incoming
		 *  along a shortest path from one of the source nodes. By following
		 *  sequential incoming edges, one can recreate the shortest path from
		 *  the nearest source node. The default value is "props.incoming". */
		public function getIncomingField():String { return _p.name; }
		public function setIncomingField(f:String):String { _p = Property._S_(f); 	return f;}
		
		/** The property in which to store a path inclusion flag for edges.
		 *  This property is used to mark edges as belonging to one of the
		 *  computed shortest paths: <code>true</code> indicates that the edge
		 *  participates in a shortest path, <code>false</code> indicates that
		 *  the edge does not lie along a shortest path. The default value is
		 *  "props.onpath". */
		public function getOnpathField():String { return _p.name; }
		public function setOnpathField(f:String):String { _p = Property._S_(f); 	return f;}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new ShortestPaths operator.
		 * @param source the source node from which to measure shortest paths
		 * @param edgeWeight the edge weight values. This can either be a
		 *  <code>Function</code> that returns weight values or a
		 *  <code>String</code> providing the name of a property to look up on
		 *  <code>EdgeSprite</code> instances.
		 */
		public function ShortestPaths(source:NodeSprite=null,
			edgeWeight:*=null)
		{
			this.source = source;
			this.edgeWeight = edgeWeight;
		}
		
		/** @inheritDoc */
		public override function operate(t:Transitioner=null):void
		{
			calculate(visualization.data, source, _w);
		