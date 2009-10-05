package flare.vis.operator.layout;

	import flare.animate.Transitioner;
	import flare.scale.ScaleType;
	import flare.util.Property;
	import flare.vis.axis.CartesianAxes;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.data.ScaleBinding;
	
	/**
	 * Layout that places items along the X and Y axes according to data
	 * properties. The AxisLayout can also compute stacked layouts, in which
	 * elements that share the same data values along an axis are consecutively
	 * stacked on top of each other.
	 */
	class AxisLayout extends Layout
	{
		public var xField(getXField, setXField) : String;
		public var xScale(getXScale, setXScale) : ScaleBinding;
		public var xStacked(getXStacked, setXStacked) : Bool;
		public var yField(getYField, setYField) : String;
		public var yScale(getYScale, setYScale) : ScaleBinding;
		public var yStacked(getYStacked, setYStacked) : Bool;
		public var _xStacks:Bool ;
		public var _yStacks:Bool ;
		
		public var _xField:Property;
		public var _yField:Property;
		public var _xBinding:ScaleBinding;
		public var _yBinding:ScaleBinding;
		
		// ------------------------------------------------
		
		/** The x-axis source property. */
		public function getXField():String { return _xBinding.property; }
		public function setXField(f:String):String { _xBinding.property = f; 	return f;}
		
		/** The y-axis source property. */
		public function getYField():String { return _yBinding.property; }
		public function setYField(f:String):String { _yBinding.property = f; 	return f;}
		
		/** Flag indicating if values should be stacked according to their
		 *  x-axis values. */
		public function getXStacked():Bool { return _xStacks; }
		public function setXStacked(b:Bool):Bool { _xStacks = b; 	return b;}

		/** Flag indicating if values should be stacked according to their
		 *  y-axis values. */
		public function getYStacked():Bool { return _yStacks; }
		public function setYStacked(b:Bool):Bool { _yStacks = b; 	return b;}
		
		/** The scale binding for the x-axis. */
		public function getXScale():ScaleBinding { return _xBinding; }
		public function setXScale(b:ScaleBinding):ScaleBinding {
			if (_xBinding) {
				if (!b.property) b.property = _xBinding.property;
				if (!b.group) b.group = _xBinding.group;
				if (!b.data) b.data = _xBinding.data;
			}
			_xBinding = b;
			return b;
		}
		
		/** The scale binding for the y-axis. */
		public function getYScale():ScaleBinding { return _yBinding; }
		public function setYScale(b:ScaleBinding):ScaleBinding {
			if (_yBinding) {
				if (!b.property) b.property = _yBinding.property;
				if (!b.group) b.group = _yBinding.group;
				if (!b.data) b.data = _yBinding.data;
			}
			_yBinding = b;
			return b;
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new AxisLayout
		 * @param xAxisField the x-axis source property
		 * @param yAxisField the y-axis source property
		 * @param xStacked indicates if values should be stacked according to
		 *  their x-axis values
		 * @param yStacked indicates if values should be stacked according to
		 *  their y-axis values
		 */		
		public function new(?xAxisField:String=null, ?yAxisField:String=null,
								   ?xStacked:Bool=false, ?yStacked:Bool=false)
		{
			
			_xStacks = false;
			_yStacks = false;
			layoutType = CARTESIAN;
			
			_xBinding = new ScaleBinding();
			_xBinding.group = Data.NODES;
			_xBinding.property = xAxisField;
			_xStacks = xStacked;
			
			_yBinding = new ScaleBinding();
			_yBinding.group = Data.NODES;
			_yBinding.property = yAxisField;
			_yStacks = yStacked;
		}
		
		/** @inheritDoc */
		public override function setup():Void
		{
			if (visualization==null) return;
			_xBinding.data = visualization.data;
			_yBinding.data = visualization.data;
			
			var axes:CartesianAxes = super.xyAxes;
			axes.xAxis.axisScale = _xBinding;
			axes.yAxis.axisScale = _yBinding;
		}
		
		/** @inheritDoc */
		public override function layout():Void
		{
			_xField = Property._S_(_xBinding.property);
			_yField = Property._S_(_yBinding.property);
			
			var axes:CartesianAxes = super.xyAxes;
			_xBinding.updateBinding(); axes.xAxis.axisScale = _xBinding;
			_yBinding.updateBinding(); axes.yAxis.axisScale = _yBinding;
			
			if (_xStacks || _yStacks) { rescale(); }			
			var x0:Int = axes.originX;
			var y0:Int = axes.originY;

			var xmap:Dynamic = _xStacks ? new Object() : null;
			var ymap:Dynamic = _yStacks ? new Object() : null;
			
			visualization.data.nodes.visit(function(d:DataSprite):Void {
				var dx:Dynamic, dy:Dynamic, x:Number, y:Number, s:Number, z:Number;
				var o:Dynamic = _t._S_(d);
				dx = _xField.getValue(d); dy = _yField.getValue(d);
				
				if (_xField != null) {
					x = axes.xAxis.X(dx);
					if (_xStacks) {
						z = x - x0;
						s = z + (isNaN(s=xmap[dy]) ? 0 : s);
						o.x = x0 + s;
						o.w = z;
						xmap[dy] = s;
					} else {
						o.x = x;
						o.w = x - x0;
					}
				}
				if (_yField != null) {
					y = axes.yAxis.Y(dy);
					if (_yStacks) {
						z = y - y0;
						s = z + (isNaN(s=ymap[dx]) ? 0 : s);
						o.y = y0 + s;
						o.h = z;
						ymap[dx] = s;
					} else {
						o.y = y;
						o.h = y - y0;
					}
				}
			});
		}
		
		/** @private */
		public function rescale():Void {
			var xmap:Dynamic = _xStacks ? new Object() : null;
			var ymap:Dynamic = _yStacks ? new Object() : null;
			var xmax:Int = 0;
			var ymax:Int = 0;
			
			visualization.data.nodes.visit(function(d:DataSprite):Void {
				var x:Dynamic = _xField.getValue(d);
				var y:Dynamic = _yField.getValue(d);
				var v:Number;
				
				if (_xStacks) {
					v = isNaN(xmap[y]) ? 0 : xmap[y];
					xmap[y] = v = (Number(x) + v);
					if (v > xmax) xmax = v;
				}
				if (_yStacks) {
					v = isNaN(ymap[x]) ? 0 : ymap[x];
					ymap[x] = v = (Number(y) + v);
					if (v > ymax) ymax = v;
				}
			});
			
			if (_xStacks) {
				_xBinding.scaleType = ScaleType.LINEAR;
				_xBinding.preferredMin = 0;
				_xBinding.preferredMax = xmax;
			}
			if (_yStacks) {
				_yBinding.scaleType = ScaleType.LINEAR;
				_yBinding.preferredMin = 0;
				_yBinding.preferredMax = ymax;
			}
		}
		
	} // end of class AxisLayout
