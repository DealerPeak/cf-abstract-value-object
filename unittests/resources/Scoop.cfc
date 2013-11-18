component displayname="Scoop VO" hint="I am a scoop." extends="cf-abstract-value-object.AbstractValueObject" accessors="true" {
	
	property name="id" type="numeric" required="true";
	property name="size" type="string";
	property name="child" type="boolean" default="false";
	
}