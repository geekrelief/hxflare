package flare.physics;

	import flash.geom.Rectangle;
	
	/**
	 * A physical simulation involving particles, springs, and forces.
	 * Useful for simulating a range of physical effects or layouts.
	 */
	class Simulation
	{
		public var bounds(getBounds, setBounds) : Rectangle;
		public var dragForce(getDragForce, null) : DragForce ;
		public var gravityForce(getGravityForce, null) : GravityForce ;
		public var nbodyForce(getNbodyForce, null) : NBodyForce ;
		public var particles(getParticles, null) : Array<Dynamic> ;
		public var springForce(getSpringForce, null) : SpringForce ;
		public var springs(getSprings, null) : Array<Dynamic> ;
		private var _particles:Array<Dynamic> ;
		private var _springs:Array<Dynamic> ;
		private var _forces:Array<Dynamic> ;
		private var _bounds:Rectangle ;
		
		/** The default gravity force for this simulation. */
		public function getGravityForce():GravityForce {
			return cast( _forces[0], GravityForce);
		}
		
		/** The default n-body force for this simulation. */
		public function getNbodyForce():NBodyForce {
			return cast( _forces[1], NBodyForce);
		}
		
		/** The default drag force for this simulation. */
		public function getDragForce():DragForce {
			return cast( _forces[2], DragForce);
		}
		
		/** The default spring force for this simulation. */
		public function getSpringForce():SpringForce {
			return cast( _forces[3], SpringForce);
		}
		
		/** Sets a bounding box for particles in this simulation.
		 *  Null (the default) indicates no boundaries. */
		public function getBounds():Rectangle { return _bounds; }
		public function setBounds(b:Rectangle):Rectangle {
			if (_bounds == b) return;
			if (b == null) { _bounds = null; return; }
			if (_bounds == null) { _bounds = new Rectangle(); }
			// ensure x is left-most and y is top-most
			_bounds.x = b.x + (b.width < 0 ? b.width : 0);
			_bounds.width = (b.width < 0 ? -1 : 1) * b.width;
			_bounds.y = b.y + (b.width < 0 ? b.height : 0);
			_bounds.height = (b.height < 0 ? -1 : 1) * b.height;
			return b;
		}
		
		/**
		 * Creates a new physics simulation.
		 * @param gx the gravitational acceleration along the x dimension
		 * @param gy the gravitational acceleration along the y dimension
		 * @param drag the default drag (viscosity) co-efficient
		 * @param attraction the gravitational attraction (or repulsion, for
		 *  negative values) between particles.
		 */
		public function new(?gx:Int=0, ?gy:Int=0,
			?drag:Float=0.1, ?attraction:Int=-5)
		{
			
			_particles = new Array();
			_springs = new Array();
			_forces = new Array();
			_bounds = null;
			_forces.push(new GravityForce(gx, gy));
			_forces.push(new NBodyForce(attraction));
			_forces.push(new DragForce(drag));
			_forces.push(new SpringForce());
		}
		
		// -- Init Simulation -------------------------------------------------
		
		/**
		 * Adds a custom force to the force simulation.
		 * @param force the force to add
		 */
		public function addForce(force:IForce):Void
		{
			_forces.push(force);
		}
		
		/**
		 * Returns the force at the given index.
		 * @param idx the index of the force to look up
		 * @return the force at the specified index
		 */ 
		public function getForceAt(idx:Int):IForce
		{
			return _forces[idx];
		}
		
		/**
		 * Adds a new particle to the simulation.
		 * @param mass the mass (charge) of the particle
		 * @param x the particle's starting x position
		 * @param y the particle's starting y position
		 * @return the added particle
		 */
		public function addParticle(mass:Number, x:Number, y:Number):Particle
		{
			var p:Particle = getParticle(mass, x, y);
			_particles.push(p);
			return p;
		}
		
		/**
		 * Removes a particle from the simulation. Any springs attached to
		 * the particle will also be removed.
		 * @param idx the index of the particle in the particle list
		 * @return true if removed, false otherwise.
		 */
		public function removeParticle(idx:UInt):Bool
		{
			var p:Particle = _particles[idx];
			if (p == null) return false;
			
			// remove springs
			var i:UInt = _springs.length;
			while (--i >= 0) {
				var s:Spring = _springs[i];
				if (s.p1 == p || s.p2 == p)
					removeSpring(i);
				;
			}
			// remove from particles
			reclaimParticle(p);
			_particles.splice(idx, 1);
			return true;
		}
		
		/**
		 * Adds a spring to the simulation
		 * @param p1 the first particle attached to the spring
		 * @param p2 the second particle attached to the spring
		 * @param restLength the rest length of the spring
		 * @param tension the tension of the spring
		 * @param damping the damping (friction) co-efficient of the spring
		 * @return the added spring
		 */
		public function addSpring(p1:Particle, p2:Particle, restLength:Number,
							      tension:Number, damping:Number):Spring
		{
			var s:Spring = getSpring(p1, p2, restLength, tension, damping);
			p1.degree++;
			p2.degree++;
			_springs.push(s);
			return s;
		}
		
		
		/**
		 * Removes a spring from the simulation.
		 * @param idx the index of the spring in the spring list
		 * @return true if removed, false otherwise
		 */
		public function removeSpring(idx:UInt):Bool
		{
			if (idx >= _springs.length) return false;
			var s:Spring = _springs[idx];
			s.p1.degree--;
			s.p2.degree--;
			reclaimSpring(s);
			_springs.splice(idx, 1);
			return true;
		}
		
		/**
		 * Returns the particle list. This is the same array instance backing
		 * the simulation, so edit the array with caution.
		 * @return the particle list
		 */
		public function getParticles():Array<Dynamic> {
			return _particles;
		}
		
		/**
		 * Returns the spring list. This is the same array instance backing
		 * the simulation, so edit the array with caution.
		 * @return the spring list
		 */
		public function getSprings():Array<Dynamic> {
			return _springs;
		}
		
		// -- Run Simulation --------------------------------------------------
		
		/**
		 * Advance the simulation for the specified time interval.
		 * @param dt the time interval to step the simulation (default 1)
		 */
		public function tick(?dt:Int=1):Void
		{	
			var p:Particle, s:Spring, i:UInt, ax:Number, ay:Number;
			var dt1:Int = dt/2, dt2:Int = dt*dt/2;
			
			// remove springs connected to dead particles
			i=_springs.length;
			while (--i>=0) {
				s = _springs[i];
				if (s.die || s.p1.die || s.p2.die) {
					s.p1.degree--;
					s.p2.degree--;
					reclaimSpring(s);
					_springs.splice(i, 1);
				}
				;
			}
			
			// update particles using Verlet integration
			i=_particles.length;
			while (--i>=0) {
				p = _particles[i];
				p.age += dt;
				if (p.die) { // remove dead particles
					reclaimParticle(p);
					_particles.splice(i, 1);
				} else if (p.fixed) {
					p.vx = p.vy = 0;
				} else {
					ax = p.fx / p.mass; ay = p.fy / p.mass;
					p.x  += p.vx*dt + ax*dt2;
					p.y  += p.vy*dt + ay*dt2;
					p._vx = p.vx + ax*dt1;
					p._vy = p.vy + ay*dt1;
				}
				;
			}
			// evaluate the forces
			eval();
			// update particle velocities
			i=_particles.length;
			while (--i>=0) {
				p = _particles[i];
				if (!p.fixed) {
					ax = dt1 / p.mass;
					p.vx = p._vx + p.fx * ax;
					p.vy = p._vy + p.fy * ax;
				}
				;
			}
			
			// enfore bounds
			if (_bounds) enforceBounds();
		}
		
		private function enforceBounds():Void {
			var minX:Int = _bounds.x;
			var maxX:Int = _bounds.x + _bounds.width;
			var minY:Int = _bounds.y;
			var maxY:Int = _bounds.y + _bounds.height;
			
			for each (var p:Particle in _particles) {
				if (p.x < minX) {
					p.x = minX; p.vx = 0;
				} else if (p.x > maxX) {
					p.x = maxX; p.vx = 0;
				}
				if (p.y < minY) {
					p.y = minY; p.vy = 0;
				}
				else if (p.y > maxY) {
					p.y = maxY; p.vy = 0;
				}
			}
		}
		
		/**
		 * Evaluates the set of forces in the simulation.
		 */
		public function eval():Void {
			var i:UInt, p:Particle;
			// reset forces
			i=_particles.length;
			while (--i >= 0) {
				p = _particles[i];
				p.fx = p.fy = 0;
				;
			}
			// collect forces
			for (i in 0..._forces.length) {
				IForce(_forces[i]).apply(this);
			}
		}
		
		// -- Particle Pool ---------------------------------------------------
		
		/** The maximum number of items stored in a simulation object pool. */
		inline public static var objectPoolLimit:Int = 5000;
		public static var _ppool:Array<Dynamic> = new Array();
		public static var _spool:Array<Dynamic> = new Array();
		
		/**
		 * Returns a particle instance, pulling a recycled particle from the
		 * object pool if available.
		 * @param mass the mass (charge) of the particle
		 * @param x the particle's starting x position
		 * @param y the particle's starting y position
		 * @return a particle instance
		 */
		public static function getParticle(mass:Number, x:Number, y:Number):Particle
		{
			if (_ppool.length > 0) {
				var p:Particle = _ppool.pop();
				p.init(mass, x, y);
				return p;
			} else {
				return new Particle(mass, x, y);
			}
		}
		
		/**
		 * Returns a spring instance, pulling a recycled spring from the
		 * object pool if available.
		 * @param p1 the first particle attached to the spring
		 * @param p2 the second particle attached to the spring
		 * @param restLength the rest length of the spring
		 * @param tension the tension of the spring
		 * @param damping the damping (friction) co-efficient of the spring
		 * @return a spring instance
		 */
		public static function getSpring(p1:Particle, p2:Particle,
			restLength:Number, tension:Number, damping:Number):Spring
		{
			if (_spool.length > 0) {
				var s:Spring = _spool.pop();
				s.init(p1, p2, restLength, tension, damping);
				return s;
			} else {
				return new Spring(p1, p2, restLength, tension, damping);
			}
		}
		
		/**
		 * Reclaims a particle, adding it to the object pool for recycling
		 * @param p the particle to reclaim
		 */
		public static function reclaimParticle(p:Particle):Void
		{
			if (_ppool.length < objectPoolLimit) {
				_ppool.push(p);
			}
		}
		
		/**
		 * Reclaims a spring, adding it to the object pool for recycling
		 * @param s the spring to reclaim
		 */
		public static function reclaimSpring(s:Spring):Void
		{
			if (_spool.length < objectPoolLimit) {
				_spool.push(s);
			}
		}
		
	} // end of class Simulation
