package flare.vis.events;

	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	
	import flash.display.DisplayObject;
	import flash.events.Event;

	/**
	 * Event fired in response to tooltip show, hide, or update events.
	 * @see flare.vis.controls.TooltipControl
	 */
	class TooltipEvent extends Event
	{
		public var edge(getEdge, null) : EdgeSprite ;
		public var node(getNode, null) : NodeSprite ;
		public var object(getObject, null) : DisplayObject ;
		public var tooltip(getTooltip, null) : DisplayObject ;
		/** A tooltip show event. */
		inline public static var SHOW:String = "show";
		/** A tooltip hide event. */
		inline public static var HIDE:String = "hide";
		/** A tooltip update event. */
		inline public static var UPDATE:String = "update";
		
		private var _object:DisplayObject;
		private var _tooltip:DisplayObject;
		
		/** The displayed tooltip object. */
		public function getTooltip():DisplayObject { return _tooltip; }
		
		/** The moused-over interface object. */
		public function getObject():DisplayObject { return _object; }
		/** The moused-over interface object, cast to a NodeSprite. */
		public function getNode():NodeSprite { return cast( _object, NodeSprite); }
		/** The moused-over interface object, cast to an EdgeSprite. */
		public function getEdge():EdgeSprite { return cast( _object, EdgeSprite); }
		
		/**
		 * Creates a new TooltipEvent.
		 * @param type the event type (SHOW,HIDE, or UPDATE)
		 * @param item the DisplayObject that was moused over
		 * @param tip the tooltip DisplayObject
		 */
		public function new(type:String, item:DisplayObject, tip:DisplayObject)
		{
			super(type);
			_object = item;
			_tooltip = tip;
		}
		
		public override function clone():Event
		{
			return new TooltipEvent(type, _object, _tooltip);
		}
		
	} // end of class TooltipEvent
