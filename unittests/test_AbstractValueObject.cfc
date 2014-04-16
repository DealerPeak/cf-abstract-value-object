component extends="mxunit.framework.TestCase" {

	/* this will run once after initialization and before setUp() */
	public void function beforeTests() {}
	
	/* this will run before every single test in this test case */
	public void function setUp() {}
	
	/* this will run after every single test in this test case */
	public void function tearDown() {}
	
	/* this will run once after all tests have been run */
	public void function afterTests() {}


	/*
	 * TESTS
	 **/
	
	/**
	* @hint Test that property defaults populate mementos
	**/
	public void function getMemento_defaults_should_populate() {
		var icecream = new resources.IceCream();
		var m = icecream.getMemento();
		
		/* test food vo property */
		assertEquals('0', m.quantity);
		/* test IceCream VO property */
		assertEquals('vanilla', m.baseFlavor);
		
		/* reset vo */
		icecream.reset();
		m = icecream.getMemento();
		
		/* test food vo property */
		assertEquals('0', m.quantity);
		
		/* test icecream vo property */
		assertEquals('vanilla', m.baseFlavor);
	}
	
	/**
	* @hint Getting a memento on nested value objects works
	**/
	public void function getMemento_valueobjects_should_work() {
		var icStruct = getChocolateIceCreamStruct();
		var vendorStruct = getVendorStruct();
		var scoops = getScoops();

		/* make everything value objects */
		var icecream = new resources.IceCream()
			.loadFromStruct(icStruct)
			.setVendorObj(new resources.Vendor().loadFromStruct(vendorStruct));
		var iceCreamScoops = [];
		for (var scoop in scoops) {
			arrayAppend(iceCreamScoops, new resources.Scoop().loadFromStruct(scoop));
		}
		icecream = icecream.setScoops(iceCreamScoops);
		icecream = icecream.getMemento();
		assertEquals(4, arrayLen(icecream.scoops));
		assertEquals('mini', icecream.scoops[1].size);
		assertEquals('Tillamook', icecream.vendorobj.name);
	}
	
	/**
	 * @hint Getting a memento with nested complex items works
	 **/
	public void function getMemento_complexproperties_should_work() {
		var icStruct = getChocolateIceCreamStruct();
		var vendor = getVendorStruct();
		var scoops = getScoops();
		
		var icecream = new resources.IceCream()
			.loadFromStruct(icStruct)
			.setVendor(vendor)
			.setScoops(scoops)
			.getMemento();
		
		assertEquals(4, arrayLen(icecream.scoops));
		assertEquals('mini', icecream.scoops[1].size);
		assertEquals('Tillamook', icecream.vendor.name);
	}
	
	/**
	 * @hint Getting a memento with nested objects (not extended with AbstractValueObject) works
	 **/
	public void function getMemento_objects_should_work() {
		var icecream = new resources.IceCream();
		icecream.setVendor(new resources.VendorObj());
		assertTrue(isObject(icecream.getVendor()));
		var m = icecream.getMemento();
		assertFalse(structKeyExists(m, 'vendor'));
	}
	
	/**
	 * @hint Getting a memento with null properties shouldn't have those properties
	 **/
	public void function getMemento_nulls_should_work() {
		var icecream = new resources.IceCream().getMemento();
		assertFalse(structKeyExists(icecream, 'id'));
	}
	
	/**
	 * @hint Getting a memento with a property set to omit if empty should omit the property
	 **/
	public void function getMemento_omitwhenempty_should_work() {
		var icecream = new resources.IceCream()
			.setCategory('')
			.setScoops([])
			.setVendor({})
			.getMemento();
		assertFalse(structKeyExists(icecream, 'category'));
		assertFalse(structKeyExists(icecream, 'scoops'));
		assertFalse(structKeyExists(icecream, 'vendor'));
	}
	
	/**
	 * @hint Booleans are true or false when getMemento is serialized
	 **/
	public void function getMemento_booleans_should_work() {
		var food = new resources.IceCream()
			.setEnjoyable(true)
			.getMemento();
		json = serializeJSON(food);
		assertTrue(find('"enjoyable":true', json) > 0);
	}
	
	/**
	 * @hint ISO formatting a date in getMemento works
	 **/
	public void function getMemento_isoFormat_should_work() {
		var food = new resources.IceCream()
			.setDateInvented(createDateTime(1975, 5, 13, 16, 30, 0))
			.setDateLastEaten(createDateTime(2013, 9, 25, 11, 17, 0))
			.getMemento();
		assertEquals(createDateTime(1975, 5, 13, 16, 30, 0), food.dateInvented);
		assertEquals('2013-09-25T11:17:00-07:00', food.dateLastEaten);
	}
	
	/**
	 * @hint Injecting a function should work
	 **/
	public void function injectFunction_should_work() {
		var icecream = new resources.IceCream();
		icecream.injectFunction('myFunction', returnTrue);
		assertTrue(icecream.myFunction());
		assertTrue(icecream.runInjectedPublicFunction());
		icecream.injectFunction('myPrivateFunction', returnFalse, true);
		assertFalse(icecream.runInjectedPrivateFunction());
	}
	
	/**
	 * @hint Injecting a private function, the function shouldn't be accessible publicly
	 * @mxunit:expectedException Application
	 **/
	public void function injectFunction_private_should_work() {
		var icecream = new resources.IceCream();
		icecream.injectFunction('myPrivateFunction', returnFalse, true);
		icecream.myPrivateFunction();
	}
	
	/**
	 * @hint Loading from a query should work
	 **/
	public void function loadFromQuery_should_work() {
		var icStruct = getChocolateIceCreamStruct();
		icStruct.enjoyable = 'yes';
		var q = structToQuery(icStruct);
		var m = new resources.IceCream()
			.loadFromQuery(q)
			.getMemento();
		assertEquals(icStruct.quantity, m.quantity);
		assertEquals(icStruct.flavor, m.flavor);
		assertEquals(icStruct.baseFlavor, m.baseFlavor);
		assertTrue(m.enjoyable);
	}
	
	/**
	 * @hint Loading from a query with a property that expects JSON should work
	 **/
	public void function loadFromQuery_loadFromJSON_should_work() {
		var vendor = serializeJSON(getVendorStruct());
		var icStruct = getChocolateIceCreamStruct();
		icStruct.vendorObj = vendor;
		var q = structToQuery(icStruct);
		var m = new resources.IceCream()
			.loadFromQuery(q)
			.getMemento();
		assertEquals(1, m.vendorObj.id);
		assertEquals("Tillamook", m.vendorObj.name);
	}
	
	/**
	* @hint Test that loadFromStruct works
	**/
	public void function loadFromStruct_should_work() {
		var icStruct = getChocolateIceCreamStruct();
		var icecream = new resources.IceCream();
		icecream.loadFromStruct(icStruct);
		var m = icecream.getMemento();
		
		/* test Food VO property */
		assertEquals(icStruct.quantity, m.quantity);

		/* test IceCream VO property */
		assertEquals(icStruct.flavor, m.flavor);
		assertEquals(icStruct.baseFlavor, m.baseFlavor);
		
		/* test nested VO property */
		assertEquals(icStruct.scoops[1].size, m.scoops[1].size);
		assertEquals(false, m.scoops[1].child);
		
		assertEquals(icStruct.vendor.name, m.vendor.name);
		assertEquals("Portland", m.vendor.location);
		
		/* Test load from struct where type in the property is a component path. */
		var scoop = new resources.Scoop();
		scoop.loadFromStruct({
			'id': 1
			,'size': 'giant'
			,'flavor': {
				'id': 555
				,'flavor': 'Cookies And Cream'
				,'base_flavor': 'vanilla'
			}
		});
		AssertEquals('Cookies And Cream', scoop.getMemento().flavor.flavor);
	}
	
	/*
	 * @hint Test that propertyExists works
	 **/
	public void function propertyExists_should_work() {
		var icecream = new resources.IceCream();
		assertTrue(icecream.propertyExists('dateInvented'));
		assertTrue(icecream.propertyExists('baseFlavor'));
		assertFalse(icecream.propertyExists('whatever'));
	}
	
	/**
	 * @hint Test that reset works
	 **/
	public void function reset_should_work() {
		var icStruct = getChocolateIceCreamStruct();
		var icecream = new resources.IceCream().loadFromStruct(icStruct);
		/* test a default */
		assertEquals(icStruct.baseFlavor, icecream.getBaseFlavor());
		icecream.reset();
		assertEquals('vanilla', icecream.getBaseFlavor());
		/* test a non-default */
		icecream = new resources.IceCream().loadFromStruct(icStruct);
		assertEquals(icStruct.id, icecream.getID());
		icecream.reset();
		var id = icecream.getID();
		assertFalse(isDefined('id'));
	}
	
	/**
	 * @hint Test that validate works
	 **/
	public void function validate_should_work() {
		
		/* test is valid */
		var icStruct = getChocolateIceCreamStruct();
		var icecream = new resources.IceCream().loadFromStruct(icStruct);
		var result = icecream.validate();
		assertTrue(result.isValid);
		
		/* test is not valid on a simple property */
		icecream = new resources.IceCream().setVendor(getVendorStruct());
		result = icecream.validate();
		assertFalse(result.isValid);
		assertEquals(1, arrayLen(result.messages));
		assertEquals('id is required but not supplied.', result.messages[1]);
		
		/* test is valid on a nested object with a validate function */
		icecream = new resources.IceCream()
			.setID('myID')
			.setVendorObj(new resources.Vendor().setID(5));
		result = icecream.validate();
		assertTrue(result.isValid);
		
		/* test is not valid on a nested object with a validate function */
		icecream = new resources.IceCream()
			.setID('myID')
			.setVendorObj(new resources.Vendor());
		result = icecream.validate();
		assertFalse(result.isValid);
		assertEquals(1, arrayLen(result.messages));
		assertEquals('In vendorObj, id is required but not supplied.', result.messages[1]);
		
		/* test is valid on a nested object without a validate function */
		icecream = new resources.IceCream()
			.setID('myID')
			.setVendorObj(new resources.VendorObj());
		result = icecream.validate();
		assertTrue(result.isValid);
		
		/* test is valid on a nested struct */
		icecream = new resources.IceCream()
			.setID('myID')
			.setVendor({id: 2, name: 'Dreyers'});
		result = icecream.validate();
		assertTrue(result.isValid);
		
		/* test is not valid on a nested struct */
		icecream = new resources.IceCream()
			.setID('myID')
			.setVendor({name: 'Dreyers'});
		result = icecream.validate();
		assertFalse(result.isValid);
		assertEquals(1, arrayLen(result.messages));
		assertEquals('In vendor, id is required but not supplied.', result.messages[1]);
		
		/* test is valid on a nested collection of objects with validate function */
		icecream = new resources.IceCream()
			.setID('myID')
			.setScoops([new resources.Scoop().setID(23)]);
		result = icecream.validate();
		assertTrue(result.isValid);
		
		/* test is not valid on a nested collection of objects with validate function */
		icecream = new resources.IceCream()
			.setID('myID')
			.setScoops([new resources.Scoop()]);
		result = icecream.validate();
		assertFalse(result.isValid);
		assertEquals(1, arrayLen(result.messages));
		assertEquals('In scoops, id is required but not supplied.', result.messages[1]);
		
		/* test is valid on a nested collection of structs */
		icecream = new resources.IceCream()
			.setID('myID')
			.setVendor({id: 2, name: 'Dreyers'})
			.setScoops([{id: 2, size: 'just right'}]);
		result = icecream.validate();
		assertTrue(result.isValid);
		
		/* test is not valid on a nested collection of structs */
		icecream = new resources.IceCream()
			.setID('myID')
			.setVendor({id: 2, name: 'Dreyers'})
			.setScoops([{size: 'just right'}]);
		result = icecream.validate();
		assertFalse(result.isValid);
		assertEquals(1, arrayLen(result.messages));
		assertEquals('In scoops, id is required but not supplied.', result.messages[1]);
	}
	
	/**
	 * @hint Test that functionExists works
	 **/
	public void function functionExists_should_work() {
		var icecream = new resources.IceCream();
		makePublic(icecream, 'functionExists');
		
		/* accessors */
		assertTrue(icecream.functionExists('getID'));
		assertTrue(icecream.functionExists('setID'));
		
		/* function does not exist */
		assertFalse(icecream.functionExists('lick'));
		
		/* custom function */
		assertTrue(icecream.functionExists('buysome'));
		
		/* function in extends */
		assertTrue(icecream.functionExists('eatsome'));
		
		/* function in abstract value object */
		assertTrue(icecream.functionExists('getMemento'));
		
	}
	
	/**
	 * @hint Test that getFunctionMap works
	 **/
	public void function getFunctionMap_should_work() {
		var icecream = new resources.IceCream();
		makePublic(icecream, 'getFunctionMap');
		var map = icecream.getFunctionMap();
		
		/* accessors */
		assertTrue(structKeyExists(map, 'getID'));
		assertTrue(structKeyExists(map, 'setID'));
		
		/* function does not exist */
		assertFalse(structKeyExists(map, 'lick'));
		
		/* custom function */
		assertTrue(structKeyExists(map, 'buysome'));
		
		/* function in extends */
		assertTrue(structKeyExists(map, 'eatsome'));
		
		/* function in abstract value object */
		assertTrue(structKeyExists(map, 'getMemento'));
		
		/* test the caching mechanism */
		icecream.myFunction = returnTrue();
		assertFalse(structKeyExists(map, 'myFunction'));
		
		icecream = new resources.IceCream();
		makePublic(icecream, 'getFunctionMap');
		icecream.injectFunction('myFunction', returnTrue);
		map = icecream.getFunctionMap();
		assertTrue(structKeyExists(map, 'myFunction'));
	}
	
	/**
	 * @hint Test that _getMetaData works
	 **/
	public void function _getMetaData_should_work() {
		var icecream = new resources.IceCream();
		makePublic(icecream, '_getMetaData');
		var md = icecream._getMetaData();
		assertEquals('cf-abstract-value-object.unittests.resources.IceCream', md.fullname);
	}
	
	/**
	 * @hint Test that getProperties works
	 **/
	public void function getProperties_should_work() {
		var icecream = new resources.IceCream();
		makePublic(icecream, 'getProperties');
		var properties = icecream.getProperties();
		assertEquals(properties.flavor.default, 'Cookies and Cream');
		assertEquals(properties.dateInvented.type, 'date');
	}
	
	/**
	 * @hint Test that valueIsEmpty works
	 **/
	public void function valueIsEmpty_should_work() {
		var icecream = new resources.IceCream();
		makePublic(icecream, 'valueIsEmpty');
		
		/* test string */
		assertTrue(icecream.valueIsEmpty('','string'));
		assertFalse(icecream.valueIsEmpty('hello','string'));
		
		/* test array */
		assertTrue(icecream.valueIsEmpty([],'array'));
		assertFalse(icecream.valueIsEmpty(['hello'],'array'));
		
		/* test struct */
		assertTrue(icecream.valueIsEmpty({},'struct'));
		assertFalse(icecream.valueIsEmpty({hello: 'world'},'struct'));
		
		/* test everything else */
		assertFalse(icecream.valueIsEmpty('', 'date'));
	}
	
	
	
	/*
	 * UTILITIES: "private" so MXUnit won't run them.
	 **/
	
	/**
	* @hint "I return a Chocolate IceCream struct."
	**/
	private struct function getChocolateIceCreamStruct() {
		return {
			/* Food Props */
			"category": "dessert", 
			"enjoyable": 1,
			"dateInvented": createDateTime(1975, 5, 13, 16, 30, 0),
			"dateLastEaten": createDateTime(2013, 9, 25, 11, 17, 0),
			"quantity": 1.75, 
			"quantityUnit": "quart",
			/* Ice Cream Props */ 
			"id": "tmk_134", 
			"baseFlavor": "chocolate", 
			"flavor": "Udderly Chocolate",
			"scoops": getScoops(),
			"vendor": getVendorStruct()
		};
	}
	
	private array function getScoops() {
		return [
			{
				"id": 1,
				"size": "mini"
			},
			{
				"id": 2,
				"size": "just right"
			},
			{
				"id": 3,
				"size": "extra large"
			},
			{
				"id": 2,
				"size": "just right"
			}
		];
	}
	
	private struct function getVendorStruct() {
		return {
			"id": 1,
			"name": "Tillamook"
		};
	}
	
	private boolean function returnFalse() {
		return false;
	}
	
	private boolean function returnTrue() {
		return true;
	}
	
	private query function structToQuery(struct structToConvert) {
		var value = '';
		var newquery = QueryNew('');
		for (var key in structToConvert) {
			value = [];
			arrayAppend(value, structToConvert[key]);
			QueryAddColumn(newquery, key, 'VARCHAR', value);
		}
		return newquery;
	}

}