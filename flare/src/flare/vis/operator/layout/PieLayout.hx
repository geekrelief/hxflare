package flare.vis.operator.layout;

	import flare.util.Property;
	import flare.util.Shapes;
	import flare.vis.data.Data;
	import flare.vis.data.DataList;
	import flare.vis.data.DataSprite;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Layout that places wedges for pie and donut charts. In addition to
	 * the layout, this operator updates each node to have a "wedge" shape.
	 */
	class PieLayout extends Layout
	{
		public var source(getSource, setSource) : String;
		private var _field:Property;
		
		/** The source property determining wedge size. */
		public function getSource():String { return _field.name; }
		public function setSource(f:String):String { _field = Property._S_(f); 	return f;}

		/** The data group to layout. */
		public var group:String ;
		
		/** The radius of the pie/donut chart. If this value is not a number
		 *  (NaN) the radius will be determined from the layout bounds. */
		public var radius:Int ;		
		/** The width of wedges, negative for a full pie slice. */
		public var width:Int ;
		/** The initial angle for the pie layout (in radians). */
		public var startAngle:Int ;
		/** The total angular size of the layout (in radians, default 2 pi). */
		public var angleWidth:Int ;
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new PieLayout
		 * @param field the source data field for determining wedge size
		 * @param width the radial width of wedges, negative for full slices
		 */		
		public function new(?field:String=null, ?width:Int=-1,
								  ?group:String=Data.NODES)
		{
			
			group = Data.NODES;
			radius = NaN;
			width = -1;
			startAngle = Math.PI/2;
			angleWidth = 2*Math.PI;
			layoutType = POLAR;
			this.group = group;
			this.width = width;
			_field = (field==null) ? null : new Property(field);
		}
		
		/** @inheritDoc */
		public override function layout():Void
		{
			var b:Rectangle = layoutBounds;
			var r:Int = isNaN(radius) ? Math.min(b.width, b.height)/2 : radius;
			var a:Int = startAngle, aw:Number;
			var list:DataList = visualization.data.group(group);
			var sum:Int = list.stats(_field.name).sum;
			var anchor:Point = layoutAnchor;
			
			list.visit(function(d:DataSprite):Void {
				var aw:Int = -angleWidth * (_field.getValue(d)/sum);
				var rh:Int = (width < 0 ? 0 : width) * r;
				var o:Dynamic = _t._S_(d);
				
				d.origin = anchor;
				
				//o.angle = a + aw/2;  // angular mid-point
				//o.radius = (r+rh)/2; // radial mid-point
				o.x = 0;
				o.y = 0;
				
				o.u = a;  // starting angle
				o.w = aw; // angle width
				o.h = r;  // outer radius
				o.v = rh; // inner radius
				o.shape = Shapes.WEDGE;

				a += aw;
			});
		}
		
	} // end of class PieLayout
