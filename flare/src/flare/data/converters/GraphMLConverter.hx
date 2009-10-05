package flare.data.converters;

	import flare.data.DataField;
	import flare.data.DataSchema;
	import flare.data.DataSet;
	import flare.data.DataTable;
	import flare.data.DataUtil;
	
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import haxe.xml.Fast;

	/**
	 * Converts data between GraphML markup and flare DataSet instances.
	 * <a href="http://graphml.graphdrawing.org/">GraphML</a> is a
	 * standardized XML format supporting graph structure and typed data
	 * schemas for both nodes and edges.
	 */
	class GraphMLConverter implements IDataConverter
	{    
		// -- reader ----------------------------------------------------------
		
		/** @inheritDoc */
		public function read(input:IDataInput, ?schema:DataSchema=null):DataSet
		{
			var str:String = input.readUTFBytes(input.bytesAvailable);
			var idx:Int = str.indexOf(GRAPHML);
			if (idx > 0) {
				str = str.substr(0, idx+GRAPHML.length) + 
					str.substring(str.indexOf(">", idx));
			}
			return parse(new Fast(Xml.parse(str)), schema);
		}
		
		/**
		 * Parses a GraphML XML object into a DataSet instance.
		 * @param graphml the XML object containing GraphML markup
		 * @param schema a DataSchema (typically null, as GraphML contains
		 *  schema information)
		 * @return the parsed DataSet instance
		 */
		public function parse(graphml:Fast, ?schema:DataSchema=null):DataSet
		{
			var lookup:Dynamic = {};
			var nodes:Array<Dynamic> = [], n:Dynamic;
			var edges:Array<Dynamic> = [], e:Dynamic;
			var id:String, sid:String, tid:String;
			var def:Dynamic, type:Int;
			var group:String, attrName:String, attrType:String;
			
			var nodeSchema:DataSchema = new DataSchema();
			var edgeSchema:DataSchema = new DataSchema();
			var schema:DataSchema;
			
			// set schema defaults
			nodeSchema.addField(new DataField(ID, DataUtil.STRING));
			edgeSchema.addField(new DataField(ID, DataUtil.STRING));
			edgeSchema.addField(new DataField(SOURCE, DataUtil.STRING));
			edgeSchema.addField(new DataField(TARGET, DataUtil.STRING));
			edgeSchema.addField(new DataField(DIRECTED, DataUtil.BOOLEAN,
									DIRECTED == graphml.node.graph.att.edgedefault));
			
			// parse data schema
			for (key in graphml.nodes.key) {
				id       = key.att.resolve(ID);
				group    = key.att.resolve(FOR);
				attrName = key.att.resolve(ATTRNAME);
				type     = toType(key.att.resolve(ATTRTYPE));
				def = key.node.resolve(DEFAULT).innerData;
				def = def != null && def.length > 0
					? DataUtil.parseValue(def, type) : null;
				
				schema = (group==EDGE ? edgeSchema : nodeSchema);
				schema.addField(new DataField(attrName, type, def, id));
			}
			
			// parse nodes
			for (node in graphml.nodes.node) {
				id = node.resolve(ID);
				n = parseData(node, nodeSchema);
				Reflect.setField(lookup, id, n);
				nodes.push(n);
			}
			
			// parse edges
			for (edge in graphml.nodes.edge) {
				id  = edge.att.resolve(ID);
				sid = edge.att.resolve(SOURCE);
				tid = edge.att.resolve.(TARGET);
				
				// error checking
				if (!Reflect.hasField(lookup, sid))
					error("Edge "+id+" references unknown node: "+sid);
				if (!Reflect.hasField(lookup, tid))
					error("Edge "+id+" references unknown node: "+tid);
								
				edges.push(e = parseData(edge, edgeSchema));
			}
			
			return new DataSet(
				new DataTable(nodes, nodeSchema),
				new DataTable(edges, edgeSchema)
			);
		}
		
		private function parseData(node:Fast, schema:DataSchema):Dynamic {
			var n:Dynamic = {};
			var name:String, field:DataField, value:Dynamic;
			
			// set default values
			for (i in 0...schema.numFields) {
				field = schema.getFieldAt(i);
				Reflect.setField(n, field.name, field.defaultValue);
			}
			
			// get attribute values
			for (attrName in node.x.attributes) {
				field = schema.getFieldByName(attrName);
				Reflect.setField(n, name, DataUtil.parseValue(node.att.resolve(attrName), field.type));
			}
			
			// get data values in XML
			for (data in node.nodes.data) {
				field = schema.getFieldById(data.att.resolve(KEY));
				name = field.name;
				Reflect.setField(n, name, DataUtil.parseValue(data.innerHTML, field.type));
			}
			
			return n;
		}

		// -- writer ----------------------------------------------------------
		
		/** @inheritDoc */
		public function write(data:DataSet, ?output:IDataOutput=null):IDataOutput
		{			
			// init GraphML
			var graphml:XML = new XML(GRAPHML_HEADER);
			
			// add schema
			graphml = addSchema(graphml, data.nodes.schema, NODE, NODE_ATTR);
			graphml = addSchema(graphml, data.edges.schema, EDGE, EDGE_ATTR);
			
			// add graph data
			var graph:XML = new XML(Xml.parse("<graph/>"));
			var ed:Dynamic = data.edges.schema.getFieldByName(DIRECTED).defaultValue;
			graph.@[EDGEDEF] = ed==DIRECTED ? DIRECTED : UNDIRECTED;
			addData(graph, data.nodes.data, data.nodes.schema, NODE, NODE_ATTR);
			addData(graph, data.edges.data, data.edges.schema, EDGE, EDGE_ATTR);
			graphml = graphml.appendChild(graph);
			
			if (output == null) output = new ByteArray();
			output.writeUTFBytes(graphml.toXMLString());
			return output;
		}
		
		private static function addSchema(xml:XML, schema:DataSchema,
			group:String, attrs:Dynamic):XML
		{
			var field:DataField;
			
			for (i in 0...schema.numFields) {
				field = schema.getFieldAt(i);
				if (attrs.hasOwnProperty(field.name)) continue;
				
				var key:XML = new XML(Xml.parse("<key/>"));
				key.@[ID] = field.id;
				key.@[FOR] = group;
				key.@[ATTRNAME] = field.name;
				key.@[ATTRTYPE] = fromType(field.type);
			
				if (field.defaultValue != null) {
					var def:XML = new XML(Xml.parse("<default/>"));
					def.appendChild(toString(field.defaultValue, field.type));
					key.appendChild(def);
				}
				
				xml = xml.appendChild(key);
			}
			return xml;
		}
		
		private static function addData(xml:XML, tuples:Array<Dynamic>,
			schema:DataSchema, tag:String, attrs:Dynamic):Void
		{
			for each (var tuple:Dynamic in tuples) {
				var x:XML = new XML("<"+tag+"/>");
				
				for (var name:String in tuple) {
					var field:DataField = schema.getFieldByName(name);
					if (tuple[name] == field.defaultValue) continue;
					if (attrs.hasOwnProperty(name)) {
						// add as attribute
						x.@[name] = toString(tuple[name], field.type);
					} else {
						// add as data child tag
						var data:XML = new XML(Xml.parse("<data/>"));
						data.@[KEY] = field.id;
						data.appendChild(toString(tuple[name], field.type));
						x.appendChild(data);
					}
				}
				
				xml.appendChild(x);
			}
		}	
		
		// -- static helpers --------------------------------------------------
		
		private static function toString(o:Dynamic, type:Int):String
		{
			return o.toString(); // TODO: formatting control?
		}
		
		private static function toType(type:String):Int {
			switch (type) {
				case INT:
				case INTEGER:
					return DataUtil.INT;
				case LONG:
				case FLOAT:
				case DOUBLE:
				case REAL:
					return DataUtil.NUMBER;
				case BOOLEAN:
					return DataUtil.BOOLEAN;
				case DATE:
					return DataUtil.DATE;
				case STRING:
				default:
					return DataUtil.STRING;
			}
		}
		
		private static function fromType(type:Int):String {
			switch (type) {
				case DataUtil.INT: 		return INT;
				case DataUtil.BOOLEAN: 	return BOOLEAN;
				case DataUtil.NUMBER:	return DOUBLE;
				case DataUtil.DATE:		return DATE;
				case DataUtil.STRING:
				default:				return STRING;
			}
		}
		
		private static function error(msg:String):Void {
			throw new Error(msg);
		}
		
		// -- constants -------------------------------------------------------
		
		private static var NODE_ATTR:Dynamic = {
			"id":1
		}
		private static var EDGE_ATTR:Dynamic = {
			"id":1, "directed":1, "source":1, "target":1
		};
		
		inline private static var GRAPHML_HEADER:String = "<graphml/>";
		//	"<graphml xmlns=\"http://graphml.graphdrawing.org/xmlns\"" 
        //    +" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\""
        //    +" xsi:schemaLocation=\"http://graphml.graphdrawing.org/xmlns"
        //    +" http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd\">"
        //    +"</graphml>";
        
        inline private static var GRAPHML:String    = "graphml";
		inline private static var ID:String         = "id";
	    inline private static var GRAPH:String      = "graph";
	    inline private static var EDGEDEF:String    = "edgedefault";
	    inline private static var DIRECTED:String   = "directed";
	    inline private static var UNDIRECTED:String = "undirected";
	    
	    inline private static var KEY:String        = "key";
	    inline private static var FOR:String        = "for";
	    inline private static var ALL:String        = "all";
	    inline private static var ATTRNAME:String   = "attr.name";
	    inline private static var ATTRTYPE:String   = "attr.type";
	    inline private static var DEFAULT:String    = "default";
	    
	    inline private static var NODE:String   = "node";
	    inline private static var EDGE:String   = "edge";
	    inline private static var SOURCE:String = "source";
	    inline private static var TARGET:String = "target";
	    inline private static var DATA:String   = "data";
	    inline private static var TYPE:String   = "type";
	    
	    inline private static var INT:String = "int";
	    inline private static var INTEGER:String = "integer";
	    inline private static var LONG:String = "long";
	    inline private static var FLOAT:String = "float";
	    inline private static var DOUBLE:String = "double";
	    inline private static var REAL:String = "real";
	    inline private static var BOOLEAN:String = "boolean";
	    inline private static var STRING:String = "string";
	    inline private static var DATE:String = "date";
		
	} // end of class GraphMLConverter
