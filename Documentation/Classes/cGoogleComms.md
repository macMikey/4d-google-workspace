# Class cGoogleComms
## Description
Handles all the comms with google.  This is intended to be a private library for use by those classes.  All other google classes extend this one.

## Constructor Parameters


|Name|Datatype|Required|Default|Description|
|--|--|--|--|--|
|Connection Method|Text|**NOT IMPLEMENTED**|**native**|**native** - use 4D's HTTP methods<br>**curl** - use [libCurl plugin](https://github.com/miyako/4d-plugin-curl-v2)<br>**ntk** - use [ntk plugin](https://www.pluggers.nl/product/ntk-plugin/)

## Constructor Example

```4d
C_OBJECT(oComms)
If (OB Is empty (cComms))
	oComms:=cs.cGoogleComms.new("native")
End if
```


## Internal API
As this is inended to be private and extended by other google classes, the API is also "internal", i.e. not intended for use outside of the google library

### \_http ( httpMethod:longint ; url:TEXT ; body: text header:object)
Executes an http call and returns an object containing the server's response and the status returned from the server.  The idea is to enable support for libCurl, ntk, or native 4D http calls by wrapping all of it.

|Parameter Name|Required?|Parameter Type|Default|Description|
|--|--|--|--|--|
|httpMethod|X|Longint|Required|One of 4D's *http* constants, e.g.<br>*HTTP DELETE method*<br>*HTTP GET method*<br>*HTTP HEAD method*<br>*HTTP OPTIONS method*<br>*HTTP POST method*<br>*HTTP PUT method*<br>*HTTP TRACE method*|
|url|X|Text|Required|URL to use|
|body|No|Text|(empty)|The body of the request.|
|header|X|Object|Required|The *auth.access.header* object obtained from *getAccess()* from a *cGoogleComms* object|
