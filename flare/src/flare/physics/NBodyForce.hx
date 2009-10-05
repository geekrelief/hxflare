package flare.physics;

	/**
	 * Force simulating an N-Body force of charged particles with pairwise
	 * interaction, such as gravity or electrical charge. This class uses a
	 * quad-tree structure to aggregate charge values and optimize computation.
	 * The force function is a standard inverse-square law (though in this case
	 * approximated due to optimization): <code>F = G * m1 * m2 / d^2</code>,
	 * where G is a constant (e.g., gravitational constant), m1 and m2 are the
	 * masses (charge) of the particles, and d is the distance between them.
	 * 
	 * <p>The algorithm used is that of J. Barnes and P. Hut, in their research
	 * paper <i>A Hierarchical  O(n log n) force calculation algorithm</i>, Nature, 
	 * v.324, December 1986. For more details on the algorithm, see one of
	 * the following links:
	 * <ul>
	 *   <li><a href="http://www.cs.berkeley.edu/~demmel/cs267/lecture26/lecture26.html">James Demmel's UC Berkeley lecture notes</a>
	 *   <li><a href="http://www.physics.gmu.edu/~large/lr_forces/desc/bh/bhdesc.html">Description of the Barnes-Hut algorithm</a>
	 *   <li><a href="http://www.ifa.hawaii.edu/~barnes/treecode/treeguide.html">Joshua Barnes' implementation</a>
	 * </ul></p>
	 */
	class NBodyForce implements IForce
	{
		public var gravitation(getGravitation, setGravitation) : Number;
		public var maxDistance(getMaxDistance, setMaxDistance) : Number;
		public var minDistance(getMinDistance, setMinDistance) : Number;
		private var _g:Number;     // gravitational constant
		private var _t:Number;     // barnes-hut theta
		private var _max:Number;   // max effective distance
		private var _min:Number;   // min effective distance
		private var _eps:Number;   // epsilon for determining 'same' location
		
		private var _x1:Number, _y1:Number, _x2:Number, _y2:Number;
		private var _root:QuadTreeNode;
		
		/** The gravitational constant to use. 
		 *  Negative values produce a repulsive force. */
		public function getGravitation():Number { return _g; }
		public function setGravitation(g:Number):Number { _g = g; 	return g;}
		
		/** The maximum distance over which forces are exerted. 
		 *  Any greater distances will be ignored. */
		public function getMaxDistance():Number { return _max; }
		public function setMaxDistance(d:Number):Number { _max = d; 	return d;}
		
		/** The minumum effective distance over which forces are exerted.
		 * 	Any lesser distances will be treated as the minimum. */
		public function getMinDistance():Number { return _min; }
		public function setMinDistance(d:Number):Number { _min = d; 	return d;}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new NBodyForce with given parameters.
		 * @param g the gravitational constant to use.
		 *  Negative values produce a repulsive force.
		 * @param maxd a maximum distance over which the force should operate.
		 *  Particles separated by more than this distance will not interact.
		 * @param mind the minimum distance over which the force should operate.
		 *  Particles closer than this distance will interact as if they were
		 *  the minimum distance apart. This helps avoid extreme forces.
		 *  Helpful when particles are very close together.
		 * @param eps an epsilon values for determining a minimum distance
		 *  between particles
		 * @param t the theta parameter for the Barnes-Hut approximation.
		 *  Determines the level of approximation (default value if 0.9).
		 */
		public function NBodyForce(g:Number=-1, max:Number=200, min:Number=2,
								   eps:Number=0.01, t:Number=0.9)
		{
			_g = g;
			_max = max;
			_min = min;
			_eps = eps;
			_t = t;
			_root = QuadTreeNode.node();
		}

		/**
		 * Applies this force to a simulation.
		 * @param sim the Simulation to apply the force to
		 */
		public function apply(sim:Simulation):void
		{
			if (_g == 0) return;
			
			// clear the quadtree
			clear(_root); _root = QuadTreeNode.node();
			
			// get the tree bounds
			bounds(sim);
        
        	// populate the tree
        	for (var i:uint = 0; i<sim.particles.length; ++i) {
        		insert(sim.particles[i], _root, _x1, _y1, _x2, _y2);
        	