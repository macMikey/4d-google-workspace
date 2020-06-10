# function getPrivateData
<!-- Type your summary here -->
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
