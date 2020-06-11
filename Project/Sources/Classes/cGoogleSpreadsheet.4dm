  //main sheet/worksheet

Class extends cGoogleComms

Class constructor  // oGoogleAuth:object ; spreadsheet_url:text
	
	C_OBJECT:C1216($1)
	C_TEXT:C284($2)
	
	Super:C1705($1.auth.username;$1.auth.scopes;$1.auth.googleKey.asString;$1.connectionMethod)
	This:C1470.spreadsheetID:=This:C1470._getSSIDFromURL($2)
	
	  //<initialize other values>
	This:C1470.endpoint:="https://sheets.googleapis.com/v4/spreadsheets/"
	  //</initialize other values>
	
	  // ===============================================================================================================
	
	
Function developerMetadata_get
	  //GET/v4/spreadsheets/{spreadsheetId}/developerMetadata/{metadataId}
	  //Returns the developer metadata with the specified ID.
	
	  // _______________________________________________________________________________________________________________
	
Function developerMetadata_search
	  //POST/v4/spreadsheets/{spreadsheetId}/developerMetadata:search
	  //Returns all developer metadata matching the specified DataFilter.
	
	  // _______________________________________________________________________________________________________________
	
Function _SS_batchUpdate
	  //POST/v4/spreadsheets/{spreadsheetId}:batchUpdate
	  //Applies one or more updates to the spreadsheet.
	
	  // _______________________________________________________________________________________________________________
	
Function _SS_create
	  //POST/v4/spreadsheets
	  //Creates a spreadsheet, returning the newly created spreadsheet.
	  // _______________________________________________________________________________________________________________
	
Function _SS_get  // {(rangeString:text , includeGridData:boolean)}
	  // loads all spreadsheet data
	  // optional params:
	  // rangeString is an A1-formatted range, e.g. "A1", "A1:B2", "A1:B2,C1"
	  // includeGridData is a boolean
	
	  //<handle params>
	C_TEXT:C284($1)
	C_BOOLEAN:C305($2)
	$rangeString:=""
	$includeGridData:=""
	$queryString:=""
	$appendSymbol:=""  // only append with ampersand if both params are defined
	
	If (Count parameters:C259>0)
		$queryString:="?"
		$ranges:=This:C1470._queryRange($1)
		
		If ($2#"")
			$includeGridData:="includeGridData="+lower(String:C10($2))
		End if 
		
		If (($ranges#"") & ($includeGridData#""))
			$appendSymbol:="&"
		End if 
		
		$queryString:=$queryString+$ranges+$appendSymbol+$includeGridData
	End if   // count parameters > 0
	  //</handle params>
	
	$url:=This:C1470.endpoint+This:C1470.spreadsheetID+$queryString
	C_OBJECT:C1216($oResult)
	$oResult:=Super:C1706._http_get($url;This:C1470.auth.access.header)
	This:C1470.status:=$oResult.status
	This:C1470.sheetData:=$oResult.value
	
	If (This:C1470.status#200)
		$0:=Null:C1517  //debugx  $0:=this.null
	Else   //fail
		$0:=This:C1470.sheetData
	End if   //$status#200
	
	  // _______________________________________________________________________________________________________________
	
Function _SS_getByDataFilter
	  //POST/v4/spreadsheets/{spreadsheetId}:getByDataFilter
	  //Returns the spreadsheet at the given ID.
	
	  // _______________________________________________________________________________________________________________
	
Function _SS_values_append
	  //POST/v4/spreadsheets/{spreadsheetId}/values/{range}:append
	  //Appends values to a spreadsheet.
	
	  // _______________________________________________________________________________________________________________
	
Function _SS_values_batchClear
	  // POST/v4/spreadsheets/{spreadsheetId}/values:batchClear
	  //Clears one or more ranges of values from a spreadsheet.
	
	  // _______________________________________________________________________________________________________________
	
Function _SS_values_batchClearByDataFilter
	  //POST/v4/spreadsheets/{spreadsheetId}/values:batchClearByDataFilter
	  //Clears one or more ranges of values from a spreadsheet.
	
	  // _______________________________________________________________________________________________________________
	
Function _SS_values_batchGet
	  // GET/v4/spreadsheets/{spreadsheetId}/values:batchGet
	  //Returns one or more ranges of values from a spreadsheet.
	
	  // _______________________________________________________________________________________________________________
	
Function _SS_values_batchGetByDataFilter
	  //POST/v4/spreadsheets/{spreadsheetId}/values:batchGetByDataFilter
	  //Returns one or more ranges of values that match the specified data filters.
	
	  // _______________________________________________________________________________________________________________
	
Function _SS_values_batchUpdate
	  //POST/v4/spreadsheets/{spreadsheetId}/values:batchUpdate
	  //Sets values in one or more ranges of a spreadsheet.
	
	  // _______________________________________________________________________________________________________________
	
Function _SS_values_batchUpdateByDataFilter
	  //POST/v4/spreadsheets/{spreadsheetId}/values:batchUpdateByDataFilter
	  //Sets values in one or more ranges of a spreadsheet.
	
	  // _______________________________________________________________________________________________________________
	
Function _SS_values_clear
	  //POST/v4/spreadsheets/{spreadsheetId}/values/{range}:clear
	  //Clears values from a spreadsheet.
	
	  // _______________________________________________________________________________________________________________
	
Function _SS_values_get  //(range:TEXT ; {valueRenderOption:TEXT ; dateTimeRenderOption:TEXT} )
	  // Returns a range of values from a spreadsheet. The caller must specify the spreadsheet ID and a range.
	
	  //<handle params>
	C_TEXT:C284($1;$2;$3)
	$queryString:=This:C1470.spreadsheetID+"/values/"+This:C1470.queryRange($1)  //e.g. 28d738fdhd3v83a/values/Sheet1!A1:B2
	
	$appendSymbol:=""
	$valueRenderOptionString:=""
	$dateTimeRenderOption:=""
	If (Count parameters:C259>1)
		$queryString:=$queryString+"?"
		
		If ($2#"")
			$valueRenderOptionString:="valueRenderOption="+$2
		End if 
		
		If ($3#"")
			$dateTimeRenderOption:="dateTimeRenderOption="+$3
		End if 
		
		If ((#2#"") & ($3#""))
			$appendSymbol:="&"
		End if 
	End if 
	
	$queryString:=$queryString+$valueRenderOptionString+$appendSymbol+$dateTimeRenderOption
	
	$url:=This:C1470.endpoint+This:C1470.spreadsheetID+$queryString
	C_OBJECT:C1216($oResult)
	$oResult:=Super:C1706._http_get($url;This:C1470.auth.access.header)
	This:C1470.status:=$oResult.status
	This:C1470.sheetData:=$oResult.value
	
	If (This:C1470.status#200)
		$0:=Null:C1517  //debugx  $0:=this.null
	Else   //fail
		$0:=This:C1470.sheetData
	End if   //$status#200
	
	  // _______________________________________________________________________________________________________________
	
Function _SS_values_update
	  //PUT/v4/spreadsheets/{spreadsheetId}/values/{range}
	  //Sets values in a range of a spreadsheet.
	
	
	  // ===============================================================================================================
	
	
Function _getSheetIDFromURL  //url:text
	  // accepts a url and extracts the ID of the sheet from that
	$found:=Match regex:C1019("(?<=[#&]gid=)([0-9]+)";$1;1;$foundAt;$length)
	If (Not:C34($found))
		$0:=""
	Else 
		$0:=Substring:C12($1;$foundAt;$length)
	End if   //(not($found))
	
	  // _______________________________________________________________________________________________________________
	
Function _getSSIDFromURL  //url:text
	  // accepts a url and extracts the ID of the sheet from that
	C_TEXT:C284($1)
	$found:=Match regex:C1019("(?<=/spreadsheets/d/)([a-zA-Z0-9-_]+)";$1;1;$foundAt;$length)
	If (Not:C34($found)
		$0:=""
	Else 
		$0:=Substring:C12($1;$foundAt;$length)
	End if   //(not($found))
	
	  // _______________________________________________________________________________________________________________
	
Function _queryRange  //(rangeString:text)
	  //turns a range string into a query-capable string
	  // 1. adds "ranges=" to the front
	  // 2. removes all spaces
	  // 3. handles comma-separated compound ranges
	C_TEXT:C284($1;$0)
	$0:=""
	If ($1#"")
		$0:="ranges="+$1
		$0=Replace string:C233($0;",";"&ranges=")  // A1:B1,C1 becomes ranges=A1:B1&ranges=C1
		$0:=Replace string:C233($0;" ";"")
	End if 
	
	  // _______________________________________________________________________________________________________________
	
	