package flare.vis.operator.encoder;

	import flare.scale.ScaleType;
	import flare.util.palette.Palette;
	import flare.util.palette.ShapePalette;
	import flare.vis.data.Data;
	
	/**
	 * Encodes a data field into shape values, using an ordinal scale.
	 * Shape values are integer indices that map into a shape palette, which
	 * provides drawing routines for shapes. See the
	 * <code>flare.palette.ShapePalette</code> and 
	 * <code>flare.data.render.ShapeRenderer</code> classes for more.
	 */
	class ShapeEncoder extends Encoder
	{
		public var palette(getPalette, setPalette) : Palette;
		public var shapes(getShapes, setShapes) : ShapePalette;
		private var _palette:ShapePalette;
		
		/** @inheritDoc */
		public override function getPalette():Palette { return _palette; }
		public override function setPalette(p:Palette):Palette {
			_palette = cast( p, ShapePalette);
			return p;
		}
		/** The palette as a ShapePalette instance. */
		public function getShapes():ShapePalette { return _palette; }
		public function setShapes(p:ShapePalette):ShapePalette { _palette = p; 	return p;}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new ShapeEncoder.
		 * @param source the source property
		 * @param group the data group to process
		 * @param palette the shape palette for assigning shapes
		 */
		public function new(?field:String=null,
			?group:String=Data.NODES, ?palette:ShapePalette=null)
		{
			super(field, "shape", group);
			_binding.scaleType = ScaleType.CATEGORIES;
			_palette = palette ? palette : ShapePalette.defaultPalette();
		}
		
		/** @inheritDoc */
		public override function encode(val:Dynamic):Dynamic
		{
			return _palette.getShape(_binding.index(val));
		}
		
	} // end of class ShapeEncoder
