package flare.physics;

	/**
	 * Force simulating a global gravitational pull on Particle instances.
	 */
	class GravityForce implements IForce
	{
		public var gravityX(getGravityX, setGravityX) : Number;
		public var gravityY(getGravityY, setGravityY) : Number;
		private var _gx:Number;
		private var _gy:Number;
		
		/** The gravitational acceleration in the horizontal dimension. */
		public function getGravityX():Number { return _gx; }
		public function setGravityX(gx:Number):Number { _gx = gx; 	return gx;}
		
		/** The gravitational acceleration in the vertical dimension. */
		public function getGravityY():Number { return _gy; }
		public function setGravityY(gy:Number):Number { _gy = gy; 	return gy;}
		
		/**
		 * Creates a new gravity force with given acceleration values.
		 * @param gx the gravitational acceleration in the horizontal dimension
		 * @param gy the gravitational acceleration in the vertical dimension
		 */
		public function new(?gx:Int=0, ?gy:Int=0) {
			_gx = gx;
			_gy = gy;
		}
		
		/**
		 * Applies this force to a simulation.
		 * @param sim the Simulation to apply the force to
		 */
		public function apply(sim:Simulation):Void
		{
			if (_gx == 0 && _gy == 0) return;
			
			var p:Particle;
			for (i in 0...sim.particles.length) {
				p = sim.particles[i];
				p.fx += _gx * p.mass;
				p.fy += _gy * p.mass;
			}
		}
		
	} // end of class GravityForce
