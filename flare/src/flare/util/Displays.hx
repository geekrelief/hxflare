package flare.util;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	
	/**
	 * Utility methods for working with display objects. The methods include
	 * support for panning, rotating, and zooming objects, generating thumbnail
	 * images, traversing children lists, and adding stage listeners.
	 */
	class Displays
	{
		private static var _point:Point = new Point();
		
		/**
		 * Constructor, throws an error if called, as this is an abstract class.
		 */
		public function new()
		{
			throw new Error("This is an abstract class.");
		}
		
		/**
		 * Adds a listener to the stage via a given display object. If the
		 * display object has already been added to the stage, the listener
		 * will be added to the stage immediately. Otherwise, the listener will
		 * be added whenever the display object is added to the stage. This
		 * method allows you to add listeners for stage events without having
		 * to explicitly manage the case where the defining elements have not
		 * yet been added to the stage.
		 * @param d the display object through which to access the stage
		 * @param eventType the event type
		 * @param listener the event listener
		 * @param useCapture the event useCapture flag
		 * @param priority the event listener priority
		 * @param useWeakReference the event useWeakReference flag
		 * @return the function that will add the listener to the stage upon
		 *  an added to stage event, or null if the listener was directly
		 *  added to the stage
		 * @see flash.events.Event
		 */
		public static function addStageListener(d:DisplayObject,
			eventType:String, listener:Dynamic, ?useCapture:Bool=false,
			?priority:Int=0, ?useWeakReference:Bool=false):Dynamic
		{
			if (d.stage) {
				d.stage.addEventListener(eventType, listener, useCapture,
					priority, useWeakReference);
				return null;
			} else {
				var add:Dynamic = function(?e:Event=null):Void
				{
					d.stage.addEventListener(eventType, listener,
						useCapture, priority, useWeakReference);
					d.removeEventListener(Event.ADDED_TO_STAGE, add);
					d.stage.invalidate();
				}
				d.addEventListener(Event.ADDED_TO_STAGE, add);
				return add;
			}
		}
		
		/**
		 * Iterates over the children of the input display object container,
		 * invoking a visitor function on each. If the visitor function returns
		 * a Boolean true value, the iteration will stop with an early exit.
		 * @param con the container to visit
		 * @param visitor the visitor function to invoke on the children
		 * @param filter an optional filter indicating which items should be
		 *  visited
		 * @param reverse optional flag indicating if the list should be
		 *  visited in reverse order
		 * @return true if the visitation was interrupted with an early exit
		 */
		public static function visitChildren(con:DisplayObjectContainer,
			visitor:Function, filter:*=null, reverse:Boolean=false):Boolean
		{
			var i:UInt, o:DisplayObject;
			var f:Dynamic ;
			if (reverse)
				for (i=con.numChildren; --i>=0; ) {
					o = con.getChildAt(i);
					if ((f==null || f(o)) && (visitor(o) as Boolean))
						return true;
				}
			else
				for (i=0; i<con.numChildren; ++i) {
					o = con.getChildAt(i);
					if ((f==null || f(o)) && (visitor(o) as Boolean))
						return true;
				