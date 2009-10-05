package flare.vis.events;

	import flare.animate.Transitioner;
	
	import flash.events.Event;

	/**
	 * Event fired in response to visualization updates.
	 */
	class VisualizationEvent extends Event
	{
		public var params(getParams, null) : Array<Dynamic> ;
		public var transitioner(getTransitioner, null) : Transitioner ;
		/** A visualization update event. */
		inline public static var UPDATE:String = "update";
		
		private var _trans:Transitioner;
		private var _params:Array<Dynamic>;
		
		/** Transitioner used in the visualization update. */
		public function getTransitioner():Transitioner { return _trans; }
		
		/** Parameter provided to the visualization update. If not null,
		 *  this string indicates the named operators that were run. */
		public function getParams():Array<Dynamic> { return _params; }
		
		/**
		 * Creates a new VisualizationEvent.
		 * @param type the event type
		 * @param trans the Transitioner used in the visualization update
		 */		
		public function new(type:String,
			?trans:Transitioner=null, ?params:Array<Dynamic>=null)
		{
			super(type);
			_params = params;
			_trans = trans==null ? Transitioner.DEFAULT : trans;
		}
		
	} // end of class VisualizationEvent
