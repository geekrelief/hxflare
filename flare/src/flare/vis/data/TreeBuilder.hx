package flare.vis.data;

	import flare.util.IEvaluable;
	import flare.util.Property;
	import flare.util.heap.FibonacciHeap;
	import flare.util.heap.HeapNode;
	
	import flash.utils.Dictionary;

	/**
	 * Calculates a spanning tree for a graph structure. This class can
	 * create spanning trees by breadth-first search, depth-first search, or by
	 * computing a minimum spanning tree. The default is to find a minimum
	 * spanning tree, which in turn defaults to breadth-first search if no edge
	 * weight function is provided.
	 * 
	 * <p>This class can annotate graph edges as belonging to the spanning tree
	 * (done if the <code>annotateEdges</code> property is true), and can
	 * construct a <code>Tree</code> instance (done if the
	 * <code>buildTree<code> property is true). Generated <code>Tree<code>
	 * instances are stored in the <code>tree</code> property. Generated trees
	 * contain the original nodes and edges in the input graph, and any
	 * previous parent or child links for input nodes will be cleared and
	 * overwritten.</p>
	 * 
	 * <p>This class is intended as a support class for creating spanning trees
	 * for <code>flare.vis.data.Data</code> instances. To create annotated
	 * spanning trees for other purposes, see the
	 * <code>flare.analytics.graph.SpanningTree</code> class, which provides a
	 * tree builder that can also be used a visualization operator.</p>
	 */
	class TreeBuilder
	{
		public var edgeWeight(getEdgeWeight, setEdgeWeight) : Dynamic;
		public var links(getLinks, setLinks) : Int;
		public var policy(getPolicy, setPolicy) : String;
		public var spanningField(getSpanningField, setSpanningField) : String;
		public var tree(getTree, null) : Tree ;
		/** Policy for a spanning tree built using depth-first search. */
		inline public static var DEPTH_FIRST:String   = "depth-first";
		/** Policy for a spanning tree built using breadth-first search. */
		inline public static var BREADTH_FIRST:String = "breadth-first";
		/** Policy for building a minimum spanning tree. */
		inline public static var MINIMUM_SPAN:String  = "minimum-span";
		
		private var _s:Property ;
		private var _w:Dynamic ;
		private var _policy:String ;
		private var _links:Int ;
		private var _tree:Tree ;
		
		/** Flag indicating if a spanning tree instance should be created. */
		public var buildTree:Bool;
		/** Flag indicating if edges in the spanning tree should be annotated.
		 *  If so, the <code>spanningField</code> property will be set for
		 *  each edge in the graph. */
		public var annotateEdges:Bool;
		
		/** The tree created by this operator. */
		public function getTree():Tree { return _tree; }
		
		/** The traveral policy used to generate the spanning tree. Should be
		 *  one of DEPTH_FIRST, BREADTH_FIRST, or MINIMUM_SPAN (default). */
		public function getPolicy():String { return _policy; }
		public function setPolicy(p:String):String {
			if (p==DEPTH_FIRST || p==BREADTH_FIRST || p==MINIMUM_SPAN) {
				_policy = p;
			} else {
				throw new Error("Unrecognized policy: "+p);
			}
			return p;
		}
		
		/** The property with which to annotate edges that make up the spanning
		 *  tree. The default value is "props.spanning". This property is used
		 *  to annotate edges as "true" (if in the spanning forest) or "false"
		 *  (if not in the spanning forest). */
		public function getSpanningField():String { return _s.name; }
		public function setSpanningField(f:String):String { _s = Property._S_(f); 	return f;}
		
		/** The root node for the spanning tree. */
		public var root:NodeSprite;
		
		/** The link type to consider when constructing a spanning tree. Should
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
		
		/** A function determining edge weights used in the spanning tree
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
			} else if (Std.is( w, IEvaluable)) {
				_w = IEvaluable(w).eval;
			} else if (Std.is( w, Function)) {
				_w = w;
			} else {
				throw new Error("Unrecognized edgeWeight value. " +
					"The value should be a Function or String.");
			}
			return w;
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new SpanningTree operator
		 * @param policy the spanning tree creation policy. The default is
		 *  <code>SpanningTree.MINIMUM_SPAN</code>
		 * @param buildTree if true, this operator will build a new
		 *  <code>Tree</code> instance containing the spanning tree
		 * @param annotateEdges if true, this operator will annotate the
		 *  edges of the original graph as belonging to the spanning tree
		 * @param root the root node from which to compute the spanning tree
		 * @param edgeWeight the edge weight values. This can either be a
		 *  <code>Function</code> that returns weight values or a
		 *  <code>String</code> providing the name of a property to look up on
		 *  <code>EdgeSprite</code> instances.
		 */
		public function TreeBuilder(policy:String=null,
			buildTree:Boolean=true, annotateEdges:Boolean=false,
			root:NodeSprite=null, edgeWeight:*=null)
		{
			if (policy) this.policy = policy;
			this.buildTree = buildTree;
			this.annotateEdges = annotateEdges;
			this.root = root;
			this.edgeWeight = edgeWeight;
		}
		
		/**
		 * Calculates the spanning tree.
		 * @param data the data set containing a graph
		 * @param n the root of the spanning tree
		 */
		public function calculate(data:Data, n:NodeSprite):void
		{
			var w:Function = edgeWeight;
			if (n==null) { _tree = null; return; 