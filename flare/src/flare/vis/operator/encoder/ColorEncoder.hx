package flare.vis.operator.encoder;

	import flare.animate.Transitioner;
	import flare.scale.ScaleType;
	import flare.util.palette.ColorPalette;
	import flare.util.palette.Palette;
	import flare.vis.data.Data;
	
	/**
	 * Encodes a data field into color values, using a scale transform and
	 * color palette.
	 */
	class ColorEncoder extends Encoder
	{
		public var colors(getColors, null) : ColorPalette ;
		public var palette(getPalette, setPalette) : Palette;
		private var _palette:ColorPalette;
		private var _setPalette:Bool ;
		private var _ordinal:Bool ;
		
		/** @inheritDoc */
		public override function getPalette():Palette { return _palette; }
		public override function setPalette(p:Palette):Palette {
			_palette = cast( p, ColorPalette);
			_setPalette = (_palette == null);
			return p;
		}
		/** The palette as a ColorPalette instance. */
		public function getColors():ColorPalette { return _palette; }
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new ColorEncoder.
		 * @param source the source property
		 * @param group the data group to encode ("nodes" by default)
		 * @param target the target property ("lineColor" by default)
		 * @param scaleType the type of scale to use. If null, the scale type
		 *  will be determined by the underlying <code>ScaleBinding</code>
		 *  instance, based on the type of data.
		 * @param palette the color palette to use. If null, a default color
		 *  palette will be determined based on the scale type.
		 */
		public function new(?source:String=null,
			?group:String=Data.NODES, ?target:String="lineColor",
			?scaleType:String=null, ?palette:ColorPalette=null)
		{
			
			_setPalette = true;
			_ordinal = false;
			super(source, target, group);
			_binding.scaleType = scaleType;
			_palette = palette;
		}
		
		/** @inheritDoc */
		public override function setup():Void
		{
			if (visualization==null) return;
			super.setup();
		}
		
		/** @inheritDoc */
		public override function operate(?t:Transitioner=null):Void
		{
			_binding.updateBinding();
			_ordinal = ScaleType.isOrdinal(_binding.scaleType);			
			
			// create a default color palette if none explicitly set
			if (_setPalette) _palette = getDefaultPalette();
			super.operate(t); // run encoder
		}
		
		/** @inheritDoc */
		public override function encode(val:Dynamic):Dynamic
		{
			if (_ordinal) {
				return _palette.getColorByIndex(_binding.index(val));
			} else {
				return _palette.getColor(_binding.interpolate(val));
			}
		}
		
		/**
		 * Returns a default color palette based on the input scale.
		 * @param scale the scale of values to map to colors
		 * @return a default color palette for the input scale
		 */
		public function getDefaultPalette():ColorPalette
		{
			/// TODO: more intelligent color palette selection?
			if (ScaleType.isOrdinal(_binding.scaleType))
			{
				return ColorPalette.category(_binding.length);
			}
			else if (ScaleType.isQuantitative(_binding.scaleType))
			{
				var min:Int = Number(_binding.min);
				var max:Int = Number(_binding.max);
				if (min < 0 && max > 0)
					return ColorPalette.diverging();
			}
			return ColorPalette.ramp();
		}
		
	} // end of class ColorEncoder
