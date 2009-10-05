package flare.vis.operator.label;

	import flare.animate.Transitioner;
	import flare.display.TextSprite;
	import flare.util.Filter;
	import flare.util.IEvaluable;
	import flare.util.Property;
	import flare.util.Shapes;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.operator.Operator;
	
	import flash.display.Sprite;
	import flash.text.TextFormat;

	/**
	 * Labeler that adds labels for items in a visualization. By default, this
	 * operator adds labels that are centered on each data sprite; this can be
	 * changed by configuring the offset and anchor settings.
	 * 
	 * <p>Labelers support two different approaches for adding labels:
	 * <code>CHILD</code> mode (the default) and <code>LAYER</code> mode.
	 * <ul>
	 *  <li>In <code>CHILD</code> mode, labels are added as children of
	 *      <code>DataSprite</code> instances and so become part of the data
	 *      sprite itself. In this mode, labels will automatically change
	 *      position as data sprites are re-positioned.</li>
	 *  <li>In <code>LAYER</code> mode, labels are instead added to a separate
	 *      layer of the visualization above the
	 *      <code>Visualization.marks</code> layer that contains the data
	 *      sprites. A new layer will be created as needed and can be accessed
	 *      through the <code>Visualization.labels</code> property. This mode
	 *      is particularly useful for ensuring that no labels can be occluded
	 *      by data marks. In <code>LAYER</code> mode, labels will not
	 *      automatically move along with the labeled <code>DataSprite</code>
	 *      instances if they are re-positioned. Instead, the labeler must be
	 *      re-run to keep the layout current.</li>
	 * </ul></p>
	 * 
	 * <p>To access created labels after a <code>Labeler</code> has been run,
	 * use the <code>props.label</code> property of a <code>DataSprite</code>.
	 * To have labels stored under a different property name, set the
	 * <code>access</code> property of this class to the desired name.</p>
	 */
	class Labeler extends Operator
	{
		public var access(getAccess, setAccess) : String;
		public var filter(getFilter, setFilter) : Dynamic;
		public var group(getGroup, setGroup) : String;
		public var labelPolicy(getLabelPolicy, null) : String ;
		public var labels(getLabels, null) : Sprite ;
		public var source(getSource, setSource) : String;
		/** Constant indicating that labels be placed in their own layer. */
		inline public static var LAYER:String = "layer";
		/** Constant indicating that labels be added as children. */
		inline public static var CHILD:String = "child";
		
		/** @private */
		public var _policy:String;
		/** @private */
		public var _labels:Sprite;
		/** @private */
		public var _group:String;
		/** @private */
		public var _filter:Dynamic;
		/** @private */
		public var _source:Property;
		/** @private */
		public var _access:Property ;
		
		/** @private */
		public var _t:Transitioner;
		
		/** The name of the property in which to store created labels.
		 *  The default is "props.label". */
		public function getAccess():String { return _access.name; }
		public function setAccess(s:String):String { _access = Property._S_(s); 	return s;}
		
		/** The name of the data group to label. */
		public function getGroup():String { return _group; }
		public function setGroup(g:String):String { _group = g; setup(); 	return g;}
		
		/** The source property that provides the label text. This
		 *  property will be ignored if the <code>textFunction<code>
		 *  property is non-null. */
		public function getSource():String { return _source.name; }
		public function setSource(s:String):String { _source = Property._S_(s); 	return s;}
		
		/** Boolean function indicating which items to process. Only items
		 *  for which this function return true will be considered by the
		 *  labeler. If the function is null, all items will be considered.
		 *  @see flare.util.Filter */
		public function getFilter():Dynamic { return _filter; }
		public function setFilter(f:Dynamic):Dynamic { _filter = Filter._S_(f); 	return f;}
		
		/** A sprite containing the labels, if a layer policy is used. */
		public function getLabels():Sprite { return _labels; }
		
		/** The policy for how labels should be applied.
		 *  One of LAYER (for adding a separate label layer) or
		 *  CHILD (for adding labels as children of data objects). */
		public function getLabelPolicy():String { return _policy; }
		
		/** Optional function for determining label text. */
		public var textFunction:Dynamic ;
		
		/** The text format to apply to labels. */
		public var textFormat:TextFormat;
		/** The text mode to use for the TextSprite labels.
		 *  @see flare.display.TextSprite */
		public var textMode:Int ;
		/** The horizontal alignment for labels.
		 *  @see flare.display.TextSprite */
		public var horizontalAnchor:Int ;
		/** The vertical alignment for labels.
		 *  @see flare.display.TextSprite */
		public var verticalAnchor:Int ;
		/** The default <code>x</code> value for labels. */
		public var xOffset:Int ;
		/** The default <code>y</code> value for labels. */
		public var yOffset:Int ;
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new Labeler. 
		 * @param source the property from which to retrieve the label text.
		 *  If this value is a string or property instance, the label text will
		 *  be pulled directly from the named property. If this value is a
		 *  Function or Expression instance, the value will be used to set the
		 *  <code>textFunction<code> property and the label text will be
		 *  determined by evaluating that function.
		 * @param group the data group to process
		 * @param format optional text formatting information for labels
		 * @param filter a Boolean-valued filter function determining which
		 *  items will be given labels
		 * @param policy the label creation policy. One of LAYER (for adding a
		 *  separate label layer) or CHILD (for adding labels as children of
		 *  data objects)
		 */
		public function Labeler(source:*=null, group:String=Data.NODES,
			format:TextFormat=null, filter:*=null, policy:String=CHILD)
		{
			if (source is String) {
				_source = Property._S_(source);
			} else if (source is Property) {
				_source = Property(source);
			