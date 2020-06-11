  // handles all comms with google.  Should be instantiated as a process object and therefore shared b/c tokens will periodically expire

Class constructor  //(username:text, scopes:text, googleKey:text; networkLayer:text)
	This:C1470._initializeConstants()
	
	  //<handle params>
	C_TEXT:C284($1;$2;$3;$4)
	This:C1470.auth.username:=$1
	This:C1470.auth.scopes:=$2
	This:C1470.auth.googleKey:=JSON Parse:C1218($3)
	This:C1470.auth.googleKey.asString:=$3  // so spreadsheets can extend this class and pass key the way other methods do.
	This:C1470.connectionMethod:="native"  // $4 //ONLY "NATIVE" IS IMPLEMENTED
	  //</handle params>
	
	
	  //<initialize properties>
	This:C1470.auth.access.expiresAt:=Current time:C178
	This:C1470.auth.access.token:=New object:C1471()
	  //</initialize properties>
	
	This:C1470._getHeader()  //initialize comms and get the token cleared
	  // _______________________________________________________________________________________________________________
	
	
Function _initializeConstants  // no params
	
	  //debugxThis.null:=New object()  //null object, return for errors where an object is returned
	
	  //<auth>
	This:C1470.auth:=New object:C1471()
	This:C1470.auth.expiresIn:=3600  //seconds
	This:C1470.auth.oHead:=New object:C1471("alg";"RS256";"typ";"JWT")
	This:C1470.auth.url:="https://oauth2.googleapis.com/token"
	This:C1470.auth.bodyPrefix:="grant_type="+This:C1470._URL_Escape("urn:ietf:params:oauth:grant-type:jwt-bearer")+"&assertion="  //xxx
	This:C1470.auth.access:=New object:C1471()
	This:C1470.auth.access.header:=New object:C1471()
	This:C1470.auth.access.header.name:="Authorization"
	This:C1470.auth.access.header.value:=""  //gets assigned later.  this is just a placeholder
	  //</auth>
	
	
	  //<JWT>
	This:C1470.auth.jwt:=New object:C1471()
	This:C1470.auth.jwt.endpoint:="https://oauth2.googleapis.com/token"
	This:C1470.auth.jwt.grantType:="urn:ietf:params:oauth:grant-type:jwt-bearer"
	This:C1470.auth.jwt.header:=New object:C1471()
	This:C1470.auth.jwt.header.name:="Content-Type"
	This:C1470.auth.jwt.header.value:="application/x-www-form-urlencoded"
	  //</JWT>
	
	
	  // ===============================================================================================================
	
	
Function getAccess  //{forceRefresh:boolean}
	  // all the access (important) stuff - timeouts, token, headers - so we can update all objects if an auth changes
	  // do it indirectly so we can hide the properties and if we change the structure we don't break something
	C_OBJECT:C1216($0)
	C_BOOLEAN:C305($1)
	
	This:C1470._getHeader($1)  //refresh header, if necessary
	$0:=This:C1470.auth.access
	
	  // _______________________________________________________________________________________________________________
	
	
Function setAccess  // set all the access (important) properties - timeouts, token, headers - so we can update all objects if an auth changes
	  // do it indirectly so we can hide the properties and if we change the structure we don't break something
	This:C1470.auth.access:=$1
	
	  // _______________________________________________________________________________________________________________
	
Function _getHeader  //{forceRefresh:boolean}
	  // returns header object to be used on subsequent calls or null
	  // retrieves a fresh access token if old one expired
	
	  //<force refresh?>
	C_BOOLEAN:C305($1)  // force refresh
	$forceRefresh:=False:C215
	If (Count parameters:C259>0)
		$forceRefresh:=$1
	End if 
	
	If ($forceRefresh)
		This:C1470.auth.access.expiresAt:=0
	End if 
	  //</force refresh?>
	
	
	$now:=Milliseconds:C459
	If ($now<=This:C1470.auth.access.expiresAt)  //token is still current
		$0:=This:C1470.auth.access.header
	Else   // request another token
		
		
		  //<build jwt/assertion>
		C_OBJECT:C1216($ojwt)
		$ojwt:=New object:C1471()
		
		  //<build jwt>
		$ojwt.iss:=This:C1470.auth.googleKey.client_email
		$ojwt.scope:=This:C1470.auth.scopes
		$ojwt.aud:=This:C1470.auth.googleKey.token_uri
		$ojwt.iat:=This:C1470._Unix_Timestamp()  // epoch seconds
		$ojwt.exp:=$ojwt.iat+This:C1470.auth.expiresIn  // an hour from now
		$ojwt.sub:=This:C1470.auth.username
		$ojwt.endpoint:=This:C1470.auth.jwt.endpoint
		$ojwt.grantType:=This:C1470.auth.jwt.grantType
		$ojwt.kid:=This:C1470.auth.googleKey.private_key_id
		  //</build jwt>
		
		$assertion:=JWT Sign (JSON Stringify:C1217(This:C1470.auth.oHead);JSON Stringify:C1217($ojwt);This:C1470.auth.googleKey.private_key)
		  //</build jwt/assertion>
		
		
		$body:=This:C1470.auth.bodyPrefix+$assertion
		
		  //<get the access token>
		C_OBJECT:C1216($oResult)
		$oResult:=This:C1470._http_post(This:C1470.auth.url;$body;This:C1470.auth.jwt.header)
		This:C1470.status:=$oResult.status
		This:C1470.auth.access.token:=$oResult.value
		  //</get the access token>
		
		
		  //<headers to be used in subsequent calls.  token is embedded in the header>
		This:C1470.auth.access.header.value:=This:C1470.auth.access.token.token_type+" "+This:C1470.auth.access.token.access_token
		  //</headers to be used in subsequent calls.  token is embedded in the header>
		
		C_OBJECT:C1216($0)
		
		If (This:C1470.status#200)
			$0:=Null:C1517  // debugx $0:=This.null
		Else   //$status=200
			This:C1470.auth.access.expiresAt:=$now+(This:C1470.auth.access.token.expires_in*1000)  //get to milliseconds to compare to system clock
			$0:=This:C1470.auth.access.header  //return the entire object
		End if   //status#200
	End if   //(($now<=This.auth.access.expiresAt)
	
	  // _______________________________________________________________________________________________________________
	
Function _http_get  //i.e. http get (url:text ; header:object)
	  // returns an object with properties  status:text ; value:object
	C_TEXT:C284($1)
	C_OBJECT:C1216($2)
	
	
	If (This:C1470.connectionMethod="native")
		ARRAY TEXT:C222($aHeaderNames;1)
		ARRAY TEXT:C222($aHeaderValues;1)
		$aHeaderNames{1}:=$2.name
		$aHeaderValues{1}:=$2.value
		C_OBJECT:C1216($0;$oReturnValue)
		$0:=New object:C1471()
		$0.status:=HTTP Request:C1158(HTTP GET method:K71:1;$1;"";$oReturnValue;$aHeaderNames;$aHeaderValues)
		$0.value:=$oReturnValue
	Else   //"curl"
		$header:=$3.name+": "+$3.value
	End if 
	
	  // _______________________________________________________________________________________________________________
	
Function _http_post  //i.e. http post (url:text; body:text; header:object)
	  // returns an object with properties  status:text ; value:object
	C_TEXT:C284($1;$2)
	C_OBJECT:C1216($3)
	
	If (This:C1470.connectionMethod="native")
		ARRAY TEXT:C222($aHeaderNames;1)
		ARRAY TEXT:C222($aHeaderValues;1)
		$aHeaderNames{1}:=$3.name
		$aHeaderValues{1}:=$3.value
		C_OBJECT:C1216($0;$oReturnValue)
		$0:=New object:C1471()
		$0.status:=HTTP Request:C1158(HTTP POST method:K71:2;$1;$2;$oReturnValue;$aHeaderNames;$aHeaderValues)
		$0.value:=$oReturnValue
	Else   //"curl"
		$header:=$3.name+": "+$3.value
	End if 
	
	  // _______________________________________________________________________________________________________________
	
Function _Unix_Timestamp
	C_LONGINT:C283($0;$time)
	
	$timestamp:=Timestamp:C1445
	
	ARRAY LONGINT:C221($pos;0)
	ARRAY LONGINT:C221($len;0)
	
	If (Match regex:C1019("((\\d{4})-(\\d{2})-(\\d{2}))T(\\d{2}:\\d{2}:\\d{2})\\.(\\d{3})Z";$timestamp;1;$pos;$len))
		
		C_DATE:C307($date)
		$date:=Date:C102(Substring:C12($timestamp;$pos{1};$len{1}))
		
		C_LONGINT:C283($yyyy;$mm;$dd)
		$yyyy:=Num:C11(Substring:C12($timestamp;$pos{2};$len{2}))
		$mm:=Num:C11(Substring:C12($timestamp;$pos{3};$len{3}))
		$dd:=Num:C11(Substring:C12($timestamp;$pos{4};$len{4}))  //eventually will be number of days since Jan 1 this year
		
		$daysInFeb:=Day of:C23(Add to date:C393(Add to date:C393(!00-00-00!;$yyyy;3;1);0;0;-1))
		Case of 
			: ($mm=1)
				
			: ($mm=2)
				$dd:=$dd+31  //daysInJan
			: ($mm=3)
				$dd:=$dd+31+$daysInFeb
			: ($mm=4)
				$dd:=$dd+62+$daysInFeb  //daysInMar
			: ($mm=5)
				$dd:=$dd+92+$daysInFeb  //daysInApr
			: ($mm=6)
				$dd:=$dd+123+$daysInFeb  //daysInMay
			: ($mm=7)
				$dd:=$dd+153+$daysInFeb  //daysInJun
			: ($mm=8)
				$dd:=$dd+184+$daysInFeb  //daysInJul
			: ($mm=9)
				$dd:=$dd+215+$daysInFeb  //daysInAug
			: ($mm=10)
				$dd:=$dd+245+$daysInFeb  //daysInSep
			: ($mm=11)
				$dd:=$dd+276+$daysInFeb  //daysInOct
			: ($mm=12)
				$dd:=$dd+306+$daysInFeb  //daysInNov
		End case 
		
		$time:=(0+Time:C179(Substring:C12($timestamp;$pos{5};$len{5})))  //seconds so far since 00:00 ZULU today
		$time:=$time+(($dd-1)*86400)  //seconds YTD through yesterday
		$time:=$time+(($yyyy-1970)*31536000)  //seconds through all non-leap years since 1970 through the beginning of the year
		$time:=$time+((($yyyy-1-1968)\4)*86400)  //seconds for leap years since 1970
	End if 
	
	$0:=$time
	
	  // _______________________________________________________________________________________________________________
	
Function _URL_Escape
	C_TEXT:C284($1;$0;$escaped)
	
	C_LONGINT:C283($i)
	C_BOOLEAN:C305($shouldEscape)
	C_BLOB:C604($data)
	
	For ($i;1;Length:C16($1))
		
		$char:=Substring:C12($1;$i;1)
		$code:=Character code:C91($char)
		
		$shouldEscape:=False:C215
		
		Case of 
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
			CONVERT FROM TEXT:C1011($char;"utf-8";$data)
			For ($j;0;BLOB size:C605($data)-1)
				$hex:=String:C10($data{$j};"&x")
				$escaped:=$escaped+"%"+Substring:C12($hex;Length:C16($hex)-1)
			End for 
		Else 
			$escaped:=$escaped+$char
		End if 
		
	End for 
	
	$0:=$escaped
	
	  // _______________________________________________________________________________________________________________