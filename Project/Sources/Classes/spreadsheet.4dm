Class extends _comms

Class constructor($authObject : Object; $url : Variant)
	Super:C1705("native")  //_comms type
	This:C1470._auth:=$authObject
	This:C1470._spreadsheetId:=This:C1470._getSSIdFromURL($url)
	
	//<initialize other values>
	This:C1470._endpoint:="https://sheets.googleapis.com/v4/spreadsheets"
	//</initialize other values>
	// _______________________________________________________________________________________________________________
	
	
	
	// ===============================================================================================================
	// =                                                                                                             =
	// =                                       P U B L I C   F U N C T I O N S                                       =
	// =                                                                                                             =
	// ===============================================================================================================
	
	
	
Function appendValues($range : Text; $valuesObject : Object; $valueInputOption : Text; $insertDataOption : Variant; $includeValuesInResponse : Variant; $responseValueRenderOption : Variant; $responseDateTimeRenderOption : Variant)
	//POST https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values/{range}:append
	//appends $valuesObject to the end of $range
	
	//<handle params>
	//<mandatory parameters>
	$rangeString:=This:C1470._queryRange($range)
	$valuesObject.range:=$rangeString  // has to match the query range
	$queryString:="?valueInputOption="+$valueInputOption  // going to have at least one query parameter, the valuesInputOption
	//</mandatory parameters>
	
	
	//<optional parameters>
	$insertDataOption:=$insertDataOption || "INSERT_ROWS"
	$includeValuesInResponse:=$includeValuesInResponse || "false"
	$responseValueRenderOption:=$responseValueRenderOption || "FORMATTED_VALUE"
	$responseDateTimeRenderOption:=$responseDateTimeRenderOption || "SERIAL_NUMBER"
	//</optional parameters>
	
	$queryString:=$queryString+\
		"&insertDataOption="+$insertDataOption+"&"+\
		"&includeValuesInResponse="+$includeValuesInResponse+"&"+\
		"&responseValueRenderOption="+$responseValueRenderOption+"&"+\
		"&responseDateTimeRenderOption="+$responseDateTimeRenderOption
	
	//</handle params>
	
	$url:=This:C1470._endpoint+"/"+\
		This:C1470._spreadsheetId+\
		"/values/"+\
		Super:C1706.URL_Escape($rangeString; "'")+\
		":append"+\
		$queryString  // don't escape the quotes at the edges of sheet name because it breaks the comparison google does with the range string.
	$oResult:=This:C1470._http(HTTP POST method:K71:2; $url; JSON Stringify:C1217($2))
	This:C1470._result.status:=$oResult.status
	This:C1470.sheetData:=$oResult.value
	
	If (This:C1470._result.status#200)  // fail
		return Null:C1517
	Else   //ok
		return This:C1470.sheetData
	End if   //$status#200
	// _______________________________________________________________________________________________________________
	
	
	
Function copySheetToSpreadsheet($sheetName : Text; $targetSpreadsheetId : Text)->$sheet : Object
	//https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/sheets/{sheetId}:copyTo"
	var $sheetColl : Collection
	var $sheetId : Integer
	var $ssid : Text
	var $url : Text
	var $bodyO : Object
	var $body : Text
	var $oResult : Object
	
	$sheetColl:=This:C1470.findSheetWithName($sheetName)
	$sheetId:=$sheetColl[0].properties.sheetId
	$ssId:=This:C1470._spreadsheetId
	
	$url:=This:C1470._endpoint+"/"+$ssId+"/sheets/"+String:C10($sheetId)+":copyTo"
	$bodyO:=New object:C1471("destinationSpreadsheetId"; $targetSpreadsheetId)
	$body:=JSON Stringify:C1217($bodyO)
	$oResult:=This:C1470._http(HTTP POST method:K71:2; $url; $body)
	If (OB Is defined:C1231($oResult.value; "error"))  // error occurred"// this chokes on "value.error" -> If (OB Is defined($oResult.value;"error"))  // error occurred
		This:C1470.error:=$oResult.value.error
	End if   //(ob is defined($oResult.value.error))
	This:C1470._result.status:=$oResult.status
	
	If (This:C1470._result.status#200)
		return Null:C1517
	Else 
		$sheet:=This:C1470._result.value
		return $sheet
	End if   //$status#200
	// _______________________________________________________________________________________________________________
	
	
	
Function createSpreadsheet()->$success : Boolean
	var $spreadsheetJSON : Text
	$spreadsheetJSON:=JSON Stringify:C1217(This:C1470.spreadsheet)
	$oResult:=This:C1470._http(HTTP POST method:K71:2; This:C1470._endpoint; $spreadsheetJSON)
	If (OB Is defined:C1231($oResult.value; "error"))  // error occurred"// this chokes on "value.error" -> If (OB Is defined($oResult.value;"error"))  // error occurred
		This:C1470.error:=$oResult.value.error
	End if   //(ob is defined($oResult.value.error))
	This:C1470._result.status:=$oResult.status
	
	If (This:C1470._result.status#200)
		return False:C215
	Else 
		This:C1470.spreadsheet:=$oResult.value
		This:C1470._spreadsheetId:=This:C1470.spreadsheet.spreadsheetId
		return True:C214
	End if   //$status#200
	// _______________________________________________________________________________________________________________
	
	
	
Function duplicateSheet($sourceSheetID : Integer; $insertSheetIndex : Integer; $newSheetID : Variant; $newSheetName : Variant)->$oReturn : Object
	// ( sourceSheetId:INTEGER ; insertSheetIndex:INTEGER ; {newSheetId:INTEGER} ; {newSheetName:Text} ) -> object
	//POST https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}:batchUpdate
/*
the request body is
{
  "requests": [
    {
      "duplicateSheet":
         {
           "sourceSheetId": integer,
           "insertSheetIndex": integer,
           "newSheetId": integer,
           "newSheetName": string
         }
    }
  ],
  "includeSpreadsheetInResponse": boolean,
  "responseRanges": [
    string
  ],
  "responseIncludeGridData": boolean
}
*/
	
	var $requestBody; $duplicateSheetRequest; $requests; $batchUpdate : Object
	
	//<build the duplicateSheetRequest object>
	$duplicateSheetRequest:=New object:C1471()
	$duplicateSheetRequest.sourceSheetId:=$sourceSheetID
	
	If (Count parameters:C259>=2)
		$duplicateSheetRequest.insertSheetIndex:=$insertSheetIndex
	End if   //count parameters>=2
	
	If (Count parameters:C259>=3)
		If (Not:C34(Undefined:C82($newSheetID)))
			If ($newSheetID#0)  // 0 means nope
				$duplicateSheetRequest.newSheetId:=$newSheetID
			End if 
		End if   //not(undefined($3))
	End if   //count parameters>=3
	
	If (Count parameters:C259>=4)
		$duplicateSheetRequest.newSheetName:=$newSheetName
	End if   // count parameters>=4
	
	$requests:=New object:C1471()
	$requests.duplicateSheet:=$duplicateSheetRequest
	//</build the duplicateSheetRequest object>
	
	$batchUpdate:=New object:C1471()
	$batchUpdate.requests:=New collection:C1472($requests)
	
	$url:=This:C1470._endpoint+"/"+This:C1470._spreadsheetId+":batchUpdate"
	
	
	$oResult:=This:C1470._http(HTTP POST method:K71:2; $url; JSON Stringify:C1217($batchUpdate))
	This:C1470._result.status:=$oResult.status
	return New object:C1471("result"; $oResult)
	
	If (This:C1470._result.status=200)
		return New object:C1471("success"; True:C214)
	Else   //$status#200
		return New object:C1471("success"; False:C215)
	End if   //status=200
	// _______________________________________________________________________________________________________________
	
	
	
Function entitySelectionToCollection($es : 4D:C1709.EntitySelection; $attributes : Collection)->$collection : Collection
	var $e : 4D:C1709.Entity
	
	$collection:=New collection:C1472()
	For each ($e; $es)
		$row:=New collection:C1472()
		For each ($attribute; $attributes)
			$row.push($e[$attribute])
		End for each   //$attribute;$attributes
		$collection.push($row)
	End for each   //$e;$es
	// _______________________________________________________________________________________________________________
	
	
	
Function findSheetWithName($sheetName : Text)->$oResult : Collection
	// used to search this.sheetData.Sheets[] for .properties.title = sheetName
	// returns a collection with all of the sheets sharing that name
	$oResult:=New collection:C1472()
	
	This:C1470._loadIfNotLoaded()
	
	For each ($sheet; This:C1470.sheetData.sheets)
		If $sheet.properties.title=$sheetName
			$oResult.push($sheet)
		End if 
	End for each   //($sheet;This.sheetData.sheets)
	// _______________________________________________________________________________________________________________
	
	
	
Function getSheetNames()->$sheetNames : Collection
	// optionally reloads the sheet, first
	
	$sheetNames:=New collection:C1472()
	
	This:C1470._loadIfNotLoaded()
	
	If (This:C1470._result.status#200)
		return Null:C1517
	End if 
	
	For ($i; 0; This:C1470.sheetData.sheets.length-1)
		$sheetNames.push(This:C1470.sheetData.sheets[$i].properties.title)
	End for 
	// _______________________________________________________________________________________________________________
	
	
	
Function getValues($range : Text; $majorDimension : Variant; $valueRenderOption : Variant; $dateTimeRenderOption : Variant)->$oValues : Object
	//(range:TEXT {; majorDimension:Text ; valueRenderOption:Text ; dateTimeRenderOption:Text} )
	// Returns a range of values from a spreadsheet. The caller must specify the spreadsheet Id and a range.
	
	//<handle params>
	$queryString:=This:C1470._queryRange($range)  //e.g. 28d738fdhd3v83a/values/Sheet1!A1:B2
	
	$majorDimension:="DIMENSION_UNSPECIFIED"
	$valueRenderOption:="FORMATTED_VALUE"
	$dateTimeRenderOption:="SERIAL_NUMBER"
	
	If (Count parameters:C259>=2)
		$majorDimension:=$majorDimension
	End if 
	
	If (Count parameters:C259>=3)
		$valueRenderOption:=$valueRenderOption
	End if 
	
	If (Count parameters:C259>=4)
		$dateTimeRenderOption:=$dateTimeRenderOption
	End if 
	
	$queryString:=$queryString+"?"+\
		"majorDimension="+$majorDimension+"&"+\
		"valueRenderOption="+$valueRenderOption+"&"+\
		"dateTimeRenderOption="+$dateTimeRenderOption
	
	$url:=This:C1470._endpoint+"/"+This:C1470._spreadsheetId+"/values/"+$queryString
	$oResult:=This:C1470._http(HTTP GET method:K71:1; $url; "")
	If (OB Is defined:C1231($oResult.value; "error"))  // error occurred"// this chokes on "value.error" -> If (OB Is defined($oResult.value;"error"))  // error occurred
		If (($oResult.value.error.code=401) & ($oResult.value.error.status="UNAUTHENTICATED"))  //token expired, try again with a forced refresh on the token
			$oResult:=This:C1470._http(HTTP GET method:K71:1; $url; ""; This:C1470._auth.getHeader(True:C214))
		End if   //($oResult.value.error.code=401) & ($oResult.value.error.status="UNAUTHENTICATED")
	End if   //(ob is defined($oResult.value.error))
	This:C1470._request:=$oResult._request
	This:C1470._result.status:=$oResult.status
	
	If (This:C1470._result.status#200)
		return Null:C1517
	Else 
		return $oResult.value
	End if   //$status#200
	// _______________________________________________________________________________________________________________
	
	
	
Function load($rangeString : Variant; $includeGridData : Variant)->$oSheetData : Object
	// {(rangeString:text , includeGridData:boolean)}
	// loads all spreadsheet data
	// optional params:
	
	//<handle params>
	var $oResult : Object
	
	$rangeString:=""
	$includeGridData:="false"
	
	If (Count parameters:C259>=2)
		$includeGridData:=Lowercase:C14(String:C10($includeGridData))
	End if 
	//</handle params>
	
	
	$queryString:="?"+\
		This:C1470._queryRange($rangeString)+"&"+\
		"includeGridData="+$includeGridData
	
	
	$url:=This:C1470._endpoint+"/"+This:C1470._spreadsheetId+$queryString
	$oResult:=This:C1470._http(HTTP GET method:K71:1; $url; "")
	This:C1470._result.status:=$oResult.status
	This:C1470.sheetData:=$oResult.value
	
	If (This:C1470._result.status#200)
		return Null:C1517
	Else   //fail
		return This:C1470.sheetData
	End if   //$status#200
	// _______________________________________________________________________________________________________________
	
	
	
Function renameSheet($sheetID : Integer; $newName : Text)->$success : Boolean
/*
POST https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}:batchUpdate
updateSheetProperties
	
body format is:
{
   "requests":[
      {
         "updateSheetProperties":
            {
               "properties":
                  {
                     "sheetId": integer,
                     "title"  : text
                  },
                "fields":"title"
            }
      }
   ]
}
*/
	var $propertiesO; $newPropertiesO; $updateSheetPropertiesO; $requestO; $bodyO : Object
	
	$url:=This:C1470._endpoint+"/"+This:C1470._spreadsheetId+":batchUpdate"
	
	
	//<body>
	$propertiesO:=New object:C1471("sheetId"; String:C10($sheetID); "title"; $newName)  // new title for the sheet
	$newPropertiesO:=New object:C1471("properties"; $propertiesO; "fields"; "title")
	$updateSheetPropertiesO:=New object:C1471("updateSheetProperties"; $newPropertiesO)
	$requestO:=New object:C1471("requests"; New collection:C1472())
	$requestO.requests.push($updateSheetPropertiesO)
	$body:=JSON Stringify:C1217($requestO)
	//</body>
	
	$oResult:=This:C1470._http(HTTP POST method:K71:2; $url; $body)
	This:C1470._result:=$oResult
	return This:C1470._result.status=200
	// _______________________________________________________________________________________________________________
	
	
	
Function setValues($range : Text; $valuesObject : Object; $valueInputOption : Text; $includeValuesInResponse : Variant; $responseValueRenderOption : Variant; $responseTimeRenderOption : Variant)->$oSheetData : Object
	//(range:TEXT ; valuesObject: Object ; valueInputOption:Text {; includeValuesInResponse: Boolean ; responseValueRenderOption: Text ; responseDateTimeRenderOption:Text})
	// PUT https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values/{range}
	//Sets values in a range of a spreadsheet.
	
	
	//<handle params>
	var $oResult : Object
	
	//<mandatory parameters>
	$rangeString:=This:C1470._queryRange($range)
	$valuesObject.range:=$rangeString  // has to match the query range
	$queryString:="?valueInputOption="+$valueInputOption  // going to have at least one query parameter, the valuesInputOption
	//</mandatory parameters>
	
	
	$appendSymbol:=""  // only append with ampersand if both params are defined
	
	
	$includeValuesInResponse:="false"
	If (Count parameters:C259>=4)
		$includeValuesInResponse:=Lowercase:C14(String:C10($includeValuesInResponse))
	End if 
	
	$responseValueRenderOption:="FORMATTED_VALUE"
	If (Count parameters:C259>=5)
		$includeValuesInResponse:=$responseValueRenderOption
	End if 
	
	$responseDateTimeRenderOption:="SERIAL_NUMBER"
	If (Count parameters:C259>=6)
		$responseDateTimeRenderOption:=$responseTimeRenderOption
	End if 
	
	
	$queryString:=$queryString+\
		"&includeValuesInResponse="+$includeValuesInResponse+"&"+\
		"&responseValueRenderOption="+$responseValueRenderOption+"&"+\
		"&responseDateTimeRenderOption="+$responseDateTimeRenderOption
	
	//</handle params>
	$url:=This:C1470._endpoint+"/"+This:C1470._spreadsheetId+"/values/"+Super:C1706.URL_Escape($rangeString; "'")+$queryString  // don't escape the quotes at the edges of sheet name because it breaks the comparison google does with the range string.
	$oResult:=This:C1470._http(HTTP PUT method:K71:6; $url; JSON Stringify:C1217($valuesObject))
	This:C1470._result.status:=$oResult.status
	This:C1470.sheetData:=$oResult.value
	
	If (This:C1470._result.status#200)  // fail
		return Null:C1517
	Else   //ok
		return This:C1470.sheetData
	End if   //$status#200
	// _______________________________________________________________________________________________________________
	
	
	
	// ===============================================================================================================
	
	//                                        P R I V A T E   F U N C T I O N S
	
	// ===============================================================================================================
	
	
	
Function _http($http_method : Text; $url : Text; $body : Text)->$oResult : Object
	// returns an object with properties  status:TEXT ; value:TEXT
	//tries the _comms._http.  If it fails, it checks to see if that is because the token expired, and if so, tries again.
	
	$oResult:=Super:C1706.http($http_method; $url; $body; This:C1470._auth.getHeader())
	If (OB Is defined:C1231($oResult.value; "error"))  // error occurred"// this chokes on the "values.error" If (OB Is defined($oResult;"value.error"))  // error occurred"
		If (($oResult.value.error.code=401) & ($oResult.value.error.status="UNAUTHENTICATED"))  //token expired, try again with a forced refresh on the token
			$oResult:=Super:C1706.http($http_method; $url; $body; This:C1470._auth.getHeader())
		End if   //($oResult.value.error.code=401) & ($oResult.value.error.status="UNAUTHENTICATED")
	End if   //(ob is defined($oResult.value.error))
	This:C1470._result:=$oResult
	This:C1470._result.status:=$oResult.status
	// _______________________________________________________________________________________________________________
	
	
	
Function _ss_batchUpdate  // (request:object ; includeSpreadsheetInResponse:boolean ; responseRanges:string ; responseIncludeGridData:boolean) -> object
	//POST https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}:batchUpdate
	//The request body contains data with the following structure:
/*
{
  "requests": [
    {
      object (Request)
    }
  ],
  "includeSpreadsheetInResponse": boolean,
  "responseRanges": [
    string
  ],
  "responseIncludeGridData": boolean
}
*/
	$url:=This:C1470._endpoint+"/"+This:C1470._spreadsheetId+":batchUpdate"
	// _______________________________________________________________________________________________________________
	
	
	
Function _getSheetIdFromURL  //url:text
	// accepts a url and extracts the Id of the sheet from that
	$found:=Match regex:C1019("(?<=[#&]gid=)([0-9]+)"; $1; 1; $foundAt; $length)
	If (Not:C34($found))
		$0:=""
	Else 
		$0:=Substring:C12($1; $foundAt; $length)
	End if   //(not($found))
	// _______________________________________________________________________________________________________________
	
	
	
Function _getSSIdFromURL  //url:text
	// accepts a url and extracts the Id of the sheet from that
	var $1 : Text
	
	$found:=Match regex:C1019("(?<=/spreadsheets/d/)([a-zA-Z0-9-_]+)"; $1; 1; $foundAt; $length)
	If (Not:C34($found))
		$0:=""
	Else 
		$0:=Substring:C12($1; $foundAt; $length)
	End if   //(not($found))
	// _______________________________________________________________________________________________________________
	
	
	
Function _loadIfNotLoaded  //   ( )  -> sheetWasNotLoaded :boolean
	// make sure sheet has been loaded for operations that just use already-loaded data.
	// return whether or not the sheet was already loaded
	
	$0:=False:C215  //reloaded
	If (This:C1470.sheetData=Null:C1517)
		$0:=True:C214  //reloaded
		This:C1470.load()
	End if 
	// _______________________________________________________________________________________________________________
	
	
	
Function _queryRange  //(rangeString:text)
	//turns a range string into a query-capable string
	// 1. replaces colons with %3A
	// 2. quotes all sheet names
	// 3. handles comma-separated compound ranges
	var $1; $0; $sheetPart; $cellsPart : Text
	var $bangPos : Integer
	$0:=""
	If ($1#"")
		$0:=$1
		//debugy when setting ranges, this breaks the range string comparison google does.  $0:=Replace string($0;":";"%3A")  //url encode
		$0:=Replace string:C233($0; ","; "&ranges=")  // A1:B1,C1 becomes ranges=A1:B1&ranges=C1
		//<quote the sheet name so names with spaces will be ok>
		$bang:="!"  // for searching and then for appending, later, if it's actually in the string
		$bangPos:=Position:C15($bang; $0)
		If ($bangPos=0)
			$bang:=""  // not in the string, so don't append it, later
			$bangPos:=Length:C16($0)+1
		End if   //$bangPos=0
		$sheetPart:=Substring:C12($0; 1; ($bangPos-1))  // beginning until just before the bang
		$cellsPart:=Substring:C12($0; ($bangPos+1); Length:C16($0))
		If (($sheetPart[[1]]#"'") & ($sheetPart[[Length:C16($sheetPart)]]#"'"))  // sheet name isn't already quoted
			$sheetPart:="'"+Super:C1706.URL_Escape($sheetPart)+"'"  // surround the sheet name with single quotes so we don't have to worry about spaces
		End if 
		$0:=$sheetPart+$bang+$cellsPart  // put it back together
		//</quote the sheet name so names with spaces will be ok>
	End if 
	// _______________________________________________________________________________________________________________
	
	
	
	// ===============================================================================================================
	
	//                         G O O G L E    S H E E T S    A P I    T O    I M P L E M E N T
	
	// ===============================================================================================================
	
	
Function _developerMetadata_get
	//GET/v4/spreadsheets/{spreadsheetId}/developerMetadata/{metadataId}
	//Returns the developer metadata with the specified Id.
	// _______________________________________________________________________________________________________________
	
Function _developerMetadata_search
	//POST/v4/spreadsheets/{spreadsheetId}/developerMetadata:search
	//Returns all developer metadata matching the specified DataFilter.
	// _______________________________________________________________________________________________________________
	
Function _ss_getByDataFilter
	//POST/v4/spreadsheets/{spreadsheetId}:getByDataFilter
	//Returns the spreadsheet at the given Id.
	
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
	
	
Function _ss_values_batchUpdateByDataFilter
	//POST/v4/spreadsheets/{spreadsheetId}/values:batchUpdateByDataFilter
	//Sets values in one or more ranges of a spreadsheet.
	
	// _______________________________________________________________________________________________________________
	
Function _ss_values_clear
	//POST/v4/spreadsheets/{spreadsheetId}/values/{range}:clear
	//Clears values from a spreadsheet.
	
	// _______________________________________________________________________________________________________________
	
	
	// ===============================================================================================================
	