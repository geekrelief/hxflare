package flare.animate;

	/**
	 * Transition representing a pause or dwell in which nothing happens.
	 * Useful for adding pauses within an animation sequence.
	 */
	class Pause extends Transition
	{
		/**
		 * Creates a new Pause transition with specified duration.
		 * @param duration the length of the pause, in seconds
		 */
		public function new(duration:Number) {
			super(duration);
		}
		
	} // end of class Pause
