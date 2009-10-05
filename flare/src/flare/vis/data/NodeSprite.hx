package flare.vis.data;

	import flare.animate.Transitioner;
	import flare.util.Arrays;
	import flare.util.Filter;
	import flare.util.Sort;
	import flare.util.IEvaluable;
	
	/**
	 * Visually represents a data element, such as a data tuple or graph node.
	 * By default, NodeSprites are drawn using a <codeShapeRenderer<code>.
	 * NodeSprites are typically managed by a <code>Data</code> object.
	 * 
	 * <p>NodeSprites can separately maintain adjacency lists for both a
	 * general graph structure (managing lists for inlinks and outlinks) and a
	 * tree structure (managing a list for child links and a parent pointer).
	 * The graph and tree lists are maintained completely separately to
	 * maximize flexibility. While the the tree lists are often used to record
	 * a spanning tree of the general network structure, they can also be used
	 * to represent a hierarchy completely distinct from a co-existing graph
	 * structure. Take this into account when iterating over the edges incident
	 * on this node.</p>
	 */
	class NodeSprite extends DataSprite
	{
		public var angle(null, setAngle) : Number;
		public var childDegree(getChildDegree, null) : UInt ;
		public var degree(getDegree, null) : UInt ;
		public var depth(getDepth, null) : UInt ;
		public var expanded(getExpanded, setExpanded) : Bool;
		public var firstChildNode(getFirstChildNode, null) : NodeSprite
		;
		public var inDegree(getInDegree, null) : UInt ;
		public var lastChildNode(getLastChildNode, null) : NodeSprite
		;
		public var nextNode(getNextNode, null) : NodeSprite
		;
		public var outDegree(getOutDegree, null) : UInt ;
		public var parentEdge(getParentEdge, setParentEdge) : EdgeSprite;
		public var parentIndex(getParentIndex, setParentIndex) : Int;
		public var parentNode(getParentNode, null) : NodeSprite
		;
		public var prevNode(getPrevNode, null) : NodeSprite
		;
		public var radius(null, setRadius) : Number;
		public var x(null, setX) : Number;
		public var y(null, setY) : Number;
		/** Flag indicating inlinks, edges that point to this node. */
		inline public static var IN_LINKS:UInt    = 1;
		/** Flag indicating outlinks, edges that point away from node. */
		inline public static var OUT_LINKS:UInt   = 2;
		/** Flag indicating both inlinks and outlinks. */
		inline public static var GRAPH_LINKS:UInt = 3;  // IN_LINKS | OUT_LINKS
		/** Flag indicating child links in a tree structure. */
		inline public static var CHILD_LINKS:UInt = 4;
		/** Flag indicating the link to a parent in a tree structure. */
		inline public static var PARENT_LINK:UInt = 8;
		/** Flag indicating both child and parent links. */
		inline public static var TREE_LINKS:UInt  = 12; // CHILD_LINKS | PARENT_LINK
		/** Flag indicating all links, including graph and tree links. */
		inline public static var ALL_LINKS:UInt   = 15; // GRAPH_LINKS | TREE_LINKS
		/** Flag indicating that a traversal should be performed in reverse. */
		inline public static var REVERSE:UInt     = 16;
		
		// -- Properties ------------------------------------------------------
		
		private var _parentEdge:EdgeSprite;
		private var _idx:Int ; // node index in parent's array
		private var _childEdges:/*EdgeSprite*/Array<Dynamic>;
		private var _inEdges:/*EdgeSprite*/Array<Dynamic>;
		private var _outEdges:/*EdgeSprite*/Array<Dynamic>;
		private var _expanded:Bool ;
		
		/** Flag indicating if this node is currently expanded. This flag can
		 *  be used by layout routines to expand/collapse connections. */
		public function getExpanded():Bool { return _expanded; }
		public function setExpanded(b:Bool):Bool { _expanded = b; 	return b;}
		
		/** The edge connecting this node to its parent in a tree structure. */
		public function getParentEdge():EdgeSprite { return _parentEdge; }
		public function setParentEdge(e:EdgeSprite):EdgeSprite { _parentEdge = e; 	return e;}
		
		/** The index of this node in its tree parent's child links list. */
		public function getParentIndex():Int { return _idx; }
		public function setParentIndex(i:Int):Int { _idx = i; 	return i;}

		// -- Node Degree Properties ------------------------------------------

		/** The number of child links. */
		public function getChildDegree():UInt { return _childEdges==null ? 0 : _childEdges.length; }
		/** The number of inlinks and outlinks. */
		public function getDegree():UInt { return inDegree + outDegree; }
		/** The number of inlinks. */
		public function getInDegree():UInt { return _inEdges==null ? 0 : _inEdges.length; }
		/** The number of outlinks. */
		public function getOutDegree():UInt { return _outEdges==null ? 0 : _outEdges.length; }

		/** The depth of this node in the tree structure. A value of zero
		 *  indicates that this is a root node or that there is no tree. */
		public function getDepth():UInt {
			for (var d:UInt=0, p:NodeSprite=parentNode; p!=null; p=p.parentNode, d++);
			return d;
		}

		// -- Node Access Properties ---------------------------

		/** The parent of this node in the tree structure. */
		public function getParentNode():NodeSprite
		{
			return _parentEdge == null ? null : _parentEdge.other(this);
		}
		
		/** The first child of this node in the tree structure. */
		public function getFirstChildNode():NodeSprite
		{
			return childDegree > 0 ? _childEdges[0].other(this) : null;
		}
		
		/** The last child of this node in the tree structure. */
		public function getLastChildNode():NodeSprite
		{
			var len:UInt = childDegree;
			return len > 0 ? _childEdges[len-1].other(this) : null;
		}
		
		/** The next sibling of this node in the tree structure. */
		public function getNextNode():NodeSprite
		{
			var p:NodeSprite = parentNode, i:Int = _idx+1;
			if (p == null || i >= p.childDegree) return null;
			return parentNode.getChildNode(i);
		}
		
		/** The previous sibling of this node in the tree structure. */
		public function getPrevNode():NodeSprite
		{
			var p:NodeSprite = parentNode, i:Int = _idx-1;
			if (p == null || i < 0) return null;
			return parentNode.getChildNode(i);
		}
		
		// -- Position Overrides -------------------------------

		/** @inheritDoc */
		public override function setX(v:Number):Number
		{
			if (x!=v) dirtyEdges();
			super.x = v;
			return v;
		}
		/** @inheritDoc */
		public override function setY(v:Number):Number
		{
			if (y!=v) dirtyEdges();
			super.y = v;
			return v;
		}
		/** @inheritDoc */
		public override function setRadius(r:Number):Number
		{
			if (_radius!=r) dirtyEdges();
			super.radius = r;
			return r;
		}
		/** @inheritDoc */
		public override function setAngle(a:Number):Number
		{
			if (_angle!=a) dirtyEdges();
			super.angle = a;
			return a;
		}
		
		// -- Methods ---------------------------------------------------------

		/** Mark all incident edges as dirty. */
		private function dirtyEdges():Void
		{
			var e:EdgeSprite;
			if (_parentEdge) _parentEdge.dirty();
			if (_childEdges) for each (e in _childEdges) { e.dirty(); }
			if (_outEdges)   for each (e in _outEdges)   { e.dirty(); }
			if (_inEdges)    for each (e in _inEdges)    { e.dirty(); }
		}
		
		// -- Test Methods -------------------------------------
		
		/**
		 * Indicates if the input node is connected to this node by an edge.
		 * @param n the node to check for connection
		 * @param opt flag indicating which links to check
		 * @return true if connected, false otherwise
		 */		
		public function isConnected(n:NodeSprite, ?opt:UInt=ALL_LINKS):Bool
		{
			return visitNodes(
				function(d:NodeSprite):Bool { return n==d; },
				opt);
		}

		// -- Accessor Methods ---------------------------------
		
		/**
		 * Gets the child edge at the specified position
		 * @param i the position of the child edge
		 * @return the child edge
		 */		
		public function getChildEdge(i:UInt):EdgeSprite
		{
			return _childEdges[i];
		}
		
		/**
		 * Gets the child node at the specified position
		 * @param i the position of the child node
		 * @return the child node
		 */
		public function getChildNode(i:UInt):NodeSprite
		{
			return _childEdges[i].other(this);
		}
		
		/**
		 * Gets the inlink edge at the specified position
		 * @param i the position of the inlink edge
		 * @return the inlink edge
		 */
		public function getInEdge(i:UInt):EdgeSprite
		{
			return _inEdges[i];
		}
		
		/**
		 * Gets the inlink node at the specified position
		 * @param i the position of the inlink node
		 * @return the inlink node
		 */
		public function getInNode(i:UInt):NodeSprite
		{
			return _inEdges[i].source;
		}
		
		/**
		 * Gets the outlink edge at the specified position
		 * @param i the position of the outlink edge
		 * @return the outlink edge
		 */
		public function getOutEdge(i:UInt):EdgeSprite
		{
			return _outEdges[i];
		}
		
		/**
		 * Gets the outlink node at the specified position
		 * @param i the position of the outlink node
		 * @return the outlink node
		 */
		public function getOutNode(i:UInt):NodeSprite
		{
			return _outEdges[i].target;
		}
		
		// -- Mutator Methods ----------------------------------
		
		/**
		 * Adds a child edge to this node.
		 * @param e the edge to add to the child links list
		 * @return the index of the added edge in the list
		 */
		public function addChildEdge(e:EdgeSprite):UInt
		{
			if (_childEdges == null) _childEdges = new Array();
			_childEdges.push(e);
			return _childEdges.length - 1;
		}
		
		/**
		 * Adds an inlink edge to this node.
		 * @param e the edge to add to the inlinks list
		 * @return the index of the added edge in the list
		 */
		public function addInEdge(e:EdgeSprite):UInt
		{
			if (_inEdges == null) _inEdges = new Array();
			_inEdges.push(e);
			return _inEdges.length - 1;
		}
		
		/**
		 * Adds an outlink edge to this node.
		 * @param e the edge to add to the outlinks list
		 * @return the index of the added edge in the list
		 */
		public function addOutEdge(e:EdgeSprite):UInt
		{
			if (_outEdges == null) _outEdges = new Array();
			_outEdges.push(e);
			return _outEdges.length - 1;
		}
		
		/**
		 * Removes all edges incident on this node. Note that this method
		 * does not update the edges themselves or the other nodes.
		 */
		public function removeAllEdges():Void
		{
			removeEdges(ALL_LINKS);
		}
		
		/**
		 * Removes all edges of the indicated edge type. Note that this method
		 * does not update the edges themselves or the other nodes.
		 * @param type the type of edges to remove. For example, IN_LINKS,
		 *  OUT_LINKS, TREE_LINKS, etc.
		 */
		public function removeEdges(type:Int):Void
		{
			var e:EdgeSprite;
			if (type & PARENT_LINK && _parentEdge) {
				_parentEdge = null;
			}
			if (type & CHILD_LINKS && _childEdges) {
				while (_childEdges.length > 0) { e=_childEdges.pop(); }
			}
			if (type & OUT_LINKS && _outEdges) {
				while (_outEdges.length > 0) { e=_outEdges.pop(); }
			}
			if (type & IN_LINKS && _inEdges) {
				while (_inEdges.length > 0) { e=_inEdges.pop(); }	
			}
		}
		
		/**
		 * Removes an edge from the child links list. Note that this method
		 * does not update the edge itself or the other node.
		 * @param e the edge to remove
		 */
		public function removeChildEdge(e:EdgeSprite):Void
		{
			Arrays.remove(_childEdges, e);
		}
		
		/**
		 * Removes an edge from the inlinks list. Note that this method
		 * does not update the edge itself or the other node.
		 * @param e the edge to remove
		 */
		public function removeInEdge(e:EdgeSprite):Void
		{
			Arrays.remove(_inEdges, e);
		}
		
		/**
		 * Removes an edge from the outlinks list. Note that this method
		 * does not update the edge itself or the other node.
		 * @param e the edge to remove
		 */
		public function removeOutEdge(e:EdgeSprite):Void
		{
			Arrays.remove(_outEdges, e);
		}
		
		// -- Visitor Methods --------------------------------------------------
		
		/**
		 * Sorts the order of connected edges according to their properties.
		 * Each type of edge (in, out, or child) is sorted separately.
		 * @param opt flag indicating which set(s) of edges should be sorted
		 * @param sort the sort arguments.
		 * 	If a String is provided, the data will be sorted in ascending order
		 *   according to the data field named by the string.
		 *  If an Array is provided, the data will be sorted according to the
		 *   fields in the array. In addition, field names can optionally
		 *   be followed by a boolean value. If true, the data is sorted in
		 *   ascending order (the default). If false, the data is sorted in
		 *   descending order.
		 */
		public function sortEdgesBy(?opt:UInt=ALL_LINKS, sort:Array<Dynamic>):Void
		{
			if (sort.length == 0) return;
			if (Std.is( sort[0], Array)) sort = sort[0];
			
			var s:Dynamic = Sort._S_(sort);
			if (opt & IN_LINKS    && _inEdges    != null) _inEdges.sort(s);
			if (opt & OUT_LINKS   && _outEdges   != null) _outEdges.sort(s);
			if (opt & CHILD_LINKS && _childEdges != null) _childEdges.sort(s);
		}
		
		/**
		 * Visits this node's edges, invoking a function on each visited edge.
		 * @param f the function to invoke on the edges. If the function
		 *  returns true, the visitation is ended with an early exit.
		 * @param opt flag indicating which sets of edges should be visited
		 * @return true if the visitation was interrupted with an early exit
		 */
		public function visitEdges(f:Function, opt:uint=ALL_LINKS,
			filter:*=null):Boolean
		{
			var ff:Dynamic ;
			var rev:Bool ;
			if (opt & IN_LINKS && _inEdges != null) { 
				if (visitEdgeHelper(f, _inEdges, rev, ff)) return true;
			}
			if (opt & OUT_LINKS && _outEdges != null) {
				if (visitEdgeHelper(f, _outEdges, rev, ff)) return true;
			