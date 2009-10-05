package flare.animate;

	import flash.events.Event;

	/**
	 * Event fired when a <code>Transition</code>
	 * starts, steps, ends, or is canceled.
	 */
	class TransitionEvent extends Event
	{
		public var transition(getTransition, null) : Transition ;
		/** A transition start event. */
		inline public static var START:String = "start";
		/** A transition step event. */
		inline public static var STEP:String = "step";
		/** A transition end event. */
		inline public static var END:String = "end";
		/** A transition cancel event. */
		inline public static var CANCEL:String = "cancel";
		
		private var _t:Transition;
		
		/** The transition this event corresponds to. */
		public function getTransition():Transition { return _t; }
		
		/**
		 * Creates a new TransitionEvent.
		 * @param type the event type (START, STEP, or END)
		 * @param t the transition this event corresponds to
		 */		
		public function new(type:String, t:Transition)
		{
			super(type);
			_t = t;
		}
		
		/** @inheritDoc */
		public override function clone():Event
		{
			return new TransitionEvent(type, _t);
		}
		
	} // end of class TransitionEvent
