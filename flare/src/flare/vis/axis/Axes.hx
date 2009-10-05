package flare.vis.axis;

	import flash.display.Sprite;
	import flare.animate.Transitioner;
	import flare.vis.Visualization;
	import flash.geom.Rectangle;
	
	/**
	 * Base class for representing metric data axes.
	 */
	class Axes extends Sprite
	{
		public var layoutBounds(getLayoutBounds, setLayoutBounds) : Rectangle;
		public var visualization(getVisualization, setVisualization) : Visualization;
		/** The visualization the axes correspond to. */
		public var _vis:Visualization;
		/** The layout bounds of the axes. */
		public var _bounds:Rectangle;
		
		/** The visualization the axes correspond to. */
		public function getVisualization():Visualization { return _vis; }
		public function setVisualization(v:Visualization):Visualization { _vis = v; 	return v;}

		/** The layout bounds of the axes. If this value is not directly set,
		 *  the layout bounds of the visualization are provided. */
		public function getLayoutBounds():Rectangle {
			if (_bounds != null) return _bounds;
			if (_vis != null) return _vis.bounds;
			return null;
		}
		public function setLayoutBounds(b:Rectangle):Rectangle { _bounds = b; 	return b;}

		/**
		 * Update these axes, performing filtering and layout as needed.
		 * @param trans a Transitioner for collecting value updates
		 * @return the input transitioner
		 */		
		public function update(?trans:Transitioner=null):Transitioner
		{
			return trans;
		}
		
	} // end of class Axes
