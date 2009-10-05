package flare.vis.controls;

	import flare.animate.Tween;
	import flare.display.TextSprite;
	import flare.vis.events.TooltipEvent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	/*[Event(name="show", type="flare.vis.events.TooltipEvent")]*/
	/*[Event(name="hide", type="flare.vis.events.TooltipEvent")]*/
	/*[Event(name="update", type="flare.vis.events.TooltipEvent")]*/

	/**
	 * Interactive control for displaying a tooltip in response to mouse
	 * hovers exceeding a minimum time interval. By default, a 
	 * <code>flare.display.TextSprite</code> instance is used to show a
	 * tooltip. To change the tooltip text, clients can set either the
	 * <code>text</code> or <code>htmlText</code> properties of this
	 * <code>TextSprite</code>. For example:
	 * 
	 * <pre>
	 * // create a new tooltip control and set the text
	 * var ttc:TooltipControl = new TooltipControl();
	 * TextSprite(ttc.tooltip).text = "The tooltip text";
	 * </pre>
	 * 
	 * <p>Furthermore, this control fires events corresponding to tooltip show,
	 * update (move), and hide events. Listeners can be added to dynamically
	 * change the tooltip text when these events occur. Additionally, the
	 * default text tooltip can be replaced with an arbitrary
	 * <code>DisplyObject</code> to provide completely customized tooltips.</p>
	 * 
	 * @see flare.vis.events.TooltipEvent
	 * @see flare.display.TextSprite
	 */
	class TooltipControl extends Control
	{		
		public var delay(getDelay, setDelay) : Number;		
		private var _cur:DisplayObject;
		
		private var _showTimer:Timer;
		private var _hideTimer:Timer;
		private var _show:Bool ;
		private var _t:Tween;
		
		/** The tooltip delay, in milliseconds. */
		public function getDelay():Number { return _showTimer.delay; }
		public function setDelay(d:Number):Number { _showTimer.delay = d; 	return d;}
		
		/** The legal bounds for the tooltip in stage coordinates.
		 *  If null (the default), the full stage bounds are used. */
		public var tipBounds:Rectangle ;
		
		/** The x-offset from the mouse at which to place the tooltip. */
		public var xOffset:Int ;
		/** The y-offset from the mouse at which to place the tooltip. */
		public var yOffset:Int ;
		
		/** The display object presented as a tooltip. */
		public var tooltip:DisplayObject ;
		
		/** Duration of fade animations (in seconds) for tooltip show and hide.
		 *  If less than or equal to zero, no fade will be performed. */
		public var fadeDuration:Float ;
		
		/** Indicates if the tooltip should follow the mouse pointer. */
		public var followMouse:Bool ;
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new TooltipControl.
		 * @param filter a Boolean-valued filter function indicating which
		 *  items should receive tooltip handling
		 */
		public function TooltipControl(filter:*=null,
			tooltip:DisplayObject=null, show:Function=null,
			update:Function=null, hide:Function=null, delay:Number=500)
		{
			this.filter = filter;
			_showTimer = new Timer(delay);
			_showTimer.addEventListener(TimerEvent.TIMER, onShow);
			_hideTimer = new Timer(100);
			_hideTimer.addEventListener(TimerEvent.TIMER, onHide);
			
			this.tooltip = tooltip ? tooltip : createDefaultTooltip();

			if (show != null) addEventListener(TooltipEvent.SHOW, show);
			if (update != null) addEventListener(TooltipEvent.UPDATE, update);
			if (hide != null) addEventListener(TooltipEvent.HIDE, hide);
		}
		
		/**
		 * Generates a default TextSprite tooltip 
		 * @return a new default tooltip object
		 */
		public static function createDefaultTooltip():TextSprite
		{
			var fmt:TextFormat = new TextFormat("Arial", 14);
			fmt.leftMargin = 2;
			fmt.rightMargin = 2;
			
			var tip:TextSprite;
			tip = new TextSprite("", fmt);
			tip.textField.border = true;
			tip.textField.borderColor = 0;
			tip.textField.background = true;
			tip.textField.backgroundColor = 0xf5f5cc;
			tip.textField.multiline = true;
			tip.filters = [new DropShadowFilter(4,45,0,0.5)];
			return tip;
		