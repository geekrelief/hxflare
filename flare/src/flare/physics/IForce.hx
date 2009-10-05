package flare.physics;

	/**
	 * Interface representing a force within a physics simulation.
	 */
	interface IForce
	{
		/**
		 * Applies this force to a simulation.
		 * @param sim the Simulation to apply the force to
		 */
		function apply(sim:Simulation):Void;
		
	} // end of interface IForce
