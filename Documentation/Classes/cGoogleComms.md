# Class cGoogleComms
<!-- Type your summary here -->
## Description
Handles all the comms with google.
Other classes extend this one **but** there should be at least one *cGoogleComms* object created separately that will be the "master".  Authorization header data should be copied from that object to the others.  Authorization headers should be checked periodically to see if they have expired or have been revoked, and then the new data shared after the authorization is renewed.

## Constructor Parameters


|Name|Datatype|Required|Default|Description|
|--|--|--|--|--|
|Username|Text|X|Required|Username to act on behalf of|
|Scopes|Text|X|Required|**Space-Delimited** scopes to use|
|Key|Text|X|Required|The text of the API key granted by Google|
|Connection Method|Text|**NOT IMPLEMENTED**|**native**|Either **native** or **curl**, telling 4D which http code to use, depending on which you have installed in your database|

## Constructor Example

```4d
C_OBJECT(oComms)
If (OB Is empty (cComms))
	oComms:=cs.cGoogleComms.new($username;$scopes;$key;"native")
End if
```

## [Using Comms Across Multiple Objects Simultaneously](#using-comms-across-multiple-objects-simultaneously)
The *cGoogleComms* object is designed to both be independent of and/or the super class of the other google objects.  That is because it is possible to be working on one or multiple google docs/spreadsheets/etc. at the same time.
The ***base case*** is simply to instantiate a single docs/spreadsheet/etc. object.  Then that object will inherit the properties and functions of *cGoogleComms* and do its thing.
If you instead want to work on multiple docs/spreadsheets/etc. simultaneously, you can do that by sharing the authorization.
The reason for doing that is because when your app signs into Google, it is given an *access token*.  That token is valid for a period of time (as of now, that is an hour).  You could have each of your document objects sign in separately and get their own access tokens, ***however*** Google advises conserving access tokens as their number is "finite".  If you anticipate your app needing to work for more than an hour (say it updates a dashboard hourly and an inventory spreadsheet every 5 minutes), or if you get an error from Google saying that your token has expired, you would need to realize that, get the new token, and pass it around.
Instead, the *cGoogleComms* class proposes a different solution:
1. Use *cGoogleComms* to sign in and get an access token.
2. Instantiate the other objects you want to work on simultaneously.
3. Share the authorization from your *cGoogleComms* object to your other objects using ***getAccess()*** and ***setAccess()***
4. Periodically have your *cGoogleComms* object obtain a new access token.
5. Pass the new access token around to your other objects.

### Authorization Pass Example

```4d
C_OBJECT(oComms)
If (OB Is empty (cComms))
	oComms:=cs.cGoogleComms.new($username;$scopes;$key;"native")
End if

C_OBJECT(s1;s2)
If (OB Is empty(s1))
   s1:=cs.cGoogleSpreadsheet.new(oComms;$sheet1)
   s1.setAccess(oComms.getAccess())
End if

If (OB Is empty(s2))
   s2:=cs.cGoogleSpreadsheet.new(oComms;$sheet2)
   s2.setAccess(oComms.getAccess())
End if
```


## API

|Name|Parameter Name|Required?|Parameter Type|Default|Description|
|--|--|--|--|--|--|
|getAccess|forceRefresh|-|Boolean|False|Get the current access object, which includes all the important information - timesouts, token, headers.  This can be passed and assigned as-is to other google objects using the *setAccess()* function.  Use *forceRefresh* if you get a token expired error from google.|
|setAccess()|||||Sets the access object properties obtained from *getAccess()*|

## Internal Structure
#### None of the information in this section is necessary to use the class.  This is for developers who may want to modify the class and submit a PR to the repo.
**Assume that all properties (and at least some functions) will eventually be made private (not available to be used outside of the class).  Any function that begins with underscore**  ***and all properties***  **should be considered private.**

### Internal Properties
Everything in parentheses is description
```raw
	auth (object containing oauth2 info)
		access (object containing the access token data - what your code will use to talk to google)
			expiresAt: the seconds when the token will expire
			header (object containing the header information that will be sent with your calls to google)
				name:  "Authorization"
				value: "Bearer " + the encoded access token
			token (object containing the access token information as originally sent by google)
				access_token: the token data, used the suffix in auth.access.header.value
				expires_in:   seconds after token was issued that it will expire
				token_type:   the type of token, used as the prefix in auth.access.header.value
		bodyPrefix: encoded information sent to google when requesting the access token.  Held for future use/token renewal
		googleKey (object containg the google API key that was granted to the developer when the service account IAM was created)
			asString:                    raw value of the contents of the key, kept this way for easy sending and assignment to other objects
			auth_provider_x509_cert_url: url that generated the certs
			auth_url:                    url called to obtain the token
			client_email:                the iam for the service account
			client_id:                   the id of the service account
			client_x509_cert_url:        the certificate provider
			private_key:                 the private key assigned to the service account for the API
			private_key_id:              the id of the private key
			project_id:                  the id of the google cloud project
			token_url:                   URL used to generate the token
			type:                        usually "service_account" - type of account that is being used to access the API
		jwt (object describing the header being sent with the jwt when requesting the access token)
			header (object containing the fields in the header)
				name:  "Content-Type"
				value: "application/x-www-form-urlencoded"
		oHead (object containing the header information for the token request.  Stored this way so key renewal is easier)
			alg: "RS256"
			typ: "JWT"
		scoopes:  scopes the app is requesting to use
		url:		 url to call for the oauth2 request
		username: username the app will act on behalf-of
	connectionMethod: either "native" or "curl" for which code we want to use to perform the transactions.  This affects the way the headers are constructed and what is called.
	status:				the http status of the last call using the object
```

## Internal API
#### None of the information in this section is necessary to use the class.  This is for developers who may want to modify the class and submit a PR to the repo.
**Assume that all properties (and at least some functions) will eventually be made private (not available to be used outside of the class).  Any function that begins with underscore**  ***and all properties***  **should be considered private.**

### \_initializeConstants ()
I put all the constants/literals in one place in case we ever have to change them

### \_http_get (url:TEXT ; header:TEXT)
Executes an http get using developer's choice of 4d native http or libcurl

|Parameter Name|Required?|Parameter Type|Default|Description|
|--|--|--|--|--|
|url|X|Text|Required|URL to get|
|header|X|Object|Required||

### \_http_post(url:TEXT ; body:TEXT ; header:OBJECT)
Executes an http post using developer's choice of 4d native http or libcurl ***libcurl not implemented, yet***

|Parameter Name|Required?|Parameter Type|Default|Description|
|--|--|--|--|--|
|url|X|Text|Required|URL to post to|
|body|X|Text|Required||
|header|X|Object|Required|header object|

### \_Unix_Timestamp()
Returns epoch seconds

#### Reference
[Keisuke Miyako's "4D-tips-google-service-account" : *Unix_timestamp()*](https://github.com/miyako/4d-tips-google-service-account/blob/master/Unix_Timestamp.txt)

### \_URL_Escape(stringToEscape: TEXT)
Escapes a string to insert into a url/header

#### Reference
[Keisuke Miyako's "4D-tips-google-service-account" : *URL_Escape()*](https://github.com/miyako/4d-tips-google-service-account/blob/master/URL_Escape.txt)