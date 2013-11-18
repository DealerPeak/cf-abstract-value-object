component {
	
	variables.__cache = {};
	
	/** 
	* @hint "I initialize the value object"
	**/
	public component function init(component TimeZone = createObject('component', 'lib.timezone')) {
		variables.TimeZone = arguments.TimeZone;
		return this;
	}
	
	/**
	* @hint "I get a struct representation of the value object based on the value object's properties"
	**/
	public struct function getMemento() {
		
		/* set up a memento object */
		var memento = {};
		
		/* get the property meta data for this value object */
		var properties = getProperties();
		
		/* for each property, run the getter */
		for (var key in properties) {
			
			var prop = properties[key];
			
			/* get the getter */
			if (functionExists('get' & prop.name)) {
				
				/* run the getter */
				memento[prop.name] = evaluate('get' & prop.name & '()');
				
				/* if the property is a boolean, force true or false instead of yes or no */
				if (structKeyExists(memento, prop.name) && prop.type == 'boolean') {
					memento[prop.name] = memento[prop.name] ? true : false;
				}
				
				/* if the property is an array, may have to getMemento on each item */
				if (structKeyExists(memento, prop.name) && prop.type == 'array') {
					var items = [];
					for (var i in memento[prop.name]) {
						if (isObject(i) && functionExists('getMemento', i)) {
							arrayAppend(items, i.getMemento());
						} else {
							arrayAppend(items, i);	
						}
					}
					memento[prop.name] = items;
				}
				
				/* if the property has a format, use it */
				if (structKeyExists(memento, prop.name) && structKeyExists(prop, 'format')) {
					switch (prop.format) {
						case 'iso': {
							memento[prop.name] = TimeZone.ConvertDateTimeToISO(memento[prop.name]);
							break;
						}
					}	
				}
				
				/* is there a getMemento() method available for the property? if so, use it */
				if (structKeyExists(memento, prop.name) && isObject(memento[prop.name]) && structKeyExists(memento[prop.name], 'getMemento') && (isClosure(memento[prop.name].getMemento) || isCustomFunction(memento[prop.name].getMemento))) {
					memento[prop.name] = memento[prop.name].getMemento();
					
					/* if it's an empty memento, don't include it */
					if (structIsEmpty(memento[prop.name])) {
						structDelete(memento, prop.name);	
					}
				}
				
				/* if the property is null, don't include it */
				if (!structKeyExists(memento, prop.name)) {
					structDelete(memento, prop.name);	
				}
				
				/* if the property should be omitted on empty, don't include it if it's empty */
				if (StructKeyExists(memento, prop.name) && StructKeyExists(prop,'omitWhenEmpty') && valueIsEmpty(memento[prop.name], prop.type)) {
					structDelete(memento, prop.name);	
				}
				
			}
				
		}
		
		/* return the momento object */
		return memento;
	}

	/**
	* @hint "I inject a method into the value object"
	**/
	public component function injectFunction(required string name, required fun, private = false) {
		if (private) {
			variables[name] = fun;
		} else {
			this[name] = variables[name] = fun;
		}
		getFunctionMap()[name] = fun;
		return this;
	}

	/**
	* @hint "I load a vo from a query"
	**/
	public component function loadFromQuery(required query q) {
		
		/* if the query is empty, do nothing */
		if (q.recordcount == 0) {
			return this;
		}
		
		/* loop over the query columns */
		for (var field in listToArray(q.columnlist)) {
			
			/* look for a setter function for the field */
			if (functionExists('set' & field) && isSimpleValue(q[field][1]) && len(q[field][1])) {
				var value = q[field][1];
				
				var fieldProps = getProperties()[field];
				
				/* force a boolean if necessary */
				if (fieldProps.type == 'boolean') {
					value = value ? true : false;	
				}
				
				/* load from json if necessary */
				if (isDefined("fieldProps.loadFromJSON")) {
					value = deserializeJSON(value);
				}
				
				/* run the setter with the query value */
				var setter = this['set' & field];
				setter(value);
				
			}
			
		}
		
		/* return the value object for chaining */
		return this;
	}
	
	/**
	* @hint "I load a vo from a struct"
	**/
	public component function loadFromStruct(required struct data, string ignorePrefix = '') {
		
		/* if the struct is empty, do nothing */
		if (structIsEmpty(data)) {
			return this;
		}
		
		/* get the properties*/
		var properties = getProperties();

		/* duplicate data so calling data structure is unaffected */
		var _data = duplicate(data);

		/* loop over the incoming structure, setting properties*/
		for (var item in _data) {
			
			/* might need to ignore a prefix on the item key */
			if (len(arguments.ignorePrefix) && left(item, len(arguments.ignorePrefix)) == arguments.ignorePrefix) {
				var value = _data[item];
				item = right(item, len(item) - len(arguments.ignorePrefix));
				_data[item] = value;
			}
			
			/* if there's a setter, and either the value is simple and has a length OR it's not simple */
			if (functionExists('set' & item) && (!isSimpleValue(_data[item]) || len(_data[item]))) {
				
				/* there may be a setter that does not have a corresponding property */
				if (structKeyExists(properties, item)) {
					
					/* get a handle on the property */
					var prop = properties[item];
					
					/* force a boolean if necessary */
					if (prop.type == 'boolean') {
						_data[item] = _data[item] ? true : false;	
					}
					
					/* handle nested items */
					if (isArray(_data[item]) && structKeyExists(prop, "item_type")) {
						var allNestedItems = [];
						var nestedPO = createObject("component", prop.item_type);
						for (var nestedItem in _data[item]) {
							arrayAppend(allNestedItems, duplicate(nestedPO.reset().loadFromStruct(nestedItem)));
						}
						_data[item] = allNestedItems;
					}
					
					if (isStruct(_data[item]) && structKeyExists(prop, "item_type")) {
						_data[item] = createObject("component", prop.item_type).loadFromStruct(_data[item]);	
					}
				}
				
				var setter = this['set' & item];
				setter(_data[item]);
				
			}
			
		}

		return this;
	}
	
	/**
	* @hint "I check to see if a property exists in the vo"
	**/
	public boolean function propertyExists(prop) {
		var properties = getProperties();
		return structKeyExists(properties, prop);
	}
	
	/**
	* @hint "I set all of an object's properties to null"
	**/
	public component function reset() {
		var properties = getProperties();
		
		for (var key in properties) {
			structDelete(variables, properties[key].name);
		}
		
		return this;
	}
	
	/**
	* @hint "I return whether or not all required properties have a value"
	**/
	public struct function validate() {
		
		/* get the properties */
		var properties = getProperties();
		
		/* setup the response */
		var result = {
			isValid: true,
			messages: []	
		};
		
		/* loop over the properties */
		for (var key in properties) {
			
			/* reset value */
			var value = Javacast('null', 0);
			
			/* get a handle on the property */
			var prop = properties[key];
			
			/* we only care about properties that have a getter */
			if (functionExists('get' & prop.name)) {
				
				/* get the value */
				value = evaluate('get' & prop.name & '()');
				
				/* if the item is required, be sure its getter has a value */
				if (structKeyExists(prop, 'required') && prop.required) {
					
					/* if the getter returned null or the value is empty, validate has failed */
					if (!isDefined('value') || valueIsEmpty(value, prop.type)) {
						
						/* add a message to the result */
						result.isValid = false;
						arrayAppend(result.messages, prop.name & ' is required but not supplied.');
						
					}
					
				}
				
				/* if the item is an object, validate it */
				if (isDefined('value') && isObject(value) && structKeyExists(value, 'validate') && (isClosure(value.validate) || isCustomFunction(value.validate))) {
					/* validate the item */
					var valid = value.validate();
					
					/* if the item is invalid, add to the result */
					if (!valid.isValid) {
						result.isValid = false;
						for (var msg in valid.messages) {
							arrayAppend(result.messages, 'In ' & prop.name & ', ' & msg);	
						}
					}
					
				}
				
				/* if the item is a struct, validate the item */
				if (isDefined('value') && prop.type == 'struct' && !isObject(value) && structKeyExists(prop, 'item_type')) {
				
					/* run the getter to get the value, unless it was already gotten above */
					value = isDefined('value') ? value : evaluate('get' & prop.name & '()');
					
					/* if there's a value, go about validating it */
					if (isDefined('value')) {
						
						/* validate the item */
						var valid = createObject('component', prop.item_type).loadFromStruct(value).validate();
						
						/* if the item is invalid, add to the result */
						if (!valid.isValid) {
							result.isValid = false;
							for (var msg in valid.messages) {
								arrayAppend(result.messages, 'In ' & prop.name & ', ' & msg);	
							}
						}
					}
				}
				
				/* if the item is an array of value objects, validate the collection */
				if (isDefined('value') && prop.type == 'array' && arrayLen(value) > 0 && isObject(value[1])) {
					
					/* loop over the collection */
					for (var item in value) {
						
						/* if the item has a validate function, run it */
						if (structKeyExists(item, 'validate') && (isClosure(item.validate) || isCustomFunction(item.validate))) {
							
							/* validate the item */
							var valid = item.validate();
							
							/* if the item is invalid, add to the result */
							if (!valid.isValid) {
								result.isValid = false;
								for (var msg in valid.messages) {
									arrayAppend(result.messages, 'In ' & prop.name & ', ' & msg);	
								}
							}
								
						}
							
					}
					
				}
				
				/* if the item is an array of structs, validate the collection */
				if (isDefined('value') && prop.type == 'array' && arrayLen(value) > 0 && !isObject(value[1]) && isStruct(value[1]) && structKeyExists(prop, 'item_type')) {
					
					/* use the item_type as a pattern object */
					var itempo = isDefined('itempo') ? itempo.reset() : createObject('component', prop.item_type);
					
					/* loop over the items, creating po's and validating them */
					for (var item in value) {
					
						/* validate the item */
						var valid = itempo.loadFromStruct(item).validate();
						
						/* if the item is invalid, add to the result */
						if (!valid.isValid) {
							result.isValid = false;
							for (var msg in valid.messages) {
								arrayAppend(result.messages, 'In ' & prop.name & ', ' & msg);	
							}
						}
						
					}
					
				}
				
			}
			
		}
		
		return result;
	}
	
	/*
	 * PRIVATE METHODS 
	 **/
	
	/**
	* @hint "I check to see if a function exists in this value object"
	**/
	private boolean function functionExists(required string functionName) {
		return StructKeyExists(getFunctionMap(), functionName);
	}
	
	/**
	* @hint "I get a list of all functions, taking inheritance into account"
	**/
	private struct function getFunctionMap() {
		if ( !StructKeyExists(variables.__cache, 'functionMap') ) {
			var metaData = _getMetaData();
			var functionMap = {};
			
			while (structKeyExists(metaData, 'extends')) {
				if (structKeyExists(metaData, 'functions') && isArray(metaData.functions)) {
					for (var fun in metaData.functions) {
						if (!StructKeyExists(functionMap, fun.name)) {
							functionMap[fun.name] = true;	
						}
					}
				}
				metaData = metaData.extends;
			}
			
			variables.__cache.functionMap = functionMap;
		}
		
		return variables.__cache.functionMap;
	}
	
	/**
	* @hint "I get this objects meta data from CF."
	**/
	private struct function _getMetaData() {
		if ( !StructKeyExists(variables.__cache, 'MetaData') ) {
			variables.__cache.MetaData = getMetaData(this);
		}
		return variables.__cache.MetaData;
	}
	
	/**
	* @hint "I get an object's properties, taking inheritance into account"
	**/
	private struct function getProperties() {
		if ( !StructKeyExists(variables.__cache, 'Properties') ) {
			var metaData = _getMetaData();
			var properties = {};
			var propertyList = "";
			
			while (structKeyExists(metaData, 'extends')) {
				if (structKeyExists(metaData, 'properties') && isArray(metaData.properties)) {
					for (var prop in metaData.properties) {
						if (!StructKeyExists(properties, prop.name)) {
							properties[prop.name] = prop;
						}
					}
				}
				metaData = metaData.extends;
			}
			
			variables.__cache.Properties = properties;
		}
		
		return variables.__cache.Properties;
	}
	
	/**
	* @hint "I check to see if a value is empty based on the incoming type"
	**/
	private boolean function valueIsEmpty(required any value, required string type) {
		switch (type) {
			case "string": {
				return len(value) == 0;
			}
			case "array": {
				return arrayLen(value) == 0;	
			}
			case "struct": {
				return structIsEmpty(value);	
			}
		}
		
		return false;
	}
	
}