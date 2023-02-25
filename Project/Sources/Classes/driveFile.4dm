Class extends _comms

Class constructor($authObject : Object; $idOrPath : Text; $metadataToRetrieve : Variant)
	Super:C1705("native")  //_comms type
	This:C1470.error:=""
	This:C1470.metadata:=New object:C1471()
	This:C1470.path:=""
	
	This:C1470._auth:=$authObject
	This:C1470._endpoint:="https://www.googleapis.com/drive/v3/files"
	This:C1470._dirty:=True:C214
	This:C1470._id:=""
	This:C1470._metadataToRetrieve:=$metadataToRetrieve || "*"
	This:C1470._mimePrefix:="application/vnd.google-apps."
	This:C1470._mimeType:=""
	This:C1470._name:=""
	This:C1470._path:=""
	
	
	If ($idOrPath[[1]]="/")
		This:C1470._path:=$idOrPath
	Else 
		This:C1470._id:=$idOrPath
	End if 
	//_______________________________________________________________________________________________
	
	
	
	// ===============================================================================================================
	// =                                                                                                             =
	// =                                       P U B L I C   F U N C T I O N S                                       =
	// =                                                                                                             =
	// ===============================================================================================================
	
	
	
Function getId()->$id : Text
	If (This:C1470._id#"")
		return This:C1470._id
	End if 
	
	//<save state before going up the rabbit hole>
	$metadata:=This:C1470.metadata
	$dirty:=This:C1470.dirty
	//</save state before going up the rabbit hole>
	
	$id:=This:C1470._getID()  // recurse the tree downward
	This:C1470._id:=$id  // save prop
	
	//<restore state>
	This:C1470.metadata:=$metadata
	This:C1470.dirty:=$dirty
	//<restore state>
	
	// _______________________________________________________________________________________________________________
	
	
	
Function getName()->$name : Text
	return This:C1470._getProp("name")
	// _______________________________________________________________________________________________________________
	
	
	
Function getPath()->$path : Text
	var $metadata : Object
	var $dirty : Boolean
	
	If (This:C1470.path#"")
		return This:C1470.path
	End if 
	
	//<save state before going up the rabbit hole>
	$metadata:=This:C1470.metadata
	$dirty:=This:C1470.dirty
	//</save state before going up the rabbit hole>
	
	$path:=This:C1470._getPath()  // recurse the tree upwards
	This:C1470._path:=$path  // save prop
	
	//<restore state>
	This:C1470.metadata:=$metadata
	This:C1470.dirty:=$dirty
	//<restore state>
	// _______________________________________________________________________________________________________________
	
	
	
Function getType()->$filetype : Text
	$type:=This:C1470._getProp("mimeType")
	$mimePrefixLenPlusOne:=Length:C16(This:C1470._mimePrefix)+1
	return Substring:C12($type; $mimePrefixLenPlusOne)
	// _______________________________________________________________________________________________________________
	
	
	
Function moveTo($toFolderID : Text)->$success : Boolean
	//https://developers.google.com/drive/api/v3/reference/files/update
	//PATCH https://www.googleapis.com/drive/v3/files/fileId
	$url:=This:C1470._endpoint+"/"+This:C1470.getId()
	$addParents:="?addParents="+$toFolderID
	$url:=$url+"/"+$addparents
	This:C1470._http("PATCH"; $url; $body)
	return (This:C1470._result.status=200)  // fail
	
	// _______________________________________________________________________________________________________________
	
	
	
	// ===============================================================================================================
	// =                                                                                                             =
	// =                                      P R I V A T E   F U N C T I O N S                                      =
	// =                                                                                                             =
	// ===============================================================================================================
	
	
	
Function _getID()->$id : Text
	var $path : Text
	var $root : cs:C1710.driveFiles
	var $folderID : Text
	var $nextSlashPos : Integer
	var $subfolderName : Text
	var $subfolderO; $fileO : cs:C1710.driveFiles
	
	
	$folderID:="root"  // can't query directly. have to say 'root' in parents
	$path:=Substring:C12(This:C1470._path; 2)  // remove leading slash
	$nextSlashPos:=Position:C15("/"; $path)
	While ($nextSlashPos>0)
		$subfolderName:=Substring:C12($path; 1; ($nextSlashPos-1))
		$subfolderO:=cs:C1710.driveFiles.new(This:C1470._auth; $subfolderName; "folder"; $folderID)
		$folderID:=$subfolderO.getID()
		$path:=Substring:C12($path; ($nextSlashPos+1))
		$nextSlashPos:=Position:C15("/"; $path)
	End while   //$nextSlashPos>0
	
	$fileO:=cs:C1710.driveFiles.new(This:C1470._auth; $path; ""; $folderID)  // we don't know the type of the last segment of the path, so omit it.
	$id:=$fileO.getID()
	// _______________________________________________________________________________________________________________
	
	
	
Function _getPath()->$path : Text
	var $parents : Collection
	var $name : Text
	var $parent : cs:C1710.driveFile
	
	$parents:=This:C1470._getProp("parents")
	If ($parents=Null:C1517)
		This:C1470._getMetadata("name,parents")  // on initial pass, dev might have specified a subset of metadata, and then asked for the path
		$parents:=This:C1470._getProp("parents")
		If ($parents=Null:C1517)  // at base
			return ""  //at root or My Drive
		End if   //$parents=null
	End if   //$parents=null
	
	$name:=This:C1470.getName()
	
	//<compute path, if not already done>
	If (This:C1470._path="")
		$parent:=cs:C1710.driveFile.new(This:C1470._auth; This:C1470._parents[0])  // use the id of the first parent in the list
		This:C1470._path:=$parent.getPath()+"/"+This:C1470._name
	End if   //this._path#""
	//</compute path, if not already done>
	
	return This:C1470._path  // there is no path metadata. this has to be generated by traversing the path, backwards
	// _______________________________________________________________________________________________________________
	
	
	
Function _getProp($what : Text)->$value : Variant
	If (This:C1470._dirty)
		This:C1470._getMetadata(This:C1470._metadataToRetrieve)
	End if 
	
	$internalPropName:="_"+$what
	This:C1470[$internalPropName]:=Null:C1517
	
	If (OB Is defined:C1231(This:C1470.metadata; $what))
		This:C1470[$internalPropName]:=This:C1470.metadata[$what]
	End if 
	
	return This:C1470[$internalPropName]
	// _______________________________________________________________________________________________________________
	
	
	
Function _getMetadata($fields : Variant)->$success : Boolean
/*
can't combine get and get files b/c for some reason getting files can't take any fieldname specs besides a "*"
(at least in my testing), so it seems we can either do a query and get a list of files (with or without all fields)
or we can load a subset of fields for a single file.
*/
	If (This:C1470._id="")
		This:C1470.error:="Can't fetch metadata without a file id."
		return 
	End if   //this._id=""
	
	If (Not:C34(Undefined:C82($fields)))  // specific fields to grab
		$fields:="?fields="+Super:C1706.URL_Escape($fields)
	End if 
	$fields:=$fields || ""  // forces it to be a string
	
	$url:=This:C1470._endpoint+"/"+This:C1470._id+$fields
	
	This:C1470._http(HTTP GET method:K71:1; $url; "")
	
	If (This:C1470._result.status#200)  // fail
		return False:C215
	Else   //ok
		This:C1470.metadata:=This:C1470._result.value
		This:C1470._dirty:=False:C215
		return True:C214
	End if   //$status#200
	// _______________________________________________________________________________________________________________
	
	
	
Function _http($http_method : Text; $url : Text; $body : Text)
	Super:C1706.http($http_method; $url; $body)
	If (OB Is defined:C1231(This:C1470._result.value; "error"))  // error occurred"// this chokes on the "values.error" If (OB Is defined($oResult;"value.error"))  // error occurred"
		If ((This:C1470._result.value.error.code=401) & (This:C1470._result.value.error.status="UNAUTHENTICATED"))  //token expired, try again with a forced refresh on the token
			Super:C1706.http($http_method; $url; $body)
		End if   //($oResult.value.error.code=401) & ($oResult.value.error.status="UNAUTHENTICATED")
	End if   //(ob is defined($oResult.value.error))
	// _______________________________________________________________________________________________________________