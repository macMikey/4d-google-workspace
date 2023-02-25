Class extends _comms

Class constructor($authObject : Object; $name : Variant; $type : Variant; $parentID : Variant)
	Super:C1705("native")  //_comms type
	This:C1470.error:=""
	This:C1470.files:=New collection:C1472()
	
	This:C1470._auth:=$authObject
	This:C1470._endpoint:="https://www.googleapis.com/drive/v3/files"
	This:C1470._dirty:=True:C214
	This:C1470._mimePrefix:="application/vnd.google-apps."
	This:C1470._mimeType:=""
	This:C1470._name:=""
	This:C1470._parentID:=""
	This:C1470._path:=""
	
	
	
	This:C1470._name:=$name
	
	$type:=$type || ""
	This:C1470.type:=$type
	
	This:C1470._parentID:=$parentID || ""
	
	This:C1470._getFiles()
	//_______________________________________________________________________________________________
	
	
	
	
	// ===============================================================================================================
	// =                                                                                                             =
	// =                                      P R O P E R T Y    S E T T E R S                                       =
	// =                                                                                                             =
	// ===============================================================================================================
	
	
	
Function set type($type : Text)
	If ($type#"")
		This:C1470._type:=$type
		$mimeType:=This:C1470._mimePrefix+$type
		This:C1470._mimeType:=$mimeType
	End if 
	// _______________________________________________________________________________________________________________
	
	
	
	// ===============================================================================================================
	// =                                                                                                             =
	// =                                       P U B L I C   F U N C T I O N S                                       =
	// =                                                                                                             =
	// ===============================================================================================================
	
	
	
Function getID()->$id : Text
	If (This:C1470.files.length=1)
		$file:=This:C1470.files[0]
		return $file.id
	Else 
		return ""
	End if 
	// _______________________________________________________________________________________________________________
	
	
	
	
	// ===============================================================================================================
	// =                                                                                                             =
	// =                                      P R I V A T E   F U N C T I O N S                                      =
	// =                                                                                                             =
	// ===============================================================================================================
	
	
	
Function _http($http_method : Text; $url : Text; $body : Text)
	Super:C1706.http($http_method; $url; $body)
	If (OB Is defined:C1231(This:C1470._result.value; "error"))  // error occurred"// this chokes on the "values.error" If (OB Is defined($oResult;"value.error"))  // error occurred"
		If ((This:C1470._result.value.error.code=401) & (This:C1470._result.value.error.status="UNAUTHENTICATED"))  //token expired, try again with a forced refresh on the token
			Super:C1706.http($http_method; $url; $body)
		End if   //($oResult.value.error.code=401) & ($oResult.value.error.status="UNAUTHENTICATED")
	End if   //(ob is defined($oResult.value.error))
	// _______________________________________________________________________________________________________________
	
	
	
Function _getFiles()
/*
can't combine get and get files b/c for some reason getting files can't take any fieldname specs besides a"*"
(at least in my testing), so it seems we can either do a query and get a list of files(with or without all fields)
or we can load a subset of fields for a single file.
*/
	
	//<build the "q", or the query for name, mimeType, and/or parents>
	$qCollection:=New collection:C1472()
	
	If (This:C1470._name#"")
		$qCollection.push("name ='"+This:C1470._name+"'")
	End if 
	
	If (This:C1470._mimeType#"")
		$qCollection.push("mimeType='"+This:C1470._mimeType+"'")
	End if 
	
	If (This:C1470._parentID#"")
		$qCollection.push("'"+This:C1470._parentID+"' in parents")
	End if 
	
	Case of 
		: ($qCollection.length=0)
			$qString:=""
		: ($qCollection.length=1)
			$qString:=$qCollection[0]
		Else 
			$qString:=$qCollection[0]
			For each ($qItem; $qCollection; 1)
				$qString+=" and "+$qItem
			End for each 
	End case 
	$q:="?q="+Super:C1706.URL_Escape($qString)
	//</build the "q", or the query for name, mimeType, and parents>
	
	$url:=This:C1470._endpoint+$q  // escaping is handled by _comms
	
	This:C1470._http(HTTP GET method:K71:1; $url; "")
	
	
	If (This:C1470._result.status#200)  // fail
		return False:C215
	Else   //ok
		This:C1470.files:=This:C1470._result.value.files
		This:C1470._dirty:=False:C215
		return True:C214
	End if   //$status#200
	// _______________________________________________________________________________________________________________  