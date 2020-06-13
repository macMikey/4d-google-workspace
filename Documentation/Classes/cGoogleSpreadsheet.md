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

## Internal API
### None of the information in this section is necessary to use the class.  This is for developers who may want to modify the class and submit a PR to the repo.
**Assume that all properties (and at least some functions) will eventually be made private (not available to be used outside of the class).  Any function that begins with underscore**  ***and all properties***  **should be considered private.**

The Internal API lines up exactly with v4 of [Google's REST API](https://developers.google.com/sheets/api/reference/rest)


### \_getSheetIDFromURL (url:TEXT)
Grabs the part of the url where the ID of the current sheet (tab) lives

###\_getSpreadsheetIDFromURL (url:TEXT)
Grabs the part of the url where the current spreadsheet lives

### \_queryRange (range:TEXT)
Builds a range query string in A1 format

### \_ss_get({range:TEXT ; includeGridData:Boolean})
Returns the spreadsheet at the given ID. The caller must specify the spreadsheet ID.
By default, data within grids will not be returned. You can include grid data one of two ways:
	1. Specify a field mask listing your desired fields using the fields URL parameter in HTTP
	2. Set the includeGridData URL parameter to true. If a field mask is set, the includeGridData parameter is ignored
For large spreadsheets, it is recommended to retrieve only the specific fields of the spreadsheet that you want.
To retrieve only subsets of the spreadsheet, use the ranges URL parameter. Multiple ranges can be specified. Limiting the range will return only the portions of the spreadsheet that intersect the requested ranges. Ranges are specified using A1 notation.

|Parameter Name|Required?|Parameter Type|Default|Description|
|--|--|--|--|--|
|range|-|Text|Null|A range, in A1 format.  Multiple ranges can be separated with commas|
|includeGridData|-|Boolean|False|Specify whether to include grid data|

#### Examples
```4d
	$oSomeObject:=ss_get()
```
```4d
	$oSomeObject:=ss_get("Sheet1!A1:B2, Sheet2!B:B")
```
```4d
	$oSomeObject:=ss_get(;True)
```

#### Reference
[Spreadsheets.get](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/get#body.QUERY_PARAMETERS.ranges)


### \_ss_values_get (range:TEXT {; valueRenderOption:TEXT ; dateTimeRenderOption:TEXT})
Returns a range of values from a spreadsheet. The caller must specify the spreadsheet ID and a range.

|Parameter Name|Required?|Parameter Type|Default|Description|
|--|--|--|--|--|
|rangeString|Yes|Text|Required|A range, in A1 format.  Only a single range may be entered.|
|majorDimension|-|Text|*DIMENSION_UNSPECIFIED*|*DIMENSION_UNSPECIFIED* - The default value, do not use.<br>*ROWS* - Operates on the rows of a sheet.<br>*COLUMNS* - Operates on the columns of a sheet *(as if it is transposed)*.|
|valueRenderOption|-|Text|*FORMATTED_VALUE*|*FORMATTED_VALUE* - Values will be calculated & formatted in the reply according to the cell's formatting. Formatting is based on the spreadsheet's locale, not the requesting user's locale. For example, if A1 is 1.23 and A2 is =A1 and formatted as currency, then A2 would return "$1.23".<br>*UNFORMATTED_VALUE* - Values will be calculated, but not formatted in the reply. For example, if A1 is 1.23 and A2 is =A1 and formatted as currency, then A2 would return the number 1.23.<br>*FORMULA* - Values will not be calculated. The reply will include the formulas. For example, if A1 is 1.23 and A2 is =A1 and formatted as currency, then A2 would return "=A1".|
|dateTimeRenderOption|-|Text|*SERIAL_NUMBER*| Ignored if *valueRenderOption* is *FORMATTED_VALUE*.<br>*SERIAL_NUMBER* - Instructs date, time, datetime, and duration fields to be output as doubles in "serial number" format, as popularized by Lotus 1-2-3. The whole number portion of the value (left of the decimal) counts the days since December 30th 1899. The fractional portion (right of the decimal) counts the time as a fraction of the day. For example, January 1st 1900 at noon would be 2.5, 2 because it's 2 days after December 30st 1899, and .5 because noon is half a day. February 1st 1900 at 3pm would be 33.625. This correctly treats the year 1900 as not a leap year.<br>*FORMATTED_STRING* - Instructs date, time, datetime, and duration fields to be output as strings in their given number format (which is dependent on the spreadsheet locale).|


### Examples
```4d
	$oValues:=_ss_values_get("Sheet1!A1:B4")
```
```4d
	$oValues:=_ss_values_get("Sheet1!A1:B2";"UNFORMATTED_VALUE";"FORMATTED_STRING")
```

#### Reference
[Spreadsheet.values.get](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/get)




### \_ss_values_update (range:TEXT ;  values:Object {;valueInputOption:TEXT ; includeValuesInResponse: Boolean ; responseValueRenderOption:TEXT; responseDateTimeRenderOption:TEXT})
Updates the range with the *valuesObject* provided.  ***NOTE:  Existing values are not overwritten unless you specify a new value for a cell.***

|Parameter Name|Required?|Parameter Type|Default|Description|
|--|--|--|--|--|
|range|Yes|Text|Required|A range, in A1 format.  Only a single range may be entered.|
|valuesObject|Yes|Object|Required|*All fields in the value object are optional*<br>{<br>  "range": string,<br>  "majorDimension":  [Dimension](https://developers.google.com/sheets/api/reference/rest/v4/Dimension),<br>  "values": [array]<br>}|
|valueInputOption|Yes|Text|Required|How the input data should be interpreted. <br>*RAW* - The values the user has entered will not be parsed and will be stored as-is.<br>*USER_ENTERED* - The values will be parsed as if the user typed them into the UI. Numbers will stay as numbers, but strings may be converted to numbers, dates, etc. following the same rules that are applied when entering text into a cell via the Google Sheets UI.|
|includeValuesInResponse|-|Boolean|False|Determines if the update response should include the values of the cells that were updated. By default, responses do not include the updated values. If the range to write was larger than the range actually written, the response includes all values in the requested range (excluding trailing empty rows and columns).|
|responseValueRenderOption|-|Text|*FORMATTED_VALUE*|Determines how values in the response should be rendered.<br>*FORMATTED_VALUE* - Values will be calculated & formatted in the reply according to the cell's formatting. Formatting is based on the spreadsheet's locale, not the requesting user's locale. For example, if `A1` is `1.23` and `A2` is `=A1` and formatted as currency, then `A2` would return `"$1.23"`.<br>*UNFORMATTED_VALUE* - Values will be calculated, but not formatted in the reply. For example, if `A1` is `1.23` and `A2` is `=A1` and formatted as currency, then `A2` would return the number `1.23`.<br>*FORMULA* - Values will not be calculated. The reply will include the formulas. For example, if `A1` is `1.23` and `A2` is `=A1` and formatted as currency, then A2 would return `"=A1"`.|
|responseDateTimeRenderOption|-|Text|*SERIAL_NUMBER*| Determines how dates, times, and durations in the response should be rendered.  Ignored if *valueRenderOption* is *FORMATTED_VALUE*.<br>*SERIAL_NUMBER* - Instructs date, time, datetime, and duration fields to be output as doubles in "serial number" format, as popularized by Lotus 1-2-3. The whole number portion of the value (left of the decimal) counts the days since December 30th 1899. The fractional portion (right of the decimal) counts the time as a fraction of the day. For example, January 1st 1900 at noon would be 2.5, 2 because it's 2 days after December 30st 1899, and .5 because noon is half a day. February 1st 1900 at 3pm would be 33.625. This correctly treats the year 1900 as not a leap year.<br>*FORMATTED_STRING* - Instructs date, time, datetime, and duration fields to be output as strings in their given number format (which is dependent on the spreadsheet locale).|

The *majorDimension* is specified in the body

### Examples
```4d
	$oValues:=ss_values_update("Sheet1!A1:B4";$oValues)
```
```4d
$oValues:=ss_values_update("Sheet1!A1:B2";$oValues;"USER_ENTERED";True;"UNFORMATTED_VALUE";"FORMATTED_STRING")
```

#### Reference
[Spreadsheet.values.update](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/update)


## References
https://developers.google.com/sheets/api/reference/rest
