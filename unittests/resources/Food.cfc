component displayname="FoodVO" hint="I am a base type of (Food) to be extended by other classes." extends="cf-abstract-value-object.AbstractValueObject" accessors="true" {
	
	property name="category" type="string" omitWhenEmpty="true";
	property name="dateInvented" type="date";
	property name="dateLastEaten" type="date" format="iso";
	property name="enjoyable" type="boolean";
	property name="quantity" type="numeric" default=0;
	property name="quantityUnit" type="string" default="ounces";
	property name="hello" type="numeric" default=0;
	
	public boolean function eatsome() {
		return true;	
	}
	
}