package flare.flex;

	import flare.data.DataSet;
	import flare.display.DirtySprite;
	import flare.vis.Visualization;
	import flare.vis.axis.Axes;
	import flare.vis.axis.CartesianAxes;
	import flare.vis.data.Data;
	
	import mx.containers.Canvas;

	/**
	 * Flex component that wraps a Flare visualization instance. This class can
	 * be used to create Flare visualizations within an MXML file. The
	 * underlying Flare <code>Visualization</code> instance can always be
	 * accessed using the <code>visualization</code> property.
	 */
	class FlareVis extends Canvas
	{
		public var axes(getAxes, null) : Axes ;
		public var controls(null, setControls) : Array<Dynamic>;
		public var dataSet(null, setDataSet) : Dynamic;
		public var operators(null, setOperators) : Array<Dynamic>;
		public var visHeight(getVisHeight, setVisHeight) : Number;
		public var visWidth(getVisWidth, setVisWidth) : Number;
		public var visualization(getVisualization, setVisualization) : Visualization;
		public var xyAxes(getXyAxes, null) : CartesianAxes ;
		private var _vis:Visualization;
		
		/** The visualization operators used by this visualization. This
		 *  should be an array of IOperator instances. */
		public function setOperators(a:Array<Dynamic>):Array<Dynamic> {
			_vis.operators.list = a;
			_vis.update();
			return a;
		}
		
		/** The interactive controls used by this visualization. This
		 *  should be an array of IControl instances. */
		public function setControls(a:Array<Dynamic>):Array<Dynamic> {
			_vis.controls.list = a;
			_vis.update();
			return a;
		}
		
		/** Sets the data visualized by this instance. The input value can be
		 *  an array of data objects, a Data instance, or a DataSet instance.
		 *  Any existing data will be removed and new NodeSprite instances will
		 *  be created for each object in the input arrary. */
		public function setDataSet(d:Dynamic):Dynamic {
			var dd:Data;
			
			if (Std.is( d, Data)) {
				dd = Data(d);
			} else if (Std.is( d, Array)) {
				dd = Data.fromArray(cast( d, Array));
			} else if (Std.is( d, DataSet)) {
				dd = Data.fromDataSet(cast( d, DataSet));
			} else {
				throw new Error("Unrecognized data set type: "+d);
			}
			_vis.data = dd;
			_vis.operators.setup();
			_vis.update();
			return d;
		}
		
		/** Returns the axes for the backing visualization instance. */
		public function getAxes():Axes { return _vis.axes; }
		
		/** Returns the CartesianAxes for the backing visualization instance. */
		public function getXyAxes():CartesianAxes { return _vis.xyAxes; }
		
		/** Returns the backing Flare visualization instance. */
		public function getVisualization():Visualization {
			return _vis;
		}
		public function setVisualization(v:Visualization):Visualization{
			if (rawChildren.contains(_vis))
				rawChildren.removeChild(_vis);
			_vis = v;
			rawChildren.addChild(_vis);
			_vis.x = _margin;
			return v;
		}
		
		public function getVisWidth():Number { return _vis.bounds.width; }
		public function setVisWidth(w:Number):Number {
			_vis.bounds.width = w;
			_vis.update();
			invalidateSize();
			return w;
		}
		
		public function getVisHeight():Number { return _vis.bounds.height; }
		public function setVisHeight(h:Number):Number {
			_vis.bounds.height = h;
			_vis.update();
			invalidateSize();
			return h;
		}
		
		// --------------------------------------------------------------------
		
		private var _margin:Int ;
		
		/**
		 * Creates a new FlareVis component. By default, a new visualization
		 * with an empty data set is created.
		 * @param data the data to visualize. If this value is null, a new
		 *  empty data instance will be used.
		 */
		public function new(?data:Data=null) {
			
			_margin = 10;
			this.rawChildren.addChild(
				_vis = new Visualization(data==null ? new Data() : data)
			);
			_vis.x = _margin;
		}
		
		// -- Flex Overrides --------------------------------------------------
		
		/** @private */
		public override function getExplicitOrMeasuredWidth():Number {
			DirtySprite.renderDirty(); // make sure everything is current
			var w:Int = _vis.bounds.width;
			if (_vis.width > w) {
				// TODO: this is a temporary hack. fix later!
				_vis.x = _margin + Math.abs(_vis.getBounds(_vis).x);
				w = _vis.width;
			}
			return 2*_margin + Math.max(super.getExplicitOrMeasuredWidth(), w);
		}
		
		/** @private */
		public override function getExplicitOrMeasuredHeight():Number {
			DirtySprite.renderDirty(); // make sure everything is current
			return Math.max(super.getExplicitOrMeasuredHeight(),
							_vis.bounds.height,
							_vis.height);
		}
		
	} // end of class FlareVis
