package flare.data.converters;

	import flare.data.DataField;
	import flare.data.DataSchema;
	import flare.data.DataSet;
	import flare.data.DataTable;
	import flare.data.DataUtil;
	
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;

	/**
	 * Converts data between delimited text (e.g., tab delimited) and
	 * flare DataSet instances.
	 */
	class DelimitedTextConverter implements IDataConverter
	{
		public var delimiter(getDelimiter, setDelimiter) : String;
		private var _delim:String;
		
		public function getDelimiter():String { return _delim; }
		public function setDelimiter(d:String):String { _delim = d; 	return d;}
		
		/**
		 * Creates a new DelimitedTextConverter.
		 * @param delim the delimiter string separating values (tab by default)
		 */
		public function new(?delim:String="\t")
		{
			_delim = delim;
		}
		
		/**
		 * @inheritDoc
		 */
		public function read(input:IDataInput, ?schema:DataSchema=null):DataSet
		{
			return parse(input.readUTFBytes(input.bytesAvailable), schema);
		}
		
		/**
		 * Converts data from a tab-delimited string into ActionScript objects.
		 * @param input the loaded input data
		 * @param schema a data schema describing the structure of the data.
		 *  Schemas are optional in many but not all cases.
		 * @param data an array in which to write the converted data objects.
		 *  If this value is null, a new array will be created.
		 * @return an array of converted data objects. If the <code>data</code>
		 *  argument is non-null, it is returned.
		 */
		public function parse(text:String, ?schema:DataSchema=null):DataSet
		{
			var tuples:Array<Dynamic> = [];
			var lines:Array<Dynamic> = ~/\r\n|\r|\n/g.split(text);
			
			if (schema == null) {
				schema = inferSchema(lines);
			}
			
			var i:Int = schema.hasHeader ? 1 : 0;
			while (i<lines.length) {
				var line:String = lines[i];
				if (line.length == 0) break;
				var tok:Array<String> = line.split(_delim);
				var tuple:Dynamic = {};
				for (j in 0...schema.numFields) {
					var field:DataField = schema.getFieldAt(j);
					Reflect.setField(tuple, field.name, DataUtil.parseValue(tok[j], field.type));
				}
				tuples.push(tuple);
				++i;
			}
			return new DataSet(new DataTable(tuples, schema));
		}
		
		/**
		 * @inheritDoc
		 */
		public function write(data:DataSet, ?output:IDataOutput=null):IDataOutput
		{
			if (output==null) output = new ByteArray();
			var tuples:Array<Dynamic> = data.nodes.data;
			var schema:DataSchema = data.nodes.schema;
			
			for (tuple in tuples) {
				var i:Int = 0, s:String;
				if (schema == null) {
					for (name in Reflect.fields(tuple)) {
						if (i>0) output.writeUTFBytes(_delim);
						output.writeUTFBytes(Std.string(Reflect.field(tuple,name))); // TODO: proper string formatting
						++i;
					}
				} else {
					;
					while (i<schema.numFields) {
						var f:DataField = schema.getFieldAt(i);
						if (i>0) output.writeUTFBytes(_delim);
						output.writeUTFBytes(Std.string(Reflect.field(tuple, f.name))); // TODO proper string formatting
						++i;
					}
				}
				output.writeUTFBytes("\n");
			}
			return output;
		}
		
		/**
		 * Infers the data schema by checking values of the input data.
		 * @param lines an array of lines of input text
		 * @return the inferred schema
		 */
		public function inferSchema(lines:Array<Dynamic>):DataSchema
		{
			var header:Array<String> = lines[0].split(_delim);
			var types:Array<Dynamic> = new Array();
			
			// initialize data types
			var tok:Array<String> = lines[1].split(_delim);
			for (col in 0...header.length) {
				types[col] = DataUtil.type(tok[col]);
			}
			
			// now process data to infer types
			for (i in 2...lines.length) {
				tok = lines[i].split(_delim);
				for (col in 0...tok.length) {
					if (types[col] == -1) continue;
					var type:Int = DataUtil.type(tok[col]);
					if (types[col] != type) {
						types[col] = -1;
					}
				}
			}
			
			// finally, we create the schema
			var schema:DataSchema = new DataSchema();
			schema.hasHeader = true;
			for (col in 0...header.length) {
				schema.addField(new DataField(header[col],
					types[col]==-1 ? DataUtil.STRING : types[col]));
			}
			return schema;
		}
		
	} // end of class DelimitedTextConverter
