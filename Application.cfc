<cfcomponent>
    <cfset this.name = "FinanceTracker">
    <cfset this.sessionManagement = true>
    <cfset this.applicationTimeout = createTimeSpan(0, 1, 0, 0)>
    <cfset this.sessionTimeout = createTimeSpan(0, 0, 30, 0)>
    <cfset this.clientManagement = true>
</cfcomponent>
