package flare.vis.operator.layout;

	import flare.animate.Transitioner;
	import flare.physics.Particle;
	import flare.physics.Simulation;
	import flare.physics.Spring;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	
	/**
	 * Layout that places nodes based on a physics simulation of
	 * interacting forces. By default, nodes repel each other, edges act as
	 * springs, and drag forces (similar to air resistance) are applied. This
	 * algorithm can be run for multiple iterations for a run-once layout
	 * computation or repeatedly run in an animated fashion for a dynamic and
	 * interactive layout (set <code>Visualization.continuousUpdates = true
	 * </code>).
	 * 
	 * <p>The running time of this layout algorithm is the greater of O(N log N)
	 * and O(E), where N is the number of nodes and E the number of edges.
	 * The addition of custom forces to the simulation may affect this.</p>
	 * 
	 * <p>The force directed layout is implemented using the physics simulator
	 * provided by the <code>flare.physics</code> package. The
	 * <code>Simulation</code> used to drive this layout can be set explicitly,
	 * allowing any number of custom force directed layouts to be created
	 * through the selection of <code>IForce</code> modules. Each node in the
	 * layout is mapped to a <code>Particle</code> instance and each edge
	 * to a <code>Spring</code> in the simulation. Once the simulation has been
	 * initialized, you can retrieve these instances through the
	 * <code>node.props.particle</code> and <code>edge.props.spring</code>
	 * properties, respectively.</p>
	 * 
	 * @see flare.physics
	 */
	class ForceDirectedLayout extends Layout
	{
		public var defaultParticleMass(getDefaultParticleMass, setDefaultParticleMass) : Number;
		public var defaultSpringLength(getDefaultSpringLength, setDefaultSpringLength) : Number;
		public var defaultSpringTension(getDefaultSpringTension, setDefaultSpringTension) : Number;
		public var enforceBounds(getEnforceBounds, setEnforceBounds) : Bool;
		public var iterations(getIterations, setIterations) : Int;
		public var simulation(getSimulation, null) : Simulation ;
		public var ticksPerIteration(getTicksPerIteration, setTicksPerIteration) : Int;
		private var _sim:Simulation;
		private var _step:Int ;
		private var _iter:Int ;
		private var _gen:UInt ;
		private var _enforceBounds:Bool ;
		
		// simulation defaults
		private var _mass:Int ;
		private var _restLength:Int ;
		private var _tension:Float ;
		private var _damping:Float ;
		
		/** The default mass value for node/particles. */
		public function getDefaultParticleMass():Number { return _mass; }
		public function setDefaultParticleMass(v:Number):Number { _mass = v; 	return v;}
		
		/** The default spring rest length for edge/springs. */
		public function getDefaultSpringLength():Number { return _restLength; }
		public function setDefaultSpringLength(v:Number):Number { _restLength = v; 	return v;}
		
		/** The default spring tension for edge/springs. */
		public function getDefaultSpringTension():Number { return _tension; }
		public function setDefaultSpringTension(v:Number):Number { _tension = v; 	return v;}
		
		/** The number of iterations to run the simulation per invocation
		 *  (default is 1, expecting continuous updates). */
		public function getIterations():Int { return _iter; }
		public function setIterations(iter:Int):Int { _iter = iter; 	return iter;}
		
		/** The number of time ticks to advance the simulation on each
		 *  iteration (default is 1). */
		public function getTicksPerIteration():Int { return _step; }
		public function setTicksPerIteration(ticks:Int):Int { _step = ticks; 	return ticks;}
		
		/** The physics simulation driving this layout. */
		public function getSimulation():Simulation { return _sim; }
		
		/** Flag indicating if the layout bounds should be enforced. 
		 *  If true, the layoutBounds will limit node placement. */
		public function getEnforceBounds():Bool { return _enforceBounds; }
		public function setEnforceBounds(b:Bool):Bool { _enforceBounds = b; 	return b;}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new ForceDirectedLayout.
		 * @param iterations the number of iterations to run the simulation
		 *  per invocation
		 * @param sim the physics simulation to use for the layout. If null
		 *  (the default), default simulation settings will be used
		 */
		public function new(?enforceBounds:Bool=false, 
			?iterations:Int=1, ?sim:Simulation=null)
		{
			
			_step = 1;
			_iter = 1;
			_gen = 0;
			_enforceBounds = false;
			_mass = 1;
			_restLength = 30;
			_tension = 0.3;
			_damping = 0.1;
			_enforceBounds = enforceBounds;
			_iter = iterations;
			_sim = (sim==null ? new Simulation(0, 0, 0.1, -10) : sim);
		}
		
		/** @inheritDoc */
		public override function layout():Void
		{
			++_gen; // update generation counter
			init(); // populate simulation
			
			// run simulation
			_sim.bounds = _enforceBounds ? layoutBounds : null;
			for (i in 0..._iter) {
				_sim.tick(_step);
			}
			visualization.data.nodes.visit(update); // update positions
			updateEdgePoints(_t);
		}
		
		// -- value transfer --------------------------------------------------
		
		/**
		 * Transfer the physics simulation results to an item's layout.
		 * @param d a DataSprite
		 * @return true, to signal a visitor to continue
		 */
		public function update(d:DataSprite):Void
		{
			var p:Particle = d.props.particle;
			if (!p.fixed) {
				var o:Dynamic = _t._S_(d);
				o.x = p.x;
				o.y = p.y;
			}
		}
		
		// -- simulation management -------------------------------------------
		
		/**
		 * Initializes the Simulation for this ForceDirectedLayout
		 */
		public function init():Void
		{
			var data:Data = visualization.data, o:Dynamic;
			var p:Particle, s:Spring, n:NodeSprite, e:EdgeSprite;
			
			// initialize all simulation entries
			for each (n in data.nodes) {
				p = n.props.particle;
				o = _t._S_(n);
				if (p == null) {
					n.props.particle = (p = _sim.addParticle(_mass, o.x, o.y));
					p.fixed = o.fixed;
				} else {
					p.x = o.x;
					p.y = o.y;
					p.fixed = o.fixed;
				}
				p.tag = _gen;
			}
			for each (e in data.edges) {
				s = e.props.spring;
				if (s == null) {
					e.props.spring = (s = _sim.addSpring(
						e.source.props.particle, e.target.props.particle,
						_restLength, _tension, _damping));
				}
				s.tag = _gen;
			}
			
			// set up simulation parameters
			// this needs to be kept separate from the above initialization
			// to ensure all simulation items are created first
			if (mass != null) {
				for each (n in data.nodes) {
					p = n.props.particle;
					p.mass = mass(n);
				}
			}
			for each (e in data.edges) {
				s = e.props.spring;
				if (restLength != null)
					s.restLength = restLength(e);
				if (tension != null)
					s.tension = tension(e);
				if (damping != null)
					s.damping = damping(e);
			}
			
			// clean-up unused items
			for each (p in _sim.particles)
				if (p.tag != _gen) p.kill();
			for each (s in _sim.springs)
				if (s.tag != _gen) s.kill();
		}
		
		/**
		 * Function for assigning mass values to particles. By default, this
		 * simply returns the default mass value. This function can be replaced
		 * to perform custom mass assignment.
		 */
		public var mass:Dynamic public var restLength:Dynamic public var tension:Dynamic public var damping:Dynamic } // end of class ForceDirectedLayout
