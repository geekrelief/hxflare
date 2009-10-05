package flare.vis.events;

	import flare.vis.data.DataList;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	
	import flash.events.Event;
	
	/**
	 * Event fired when a data collection is modified.
	 */
	class DataEvent extends Event
	{
		public var edge(getEdge, null) : EdgeSprite ;
		public var item(getItem, null) : DataSprite ;
		public var items(getItems, null) : Array<Dynamic> ;
		public var length(getLength, null) : Int ;
		public var list(getList, null) : DataList ;
		public var node(getNode, null) : NodeSprite ;
		public var object(getObject, null) : Dynamic ;
		/** A data added event. */
		inline public static var ADD:String    = "add";
		/** A data removed event. */
		inline public static var REMOVE:String = "remove";
		/** A data updated event. */
		inline public static var UPDATE:String = "update";
		
		/** @private */
		public var _items:Array<Dynamic>;
		/** @private */
		public var _item:Dynamic;
		/** @private */
		private var _list:DataList;
		
		/** The number of items in this data event. */
		public function getLength():Int {
			return _items ? _items.length : 1;
		}
		
		/** The list of effected data items. */
		public function getItems():Array<Dynamic> {
			if (_items == null) _items = [_item];
			return _items;
		}
		
		/** The data list (if any) the items belong to. */
		public function getList():DataList { return _list; }
		
		/** The first element in the event list as an Object. */
		public function getObject():Dynamic { return _item; }
		/** The first element in the event list as a DataSprite. */
		public function getItem():DataSprite { return cast( _item, DataSprite); }
		/** The first element in the event list as a NodeSprite. */
		public function getNode():NodeSprite { return cast( _item, NodeSprite); }
		/** The first element in the event list as an EdgeSprite. */
		public function getEdge():EdgeSprite { return cast( _item, EdgeSprite); }
		
		/**
		 * Creates a new DataEvent.
		 * @param type the event type (ADD, REMOVE, or UPDATE)
		 * @param items the DataSprite(s) that were added, removed, or updated
		 * @param list (optional) the data list that was modified
		 */
		public function new(type:String, items:Dynamic, ?list:DataList=null)
		{
			super(type, false, true);
			if (Std.is( items, Array)) {
				_items = items;
				_item = _items[0];
			} else {
				_items = null;
				_item = items;
			}
			_list = list;
		}
		
		/** @inheritDoc */
		public override function clone():Event
		{
			return new DataEvent(type, _items?_items:_item, _list);
		}
		
	} // end of class DataEvent
