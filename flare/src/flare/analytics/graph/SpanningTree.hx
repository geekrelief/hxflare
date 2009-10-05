package flare.analytics.graph;

	import flare.animate.Transitioner;
	import flare.vis.Visualization;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.TreeBuilder;
	import flare.vis.operator.IOperator;
	import flare.vis.operator.Operator;

	/**
	 * Calculates a spanning tree for a graph structure. This operator can
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
	 * <p>This class extends the TreeBuilder class to also function as an
	 * operator that can be added to a visualization's operator list.</p>
	 */
	class SpanningTree extends TreeBuilder implements IOperator
	{
		public var enabled(getEnabled, setEnabled) : Bool;
		public var parameters(null, setParameters) : Dynamic;
		public var visualization(getVisualization, setVisualization) : Visualization;
		private var _vis:Visualization;
		private var _enabled:Bool;
		
		/** @inheritDoc */
		public function getVisualization():Visualization { return _vis; }
		public function setVisualization(v:Visualization):Visualization {
			_vis = v; setup();
			return v;
		}
		
		/** @inheritDoc */
		public function getEnabled():Bool { return _enabled; }
		public function setEnabled(b:Bool):Bool { _enabled = b; 	return b;}
		
		/** @inheritDoc */
		public function setParameters(params:Dynamic):Dynamic
		{
			Operator.applyParameters(this, params);
			return params;
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
		public function SpanningTree(policy:String=null,
			buildTree:Boolean=false, annotateEdges:Boolean=true,
			root:NodeSprite=null, edgeWeight:*=null)
		{
			super(policy, buildTree, annotateEdges, root, edgeWeight);
		}
		
		/** @inheritDoc */
		public function operate(t:Transitioner=null):void
		{
			super.calculate(visualization.data, root);
		