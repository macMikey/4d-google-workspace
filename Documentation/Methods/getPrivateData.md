<!--
getPrivateData ( short filename with extension : TEXT ) -> contentsOfFile : TEXT
 -->
 ﻿# function getPrivateData

## Description
Returns contents of /Resources/Private/$1

## Parameters
| Name | Datatype |Description |
|--|--|--|
|$1|Text|Short filename with extension|
|$0|Text|Contents of file|

## Example

```4d
$username:=getPrivateData("testuser.txt")
```
