component displayname="Flavor VO" hint="I am a flavor." extends="cf-abstract-value-object.AbstractValueObject" accessors="true" {
	
	property name="id" type="numeric" required="true";
	property name="base_flavor" type="string";
	property name="flavor" type="string";
	
}