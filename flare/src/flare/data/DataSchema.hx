package flare.data;

	import flare.util.Arrays;
	
	/**
	 * A data schema represents a set of data variables and their associated 
	 * types. A schema maintains a collection of <code>DataField</code>
	 * objects.
	 * @see flare.data.DataField
	 */
	class DataSchema
	{
		public var fields(getFields, null) : Array<DataField> ;
		public var numFields(getNumFields, null) : Int ;
		public var dataRoot:String ;
		public var hasHeader:Bool ;
		
		private var _fields:/*DataField*/Array<DataField> ;
		private var _nameLookup:/*String->DataField*/Hash<DataField> ;
		private var _idLookup:/*String->DataField*/Hash<DataField> ;
		
		/** An array containing the data fields in this schema. */
		public function getFields():Array<Dynamic> { return Arrays.copy(_fields); }
		/** The number of data fields in this schema. */
		public function getNumFields():Int { return _fields.length; }
		
		/**
		 * Creates a new DataSchema.
		 * @param fields an ordered list of data fields to include in the
		 * schema
		 */
		public function new(fields:Array<DataField>)
		{
			
			dataRoot = null;
			hasHeader = false;
			_fields = [];
			_nameLookup = new Hash();
			_idLookup = new Hash();
			for (i in 0...fields.length) {
				addField(fields[i]);
			}
		}
		
		/**
		 * Adds a field to this schema.
		 * @param field the data field to add
		 */
		public function addField(field:DataField):Void
		{
			_fields.push(field);
			_nameLookup[field.name] = field;
			_idLookup[field.id] = field;
		}
		
		/**
		 * Retrieves a data field by name.
		 * @param name the data field name
		 * @return the corresponding data field, or null if no data field is
		 *  found matching the name
		 */
		public function getFieldByName(name:String):DataField
		{
			return _nameLookup.get(name);
		}
		
		/**
		 * Retrieves a data field by id.
		 * @param name the data field id
		 * @return the corresponding data field, or null if no data field is
		 *  found matching the id
		 */
		public function getFieldById(id:String):DataField
		{
			return _idLookup.get(id);
		}
		
		/**
		 * Retrieves a data field by its index in this schema.
		 * @param idx the index of the data field in this schema
		 * @return the corresponding data field
		 */
		public function getFieldAt(idx:Int):DataField
		{
			return _fields[idx];
		}
		
	} // end of class DataSchema
