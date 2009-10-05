package flare.data;
	
	/**
	 * Utility class for parsing and representing data field values.
	 */
	class DataUtil
	{
		/** Constant indicating a numeric data type. */
		inline public static var NUMBER:Int  = 0;
		/** Constant indicating an integer data type. */
		inline public static var INT:Int     = 1;
		/** Constant indicating a Date data type. */
		inline public static var DATE:Int    = 2;
		/** Constant indicating a String data type. */
		inline public static var STRING:Int  = 3;
		/** Constant indicating an arbitrary Object data type. */
		inline public static var OBJECT:Int  = 4;
		/** Constant indicating a boolean data type. */
		inline public static var BOOLEAN:Int = 5;
		
		/**
		 * Parse an input value given its data type.
		 * @param val the value to parse
		 * @param type the data type to parse as
		 * @return the parsed data value
		 */
		public static function parseValue(val:Dynamic, type:Int):Dynamic
		{
			switch (type) {
				case NUMBER:
					return Std.is(val, String) ? Std.parseFloat(val) : val ;
				case INT:	
					return Std.is(val, String) ? Std.parseInt(val) : val;
				case BOOLEAN:
					return Std.is(val, String) ? val == "true" : val;
				case DATE:
					return Std.is(val, String) ? Date.fromString(val) : Date.fromTime(val);
				default:		return val;
			}
		}
		
		/**
		 * Returns the data type for the input string value. This method
		 * attempts to parse the value as a number of different data types.
		 * If successful, the matching data type is returned. If no parse
		 * succeeds, this method returns the <code>STRING</code> constant.
		 * @param s the string to parse
		 * @return the inferred data type of the string contents
		 */
		public static function type(s:String):Int
		{
			if (!isNaN(Number(s))) return NUMBER;
			if (!isNaN(Date.parse(s))) return DATE;
			return STRING;

			var v:Dynamic = null;
			try{ v = Date.fromString(s); } catch (e:Dynamic) {}
			if(v != null) { 
				return DATE;
			}

			if(v == null && s.indexOf(".") == -1) {	
				v = Std.parseInt(s); 
				if(!Math.isNaN(v)) {
					return INT;
				}
			}

			if(v == null) {	
				v = Std.parseFloat(s); 
				if(!Math.isNaN(v)) {
					return NUMBER;
				}

			if(v == "true" || v == "TRUE" || v == "false" || v == "FALSE") {
				return BOOLEAN;
			}

			return STRING;	
		}
		
		/**
		 * Infers the data schema by checking values of the input data.
		 * @param tuples an array of data tuples
		 * @return the inferred schema
		 */
		public static function inferSchema(tuples:Array<Dynamic>):DataSchema
		{
			if (tuples==null || tuples.length==0) return null;
			
			var header:Array<Dynamic> = [];
			for (name in tuples[0]) {
				header.push(name);
			}
			var types:Array<Dynamic> = [];
			
			// initialize data types
			for (col in 0...header.length) {
				types[col] = DataUtil.type(tuples[0][header[col]]);
			}
			
			// now process data to infer types
			for (i in 2...tuples.length) {
				var tuple:Dynamic = tuples[i];
				for (col in 0...header.length) {
					name = header[col];
					var value:Dynamic = tuple[name];
					if (types[col] == -1 || value==null) continue;
					
					var type:Int = 
						Std.is( value, Boolean) ? BOOLEAN :
						Std.is( value, Date) ? DATE :
						Std.is( value, Int) ? INT :
						Std.is( value, Float) ? NUMBER :
						Std.is( value, String) ? STRING : OBJECT;

					if (types[col] != type) {
						types[col] = -1;
					}
				}
			}
			
			// finally, we create the schema
			var schema:DataSchema = new DataSchema();
			for (col in 0...header.length) {
				schema.addField(new DataField(header[col],
					types[col]==-1 ? DataUtil.STRING : types[col]));
			}
			return schema;
		}
		
	} // end of class DataUtil
