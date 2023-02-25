// handles all comms with google.

Class constructor($connectionMethod : Variant)
	
	$connectionMethod:=$connectionMethod || "native"
	This:C1470._connectionMethod:=$connectionMethod
	
	
	// ===============================================================================================================
	
	
Function http($httpMethod : Text; $url : Text; $body : Text; $header : Variant)->$oResult : Object
	// (http_method:TEXT ; url:TEXT; body:TEXT; header:object)
	// returns an object with properties  status:TEXT ; value:TEXT
	var $oReturnValue : Object
	$oHeader:=$header || This:C1470._auth.getHeader()
	
	Case of 
		: (This:C1470._connectionMethod="native")
			ARRAY TEXT:C222($aHeaderNames; 1)
			ARRAY TEXT:C222($aHeaderValues; 1)
			$aHeaderNames{1}:=$oHeader.name
			$aHeaderValues{1}:=$oHeader.value
			
			This:C1470._result:=New object:C1471()
			$oResult:=This:C1470._result
			$oResult.request:=$httpMethod+" "+$url+" "+$body
			$oResult.status:=0
			$oResult.value:=New object:C1471()
			$retryCounter:=0
			
			Repeat   //cope with rate limiting using exponential backoff
				DELAY PROCESS:C323(Current process:C322; ((2^$retryCounter)-1))  // rate limiter if we hit an error using exponential backoff. for retry 0 (first try), ((2^0)-1) = 0 = no wait.  exponential backoff is 2^c-1.  Since we're dealing with a rate limit, instead of using random we'll do it deterministically.
				err_clear
				ON ERR CALL:C155("err_get")
				$oResult.status:=HTTP Request:C1158($httpMethod; $url; $body; $oReturnValue; $aHeaderNames; $aHeaderValues)  // gets a 0 if there is an error
				ON ERR CALL:C155("")
				
				If (errorMessage#"")
					$oResult.value.error:=New object:C1471("code"; 0; "status"; errorMessage)
					err_clear
					return 
				End if 
				
				If ($oReturnValue#Null:C1517)
					$oResult.value:=$oReturnValue
				End if   //$oReturnValue#null
				
				If (OB Is defined:C1231($oResult.value; "error"))
					If ($oResult.status=429)  // hit rate limit
						$retryCounter:=$retryCounter+1
					End if   //($oReturnValue.error.code=429)
				End if   //(OB Is defined($oResult.value;"error"))
			Until (($oResult.status#429) | ($retryCounter>10))  // $retryCounter=10 delivers 17 seconds of waiting.  If we're still getting this error, abort.
		: (This:C1470._connectionMethod="curl")  // not implemented yet
			$header:=$oHeader.name+": "+$oHeader.value
			$oResult:=Null:C1517
		: (This:C1470._connectionMethod="ntk")  //not implemented yet
			$oResult:=Null:C1517
		Else   // error
			$oResult:=Null:C1517
	End case 
	// _______________________________________________________________________________________________________________
	
	
	
Function parseError()->$error : Text  //()
	// parses an error object and returns the contents
	var $oError : Object
	$oError:=This:C1470._result.error
	$error:=""
	If ($oError#Null:C1517)
		$error:="Request: "+This:C1470._request+"\r"+\
			"Code: "+String:C10($oError.code)+"\r"+\
			"Status: "+$oError.status+"\r"+\
			"Message: "+$oError.message
	End if   //$oError#Null
	// _______________________________________________________________________________________________________________
	
	
	
	
Function URL_Escape
	// ripped from https://kb.4d.com/assetid=79062
	var $2; $charsToSkip; $1; $0; $escaped : Text
	var $i : Integer
	var $shouldEscape : Boolean
	var $data : Blob
	
	$charsToSkip:=""
	If (Count parameters:C259>=2)
		$charsToSkip:=$2
	End if 
	
	For ($i; 1; Length:C16($1))
		
		$char:=Substring:C12($1; $i; 1)
		$code:=Character code:C91($char)
		
		$shouldEscape:=False:C215
		
		Case of 
			: (Position:C15($char; $charsToSkip)>0)
			: ($code=45)
			: ($code=46)
			: ($code>47) & ($code<58)
			: ($code>63) & ($code<91)
			: ($code=95)
			: ($code>96) & ($code<123)
			: ($code=126)
			Else 
				$shouldEscape:=True:C214
		End case 
		
		If ($shouldEscape)
			CONVERT FROM TEXT:C1011($char; "utf-8"; $data)
			For ($j; 0; BLOB size:C605($data)-1)
				$hex:=String:C10($data{$j}; "&x")
				$escaped:=$escaped+"%"+Substring:C12($hex; Length:C16($hex)-1)
			End for 
		Else 
			$escaped:=$escaped+$char
		End if 
		
	End for 
	
	$0:=$escaped
	// _______________________________________________________________________________________________________________
	