# Class cGoogleSpreadsheet
<!-- Type your summary here -->
## Description
Class for accessing and updating google sheets.
Extends *cGoogleComms*, **but** there should be at least one *cGoogleComms* object created separately that will be the "master".  Authorization header data should be copied from that object to the others.  Authorization headers should be checked periodically to see if they have expired or have been revoked, and then the new data shared after the authorization is renewed.

## Constructor Parameters

|Name|Datatype|Description|
|--|--|--|
|cGoogleAuth|object|Object obtained from a *cGoogleComms* class via **getAuthAccess** |
|URL|Text|The URL of the spreadsheet you want to work with|

## Constructor Example

```4d
C_OBJECT(s)
If (OB Is empty (s))
	s:=cs.cGoogleSpreadsheet.new(oGoogleComms;$url)
End if
```
After the comms object is created and instantiated, the authorization should be copied to other google objects using *getAccess()* and *setAccess()*.

## Authorization Pass Example
Passing the authorization from a cGoogleComms object to a spreadsheet looks like this:

```4d
   s.setAccess(oComms.getAccess())
```
Then the spreadsheet is ready to go.

## API


|Name|Parameter Name|Required?|Parameter Type|Default|Description|
|--|--|--|--|--|--|
|getSpreadsheet|-|-|-|-|Returns an object with the spreadsheet data|
||rangeString|-|Text|Null|A range, in A1 format.  Multiple ranges can be separated with commas|
||includeGridData|-|Boolean|False|Specify whether to include grid data|


## Internal Structure
#### None of the information in this section is necessary to use the class.  This is for developers who may want to modify the class and submit a PR to the repo.
**Assume that all properties (and at least some functions) will eventually be made private (not available to be used outside of the class).  Any function that begins with underscore**  ***and all properties***  **should be considered private.**

### Internal Properties
Everything in parentheses is description
```raw
	spreadsheetID (The part of the URL after /spreadsheets/d/)
	endpoint (the base url for the API to use)
	status (http status of the request)
	sheetData (the object returned from google)
```

### Internal API

|Name|Parameter Name|Required?|Parameter Type|Default|Description|
|--|--|--|--|--|--|
|_getSheetIDFromURL|url|X|Text|Required|Grabs the part of the url where the ID of the current sheet (tab) lives|
|_getSpreadsheetIDFromURL|url|X|Text|Required|Grabs the part of the url where the current spreadsheet lives|
|_queryRange|rangeString|-|Text|Null|builds a range query string|

## References
https://developers.google.com/sheets/api/reference/rest