package flare.vis.operator.label;

	import flare.display.TextSprite;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	
	/**
	 * Labeler for a stacked area chart. Use in conjunction with the
	 * <code>StackedAreaLayout</code> operator. Adds labels to stacks whose
	 * maximum height in pixels exceeds the minimum <code>threshold</code>
	 * value.
	 * 
	 * <p><b>NOTE</b>: This has only been tested for use with horizontally
	 * oriented stacks. In the future, this will be extended to work with
	 * vertically oriented stacks as well.</p>
	 */
	class StackedAreaLabeler extends Labeler
	{
		/** The minimum width for a stack to receive a label (default 12). */
		public var threshold:Int ;
		/** The base (minimum) size for labels. */
		public var baseSize:Int ;
		/** Indicates the first column considered for label placement. This
		 *  prevents columns on the edges of the display from being labeled,
		 *  as the labels might then bleed outside the display. */
		public var columnIndex:Int ;
		
		/**
		 * Creates a new StackedAreaLabeler. 
		 * @param source the property from which to retrieve the label text.
		 *  If this value is a string or property instance, the label text will
		 *  be pulled directly from the named property. If this value is a
		 *  Function or Expression instance, the value will be used to set the
		 *  <code>textFunction<code> property and the label text will be
		 *  determined by evaluating that function.
		 */
		public function StackedAreaLabeler(source:*=null,
			group:String=Data.NODES)
		{
			super(source, group, null, null, LAYER);
		}

		/** @inheritDoc */
		protected override function process(d:DataSprite):void
		{
			var label:TextSprite;
				
			// early exit if no chance of label visibility
			if (!d.visible && !(_t._S_(d).visible)) {
				label = getLabel(d, false);
				if (label) label.visible = false;
				return;
			