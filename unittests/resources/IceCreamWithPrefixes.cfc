component displayname="Ice Cream VO" hint="I am ice cream. We all scream for ice cream." extends="UnitTests.resources.vo.Food" accessors="true" {
	
	property name="ic_id" type="string";
	property name="ic_baseFlavor" type="string" default="vanilla";
	property name="flavor" type="string" default="Cookies and Cream";
	property name="scoops" type="array" omitWhenEmpty="true";
	property name="vendor" type="struct" omitWhenEmpty="true";
	property name="vendorObj" type="any";
	
}