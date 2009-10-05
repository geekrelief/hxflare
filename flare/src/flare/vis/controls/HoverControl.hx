package flare.vis.controls;

	import flare.vis.events.SelectionEvent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;

	/*[Event(name="add",    type="flare.vis.events.SelectionEvent")]*/
	/*[Event(name="remove", type="flare.vis.events.SelectionEvent")]*/

	/**
	 * Interactive control for responding to mouse hover events. Select and
	 * deselect event listeners can be added to respond to mouse roll over
	 * and roll out, respectively.
	 * 
	 * <p>This control also provides multiple policies on how the drawing order
	 * of items may be affected by a hover event. By default no changes are made
	 * (<code>DONT_MOVE</code>). The <code>MOVE_TO_FRONT</code> policy moves a
	 * hovered-over item to the end of its <code>parent</code> container's
	 * children list, such that it is drawn over its sibling items. Upon roll-out
	 * the item is left at the top of the list, such that the order of items
	 * partially reflects the order of mouse visits. The
	 * <code>MOVE_AND_RETURN</code> policy moves items to the top as well, but
	 * returns them to their original index upon roll-out.</p>
	 * 
	 * @see flare.vis.events.SelectionEvent
	 */
	class HoverControl extends Control
	{
		public var movePolicy(getMovePolicy, setMovePolicy) : Int;
		/** Constant indicating that objects hovered over should not be moved
		 *  within their parent container changed. */
		inline public static var DONT_MOVE:Int = 0;
		/** Constant indicating that objects hovered over should be moved to
		 *  the front of their parent container and kept there. */
		inline public static var MOVE_TO_FRONT:Int = 1;
		/** Constant indicating that objects hovered over should be moved to
		 *  the front of their parent container and then returned to their
		 *  previous position when the mouse rolls out. */
		inline public static var MOVE_AND_RETURN:Int = 2;
		
		private var _cur:DisplayObject;
		private var _idx:Int;
		private var _movePolicy:Int;
		
		/** The policy for moving items forward when highlighted.
		 *  One of <code>DONT_MOVE</code>, <code>MOVE_TO_FRONT</code>, or
		 *  <code>MOVE_AND_RETURN</code>. */
		public function getMovePolicy():Int { return _movePolicy; }
		public function setMovePolicy(p:Int):Int {
			if (p == _movePolicy) return;
			if (_cur != null && p != MOVE_TO_FRONT &&
				_movePolicy == MOVE_AND_RETURN)
			{
				_cur.parent.setChildIndex(_cur, _idx);
			}
			_movePolicy = p;
			return p;
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new HoverControl.
		 * @param filter a Boolean-valued filter function indicating which
		 *  items should trigger hover processing
		 * @param movePolicy indicates which policy should be used for changing
		 *  the z-ordering of hovered items. One of DONT_MOVE (the default),
		 *  MOVE_TO_FRONT, or MOVE_AND_RETURN.
		 * @param rollOver an optional SelectionEvent listener for roll-overs
		 * @param rollOut an optional SelectionEvent listener for roll-outs
		 */
		public function HoverControl(filter:*=null, movePolicy:int=DONT_MOVE,
			rollOver:Function=null, rollOut:Function=null)
		{
			this.filter = filter;
			_movePolicy = movePolicy;
			if (rollOver != null)
				addEventListener(SelectionEvent.SELECT, rollOver);
			if (rollOut != null)
				addEventListener(SelectionEvent.DESELECT, rollOut);
		}
		
		/** @inheritDoc */
		public override function attach(obj:InteractiveObject):void
		{
			super.attach(obj);
			if (obj != null) {
				obj.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				obj.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			