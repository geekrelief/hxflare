package flare.vis.operator.layout;

	import flare.util.Shapes;
	import flare.util.Sort;
	import flare.vis.data.Data;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.render.ShapeRenderer;
	
	import flash.geom.Rectangle;

	/**
	 * Layout that places nodes as circles compacted into a larger circle.
	 * 
	 * <p>Circle sizes are determined by a node's <code>size</code> property.
	 * It is assumed that the sizes are set <i>before</i> this operator is run,
	 * for example, by placing a <code>SizeEncoder</code> prior to this layout
	 * in an operator list.</p>
	 * 
	 * <p>If the <code>treeLayout</code> property is <code>false</code>, all
	 * nodes will be treated the same and the result will be a "bubble" chart.
	 * If the <code>treeLayout<code> property is <code>true<code>, circles will
	 * be nested inside each other according to the tree structure of the data.
	 * </p>
	 * 
	 * <p>The results of this layout can vary dramatically based on the sort
	 * order of the nodes. For example, sorting the nodes by the
	 * <code>size</code> property (in either ascending or descending order)
	 * can result in much cleaner layouts. Use the <code>sort</code> property
	 * of this class to set a preferred sorting routine. By default, this
	 * operator will not perform any sorting.</p>
	 * 
	 * <p>NOTE: This operator will set a node's <code>renderer</code> and
	 * <code>shape</code> properties, overriding any previous values.</p>
	 * 
	 * <p>The algorithm used to perform the circle packing is adapted from
	 * W. Wang, H. Wang, G. Dai, and H. Wang's <a
	 * href="http://portal.acm.org/citation.cfm?id=1124772.1124851">
	 * Visualization of large hierarchical data by circle packing</a>,
	 * ACM CHI 2006.</p>
	 */
	class CirclePackingLayout extends Layout
	{
		public var sort(getSort, setSort) : Dynamic;
		private var _sort:Sort ;
		private var _order:Int;
		private var _b:Rectangle ;
		
		/** The amount of spacing between neighboring circles.
		 *  The default value is 4 pixels. */
		public var spacing:Int ;
		
		/** Indicates if the view should be scaled to fit within the
		 *  display bounds. The default is true. */
		public var fitInBounds:Bool ;
		
		/** Indicates if a tree layout (circles nested within circles) should
		 *  be computed. The default is false. */
		public var treeLayout:Bool ;
		
		/** A sort criteria for ordering nodes in this layout.
		 *  Ordered nodes are placed in a spiral starting at the center.
		 *  The default is null, meaning no sorting is performed. */
		public function getSort():Dynamic { return _sort; }
		public function setSort(s:Dynamic):Dynamic {
			_sort = s==null ? s : (Std.is( s, Sort) ? Sort(s) : new Sort(s));
			return s;
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new CirclePackingLayout.
		 * @param spacing the minimum spacing between neighboring circles
		 * @param treeLayout if true, a hierarchical circles-within-circles
		 *  layout will be peformed; if false (the default) all nodes will be
		 *  considered equally
		 * @param sort a sort criteria for ordering nodes in the layout.
		 *  Ordered nodes are placed in a spiral starting at the center.
		 */
		public function CirclePackingLayout(spacing:Number=4,
			treeLayout:Boolean=false, sort:*=null)
		{
			this.spacing = spacing;
			this.treeLayout = treeLayout;
			this.sort = sort;
		}
		
		/** @inheritDoc */
		protected override function layout():void
		{
			_order = 0;
			
			var data:Data = visualization.data;
			data.nodes.setProperty("shape", Shapes.CIRCLE, _t);
			data.nodes.setProperty("renderer", ShapeRenderer.instance, _t);
			
			// determine layout anchor from bounds
			var bounds:Rectangle = layoutBounds;
			_anchor.x = (bounds.left + bounds.right) / 2;
			_anchor.y = (bounds.top + bounds.bottom) / 2;

			// compute the circle packing(s)
			var radius:Number;			
			if (treeLayout) {
				// perform hierarchial tree layout
				var root:NodeSprite = layoutRoot as NodeSprite;
				var cn:ChainNode = getChainNode(root); cn.x = 0; cn.y = 0;
				
				if (root.childDegree > 0) {
					radius = (cn.r = packTree(root));
					_t._S_(root).size = radius / ShapeRenderer.instance.defaultSize;
				