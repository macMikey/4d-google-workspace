  //main sheet/worksheet

Class extends cGoogleComms

Class constructor  // oGoogleAuth:object ; spreadsheet_url:text

	C_OBJECT($1)
	C_TEXT($2)

	Super($1.auth.username;$1.auth.scopes;$1.auth.googleKey.asString;$1.connectionMethod)
	This.spreadsheetID:=This._getSSIDFromURL($2)

	  //<initialize other values>
	This.endpoint:="https://sheets.googleapis.com/v4/spreadsheets/"
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

Function _ss_batchUpdate
	  //POST/v4/spreadsheets/{spreadsheetId}:batchUpdate
	  //Applies one or more updates to the spreadsheet.

	  // _______________________________________________________________________________________________________________

Function _ss_create
	  //POST/v4/spreadsheets
	  //Creates a spreadsheet, returning the newly created spreadsheet.
	  // _______________________________________________________________________________________________________________

Function _ss_get  // {(rangeString:text , includeGridData:boolean)}
	  // loads all spreadsheet data
	  // optional params:

	  //<handle params>
	C_TEXT($1)
	C_BOOLEAN($2)

	$includeGridData:=False
	If (Count parameters#2)
		$includeGridData:=False
	End if

	$queryString:="?"+\
		This._queryRange($1)+"&"+\
		"includeGridData="+Lowercase(String($includeGridData))
	  //</handle params>

	$url:=This.endpoint+This.spreadsheetID+$queryString
	C_OBJECT($oResult)
	$oResult:=Super._http(HTTP GET method;$url;"";This.auth.access.header)
	This.status:=$oResult.status
	This.sheetData:=$oResult.value

	If (This.status#200)
		$0:=Null
	Else   //fail
		$0:=This.sheetData
	End if   //$status#200

	  // _______________________________________________________________________________________________________________

Function _ss_getByDataFilter
	  //POST/v4/spreadsheets/{spreadsheetId}:getByDataFilter
	  //Returns the spreadsheet at the given ID.

	  // _______________________________________________________________________________________________________________

Function _ss_values_append
	  //POST/v4/spreadsheets/{spreadsheetId}/values/{range}:append
	  //Appends values to a spreadsheet.

	  // _______________________________________________________________________________________________________________

Function _ss_values_batchClear
	  // POST/v4/spreadsheets/{spreadsheetId}/values:batchClear
	  //Clears one or more ranges of values from a spreadsheet.

	  // _______________________________________________________________________________________________________________

Function _ss_values_batchClearByDataFilter
	  //POST/v4/spreadsheets/{spreadsheetId}/values:batchClearByDataFilter
	  //Clears one or more ranges of values from a spreadsheet.

	  // _______________________________________________________________________________________________________________

Function _ss_values_batchGet
	  // GET/v4/spreadsheets/{spreadsheetId}/values:batchGet
	  //Returns one or more ranges of values from a spreadsheet.

	  // _______________________________________________________________________________________________________________

Function _ss_values_batchGetByDataFilter
	  //POST/v4/spreadsheets/{spreadsheetId}/values:batchGetByDataFilter
	  //Returns one or more ranges of values that match the specified data filters.

	  // _______________________________________________________________________________________________________________

Function _ss_values_batchUpdate
	  //POST/v4/spreadsheets/{spreadsheetId}/values:batchUpdate
	  //Sets values in one or more ranges of a spreadsheet.

	  // _______________________________________________________________________________________________________________

Function _ss_values_batchUpdateByDataFilter
	  //POST/v4/spreadsheets/{spreadsheetId}/values:batchUpdateByDataFilter
	  //Sets values in one or more ranges of a spreadsheet.

	  // _______________________________________________________________________________________________________________

Function _ss_values_clear
	  //POST/v4/spreadsheets/{spreadsheetId}/values/{range}:clear
	  //Clears values from a spreadsheet.

	  // _______________________________________________________________________________________________________________

Function _ss_values_get  //(range:TEXT {; majorDimension: Text ; valueRenderOption:Text ; dateTimeRenderOption:Text} )
	  // Returns a range of values from a spreadsheet. The caller must specify the spreadsheet ID and a range.

	  //<handle params>
	C_TEXT($1;$2;$3;$4)
	$queryString:=This._queryRange($1)  //e.g. 28d738fdhd3v83a/values/Sheet1!A1:B2

	$appendSymbol:=""
	$valueRenderOption:=""

	$majorDimension:="DIMENSION_UNSPECIFIED"
	If (Count parameters>=3)
		$valueRenderOption:=$3
	End if

	$valueRenderOption:="FORMATTED_VALUE"
	If (Count parameters>=4)
		$valueRenderOption:=$4
	End if

	$dateTimeRenderOption:="SERIAL_NUMBER"
	If (Count parameters>=5)
		$dateTimeRenderOption:=$5
	End if

	$queryString:=$queryString+"?"+\
		"majorDimension="+$majorDimension+"&"+\
		"valueRenderOption="+$valueRenderOption+"&"+\
		"dateTimeRenderOption="+$dateTimeRenderOption

	$url:=This.endpoint+This.spreadsheetID+"/values/"+$queryString
	C_OBJECT($oResult)
	$oResult:=Super._http(HTTP GET method;$url;"";This.auth.access.header)
	This.status:=$oResult.status
	This.sheetData:=$oResult.value

	If (This.status#200)
		$0:=Null
	Else   //fail
		$0:=This.sheetData
	End if   //$status#200

	  // _______________________________________________________________________________________________________________

Function _ss_values_update  //(range:TEXT ; valuesObject: Object ; valueInputOption:Text {; includeValuesInResponse: Boolean ; responseValueRenderOption: Text ; responseDateTimeRenderOption:Text})
	  // PUT https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values/{range}
	  //Sets values in a range of a spreadsheet.


	  //<handle params>
	C_TEXT($1)
	C_OBJECT($2)
	C_TEXT($3)
	C_BOOLEAN($4)
	C_TEXT($5)
	C_TEXT($6)

	  //<mandatory parameters>
	$rangeString:=This._queryRange($1)
	$queryString:="?valueInputOption="+$3  // going to have at least one query parameter, the valuesInputOption
	  //</mandatory parameters>


	$appendSymbol:=""  // only append with ampersand if both params are defined


	$includeValuesInResponse:="false"
	If (Count parameters>=4)
		$includeValuesInResponse:=Lowercase(String($4))
	End if

	$responseValueRenderOption:="FORMATTED_VALUE"
	If (Count parameters>=5)
		$includeValuesInResponse:=$5
	End if

	$responseDateTimeRenderOption:="SERIAL_NUMBER"
	If (Count parameters>=6)
		$responseDateTimeRenderOption:=$6
	End if


	$queryString:=$queryString+\
		"&includeValuesInResponse="+$includeValuesInResponse+"&"+\
		"&responseValueRenderOption="+$responseValueRenderOption+"&"+\
		"&responseDateTimeRenderOption="+$responseDateTimeRenderOption

	  //</handle params>

	$url:=This.endpoint+This.spreadsheetID+"/values/"+$rangeString+$queryString
	C_OBJECT($oResult)
	$oResult:=Super._http(HTTP PUT method;$url;JSON Stringify($2);This.auth.access.header)
	This.status:=$oResult.status
	This.sheetData:=$oResult.value

	If (This.status#200)
		$0:=Null  //debugx  $0:=this.null
	Else   //fail‘
		$0:=This.sheetData
	End if   //$status#200

	  // ===============================================================================================================


Function _getSheetIDFromURL  //url:text
	  // accepts a url and extracts the ID of the sheet from that
	$found:=Match regex("(?<=[#&]gid=)([0-9]+)";$1;1;$foundAt;$length)
	If (Not($found))
		$0:=""
	Else
		$0:=Substring($1;$foundAt;$length)
	End if   //(not($found))

	  // _______________________________________________________________________________________________________________

Function _getSSIDFromURL  //url:text
	  // accepts a url and extracts the ID of the sheet from that
	C_TEXT($1)
	$found:=Match regex("(?<=/spreadsheets/d/)([a-zA-Z0-9-_]+)";$1;1;$foundAt;$length)
	If (Not($found)
		$0:=""
	Else
		$0:=Substring($1;$foundAt;$length)
	End if   //(not($found))

	  // _______________________________________________________________________________________________________________

Function _queryRange  //(rangeString:text)
	  //turns a range string into a query-capable string
	  // 1. replaces colons with %3A
	  // 2. removes all spaces
	  // 3. handles comma-separated compound ranges
	C_TEXT($1;$0)
	$0:=""
	If ($1#"")
		$0:=$1
		$0:=Replace string($0;":";"%3A")  //url encode
		$0:=Replace string($0;",";"&ranges=")  // A1:B1,C1 becomes ranges=A1:B1&ranges=C1
		$0:=Replace string($0;" ";"")
	End if

	  // _______________________________________________________________________________________________________________
