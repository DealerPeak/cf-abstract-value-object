cf-abstract-value-object
========================
A value or pattern object in ColdFusion is likely to share common functionality with other 
value or pattern objects within an application. The cf-abstract-value-object adds functions 
that make a pattern or value object more powerful and more usable.

Use It
------
Put AbstractValueObject.cfc anywhere you like, at a component accessible path. Unless you already 
have the timezone.cfc (in /lib in this repo), you'll need to save it also to a component accessible 
path, then wire it into AbstractValueObject.cfc either with your preferred DI framework or 
manually in the ```init()```.

Use AbstractValueObject.cfc by extending it from your value or pattern object.

	component extends="cf-abstract-value-object.AbstractValueObject" accessors="true" {}

or

	<cfcomponent extends="cf-abstract-value-object.AbstractValueObject"></cfcomponent>

Be sure to change the extends path to the location where you saved AbstractValueObject.cfc.

Highlights
----------
### getMemento()
The ```getMemento()``` function uses the getters in your value or pattern object to return 
a structural representation of the properties in your object.

Use ```format="iso"``` as an attribute of a date-typed property to return the property as 
an ISO formatted date time string.

Use ```omitWhenEmpty="true"``` as an attribute of a property to remove it from the 
memento if it's an empty string, struct, or array.

A property with a getter that returns null will not be included in the memento.

### injectFunction()
Use ```injectFunction(name, theFunction, private)``` to, you guessed it, inject a function 
into your value or pattern object. Use ```injectFunction()``` instead of direct assignment 
so that the object's cache is updated appropriately to include the injected function.

### loadFromQuery()
The ```loadFromQuery(query)``` function is handy for loading up the pattern or value object 
from a recordset. ```loadFromQuery()``` uses the setters in the value or pattern object to 
set the values of the properties based on the projected columns in the recordset. 

If a property of the object has an attribute ```loadFromJSON="true"```, the contents of the 
recordset column data will be deserialized for you. 

### loadFromStruct()
```loadFromStruct(struct, ignorePrefix)``` loads up the pattern or value object by matching 
the keys in the incoming structure with the setters in the object. 

Setting the ```ignorePrefix``` argument to a string will ensure that the supplied string 
will be ignored in the key names when looking for matches.

### reset()
If AbstractValueObject.cfc is used as a pattern object, ```reset()``` will bring the 
object back to its original state to be loaded again. For example:

	books = [
		{
			author: 'John Steinbeck',
			title: 'The Pearl'
		},
		{
			author: 'Eckhart Tolle',
			title: 'The Power of Now'
		}
	];
	
	bookResult = [];
	bookPO = new book();
	
	for (b in books) {
		arrayAppend(bookResult, bookPO.reset().loadFromStruct(books[b]));
	}

### validate()
The ```validate()``` function uses a ```required="true"``` attribute on a property to 
be sure that there is a value. If ```validate()``` finds a property that should be 
required but has no value, it will return a struct with messages. For example:

	{
		isValid: false,
		messages: [
			'flavor is required but was not supplied.',
			'enjoyable is required but was not supplied.'
		]
	}

```validate()``` will recursively check nested objects and collections of objects that 
either have their own ```validate()``` function or are memento representations of objects 
that have their own ```validate()``` function. By providing an ```item_type``` as an 
attribute on a property, the ```validate()``` function can check for required properties 
in embedded items.

	property name="scoops" type="array" omitWhenEmpty="true" item_type="cf-abstract-value-object.unittests.resources.Scoop";
	property name="vendor" type="struct" omitWhenEmpty="true" item_type="cf-abstract-value-object.unittests.resources.Vendor";

Unit Tests
----------
The unit tests for this project are built with [MXUnit](https://github.com/mxunit/mxunit).

The resources in the /unittests directory expect to find the AbstractValueObject.cfc 
at the following component path: ```cf-abstract-value-object.AbstractValueObject```. 
The component must be at this path in your web root or you'll need to set up a 
mapping in order to run the unit tests.
