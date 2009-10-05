package flare.vis.events;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * Event fired in response to interactive selection events. 
	 */
	class SelectionEvent extends DataEvent
	{
		public var cause(getCause, null) : MouseEvent ;
		/** A selection event. */
		inline public static var SELECT:String   = "select";
		/** A deselection event. */
		inline public static var DESELECT:String = "deselect";
		
		/** Indicates whether the Alt key is active (<code>true</code>)
		 *  or inactive (<code>false</code>). */
		public var altKey:Bool;
		/** Indicates whether the Control key is active (<code>true</code>)
		 *  or inactive (<code>false</code>). On Macintosh computers, you must
		 *  use this property to represent the Command key. */
		public var ctrlKey:Bool;
		/** Indicates whether the Shift key is active (<code>true</code>)
		 *  or inactive (<code>false</code>). */
		public var shiftKey:Bool;
		
		/** The event that triggered this event, if any. */
		public function getCause():MouseEvent { return _cause; }
		private var _cause:MouseEvent;

		/**
		 * Creates a new SelectionEvent.
		 * @param type the event type (SELECT or DESELECT)
		 * @param item the display object(s) that were selected or deselected
		 * @param e (optional) the MouseEvent that triggered the selection
		 */
		public function new(type:String, items:Dynamic, ?e:MouseEvent=null)
		{
			super(type, items);
			if (e != null) {
				_cause = e;
				altKey = e.altKey;
				ctrlKey = e.ctrlKey;
				shiftKey = e.shiftKey;
			}
		}
		
		/** @inheritDoc */
		public override function clone():Event
		{
			var se:SelectionEvent = new SelectionEvent(type,
				_items?_items:_item, _cause);
			se.altKey = altKey;
			se.ctrlKey = ctrlKey;
			se.shiftKey = shiftKey;
			return se;
		}
		
	} // end of class SelectionEvent
