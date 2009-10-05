package flare.data;

	/**
	 * A data field stores metadata for an individual data variable.
	 */
	class DataField
	{
		public var defaultValue(getDefaultValue, null) : Dynamic ;
		public var format(getFormat, null) : String ;
		public var id(getId, null) : String ;
		public var label(getLabel, null) : String ;
		public var name(getName, null) : String ;
		public var type(getType, null) : Int ;
		private var _id:String;
		private var _name:String;
		private var _format:String;
		private var _label:String;
		private var _type:Int;
		private var _def:Dynamic;
		
		/** A unique id for the data field, often the name. */
		public function getId():String { return _id; }
		/** The name of the data field. */
		public function getName():String { return _name; }
		/** A formatting string for printing values of this field.
		 *  @see flare.util.Stings#format
		 */
		public function getFormat():String { return _format; }
		/** A label describing this data field, useful for axis titles. */
		public function getLabel():String { return _label; }
		/** The data type of this field.
		 *  @see flare.data.DataUtil. */
		public function getType():Int { return _type; }
		/** The default value for this data field. */
		public function getDefaultValue():Dynamic { return _def; }
		
		/**
		 * Creates a new DataField.
		 * @param name the name of the data field
		 * @param type the data type of this field
		 * @param def the default value of this field
		 * @param id a unique id for the field. If null, the name will be used
		 * @param format a formatting string for printing values of this field
		 * @param label a label describing this data field
		 */
		public function new(name:String, type:Int, ?def:Dynamic=null,
		           ?id:String=null, ?format:String=null, ?label:String=null)
		{
			_name = name;
			_type = type;
			_def = def;
			_id = (id==null ? name : id);
			_format = format;
			_label = label==null ? name : _label;
		}
		
	} // end of class DataField
