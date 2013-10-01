component displayname="Ice Cream VO" hint="I am ice cream. We all scream for ice cream." extends="Food" accessors="true" {
	
	property name="id" type="string" required="true";
	property name="baseFlavor" type="string" default="vanilla";
	property name="flavor" type="string" default="Cookies and Cream";
	property name="scoops" type="array" omitWhenEmpty="true" item_type="cf-abstract-value-object.unittests.resources.Scoop";
	property name="vendor" type="struct" omitWhenEmpty="true" item_type="cf-abstract-value-object.unittests.resources.Vendor";
	property name="vendorObj" type="any" loadFromJSON="true";
	
	public boolean function buysome() {
		return true;	
	}
	
	public boolean function runInjectedPrivateFunction() {
		return myPrivateFunction();	
	}
	
	public boolean function runInjectedPublicFunction() {
		return myFunction();	
	}
	
}