package flare.vis.data;

	import flare.vis.events.DataEvent;
		
	/**
	 * Data structure for managing a collection of visual data objects in a
	 * tree (hierarchy) structure. This class extends the functionality of
	 * the Data class to model a hierarchy. The class can be used as an
	 * alternative to the Data class when the data forms a strict tree, or to
	 * model a spanning tree over a general graph.
	 */
	class Tree extends Data
	{	
		public var root(null, setRoot) : NodeSprite;	
		public var tree(getTree, setTree) : Tree;	
		/**
		 * Sets the root node of this tree. This property can only be set
		 * when the tree does not yet have a root node. */
		public override function setRoot(n:NodeSprite):NodeSprite {
			if (_root == null) {
				super.addNode(n); _root = n; _root.parentIndex = -1;
				addDescendants(_root);
			} else {
				throw new ArgumentError("Can't set root unless the tree is empty." +
				"If you want to set an entirely new root, call clear() first.");
			}
			return n;
		}
		
		/** This property simply points back to this object. */
		public override function getTree():Tree { return this; }
		public override function setTree(t:Tree):Tree { /* do nothing */ 	return t; /* do nothing */}
		
		// -- Methods ---------------------------------------------------------
		
		/**
		 * Creates and returns a new root NodeSprite for the tree. If the
		 * tree already has a root, this method throws an error.
		 * @return the newly added root
		 */
		public function addRoot():NodeSprite
		{
			if (_root != null) throw new Error(
				"addRoot can only be called on an empty tree!");
			return (_root = super.addNode());
		}
		
		/**
		 * Add a node to the tree. If the child node argument is null,
		 * a new NodeSprite will be created. A new EdgeSprite connecting
		 * the nodes will be created. Returns the new child node.
		 * @param p the parent node
		 * @param c the child node. If null, a new child node is created.
		 * @return the new child node
		 */
		public function addChild(p:NodeSprite, ?c:NodeSprite=null):NodeSprite
		{			
			if (!_nodes.contains(p)) {
				throw new ArgumentError("Parent node must be in the tree!");
			}
			c = super.addNode(c);
			var e:EdgeSprite = newEdge(p, c, directedEdges, null);
			c.parentIndex = p.addChildEdge(e);
			c.parentEdge = e;
			super.addEdge(e);
			return c;
		}
		
		/**
		 * Adds the given edge as a child edge between a node already
		 * in the tree and another node not yet in the tree.
		 * @param e the edge to add to the tree
		 * @return the newly added edge
		 */
		public function addChildEdge(e:EdgeSprite):EdgeSprite
		{
			var n1:NodeSprite = e.source, b1:Bool = _nodes.contains(n1);
			var n2:NodeSprite = e.target, b2:Bool = _nodes.contains(n2);
			
			if (b1 && b2) {
				throw new ArgumentError("One node must not be in the tree");
			}
			if (!(b1 || b2))
				throw new ArgumentError("One node must already be in the tree");
				
			var p:NodeSprite = b1 ? n1 : n2;
			var c:NodeSprite = b1 ? n2 : n1;
			
			c.parentEdge = e;
			c.parentIndex = p.addChildEdge(e);
			
			super.addNode(c);
			return super.addEdge(e);
		}
		
		/**
		 * Registers all tree descendants with this Tree instance. 
		 * @param n a sub-tree root that has already been added to this Tree
		 */
		public function addDescendants(n:NodeSprite):Void
		{
			for (i in 0...n.childDegree) {
				var e:EdgeSprite = n.getChildEdge(i);
				var c:NodeSprite = e.other(n);
				c.parentEdge = e;
				c.parentIndex = i;
				super.addNode(c);
				super.addEdge(e);
				addDescendants(c);
			}
		}
		
		/**
		 * Clears the tree, removing all nodes and edges.
		 */
		public override function clear():Void
		{
			super.clear(); _root = null;
		}
		
		/**
		 * Removes a node from the tree, removing the entire
		 * subtree rooted at that node.
		 * @param n the node to remove
		 * @return true if the node was successfully removed, false otherwise
		 */
		public override function removeNode(n:NodeSprite):Bool
		{
			if (n==_root) {
				clear(); return true;
			} else {
				return removeEdge(n.parentEdge);
			}
		}
		
		/**
		 * Removes an edge from tree tree, removing the entire
		 * subtree rooted at the child node adjacent to the edge.
		 * @param e the edge to remove from the tree
		 * @return true if the edge was successfully removed, false otherwise
		 */
		public override function removeEdge(e:EdgeSprite):Bool
		{
			if (e==null || !_edges.contains(e)) return false;
			
			// disconnect tree
			var c:NodeSprite = (e.target.parentNode==e.source ? e.target : e.source);
			var p:NodeSprite = c.parentNode;
			var i:Int = c.parentIndex;
			p.removeChildEdge(e);
			
			// walk disconnected segment to fire updates
			c.visitTreeDepthFirst(function(n:NodeSprite):Void {
				_edges.remove(n.parentEdge);
				_nodes.remove(n);
			});
			_edges.remove(e);
			
			// update parent index values
			;
			while (i<p.childDegree) {
				p.getChildNode(i).parentIndex = i;
				++i;
			}
			return true;	
		}
		
		/** @private */
		public override function onRemoveNode(evt:DataEvent):Void
		{
			fireEvent(evt);
		}
		
		/** @private */
		public override function onRemoveEdge(evt:DataEvent):Void
		{
			fireEvent(evt);
		}

		// --------------------------------------------------------------------
		
		/**
		 * Counts the number of leaf nodes in the tree.
		 * @return the number of leaf nodes
		 */
		public function countLeaves():Int
		{
			var leaves:Int = 0;
			for each (var ns:NodeSprite in _nodes.list) {
				if (ns.childDegree == 0) ++leaves;
			}
			return leaves;
		}

		// --------------------------------------------------------------------

		/**
		 * Continuously swaps the given node with its parent node
		 * until it is the root.
		 * <p>
		 * <strong>WARNING:</strong> this method causes connecting edges to be
		 * reconfigured. If this tree is a spanning tree, this can cause havoc.
		 * </p>
		 * @param n the node to swap with its parent until it becomes the root
		 */
		public function swapToRoot(n:NodeSprite):Void
		{
			while (n.parent != null) {
				swapWithParent(n);
			}
		}

		/**
		 * Swaps the given node with its parent node.
		 * <p>
		 * <strong>WARNING:</strong> this method causes connecting edges to be
		 * reconfigured. If this tree is a spanning tree, this can cause havoc.
		 * </p>
		 * @param n the node to swap with its parent
		 */
		public function swapWithParent(n:NodeSprite):Void
		{
			var p:NodeSprite = n.parentNode, gp:NodeSprite;
			var e:EdgeSprite, ge:EdgeSprite, idx:Int;
			if (p==null) return;
			
			gp = p.parentNode;
			ge = p.parentEdge;
			idx = p.parentIndex;
			
			// swap parent edge
			e = n.parentEdge;
			p.removeChild(n);
			p.parentEdge = e;
			p.parentIndex = n.addChildEdge(e);
			
			// connect to grandparents
			if (gp==null) {
				n.parentIndex = -1;
				n.parentEdge = null;
			} else {
				if (ge.source == gp) {
					ge.target = n;
				} else {
					ge.source = n;
				}
				n.parentIndex = idx;
				n.parentEdge = ge;
			}
		}

	} // end of class Tree
