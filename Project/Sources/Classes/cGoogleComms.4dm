  // handles all comms with google.  Should be instantiated as a process object and therefore shared b/c tokens will periodically expire

Class constructor  //(username:text, scopes:text, googleKey:text; connectionMethod:text)
	This._initializeConstants()

	  //<handle params>
	C_TEXT($1;$2;$3;$4)
	This.auth.username:=$1
	This.auth.scopes:=$2
	This.auth.googleKey:=JSON Parse($3)
	This.auth.googleKey.asString:=$3  // so spreadsheets can extend this class and pass key the way other methods do.
	This.connectionMethod:="native"  // $4 //ONLY "NATIVE" IS IMPLEMENTED
	  //</handle params>


	  //<initialize properties>
	This.auth.access.expiresAt:=Current time
	This.auth.access.token:=New object()
	  //</initialize properties>

	  //debugx this seems counterproductive if we're in a sheet and we redo this.  This._getHeader()  //initialize comms and get the token cleared
	  // _______________________________________________________________________________________________________________


Function _initializeConstants  // no params


	  //<auth>
	This.auth:=New object()
	This.auth.expiresIn:=3600  //seconds
	This.auth.oHead:=New object("alg";"RS256";"typ";"JWT")
	This.auth.url:="https://oauth2.googleapis.com/token"
	This.auth.bodyPrefix:="grant_type="+This._URL_Escape("urn:ietf:params:oauth:grant-type:jwt-bearer")+"&assertion="  //xxx
	This.auth.access:=New object()
	This.auth.access.header:=New object()
	This.auth.access.header.name:="Authorization"
	This.auth.access.header.value:=""  //gets assigned later.  this is just a placeholder
	  //</auth>


	  //<JWT>
	This.auth.jwt:=New object()
	This.auth.jwt.endpoint:="https://oauth2.googleapis.com/token"
	This.auth.jwt.grantType:="urn:ietf:params:oauth:grant-type:jwt-bearer"
	This.auth.jwt.header:=New object()
	This.auth.jwt.header.name:="Content-Type"
	This.auth.jwt.header.value:="application/x-www-form-urlencoded"
	  //</JWT>


	  // ===============================================================================================================


Function getAccess  //{forceRefresh:boolean}
	  // all the access (important) stuff - timeouts, token, headers - so we can update all objects if an auth changes
	  // do it indirectly so we can hide the properties and if we change the structure we don't break something
	C_OBJECT($0)
	C_BOOLEAN($1)

	This._getHeader($1)  //refresh header, if necessary
	$0:=This.auth.access

	  // _______________________________________________________________________________________________________________

Function setAccess  // set all the access (important) properties - timeouts, token, headers - so we can update all objects if an auth changes
	  // do it indirectly so we can hide the properties and if we change the structure we don't break something
	This.auth.access:=$1

	  // _______________________________________________________________________________________________________________

Function _getHeader  //{forceRefresh:boolean}
	  // returns header object to be used on subsequent calls or null
	  // retrieves a fresh access token if old one expired

	  //<force refresh?>
	C_BOOLEAN($1)  // force refresh
	$forceRefresh:=False
	If (Count parameters>0)
		$forceRefresh:=$1
	End if

	If ($forceRefresh)
		This.auth.access.expiresAt:=0
	End if
	  //</force refresh?>


	$now:=Milliseconds
	If ($now<=This.auth.access.expiresAt)  //token is still current
		$0:=This.auth.access.header
	Else   // request another token


		  //<build jwt/assertion>
		C_OBJECT($ojwt)
		$ojwt:=New object()

		  //<build jwt>
		$ojwt.iss:=This.auth.googleKey.client_email
		$ojwt.scope:=This.auth.scopes
		$ojwt.aud:=This.auth.googleKey.token_uri
		$ojwt.iat:=This._Unix_Timestamp()  // epoch seconds
		$ojwt.exp:=$ojwt.iat+This.auth.expiresIn  // an hour from now
		$ojwt.sub:=This.auth.username
		$ojwt.endpoint:=This.auth.jwt.endpoint
		$ojwt.grantType:=This.auth.jwt.grantType
		$ojwt.kid:=This.auth.googleKey.private_key_id
		  //</build jwt>

		  //<debugx>
		$x:=JSON Stringify(This.auth.oHead)
		$y:=JSON Stringify($ojwt)
		$assertion:=JWT Sign (JSON Stringify(This.auth.oHead);JSON Stringify($ojwt);This.auth.googleKey.private_key)
		  //</build jwt/assertion>


		$body:=This.auth.bodyPrefix+$assertion

		  //<get the access token>
		C_OBJECT($oResult)
		$oResult:=This._http(HTTP POST method;This.auth.url;$body;This.auth.jwt.header)
		This.status:=$oResult.status
		This.auth.access.token:=$oResult.value
		  //</get the access token>


		  //<headers to be used in subsequent calls.  token is embedded in the header>
		This.auth.access.header.value:=This.auth.access.token.token_type+" "+This.auth.access.token.access_token
		  //</headers to be used in subsequent calls.  token is embedded in the header>

		C_OBJECT($0)

		If (This.status#200)
			$0:=Null
		Else   //$status=200
			This.auth.access.expiresAt:=$now+(This.auth.access.token.expires_in*1000)  //get to milliseconds to compare to system clock
			$0:=This.auth.access.header  //return the entire object
		End if   //status#200
	End if   //(($now<=This.auth.access.expiresAt)

	  // _______________________________________________________________________________________________________________

Function _http  // (http_method:TEXT ; url:TEXT; body:TEXT; header:object)
	  // returns an object with properties  status:TEXT ; value:TEXT
	C_TEXT($1;$2;$3)
	C_OBJECT($4)

	If (This.connectionMethod="native")
		ARRAY TEXT($aHeaderNames;1)
		ARRAY TEXT($aHeaderValues;1)
		$aHeaderNames{1}:=$4.name
		$aHeaderValues{1}:=$4.value
		C_OBJECT($0;$oReturnValue)
		$0:=New object()
		$0.status:=HTTP Request($1;$2;$3;$oReturnValue;$aHeaderNames;$aHeaderValues)
		$0.value:=$oReturnValue
	Else   //"curl" // not implemented yet
		$header:=$4.name+": "+$4.value
		$0:=Null
	End if

	  // _______________________________________________________________________________________________________________

Function _Unix_Timestamp
	C_LONGINT($0;$time)

	$timestamp:=Timestamp

	ARRAY LONGINT($pos;0)
	ARRAY LONGINT($len;0)

	If (Match regex("((\\d{4})-(\\d{2})-(\\d{2}))T(\\d{2}:\\d{2}:\\d{2})\\.(\\d{3})Z";$timestamp;1;$pos;$len))

		C_DATE($date)
		$date:=Date(Substring($timestamp;$pos{1};$len{1}))

		C_LONGINT($yyyy;$mm;$dd)
		$yyyy:=Num(Substring($timestamp;$pos{2};$len{2}))
		$mm:=Num(Substring($timestamp;$pos{3};$len{3}))
		$dd:=Num(Substring($timestamp;$pos{4};$len{4}))  //eventually will be number of days since Jan 1 this year

		$daysInFeb:=Day of(Add to date(Add to date(!00-00-00!;$yyyy;3;1);0;0;-1))
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

		$time:=(0+Time(Substring($timestamp;$pos{5};$len{5})))  //seconds so far since 00:00 ZULU today
		$time:=$time+(($dd-1)*86400)  //seconds YTD through yesterday
		$time:=$time+(($yyyy-1970)*31536000)  //seconds through all non-leap years since 1970 through the beginning of the year
		$time:=$time+((($yyyy-1-1968)\4)*86400)  //seconds for leap years since 1970
	End if

	$0:=$time

	  // _______________________________________________________________________________________________________________

Function _URL_Escape
	C_TEXT($1;$0;$escaped)

	C_LONGINT($i)
	C_BOOLEAN($shouldEscape)
	C_BLOB($data)

	For ($i;1;Length($1))

		$char:=Substring($1;$i;1)
		$code:=Character code($char)

		$shouldEscape:=False

		Case of
			: ($code=45)
			: ($code=46)
			: ($code>47) & ($code<58)
			: ($code>63) & ($code<91)
			: ($code=95)
			: ($code>96) & ($code<123)
			: ($code=126)
			Else
				$shouldEscape:=True
		End case

		If ($shouldEscape)
			CONVERT FROM TEXT($char;"utf-8";$data)
			For ($j;0;BLOB size($data)-1)
				$hex:=String($data{$j};"&x")
				$escaped:=$escaped+"%"+Substring($hex;Length($hex)-1)
			End for
		Else
			$escaped:=$escaped+$char
		End if

	End for

	$0:=$escaped

	  // _______________________________________________________________________________________________________________
