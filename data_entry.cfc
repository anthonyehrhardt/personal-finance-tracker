<cfcomponent>
    <cfset VARIABLES.date_format = "mm-dd-yyyy">
    <cfset VARIABLES.CATEGORIES = {"I" = "Income", "E" = "Expense"}>

    <cffunction name="getDate" access="public" returntype="string">
        <cfargument name="dateStr" type="string" required="false" default="">
        <cfargument name="allowDefault" type="boolean" required="false" default="false">
        <cfset var validDate = "">
        
        <cfif ARGUMENTS.allowDefault AND ARGUMENTS.dateStr EQ "">
            <cfreturn dateFormat(now(), VARIABLES.date_format)>
        </cfif>

        <cftry>
            <cfset validDate = parseDateTime(ARGUMENTS.dateStr, VARIABLES.date_format)>
            <cfreturn dateFormat(validDate, VARIABLES.date_format)>
            <cfcatch>
                <cfoutput>Invalid date format. Please enter the date in dd-mm-yyyy format.</cfoutput>
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="getAmount" access="public" returntype="numeric">
        <cfargument name="amountStr" type="string" required="true">
        <cfset var amount = 0>

        <cftry>
            <cfset amount = parseNumber(ARGUMENTS.amountStr)>
            <cfif amount LE 0>
                <cfthrow message="Amount must be a non-negative non-zero value.">
            </cfif>
            <cfreturn amount>
            <cfcatch>
                <cfoutput>#cfcatch.message#</cfoutput>
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="getCategory" access="public" returntype="string">
        <cfargument name="categoryStr" type="string" required="true">
        <cfset var category = "">
        <cfset category = uCase(ARGUMENTS.categoryStr)>
        <cfif StructKeyExists(VARIABLES.CATEGORIES, category)>
            <cfreturn VARIABLES.CATEGORIES[category]>
        <cfelse>
            <cfoutput>Invalid category. Please enter 'I' for Income or 'E' for Expense.</cfoutput>
        </cfif>
    </cffunction>

    <cffunction name="getDescription" access="public" returntype="string">
        <cfargument name="descriptionStr" type="string" required="false" default="">
        <cfreturn ARGUMENTS.descriptionStr>
    </cffunction>
</cfcomponent>
