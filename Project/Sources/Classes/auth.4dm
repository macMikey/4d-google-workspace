// handles all the authentication...stuff.
// Should be instantiated as a process object and therefore shared b/c tokens will periodically expire

Class extends _comms

Class constructor($username : Text; $scopes : Text; $key : Text; $connectionMethod : Variant)
	
	Super:C1705($connectionMethod)
	
	//<constants>
	//<auth>
	This:C1470.expiresIn:=3600  //seconds
	This:C1470.oHead:=New object:C1471("alg"; "RS256"; "typ"; "JWT")
	This:C1470.url:="https://oauth2.googleapis.com/token"
	This:C1470.bodyPrefix:="grant_type="+Super:C1706._URL_Escape("urn:ietf:params:oauth:grant-type:jwt-bearer")+"&assertion="
	This:C1470.access:=New object:C1471()
	This:C1470.access.header:=New object:C1471()
	This:C1470.access.header.name:="Authorization"
	This:C1470.access.header.value:=""  //gets assigned later.  this is just a placeholder
	//</auth>
	
	//<JWT>
	This:C1470.jwt:=New object:C1471()
	This:C1470.jwt.endpoint:="https://oauth2.googleapis.com/token"
	This:C1470.jwt.grantType:="urn:ietf:params:oauth:grant-type:jwt-bearer"
	This:C1470.jwt.header:=New object:C1471()
	This:C1470.jwt.header.name:="Content-Type"
	This:C1470.jwt.header.value:="application/x-www-form-urlencoded"
	//</JWT>
	//</constants>
	
	
	//<handle params>
	This:C1470.username:=$username
	This:C1470.scopes:=$scopes
	This:C1470.googleKey:=JSON Parse:C1218($key)
	//</handle params>
	
	
	//<initialize properties>
	This:C1470.createdAtTicks:=0  // will be corrected when we create the header, below
	This:C1470.access.token:=New object:C1471()
	//</initialize properties>
	
	
	This:C1470.getHeader(True:C214)  //initialize and force refresh
	// ===============================================================================================================
	
	
	
Function getHeader($forceRefresh : Variant)
	// returns header object to be used on subsequent calls or null
	// retrieves a fresh access token if old one expired
	
	$forceRefresh:=False:C215
	If (Count parameters:C259>0)
		$forceRefresh:=$1
	End if 
	
	
	//<see if the token has expired>
	$now:=Tickcount:C458
	$then:=This:C1470.createdAtTicks
	Case of 
		: ((($now>0) & ($then>0)) | (($now<0) & ($then<0)))  // signs the same on both
			$diff:=$now-$then
		: (($now>0) & ($then<0))
			$diff:=Abs:C99((MAXLONG:K35:2-$now)+($then-MAXLONG:K35:2))
		Else   // $now<0 and $end>0
			$diff:=($now-MAXLONG:K35:2)+(MAXLONG:K35:2-$then)
	End case 
	
	If ($diff>=(This:C1470.expiresIn*60))
		$forceRefresh:=True:C214
	End if   //$diff>=(This.access.expiresIn*60)
	//</see if the token has expired>
	
	
	If (Not:C34($forceRefresh))  //token is still current
		$0:=This:C1470.access.header
	Else   // request another token
		
		
		//<build jwt/assertion>
		var $ojwt : Object
		$ojwt:=New object:C1471()
		
		//<build jwt>
		$ojwt.iss:=This:C1470.googleKey.client_email
		$ojwt.scope:=This:C1470.scopes
		$ojwt.aud:=This:C1470.googleKey.token_uri
		$ojwt.iat:=This:C1470._computeNowSeconds()
		$ojwt.exp:=$ojwt.iat+This:C1470.expiresIn  // an hour from now
		$ojwt.sub:=This:C1470.username
		$ojwt.endpoint:=This:C1470.jwt.endpoint
		$ojwt.grantType:=This:C1470.jwt.grantType
		$ojwt.kid:=This:C1470.googleKey.private_key_id
		//</build jwt>
		
		
		$settings:=New object:C1471("type"; "PEM"; "pem"; This:C1470.googleKey.private_key)
		$jwt:=cs:C1710._jwt.new($settings)
		$assertion:=$jwt.sign(This:C1470.oHead; $ojwt; New object:C1471("algorithm"; "RS256"))
		//</build jwt/assertion>
		
		
		$body:=This:C1470.bodyPrefix+$assertion
		
		//<get the access token>
		var $oResult : Object
		This:C1470.status:=Null:C1517
		This:C1470.access.token:=Null:C1517
		$oResult:=This:C1470._http(HTTP POST method:K71:2; This:C1470.url; $body; This:C1470.jwt.header)
		If (Not:C34(Undefined:C82($oResult.value.error)))
			This:C1470.error:=New object:C1471()
			This:C1470.error.status:=$oResult.status
			This:C1470.error.error:=$oResult.value.error
			This:C1470.error.error_description:=$oResult.value.error_description
			return Null:C1517
		End if 
		This:C1470.status:=$oResult.status
		This:C1470.access.token:=$oResult.value
		//</get the access token>
		
		
		//<headers to be used in subsequent calls.  token is embedded in the header>
		This:C1470.access.header.value:=This:C1470.access.token.token_type+" "+This:C1470.access.token.access_token
		//</headers to be used in subsequent calls.  token is embedded in the header>
		
		var $0 : Object
		
		If (This:C1470.status#200)
			$0:=Null:C1517
		Else   //$status=200
			$0:=This:C1470.access.header  //return the entire object
			This:C1470.createdAtTicks:=Tickcount:C458-600  //just to be safe, force refresh token 10 seconds before we think it's going to expire by aging it by 10 seconds.
		End if   //status#200
	End if   //(not($forceRefresh))
	// _______________________________________________________________________________________________________________
	
	
	
Function _computeNowSeconds()  // in zulu
	$Epoch_Date_D:=Date:C102("1/1/1970")
	
	$today:=Current date:C33
	$days:=$today-$Epoch_Date_D
	$secondsToToday:=$days*86400
	$secondsSinceMidnight:=Current time:C178()
	$zuluTimestamp:=Timestamp:C1445
	$localTimestamp:=Substring:C12($zuluTimestamp; 1; 23)  // remove the z
	$offset:=((Date:C102($zuluTimestamp)-Date:C102($localTimestamp))*86400)+((Time:C179($zuluTimestamp)-Time:C179($localTimestamp))*1)
	return $secondsToToday+$secondsSinceMidnight-$offset  // 4D date/time are in local, and we are returning zulu
	// _______________________________________________________________________________________________________________
	