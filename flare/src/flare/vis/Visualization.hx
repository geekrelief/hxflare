package flare.vis;

	import flare.animate.ISchedulable;
	import flare.animate.Scheduler;
	import flare.animate.Transitioner;
	import flare.util.Displays;
	import flare.vis.axis.Axes;
	import flare.vis.axis.CartesianAxes;
	import flare.vis.controls.ControlList;
	import flare.vis.data.Data;
	import flare.vis.data.Tree;
	import flare.vis.events.DataEvent;
	import flare.vis.events.VisualizationEvent;
	import flare.vis.operator.IOperator;
	import flare.vis.operator.OperatorList;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;

	/*[Event(name="update", type="flare.vis.events.VisualizationEvent")]*/

	/**
	 * The Visualization class represents an interactive data visualization.
	 * A visualization instance consists of
	 * <ul>
	 *  <li>A <code>Data</code> instance containing <code>DataSprite</code>
	 *      objects that visually represent individual data elements</li>
	 *  <li>An <code>OperatorList</code> of visualization operators that
	 *      determine visual encodings for position, color, size and other
	 *      properties.</li>
	 *  <li>A <code>ControlList</code> of interactive controls that enable
	 *      interaction with the visualized data.</li>
	 *  <li>An <code>Axes</code> instance for presenting axes for metric
	 *      data visualizations. Axes are often configuring automatically by
	 *      the visualization's operators.</li>
	 * </ul>
	 * 
	 * <p>Visual objects are added to the display list within the
	 * <code>marks</code> property of the visualization, as the
	 * <code>Data</code> object is not a <code>DisplayObjectContainer</code>.
	 * </p>
	 * 
	 * <p>All visual elements are contained within <code>layers</code> Sprite.
	 * This includes the <code>axes</code>, <code>marks</code>, and
	 * (optionally) <code>labels</code> layers. Clients who wish to add
	 * additional layers to a visualization should add them directly to the
	 * <code>layers</code> sprite. Just take care to maintain the desired order
	 * of elements to avoid occlusion.</p>
	 * 
	 * <p>To create a new Visualization, load in a data set, construct
	 * a <code>Data</code> instance, and instantiate a new
	 * <code>Visualization</code> with the input data. Then add the series
	 * of desired operators to the <code>operators</code> property to 
	 * define the visual encodings.</p>
	 * 
	 * @see flare.vis.operator
	 */
	class Visualization extends Sprite
	{	
		public var axes(getAxes, setAxes) : Axes;	
		public var bounds(getBounds, setBounds) : Rectangle;	
		public var continuousUpdates(getContinuousUpdates, setContinuousUpdates) : Bool;	
		public var controls(getControls, null) : ControlList ;	
		public var data(getData, setData) : Data;	
		public var labels(getLabels, setLabels) : Sprite;	
		public var layers(getLayers, null) : Sprite ;	
		public var marks(getMarks, null) : Sprite ;	
		public var operators(getOperators, null) : OperatorList ;	
		public var tree(getTree, null) : Tree ;	
		public var xyAxes(getXyAxes, null) : CartesianAxes ;	
		// -- Properties ------------------------------------------------------
		
		private var _bounds:Rectangle ;
		
		private var _layers:Sprite; // sprite for all layers in visualization
		private var _marks:Sprite;  // sprite for all visualized data items
		private var _labels:Sprite; // (optional) sprite for labels
		private var _axes:Axes;     // (optional) axes, lines, and axis labels
		
		private var _data:Data;     // data structure holding visualized data
		
		private var _ops:Dynamic;              // map of all named operators
		private var _operators:OperatorList;  // the "main" operator list
		private var _controls:ControlList;    // interactive controls
		private var _rec:ISchedulable; // for running continuous updates
		
		/** The layout bounds of the visualization. This determines the layout
		 *  region for data elements. For example, with an axis layout, the
		 *  bounds determined the data layout region--this does not include
		 *  space used by axis labels. */
		public function getBounds():Rectangle { return _bounds; }
		public function setBounds(r:Rectangle):Rectangle {
			_bounds = r;
			if (stage) stage.invalidate();
			return r;
		}
		
		/** Container sprite holding each layer in the visualization. */
		public function getLayers():Sprite { return _layers; }
		
		/** Sprite containing the <code>DataSprite</code> instances. */
		public function getMarks():Sprite { return _marks; }
		
		/** Sprite containing a separate layer for labels. Null by default. */
		public function getLabels():Sprite { return _labels; }
		public function setLabels(l:Sprite):Sprite {
			if (_labels != null)
				_layers.removeChild(_labels);
			_labels = l;
			if (_labels != null) {
				_labels.name = "_labels";
				_layers.addChildAt(_labels, _layers.getChildIndex(_marks)+1);
			}
			return l;
		}
		
		/**
		 * The axes for this visualization. May be null if no axes are needed.
		 */
		public function getAxes():Axes { return _axes; }
		public function setAxes(a:Axes):Axes {
			if (_axes != null)
				_layers.removeChild(_axes);
			_axes = a;
			if (_axes != null) {
				_axes.visualization = this;
				_axes.name = "_axes";
				_layers.addChildAt(_axes, 0);
			}
			return a;
		}
		/** The axes as an x-y <code>CartesianAxes</code> instance. Returns
		 *  null if <code>axes</code> is null or not a cartesian axes instance.
		 */
		public function getXyAxes():CartesianAxes { return cast( _axes, CartesianAxes); }
		
		/** The visual data elements in this visualization. */
		public function getData():Data { return _data; }
		
		/** Tree structure of visual data elements in this visualization.
		 *  Generates a spanning tree over a graph structure, if necessary. */
		public function getTree():Tree { return _data.tree; }
		public function setData(d:Data):Data
		{
			if (_data != null) {
				_data.visit(_marks.removeChild);
				_data.removeEventListener(DataEvent.ADD, dataAdded);
				_data.removeEventListener(DataEvent.REMOVE, dataRemoved);
			}
			_data = d;
			if (_data != null) {
				_data.visit(_marks.addChild);
				_data.addEventListener(DataEvent.ADD, dataAdded);
				_data.addEventListener(DataEvent.REMOVE, dataRemoved);
			}
			return d;
		}

		/** The operator list for defining the visual encodings. */
		public function getOperators():OperatorList { return _operators; }
		
		/** The control list containing interactive controls. */
		public function getControls():ControlList { return _controls; }
		
		/** Flag indicating if the visualization should update with every
		 *  frame. False by default. */
		public function getContinuousUpdates():Bool { return _rec != null; }
		public function setContinuousUpdates(b:Bool):Bool
		{
			if (b && _rec==null) {
				_rec = new Recurrence(this);
				Scheduler.instance.add(_rec);
			}
			else if (!b && _rec!=null) {
				Scheduler.instance.remove(_rec);
				_rec = null;
			}
			return b;
		}
		
		// -- Methods ---------------------------------------------------------
		
		/**
		 * Creates a new Visualization with the given data and axes.
		 * @param data the <code>Data</code> instance containing the
		 *  <code>DataSprite</code> elements in this visualization.
		 * @param axes the <code>Axes</code> to use with this visualization.
		 *  Null by default; layout operators may re-configure the axes.
		 */
		public function new(?data:Data=null, ?axes:Axes=null) {
			
			_bounds = new Rectangle(0,0,500,500);
			addChild(_layers = new Sprite());
			_layers.name = "_layers";
			
			_layers.addChild(_marks = new Sprite()); 
			_marks.name = "_marks";
			
			if (data != null) this.data = data;
			if (axes != null) this.axes = axes;
			
			_operators = new OperatorList();
			_operators.visualization = this;
			_ops = { main:_operators };
			
			_controls = new ControlList();
			_controls.visualization = this;
			
			Displays.addStageListener(this, Event.RENDER,
				setHitArea, false, int.MIN_VALUE+1);
		}
		
		/**
		 * Update this visualization, re-calculating axis layout and running
		 * the operator chain. The input transitioner is used to actually
		 * perform value updates, enabling animated transitions. This method
		 * also issues a <code>VisualizationEvent.UPDATE</code> event to any
		 * registered listeners.
		 * @param t a transitioner or time span for updating object values. If
		 *  the input is a transitioner, it will be used to store the updated
		 *  values. If the input is a number, a new Transitioner with duration
		 *  set to the input value will be used. The input is null by default,
		 *  in which case object values are updated immediately.
		 * @param operators an optional list of named operators to run in the
		 *  update. 
		 * @return the transitioner used to store updated values.
		 */
		public function update(t:*=null, ...operators):Transitioner
		{
			if (operators) {
				if (operators.length == 0) {
					operators = null;
				} else if (operators[0] is Array) {
					operators = operators[0].length > 0 ? operators[0] : null;
				