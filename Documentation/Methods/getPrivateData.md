<!--
getPrivateData ( short filename with extension : TEXT ) -> contentsOfFile : TEXT
 -->

 ﻿# function getPrivateData



## Description

* Provides an easy way for you to store things like your key, scopes, and url's near your project
* Returns contents of /Resources/Private/$1
* If you keep your project in a repo, remember to add `Resources` or `Resources/Private` to your *.gitignore*

```
Resources/Private/
```



## Parameters
| Name | Datatype |Description |
|--|--|--|
|$1|Text|Short filename with extension|
|$0|Text|Contents of file|



## Example

```4d
$username:=getPrivateData("testuser.txt")
$key:=getPrivateData("google-key.json")
$scopes:=getPrivateData("scopes.txt")
$apiKey:=getPrivateData("calendar-apikey.txt")

$auth:=cs.Auth.new($username; $scopes; $key; "native")
$c:=cs.Calendar.new($auth; $apiKey)

```
