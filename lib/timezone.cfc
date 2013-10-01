<cfcomponent displayname="timezone" hint="Note:this cfc gets included into utilities.cfc - various timezone functions not included in mx: version 2.1 jul-2005 Paul Hastings (paul@sustainbleGIS.com)" output="No">
	<!---
	author:		paul hastings <paul@sustainableGIS.com>
	date:		11-sep-2003
	methods in this CFC:
				- isDST determines if a given date & timezone are in DST. if no date or timezone is passed
				the method defaults to current date/time and server timezone. PUBLIC.
				- getAvailableTZ returns an array of available timezones on this server (ie according to
				server's JVM). PUBLIC.
				- isValidTZ determines if a given timezone is valid according to getAvailableTZ. PUBLIC.
				- usesDST determines if a given timezone uses DST. PUBLIC.
				- getRawOffset returns the raw (as opposed to DST) offset in hours for a given timezone.
				PUBLIC.
				- getTZOffset returns offset in hours for a given date/time & timezone, uses DST if timezone
				uses and is currently in DST. returns -999 if bad date or bad timezone. PUBLIC.
				- getDST returns DST savings for given timezone. returns -999 for bad timezone. PUBLIC.
				- castToUTC return UTC from given datetime in given timezone. required argument thisDate,
				optional argument thisTZ valid timezone ID, defaults to server timezone. PUBLIC.
				- castfromUTC return date in given timezone from UTC datetime. required argument thisDate,
				optional argument thisTZ valid timezone ID, defaults to server timezone. PUBLIC.
				- castToServer returns server datetime from given datetime in given timezone. required argument
				thisDate valid datetime, optional argument thisTZ valid timezone ID, defaults to server
				timezone. PUBLIC.
				- castfromServer return datetime in given timezone from server datetime. required argument
				thisDate valdi datetime, optional argument thisTZ valid timezone ID, defaults to server
				timezone. PUBLIC.
				- getServerTZ returns server timezone. PUBLIC
				- getServerTZShort returns "short" name for the server's timezone. PUBLIC
				- getServerId returns ID for the server's timezone. PUBLIC
				-ConvertIsoToDateTime will take an ISO 8601 string and convert it to a date.
	 --->

	<!--- the time zone object itself --->
	<cfset variables.tzObj = createObject("java","java.util.TimeZone")>
	<!--- list of all available timezone ids --->
	<cfset variables.tzList = listsort(arrayToList(variables.tzObj.getAvailableIDs()), "textnocase")>
	<!--- default timezone on the server --->
	<cfset variables.mytz = variables.tzObj.getDefault().ID>


	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="Any">
		<cfreturn this>
	</cffunction>


	<!--- isValidTZ --->
	<cffunction name="isValidTZ" output="false" returntype="boolean" access="public"
				hint="validates if a given timezone is in list of timezones available on this server">
		<cfargument name="tz" required="false" default="#variables.mytz#">
		<cfreturn IIF(listFindNoCase(variables.tzList,arguments.tz), true, false)>
	</cffunction>


	<!--- isDST --->
	<cffunction name="isDST" output="false" returntype="boolean" access="public"
				hint="determines if a given date in a given timezone is in DST">
		<cfargument name="dateToTest" required="false" type="date" default="#now()#">
		<cfargument name="tz" required="true" default="#variables.mytz#">
		<cfreturn variables.tzObj.getTimeZone(arguments.tz).inDaylightTime(arguments.dateTotest)>
	</cffunction>


	<!--- getAvailableTZ --->
	<cffunction name="getAvailableTZ" output="false" returntype="array" access="public"
				hint="returns a list of timezones available on this server">
		<cfreturn listToArray(variables.tzList)>
	</cffunction>


	<!--- getTZByOffset --->
	<cffunction name="getTZByOffset" output="false" returntype="array" access="public"
				hint="returns a list of timezones available on this server for a given raw offset">
		<cfargument name="thisOffset" required="true" type="numeric">
		<cfset var rawOffset = javacast("long", arguments.thisOffset * 3600000)>
		<cfreturn variables.tzObj.getAvailableIDs(rawOffset)>
	</cffunction>


	<!--- usesDST --->
	<cffunction name="usesDST" output="false" returntype="boolean" access="public"
				hint="determines if a given timezone uses DST">
		<cfargument name="tz" required="false" default="#variables.mytz#">
		<cfreturn variables.tzObj.getTimeZone(arguments.tz).useDaylightTime()>
	</cffunction>


	<!--- getRawOffset --->
	<cffunction name="getRawOffset" output="false" access="public" returntype="numeric"
				hint="returns rawoffset in hours">
		<cfargument name="tz" required="false" default="#variables.mytz#">
		<cfreturn variables.tzObj.getTimeZone(arguments.tz).getRawOffset() / 3600000>
	</cffunction>


	<!--- getTZOffset --->
	<cffunction name="getTZOffset" output="false" access="public" returntype="numeric"
				hint="returns offset in hours">
		<cfargument name="thisDate" required="no" type="date" default="#now()#">
		<cfargument name="tz" required="false" default="#variables.mytz#">
		<cfset var timezone = variables.tzObj.getTimeZone(arguments.tz)>
		<cfset var tYear = javacast("int", Year(arguments.thisDate))>
		<!--- java months are 0 based --->
		<cfset var tMonth = javacast("int", month(arguments.thisDate)-1)>
		<cfset var tDay = javacast("int", Day(thisDate))>
		<!--- day of week --->
		<cfset var tDOW = javacast("int", DayOfWeek(thisDate))>
		<cfreturn timezone.getOffset(1, tYear, tMonth, tDay, tDOW, 0) / 3600000>
	</cffunction>


	<!--- getDST --->
	<cffunction name="getDST" output="false" access="public" returntype="numeric"
				hint="returns DST savings in hours">
		<cfargument name="tz" required="false" default="#variables.mytz#">
		<cfreturn variables.tzObj.getTimeZone(arguments.tz).getDSTSavings() / 3600000>
	</cffunction>


	<!--- castToUTC --->
	<cffunction name="castToUTC" output="false" access="public" returntype="date"
				hint="returns UTC from given date in given TZ, takes DST into account">
		<cfargument name="thisDate" required="yes" type="date">
		<cfargument name="tz" required="false" default="#variables.mytz#">
		
		<cfreturn dateAdd("h", -getTZOffset(arguments.thisdate, arguments.tz), arguments.thisDate)>
	</cffunction>


	<!--- castFromUTC --->
	<cffunction name="castFromUTC" output="false" access="public" returntype="date"
				hint="returns date in given TZ from given UTC date, takes DST into account">
		<cfargument name="thisDate" required="yes" type="date">
		<cfargument name="tz" required="false" default="#variables.mytz#">
		<cfreturn dateAdd("h", getTZOffset(arguments.thisdate, arguments.tz), arguments.thisDate)>
	</cffunction>


	<!--- castToServer --->
	<cffunction name="castToServer" output="false" access="public" returntype="date"
				hint="returns server date in given TZ from given UTC date, takes DST into account">
		<cfargument name="thisDate" required="yes" type="date">
		<cfargument name="tz" required="false" default="#variables.mytz#">
		<cfreturn dateConvert("utc2Local",castToUTC(arguments.thisDate, arguments.tz)).toString() /><!--- Fix CF10 Bug 3338974 --->
	</cffunction>


	<!--- castFromServer --->
	<cffunction name="castFromServer" output="false" access="public" returntype="date"
				hint="returns date in given TZ from given server date, takes DST into account">
		<cfargument name="thisDate" required="yes" type="date">
		<cfargument name="tz" required="false" default="#variables.mytz#">
		<cfreturn castFromUTC(dateConvert("local2UTC",arguments.thisDate).toString(),arguments.tz)><!--- Fix CF10 Bug 3338974 --->
	</cffunction>


	<!--- getServerTZ --->
	<cffunction name="getServerTZ" output="false" access="public" returntype="string"
				hint="returns server TZ (long)">
		<cfreturn variables.tzObj.getDefault().getDisplayName(true, variables.tzObj.LONG)>
	</cffunction>


	<!--- getServerTZShort --->
	<cffunction name="getServerTZShort" output="false" access="public" returntype="string"
				hint="returns server TZ (short). contributed by dan switzer: dswitzer@pengoworks.com">
		<cfreturn variables.tzObj.getDefault().getDisplayName(true, variables.tzObj.SHORT)>
	</cffunction>


	<!--- getServerId --->
	<cffunction name="getServerId" output="false" access="public" returntype="any"
				hint="returns the server timezone id. contributed by dan switzer: dswitzer@pengoworks.com">
		<cfreturn variables.mytz>
	</cffunction>
	
	
	<cffunction name="ConvertDateTimeToISO" output="false" access="public" hint="takes any valid date and/or time with timezone(defaults to local server time) and converts to ISO 8601(YYYY-MM-DDThh:mm:ssZ).">
		<cfargument name="dateTime" required="true" type="date">
		<cfargument name="withOffset" required="false" default="true">
		<cfargument name="zoneName" required="false" type="string" default="US/Pacific">
		<cfset var iso = ''>
		
		<cfif arguments.withOffset>
			<cfset iso = DateFormat(arguments.dateTime, 'yyyy-mm-dd') & 'T' & TimeFormat(arguments.dateTime, 'HH:mm:ss') & NumberFormat(this.getTZOffset(arguments.dateTime, arguments.zoneName), '+0_') & ':00'>
		<cfelse>
			<cfset var utc = this.castToUTC(arguments.dateTime, arguments.zoneName)>
			<cfset iso = DateFormat(utc, 'yyyy-mm-dd') & 'T' & TimeFormat(utc, 'HH:mm:ss') & 'Z'>
		</cfif>
		
		<cfreturn iso>		
	</cffunction>
	
	<!--- ConvertIsoToDateTime --->
	<cffunction name="ConvertIsoToDateTime" access="public" returntype="date" output="yes" description="Will take an ISO-8601 UTC time and convert it to either local time, utc time, or to a specific timezone.">
		<cfargument name="sDate" required="yes" type="string" hint="Properly formed ISO-8601 dateTime String">
		<cfargument name="sConvert" required="no" type="string" default="local" hint="utc|local|zoneName (i.e US/Pacific)" >
		<cfset var sWork = "">
		<cfset var sDatePart = "">
		<cfset var sTimePart = "">
		<cfset var sOffset = "">
		<cfset var nPos = 0>
		<cfset var dtDateTime = CreateDateTime(1900,1,1,0,0,0)>
		<!--- Trim the inbound string; set it to uppercase in preparation for conversion --->
		<cfset sWork = UCase(Trim(Arguments.sDate))>
		<!--- if the rightmost character of the sting is "Z" (for Zulu meaning UTC), remove it and change the offset to positive-zero) --->
		<cfif Right(sWork,1) IS "Z">
			<cfset sWork = Replace(sWork,"Z"," +0000", "ONE")>
		</cfif>
		<!--- extract the "T" and split out the date --->
		<cfif sWork CONTAINS "T">
			<cfset sWork = Replace(sWork, "T", " ", "ONE")>
		</cfif>
		<cfset sDatePart = ListFirst(sWork, " ")>
		<cfset sTimePart = ListGetAt(sWork, 2, " ")>
		<!--- figure out where the offset begins in the time part --->
		<cfset nPos = REFind("[\+\-]",sTimePart)>
		<cfif nPos GT 0>
			<!--- split out the offset from the time part --->
			<cfset sOffset = Right(sTimePart,Len(sTimePart)-nPos+1)>
			<cfset sTimePart = Replace(sTimePart,sOffset,"","ONE")>
		</cfif>
		
		<!--- convert the parts into the formats that are needed for conversion to POP datetime format --->
		<cfset sDatePart = DateFormat(sDatePart,"ddd, dd mmm yyyy")>
		<!--- Considers the special rule created when midnight is represented as 24:xx--->
		<cfif ListFirst(sTimePart,":") EQ 24>
			<cfset sTimePart = ListSetAt(sTimePart,1,"00",":")>
			<cfset sDatePart = DateFormat(DateAdd("d",1,sDatePart),"ddd, dd mmm yyyy")>
		</cfif>
		<cfset sTimePart = TimeFormat(sTimePart,"HH:mm:ss")>
		<cfset sOffset = Replace(sOffset,":","","ALL")>
		<!--- parse the date, time and offset parts as a POP datetime formatted string --->
		<cfset dtDateTime = ParseDateTime("#sDatePart# #sTimePart# #sOffset#","pop").toString()>
		<!--- convert the date time to local time if required --->
		<cfif len(Arguments.sConvert) AND Arguments.sConvert IS "local">
			<cfset dtDateTime = DateConvert("utc2local",dtDateTime).toString()><!--- Fix CF10 Bug 3338974 --->
		<cfelseif len(Arguments.sConvert) AND isValidTZ(Arguments.sConvert)>
			<cfset dtDateTime = castFromUTC(dtDateTime,Arguments.sConvert)>
		</cfif>
	
		<cfreturn dtDateTime>
	</cffunction>

</cfcomponent>