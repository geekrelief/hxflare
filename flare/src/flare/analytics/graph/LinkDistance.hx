package flare.analytics.graph;

	import flare.animate.Transitioner;
	import flare.util.Property;
	import flare.vis.data.Data;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.Operator;
	
	/**
	 * Calculates the link distance from a source node based on a breadth-first
	 * traversal. Link distance is calculated as the smallest number of edges
	 * connecting a node to a source node. Any edge weights are ignored, to
	 * include weighted edges in the calculation, use the
	 * <code>ShortestPaths</code> operator instead.
	 * 
	 * </p>Nodes are annotated with both the computed distance and the incoming
	 * edge in the shortest link distance path to a source node. Edges are
	 * annotated with a Boolean value indicating whether or not the edge lies
	 * along one of these computed shortest paths.</p>
	 */
	class LinkDistance extends Operator
	{
		public var distanceField(getDistanceField, setDistanceField) : String;
		public var incomingField(getIncomingField, setIncomingField) : String;
		public var links(getLinks, setLinks) : Int;
		public var onpathField(getOnpathField, setOnpathField) : String;
		private var _d:Property ;
		private var _p:Property ;
		private var _e:Property ;
		private var _links:Int ;
		
		/** The roots of the breadth-first search. The elements of the array
		 *  should either be NodeSprite instances or integer indices into
		 *  the node array. */
		public var sources:Array<Dynamic>;
		
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
		
		/** The link type to consider when calculating link distance. Should
		 *  be one of <code>NodeSprite.GRAPH_LINKS</code>,
		 *  <code>NodeSprite.IN_LINKS</code>, or
		 *  <code>NodeSprite.OUT_LINKS</code>. */
		public function getLinks():Int { return _links; }
		public function setLinks(linkType:Int):Int {
			if (linkType == NodeSprite.GRAPH_LINKS ||
				linkType == NodeSprite.IN_LINKS ||
				linkType == NodeSprite.OUT_LINKS) 
			{
				_links = linkType;
			} else {
				throw new Error("Unsupported link type: "+linkType);
			}
			return linkType;
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new LinkDistance operator.
		 * @param sources an Array specifying the roots of the breadth-first
		 *  search. The elements of the array should either be
		 *  <code>NodeSprite</code> instances or integer indices into the node
		 *  array.
		 */
		public function new(?sources:Array<Dynamic>=null)
		{
			
			_d = Property._S_("props.distance");
			_p = Property._S_("props.incoming");
			_e = Property._S_("props.onpath");
			_links = NodeSprite.GRAPH_LINKS;
			this.sources = sources;
		}
		
		/** @inheritDoc */
		public override function operate(?t:Transitioner=null):Void
		{
			calculate(visualization.data, sources);
		}
			
		/**
		 * Calculates link distances from a set of source nodes for for each
		 * node in the graph. Each node in the graph will be annotated with
		 * its link distance from the nearest source node.
		 * @param data the graph to calculate distances for
		 * @param sources one or more source nodes from which to measure the
		 *  distance. This input can either be a single node or an array of
		 *  nodes. Nodes can be indicated as either a <code>NodeSprite</code>
		 *  instance or an integer index into the <code>data.nodes</code>
		 *  property.
		 */
		public function calculate(data:Data, sources:Dynamic):Void
		{
			var i:Int, n:NodeSprite;
			data.edges.setProperty(_e.name, false);
			data.nodes.visit(function(n:NodeSprite):Void {
				_d.setValue(n, Number.POSITIVE_INFINITY);
				_p.setValue(n, null);
			});
						
			// initialize queue
			var roots:Array<Dynamic> = Std.is( sources, Array) ? cast( sources, Array) : [sources];
			var queue:Array<Dynamic> = [];
			for (i in 0...roots.length) {
				var r:Dynamic = roots[i];
				if (Std.is( r, NodeSprite)) {
					n = NodeSprite(r);
				} else if (Std.is( r, int)) {
					n = data.nodes[int(r)];
				}
				queue.push(n);
				_d.setValue(n, 0);
			}
			
			while (queue.length > 0) {
				var u:NodeSprite = queue.shift();
				var du:Int = _d.getValue(u) + 1;
				u.visitEdges(function(e:EdgeSprite):Void {
					var v:NodeSprite = e.other(u);
					var d:Int = _d.getValue(v);
					if (!isFinite(d)) {
						queue.push(v);
						_d.setValue(v, du); 
						_p.setValue(v, e);
					} else if (d > du) {
						_d.setValue(v, du);
						_p.setValue(v, e);
					}
				}, _links);
			}
			
			data.nodes.visit(function(n:NodeSprite):Void {
				var e:EdgeSprite = _p.getValue(n);
				if (e) _e.setValue(e, true);
			});
		}
		
	} // end of class LinkDistance
