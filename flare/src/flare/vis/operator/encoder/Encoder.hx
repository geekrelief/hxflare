package flare.vis.operator.encoder;

	import flare.animate.Transitioner;
	import flare.util.Filter;
	import flare.util.Property;
	import flare.util.palette.Palette;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.data.ScaleBinding;
	import flare.vis.operator.Operator;

	/**
	 * Base class for Operators that perform encoding of visual variables such
	 * as color, shape, and size. All Encoders share a similar structure:
	 * A source property (e.g., a data field) is mapped to a target property
	 * (e.g., a visual variable) using a <tt>ScaleBinding</tt> instance to map
	 * between values and a <tt>Palette</tt> instance to map scaled output
	 * into visual variables such as color, shape, and size.
	 */
	class Encoder extends Operator
	{
		public var filter(getFilter, setFilter) : Dynamic;
		public var group(getGroup, setGroup) : String;
		public var palette(getPalette, setPalette) : Palette;
		public var scale(getScale, setScale) : ScaleBinding;
		public var source(getSource, setSource) : String;
		public var target(getTarget, setTarget) : String;
		/** Boolean function indicating which items to process. */
		public var _filter:Dynamic;
		/** The target property. */
		public var _target:String;
		/** A transitioner for collecting value updates. */
		public var _t:Transitioner;
		/** A scale binding to the source data. */
		public var _binding:ScaleBinding;

		/** A scale binding to the source data. */
		public function getScale():ScaleBinding { return _binding; }
		public function setScale(b:ScaleBinding):ScaleBinding {
			if (_binding) {
				if (!b.property) b.property = _binding.property;
				if (!b.group) b.group = _binding.group;
				if (!b.data) b.data = _binding.data;
			}
			_binding = b;
			return b;
		}

		/** Boolean function indicating which items to process. Only items
		 *  for which this function return true will be considered by the
		 *  labeler. If the function is null, all items will be considered.
		 *  @see flare.util.Filter */
		public function getFilter():Dynamic { return _filter; }
		public function setFilter(f:Dynamic):Dynamic { _filter = Filter._S_(f); 	return f;}

		/** The name of the data group for which to compute the encoding. */
		public function getGroup():String { return _binding.group; }
		public function setGroup(g:String):String { _binding.group = g; 	return g;}
		
		/** The source property. */
		public function getSource():String { return _binding.property; }
		public function setSource(f:String):String { _binding.property = f; 	return f;}
		
		/** The target property. */
		public function getTarget():String { return _target; }
		public function setTarget(f:String):String { _target = f; 	return f;}
		
		/** The palette used to map scale values to visual values. */
		public function getPalette():Palette { return null; }
		public function setPalette(p:Palette):Palette { 	return p;}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new Encoder.
		 * @param source the source property
		 * @param target the target property
		 * @param group the data group to process
		 * @param filter a filter function controlling which items are encoded
		 */		
		public function Encoder(source:String=null, target:String=null,
							group:String=Data.NODES, filter:*=null)
		{
			_binding = new ScaleBinding();
			_binding.property = source;
			_binding.group = group;
			_target = target;
			this.filter = filter;
		}
		
		/** @inheritDoc */
		public override function setup():void
		{
			if (visualization==null) return;
			_binding.data = visualization.data;
		