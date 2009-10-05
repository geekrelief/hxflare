package flare.vis.controls;

	import flare.vis.events.SelectionEvent;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/*[Event(name="select",   type="flare.vis.events.SelectionEvent")]*/
	/*[Event(name="deselect", type="flare.vis.events.SelectionEvent")]*/
	
	/**
	 * Interactive control for responding to mouse clicks events. Select event
	 * listeners can be added to respond to the mouse clicks. This control
	 * also allows the number of mouse-clicks (single, double, triple, etc) and
	 * maximum delay time between clicks to be configured.
	 * @see flare.vis.events.SelectionEvent
	 */
	class ClickControl extends Control
	{
		public var clickDelay(getClickDelay, setClickDelay) : Number;
		private var _timer:Timer;
		private var _cur:DisplayObject;
		private var _clicks:UInt ;
		private var _clear:Bool ;
		private var _evt:MouseEvent ;
		
		/** The number of clicks needed to trigger a click event. Setting this
		 *  value to zero effectively disables the click control. */
		public var numClicks:UInt;
		
		/** The maximum allowed delay (in milliseconds) between clicks. 
		 *  The delay determines the maximum time interval between a
		 *  mouse up event and a subsequent mouse down event. */
		public function getClickDelay():Number { return _timer.delay; }
		public function setClickDelay(d:Number):Number { _timer.delay = d; 	return d;}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new ClickControl.
		 * @param filter a Boolean-valued filter function indicating which
		 *  items should trigger hover processing
		 * @param numClicks the number of clicks
		 * @param onClick an optional SelectionEvent listener for click events
		 */
		public function ClickControl(filter:*=null, numClicks:uint=1,
			onClick:Function=null, onClear:Function=null)
		{
			this.filter = filter;
			this.numClicks = numClicks;
			_timer = new Timer(150);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			if (onClick != null)
				addEventListener(SelectionEvent.SELECT, onClick);
			if (onClear != null)
				addEventListener(SelectionEvent.DESELECT, onClear);
		}
		
		/** @inheritDoc */
		public override function attach(obj:InteractiveObject):void
		{
			if (obj==null) { detach(); return; 