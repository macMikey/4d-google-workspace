# Class spreadsheet

Class for accessing and updating google sheets.

Extends the *_comms* class.

Wherever appropriate, I have copied/pasted information directly from Google's documentation. In some cases I have paraphrased or rewritten for clarity.

Extra spaces added in the examples to make them easier to read.



Spreadsheets are complicated. I have found that a lot of trial-and-error has been the best way to learn how to implement them.



## Contents

[Vocabulary](#vocabulary)

[Constructor Parameters](#constructor-parameters)

[API](#api)

[Public Properties](#public-properties)

[Private Properties](#private-properties)

[Internal API](#internal-api)

[References](#references)



## Vocabulary

Much of the documentation is copied/pasted from Google's documentation, so some of the vocabulary is different than 4D vocabulary.



Term | Description
-- | --
Array | What 4D calls a *Collection* 
Range | *Generally* can be a sheet name, or a sheet name plus the bang `!` symbol, plus a range in "A1" format, e.g. Sheet1!A1:B2 
Sheet | A tab in a spreadsheet
Spreadsheet | A document that contains one or more Sheets.
spreadsheetId | Google's capitalization is not spreadsheetID, it's spreadsheetId. Rather than fighting it and having to overcome the cases where it matters, I choose to comply. 



## Constructor Parameters

|Name|Mandatory | Datatype|Description|
|--|--|--|--|
|auth|Mandatory| object |Object obtained from a *cs.google.comms* class via **getAuthAccess** |
|URL (or, just the spreadsheetId part of the URL)|Optional<br>**Omit if creating a new spreadsheet (not a new sheet)** |Text|Either the URL of the spreadsheet you want to work with (the class will strip out the parts it needs, so you could just load the spreadsheet in your browser, then copy the entire URL from the URL field) **or** the SpreadsheetId part of the URL (the part that follows the "/d/")|



### Constructor Example

```4d
var $s : cs.google.spreadsheet
If ( OB Is empty ( $s ) )
  $s := cs.cs.google.spreadsheet.new ( oGoogleComms ; $url )
  $s.load()
End if
```



## API

Function Name | Description
-- | --
[appendValues](#appendvalues) | Adds the collection to the end (below) the values in the sheet
[createSpreadsheet](#createspreadsheet)|Creates a new spreadsheet (file) and loads it.
[copySheetToSpreadsheet](#copyto)|Copies a sheet from one spreadsheet to another
[duplicateSheet](#duplicatesheet) | Duplicates a sheet (tab)
[entitySelectionToCollection](#entityselectiontocollection) | Turns an entity selection into a values collection
[findSheetWithName](#findsheetwithname)| Returns a collection of sheet objects whose names match the one provided to the function
[getSheetNames](#getsheetnames) | 1. Reloads all sheet data<br>2. Returns a collection of the names of the sheets (tabs) in the spreadsheet. 
[getValues](#getvalues)|1. Reloads all values for the sheet<br>2. Returns an object containing the value range
[load](#load) | Retrieves the metadata for the spreadsheet
[parseError](#parseerror) | Parses the error object created by google sheets
[renameSheet](#renamesheet) | Renames a sheet 
[setValues](#setvalues) | 1. Updates the range with the *valuesObject* provided.  ***NOTE:  Existing values are not overwritten unless you specify a new value for a cell.***<br>2. If successful, the response body contains a response object




### appendValues ( range : TEXT ;  values:Object { ; valueInputOption:TEXT { ; insertDataOption: TEXT { ; includeValuesInResponse: Boolean { ; responseValueRenderOption:TEXT { ; responseDateTimeRenderOption:TEXT } } } } } ) -> Object <a name="appendvalues"></a>

Implements [Spreadsheet.values.append](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/append)

1. Updates the range with the *valuesObject* provided.

   ***NOTE:  Existing values are not overwritten unless you specify a new value for a cell.***

   ***NOTE: It is not necessary to specify the last populated row before a blank range. Google Sheets will find it for you.***

2. If successful, the response body contains an instance of [UpdateValuesResponse](https://developers.google.com/sheets/api/reference/rest/v4/UpdateValuesResponse).

| Parameter Name               | Required? | Parameter Type | Default           | Description                                                  |
| ---------------------------- | --------- | -------------- | ----------------- | ------------------------------------------------------------ |
| range                        | Yes       | Text           | Required          | A range, in [A1 format](https://developers.google.com/sheets/api/guides/concepts#cell).  Only a single range may be entered. |
| valuesObject                 | Yes       | Object         | Required          | *All fields in the value object are optional*<br>{<br>  "range": string,<br>  "majorDimension":  [Dimension](https://developers.google.com/sheets/api/reference/rest/v4/Dimension),<br>  "values": [array]<br>} |
| valueInputOption             | Yes       | Text           | Required          | [How the input data should be interpreted.](https://developers.google.com/sheets/api/reference/rest/v4/ValueInputOption) <br>*RAW* - The values the user has entered will not be parsed and will be stored as-is.<br>*USER_ENTERED* - The values will be parsed as if the user typed them into the UI. Numbers will stay as numbers, but strings may be converted to numbers, dates, etc. following the same rules that are applied when entering text into a cell via the Google Sheets UI. |
| insertDataOption             | No        | Text           | INSERT_ROWS       | [How to handle rows that are not blank after **range**](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/append#insertdataoption)<br>OVERWRITE - The new data overwrites existing data in the areas it is written. (Note: adding data to the end of the sheet will still insert new rows or columns so the data can be written.)<br>INSERT_ROWS - Rows are inserted for the new data. |
| includeValuesInResponse      | No        | Boolean        | False             | Determines if the update response should include the values of the cells that were updated. By default, responses do not include the updated values. If the range to write was larger than the range actually written, the response includes all values in the requested range (excluding trailing empty rows and columns). |
| responseValueRenderOption    | No        | Text           | *FORMATTED_VALUE* | Determines how values in the response should be rendered.<br>*FORMATTED_VALUE* - Values will be calculated & formatted in the reply according to the cell's formatting. Formatting is based on the spreadsheet's locale, not the requesting user's locale. For example, if `A1` is `1.23` and `A2` is `=A1` and formatted as currency, then `A2` would return `"$1.23"`.<br>*UNFORMATTED_VALUE* - Values will be calculated, but not formatted in the reply. For example, if `A1` is `1.23` and `A2` is `=A1` and formatted as currency, then `A2` would return the number `1.23`.<br>*FORMULA* - Values will not be calculated. The reply will include the formulas. For example, if `A1` is `1.23` and `A2` is `=A1` and formatted as currency, then A2 would return `"=A1"`. |
| responseDateTimeRenderOption | No        | Text           | *SERIAL_NUMBER*   | Determines how dates, times, and durations in the response should be rendered.  Ignored if *valueRenderOption* is *FORMATTED_VALUE*.<br>*SERIAL_NUMBER* - Instructs date, time, datetime, and duration fields to be output as doubles in "serial number" format, as popularized by Lotus 1-2-3. The whole number portion of the value (left of the decimal) counts the days since December 30th 1899. The fractional portion (right of the decimal) counts the time as a fraction of the day. For example, January 1st 1900 at noon would be 2.5, 2 because it's 2 days after December 30st 1899, and .5 because noon is half a day. February 1st 1900 at 3pm would be 33.625. This correctly treats the year 1900 as not a leap year.<br>*FORMATTED_STRING* - Instructs date, time, datetime, and duration fields to be output as strings in their given number format (which is dependent on the spreadsheet locale). |

The *majorDimension* is specified in the body



#### Return Object

An object with the following fields:

| Fieldname | Description                                                  |
| --------- | ------------------------------------------------------------ |
| status    | http status.  *200* means success                            |
| value     | If successful, it will contain an instance of [UpdateValuesResponse](https://developers.google.com/sheets/api/reference/rest/v4/UpdateValuesResponse) (see below).<br>If unsuccessful/error it will contain an error object. |



**value** subfields (assuming success)


| *value.*Fieldname      | Type                                                         | Description                                                  |
| ---------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| value.*spreadsheetId*  | String                                                       | The spreadsheet the updates were applied to.                 |
| value.*updatedRange*   | String                                                       | The range (in A1 notation) that updates were applied to.     |
| value.*updatedRows*    | Integer                                                      | The number of rows where at least one cell in the row was updated. |
| value.*updatedColumns* | Integer                                                      | The number of columns where at least one cell in the column was updated. |
| value.*updatedCells*   | Integer                                                      | The number of cells updated.                                 |
| value.*updatedData*    | object ([ValueRange](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values#ValueRange)) | The values of the cells after updates were applied. This is only included if the request's includeValuesInResponse field was true. |



#### Examples

Pull data from the sheet just so we get the range, which we need to specify when we append:

```4d
$ss.getValues($sheetName) // gets data from the sheet. It isn't necessary to find where the data ends and the blank rows begin in the range. Google Sheets will do that for you when you tell it to append.
$range:=$ss.sheetData.range
//<create the values object>
   $oValues := new Object ("range";$range) // for append, we can just put the existing sheet's range
   $coll := new Collection()
   $row := new Collection ()
   $row.push("Col1";"Col2";"Col3")
   $coll.push($row) // makes $coll[0] = $row thus making $coll a 2d "array" [0][0]="Col1", [0][1]="Col2" , [0][1]="Col3"
   $oValues.values=$coll
//</create the values object>
$oResult := $ss.appendValues ( $range ; $oValues ; "RAW" )
If ($oResult=Null)//fail
   $errorMessage:=$ss.parseError()
   return $errorMessage
End If
```



Example setting more query parameters:

```4d
$oResult := $ss.appendValues ( "Sheet1!A1:B2" ; $oValues ; "USER_ENTERED" ; "INSERT_ROWS" ; True ; "UNFORMATTED_VALUE" ; "FORMATTED_STRING")
If ($oResult#Null)
     //success
Else
   $errorMessage:=$ss.parseError()
   ALERT($errorMessage)
End If
```



Example grabbing the range from the sheet's data:

```4d
$oResult := $ss.appendValues ( $ss.sheetData.range ; $oValues ; "USER_ENTERED" ; "INSERT_ROWS" ; True ; "UNFORMATTED_VALUE" ; "FORMATTED_STRING")  // can get the range from the sheetData.range property.
If ($oResult#Null)
     //success
Else
   $errorMessage:=$ss.parseError()
   ALERT($errorMessage)
End If
```



### copySheetToSpreadsheet ( $sheetName : Text ; $toSpreadsheetId : Text ) -> $resultSheet : Object <a name="copyto"></a>

* Implements [copyTo](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.sheets/copyTo)
* Copies a single sheet (the current sheet) from one spreadsheet to another
* Google does not support duplicating a spreadsheet. This is one way to achieve something similar (note that you can also achieve a deep copy of a spreadsheet, manually. See the example in [createSpreadshet](#createspreadsheet).
* **You must reload the spreadsheet for the changes to appear. This does not happen, in case this operation is part of a series of operations, such as copying the sheet followed by renaming it.**
* If successful, returns a [Sheet Object](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/sheets#SheetProperties)
* If successful, the new sheet name will be "Copy of " + *$sheetName*. That is what Google names the sheet.
* If, after copying the sheet, you want to do something like modifying the sheet's name or position, use [renameSheet](#renamesheet)




#### Example

```4d
$sheetName := "TEMPLATE"
$targetSS := getPrivateData ( "target-spreadsheet-url.txt" )
$newSheet := $s.copySheetToSpreadsheet ( $sheetName ; $targetSS )
$success := $s.renameSheet ( $newSheet.sheetId ; $sheetName ) // rename sheet to change name from "Copy of" + $sheetName to $sheetName
```






### createSpreadsheet  () -> $success : boolean<a name="createspreadsheet"></a>

Implements [spreadsheets.create](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/create)

* Any options or parameters you wish to specify, including any sheets you want to immediately add can be set in the **This.spreadsheet** [spreadsheet properties](#public-properties) of this object before calling this function. See the example, below.
* The created spreadsheet is placed at the user's root folder. To move it, see the second example in the [driveFile.moveFile](driveFile.md#move-file) documentation.
* Loads the new spreadsheet into `.spreadsheet` (see [Public Properties](#public-properties). The structure of that object is [Spreadsheet](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#Spreadsheet)



#### Response Body

If successful:

* The `.spreadsheet` property will contain the [Spreadsheet](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#Spreadsheet).
* The function will return True



#### Examples

Create a new spreadsheet in the user's root folder

```4d
$s := cs.google.spreadsheet.new ( $auth ) // no url b/c we're creating a sheet
$properties := new object ( "title" ; "test spreadsheet" )
$s.spreadsheet : =New object ( "properties" ; $properties )
// define two sheets to add
$s.spreadsheet.sheets := New Collection()
$sheet1 := New object ( "properties" ; New object ( "title" ; "Sheet1" ; "index" ; 1 ) )
$sheet2 := New object ( "properties" ; New object ( "title" ; "Sheet2" ; "index" ; 2 ) )
$s.spreadsheet.sheets.push ( $sheet1 )
$s.spreadsheet.sheets.push ( $sheet2 )

$success := $s.createSpreadsheet ()  // $s.spreadsheet will be replaced with the properties of the spreadsheet
ASSERT ( $success )
```



* Create a new spreadsheet *by copying a template sheet from another spreadsheet*.

* Move the new spreadsheet to a new location

```4d
$s := cs.spreadsheet.new ( $auth )
$properties := New object ( "title" ; "test spreadsheet" )
$s.spreadsheet := New object ( "properties" ; $properties )
$templateSS := cs.spreadsheet.new ( $auth ; $templateURL )
$templateSS.load ( "TEMPLATE" ; True ) // in the TEMPLATE sheet, load the grid data, which includes the cell metadata
$s.spreadsheet.sheets := $templateSS.sheetData.sheets // deep-copies the TEMPLATE sheet into the new spreadsheet
$success := $s.createSpreadsheet ()
ASSERT ($success)
// spreadsheet is at the root folder. Now, move it.

$ssID:=$s._spreadsheetId
$ssf := cs.google.driveFile.new ( $auth ; $ssID )  // the spreadsheet file
$fs := cs.google.driveFiles.new ( $auth ; "inspection logs" ; "folder" )  // find the folder with the name "inspection logs"
$numMatches := $fs.files.length
ASSERT ( $numMatches = 1 )

$folderID := $fs.getID()
ASSERT ( $folderID # Null )

$success := $ssf.moveTo ( $folderID )
ASSERT($success)
```

 

#### References

[API: spreadsheets.create](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/create)

[Spreadsheets Object](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#Spreadsheet)

[Google Sheets API Guide For Creating A Spreadsheet](https://developers.google.com/sheets/api/guides/create#work_with_folders)





### duplicateSheet ( sourceSheetID:INTEGER ; insertSheetIndex:INTEGER ; {newSheetID:INTEGER} ; {newSheetName:Text} ) -> object <a name="duplicatesheet"></a>

Implements [Batch Update](https://developers.google.com/sheets/api/guides/batchupdate) with a [Duplicate Sheet Request](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#duplicatesheetrequest) to duplicate a sheet

|Parameters|Required?|Datatype|Description|
|--|--|--|--|
|sourceSheetId|Yes|Integer|The sheet to duplicate.|
|insertSheetIndex|Yes|Integer|The zero-based index where the new sheet should be inserted. The index of all sheets after this are incremented.|
|newSheetId|No|Integer|If set, the ID of the new sheet. If not set, an ID is chosen. If set, the ID must not conflict with any existing sheet ID. If set, it must be non-negative.|
|newSheetName|No|Text|The name of the new sheet. If empty, a new name is chosen for you.|



#### Return object:

* If no matches are found for *sheetName*, **$0** will have the following structure:

  ```
  .success : False
  .message : "No match."
  .matches : Null
  ```

* If one match is found, the sheet will be duplicated, and **$0** will have the following structure, [including a sheetsProperties object](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/sheets#SheetProperties):
 ```
  .success 										        : True
  .message 										        : ""
  .result 										          : (Object)
  	.status										          : http status (200)
  	.value									          	: (Object)
  		.replies							          	: (Collection)
  		   [0..n]
  		      .duplicateSheet	    	      : (Object)
  		         .properties	    	      : (Object)
  		            .gridProperties       : (Object)
  		               .columnCount       : integer
  		               .frozenColumnCount : integer
  		               .rowCount          : integer
  		            .index                : integer
  		            .sheetID							: integer
  		            .sheetType						: text (e.g. "GRID")
  		            .title								: text
  		.spreadsheetId                    : text
 ```


#### Example:

```4d
$s.duplicateSheet($sheetID;$index;;$part.Part_Number)
```



### entitySelectionToCollection ( $entitySelection : 4D.EntitySelection ; $attributes : Collection ) -> collection <a name="entityselectiontocollection"></a>

Accepts an entity selection, and returns a collection of values, i.e. a collection that only consists of row and column values, with no object properties. This format is appropriate for use where **values** are called for.

Parameters | Required | Description
-- | -- | --
entitySelection | True | The entity selection to extract values from. The values are extracted in the order passed to the function
attributes | True | The attributes (columns) to be extracted, in order.



#### Example

```4d
$es:=ds.someTable.all().orderBy("someField")
$columnNames:=new Collection ("ID";"name";"description")
$valuesCollection:=$s.entitySelectionToCollection($es;$columnNames) // will return a collection like [["1","Pen","For writing"]["2","Paper","For writing"]]
```




### findSheetWithName (sheetName:TEXT) -> collection <a name="findsheetwithname"></a>

Returns a collection of sheet (tab) objects that have the name *sheetName*
[with the following properties](https://developers.google.com/sheets/api/samples/sheet#determine_sheet_id_and_other_properties)

```
[0..n]                                 : (collection)
    ├── properties                     : (object)
    │    ├── gridProperties            : (object)
    │    │   ├── columnCount           : number of columns
    │    │   ├── frozenColumnCount     : number of rows
    │    │   ├── frozenRowCount        : number of frozen rows
    │    │   └── rowCount              : number of rows
    │    ├── index                     : integer - position of the sheet (tab) in the spreadsheet
    │    ├── sheetId                   : integer id used to reference the sheet
    │    ├── sheetType                 : (add when you find out)
    │    └── title                     : name of the sheet
    └── protectedRanges                : (collection)
         [0..n]                        : (object)
             ├── editors               : (object)
             │   └── users             : (collection)
             │       [0..n]            : text
             ├── protectedRangeId      : integer
             ├── range                 : (object)
             └── requestingUserCanEdit : boolean
                         
```



### getSheetNames () -> sheetNames : collection <a name="getsheetnames"></a>

* Reloads all sheet data
* Returns a collection with the names of the sheets (tabs) in the spreadsheet.




### getValues (range:TEXT {; majorDimension:TEXT ; valueRenderOption:TEXT ; dateTimeRenderOption:TEXT}) -> object<a name="getvalues"></a>

Implements [Spreadsheet.values.get](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/get)

* Reloads all cell values

* Returns an object containing a [valueRange](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values#ValueRange) from a spreadsheet. The caller must specify the spreadsheet ID and a range.
* Does not update the properties of the spreadsheet object.
* Does not fill empty trailing rows or columns (the range returned is the size of the sheet, not the size of the data within the sheet)



#### Parameters:

|Parameter Name|Required?|Parameter Type|Default|Description|
|--|--|--|--|--|
|rangeString|Yes|Text|Yes|A range, in A1 format.  Only a single range may be entered.|
|majorDimension|No|Text|*DIMENSION_UNSPECIFIED*|*DIMENSION_UNSPECIFIED* - The default value, do not use.<br>*ROWS* - Operates on the rows of a sheet.<br>*COLUMNS* - Operates on the columns of a sheet *(as if it is transposed)*.|
|valueRenderOption|No|Text|*FORMATTED_VALUE*|*FORMATTED_VALUE* - Values will be calculated & formatted in the reply according to the cell's formatting. Formatting is based on the spreadsheet's locale, not the requesting user's locale. For example, if A1 is 1.23 and A2 is =A1 and formatted as currency, then A2 would return "$1.23".<br>*UNFORMATTED_VALUE* - Values will be calculated, but not formatted in the reply. For example, if A1 is 1.23 and A2 is =A1 and formatted as currency, then A2 would return the number 1.23.<br>*FORMULA* - Values will not be calculated. The reply will include the formulas. For example, if A1 is 1.23 and A2 is =A1 and formatted as currency, then A2 would return "=A1".<BR>**Note:** You cannot combine options. Thus if you use *FORMULA*, numbers that you intended to be used as strings, such as values with leading zeroes will be evaluated as if they are numbers, so leading zeroes will be removed. String escaping via `'` will be stripped.|
|dateTimeRenderOption|No|Text|*SERIAL_NUMBER*| Ignored if *valueRenderOption* is *FORMATTED_VALUE*.<br>*SERIAL_NUMBER* - Instructs date, time, datetime, and duration fields to be output as doubles in "serial number" format, as popularized by Lotus 1-2-3. The whole number portion of the value (left of the decimal) counts the days since December 30th 1899. The fractional portion (right of the decimal) counts the time as a fraction of the day. For example, January 1st 1900 at noon would be 2.5, 2 because it's 2 days after December 30st 1899, and .5 because noon is half a day. February 1st 1900 at 3pm would be 33.625. This correctly treats the year 1900 as not a leap year.<br>*FORMATTED_STRING* - Instructs date, time, datetime, and duration fields to be output as strings in their given number format (which is dependent on the spreadsheet locale).|



#### Return object:

The object contains a [valueRange](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values#ValueRange)

|Field|Contents|Description|
|--|--|--|
|range|String|The range the values cover, in A1 notation. For output, this range indicates the entire requested range, even though the values will exclude trailing rows and columns. When appending values, this field represents the range to search for a table, after which values will be appended.|
|majorDimension|**ROWS**<br>**COLUMNS**|The major dimension of the values.  For output, if the spreadsheet data is: A1=1,B1=2,A2=3,B2=4, then requesting range=A1:B2,majorDimension=ROWS will return [[1,2],[3,4]], whereas requesting range=A1:B2,majorDimension=COLUMNS will return [[1,3],[2,4]].|
|values|array ([ListValue](https://developers.google.com/protocol-buffers/docs/reference/google.protobuf#google.protobuf.ListValue) format)|The data that was read or to be written. This is an array of arrays, the outer array representing all the data and each inner array representing a major dimension. Each item in the inner array corresponds with one cell.<br>**For output, empty trailing rows and columns will not be included.**|



#### Examples:

Get the values for a whole sheet

```4d
$oValues := $ss.getValues ( "Sheet1" )
```



Get the values in a range on a sheet, alert if any of the cells contain "1"

```4d
$oValues := $ss.getValues ( "Sheet1" )
For ( $row ; 1 ; $oValues.values.length - 1 )
   For ( $col ; 1 ; $oValues.values [ $row ] . length - 1 )
      If ( $oValues.values [ $row ] [ $col ] = "1" )
			   ALERT ( "Value in " + String ( $row ) + ", " + String ( $col ) + " is 1." )
			End if //$oValues.values[$row][$col]="1"
   End for //$col; 1; $oValues.values[$row].length-1
End for //$row; 1; $oValues.values.length-1
```


Get the values in a range, with other parameters specified.

```4d
$oValues := $ss.getValues ( "Sheet1!A1:B2" ; "ROWS" ; "UNFORMATTED_VALUE" ; "FORMATTED_STRING" )
```



### load ( { range:TEXT ; includeGridData:Boolean } ) -> Object <a name = "load"></a>

Implements [Spreadsheets.get](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/get#body.QUERY_PARAMETERS.ranges)

Returns the spreadsheet at the given ID, and populates *This.sheetData*.

By default, data within grids (cell metadata) will not be returned. You can include grid data one of two ways:

  1. Specify a field mask listing your desired fields using the fields URL parameter in HTTP
  2. Set the includeGridData URL parameter to true. If a field mask is set, the includeGridData parameter is ignored
For large spreadsheets, it is recommended to retrieve only the specific fields of the spreadsheet that you want.
To retrieve only subsets of the spreadsheet, use the ranges URL parameter. Multiple ranges can be specified. Limiting the range will return only the portions of the spreadsheet that intersect the requested ranges. Ranges are specified using A1 notation.



#### Parameters

|Parameter Name|Required?|Parameter Type|Default|Description|
|--|--|--|--|--|
|range|No|Text|Null|A [valueRange](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values#ValueRange), in A1 format.  Multiple ranges can be separated with commas. Note that a range can be empty (load everything) or it can just specify the name of a single sheet.|
|includeGridData|No|Boolean|False|Specify whether to include [grid data](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/sheets#GridData) (the metadata of the cells, such as their colors, borders, dimensions, etc.|



#### Return Object

An object with the following fields:

|Fieldname|Description|
|--|--|
|status|http status.  *200* means success|
|value|If successful, the response body contains an instance of [Spreadsheet](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#Spreadsheet).<br>If unsuccessful/error it will contain an error object.|



#### This.sheetData properties (assuming success)

If we are able to load the range, 

|*This.sheetData.*Fieldname|Type|Description|
|--|--|--|
|properties|Object|[Spreadsheet Properties](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#SpreadsheetProperties)|
|sheets|Collection|[The spreadsheet's sheets](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/sheets#Sheet).<br>Even though you can obtain values by traversing this tree, it is easier to retrieve them using the [getValues](#getvalues) function.|
|spreadsheetId|string|The ID of the spreadsheet.|
|spreadsheetUrl|string|The url of the spreadsheet ( i.e. "https://docs.google.com/spreadsheets/d/" + This.sheetData.spreadsheetId )|



#### Example This.sheetData property layout

```
This.sheetData
├── properties                        : Object
│   ├── autoRecalc                    : Text
│   ├── defaultFormat                 : Object
│   │   └──  <properties> 
│   ├── locale                        : Text
│   ├── spreadsheetTheme              : Object
│   │   └──  <properties> 
│   ├── timeZone                      : Text
│   ├── title                         : Text
├── sheets                            : Collection
│   └── [ 0..n ]
│       ├── data                      : Collection
│       │   └── [ 0..n ]              : Object
│       │       └── <properties>      : Collection
│       └── properties                : Object
│           └── <properties>
├── spreadsheetId											: Text
└── spreadsheetUrl										: Text
```



#### Examples

```4d
$oSheetData:=$ss.load("Sheet1") `This is a valid range for loading, but not for updating.
If ($oResult#Null)
     //success
Else
   $errorMessage:=$ss.parseError()
   ALERT($errorMessage)
End If
```
```4d
$oResult:=$ss.load("Sheet1!A1:B2, Sheet2!B:B")
If ($oResult#Null)
     //success
Else
   $errorMessage:=$ss.parseError()
   ALERT($errorMessage)
End If
```
```4d
$oResult:=$ss.load(;True)`This is a valid range for loading, but not for updating.
If ($oResult#Null)
     //success
Else
   $errorMessage:=$ss.parseError()
   ALERT($errorMessage)
End If
```



### parseError() <a name="parseerror"></a>

Parses an (undocumented) Error Object as a multiple-line text variable

Currently, those lines are:
**Code:**
**Status:**
**Message:**

#### Example:
```4d
$oResult:=$ss.load("Sheet1")
If ($oResult#Null)
     //success
Else
   $errorMessage:=$ss.parseError()
   ALERT($errorMessage)
End If
```



### renameSheet ( $sheetId : Integer ; $newName : Text ) -> $success : Boolean

* Changes the name (title) of *$sheetId* to *$newName*
* **You must reload the spreadsheet for the changes to appear in your spreadsheet object. This is not done, automatically, in case renaming is part of a series of operations, to minimize the number of network operations.**
* If successful, returns *True*



#### Example

```4d
$sheetId := $s.findSheetWithName ( "Copy of Template" ) [0] . properties . sheetId
$success := $s.renameSheet ( $sheetId ; "TEMPLATE" )
```



#### References

* [batchUpdate](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/batchUpdate)
* [request](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#Request)
* [updateSheetProperties](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#UpdateSheetPropertiesRequest).





### setValues (range:TEXT ;  values:Object {;valueInputOption:TEXT ; includeValuesInResponse: Boolean ; responseValueRenderOption:TEXT; responseDateTimeRenderOption:TEXT}) -> Object <a name="setvalues"></a>

Implements [Spreadsheet.values.update](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/update)

1. Updates the range with the *valuesObject* provided.  ***NOTE:  Existing values are not overwritten unless you specify a new value for a cell.***
2. If successful, the response body contains an instance of [UpdateValuesResponse](https://developers.google.com/sheets/api/reference/rest/v4/UpdateValuesResponse).

|Parameter Name|Required?|Parameter Type|Default|Description|
|--|--|--|--|--|
|range|Yes|Text|Required|A range, in A1 format.  Only a single range may be entered.|
|valuesObject|Yes|Object|Required|*All fields in the value object are optional*<br>{<br>  "range": string,<br>  "majorDimension":  [Dimension](https://developers.google.com/sheets/api/reference/rest/v4/Dimension),<br>  "values": [array]<br>}|
|valueInputOption|Yes|Text|Required|How the input data should be interpreted. <br>*RAW* - The values the user has entered will not be parsed and will be stored as-is.<br>*USER_ENTERED* - The values will be parsed as if the user typed them into the UI. Numbers will stay as numbers, but strings may be converted to numbers, dates, etc. following the same rules that are applied when entering text into a cell via the Google Sheets UI.|
|includeValuesInResponse|No|Boolean|False|Determines if the update response should include the values of the cells that were updated. By default, responses do not include the updated values. If the range to write was larger than the range actually written, the response includes all values in the requested range (excluding trailing empty rows and columns).|
|responseValueRenderOption|No|Text|*FORMATTED_VALUE*|Determines how values in the response should be rendered.<br>*FORMATTED_VALUE* - Values will be calculated & formatted in the reply according to the cell's formatting. Formatting is based on the spreadsheet's locale, not the requesting user's locale. For example, if `A1` is `1.23` and `A2` is `=A1` and formatted as currency, then `A2` would return `"$1.23"`.<br>*UNFORMATTED_VALUE* - Values will be calculated, but not formatted in the reply. For example, if `A1` is `1.23` and `A2` is `=A1` and formatted as currency, then `A2` would return the number `1.23`.<br>*FORMULA* - Values will not be calculated. The reply will include the formulas. For example, if `A1` is `1.23` and `A2` is `=A1` and formatted as currency, then A2 would return `"=A1"`.|
|responseDateTimeRenderOption|No|Text|*SERIAL_NUMBER*| Determines how dates, times, and durations in the response should be rendered.  Ignored if *valueRenderOption* is *FORMATTED_VALUE*.<br>*SERIAL_NUMBER* - Instructs date, time, datetime, and duration fields to be output as doubles in "serial number" format, as popularized by Lotus 1-2-3. The whole number portion of the value (left of the decimal) counts the days since December 30th 1899. The fractional portion (right of the decimal) counts the time as a fraction of the day. For example, January 1st 1900 at noon would be 2.5, 2 because it's 2 days after December 30st 1899, and .5 because noon is half a day. February 1st 1900 at 3pm would be 33.625. This correctly treats the year 1900 as not a leap year.<br>*FORMATTED_STRING* - Instructs date, time, datetime, and duration fields to be output as strings in their given number format (which is dependent on the spreadsheet locale).|

The *majorDimension* is specified in the body



#### Return Object
An object with the following fields:

|Fieldname|Description|
|--|--|
|status|http status.  *200* means success|
|value|If successful, it will contain an instance of [UpdateValuesResponse](https://developers.google.com/sheets/api/reference/rest/v4/UpdateValuesResponse) (see below).<br> If unsuccessful/error it will contain an error object.|



**value subfields (assuming success)**

|*value.*Fieldname|Type|Description|
|--|--|--|
|value.*spreadsheetId*|String|The spreadsheet the updates were applied to.|
|value.*updatedRange*|String|The range (in A1 notation) that updates were applied to.|
|value.*updatedRows*|Integer|The number of rows where at least one cell in the row was updated.|
|value.*updatedColumns*|Integer|The number of columns where at least one cell in the column was updated.|
|value.*updatedCells*|Integer|The number of cells updated.|
|value.*updatedData*|object ([ValueRange](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values#ValueRange))|The values of the cells after updates were applied. This is only included if the request's includeValuesInResponse field was true.|



#### Examples

```4d
$oResult := $ss.setValues ( "Sheet1!A1:B4" ; $oValues )
If ( $oResult # Null )
     //success
Else
   $errorMessage := $ss.parseError()
   ALERT ( $errorMessage )
End If
```
```4d
$oResult := $ss.setValues ( "Sheet1!A1:B2" ; $oValues ; "USER_ENTERED" ; True ; "UNFORMATTED_VALUE" ; "FORMATTED_STRING" )
If ( $oResult # Null )
     //success
Else
   $errorMessage := $ss.parseError()
   ALERT( $errorMessage )
End If
```

```4d
$oResult := $ss.setValues ( $ss.sheetData.range ; $oValues ; "USER_ENTERED" ; True ; "UNFORMATTED_VALUE" ; "FORMATTED_STRING" )  // can get the range from the sheetData.range property.
If ( $oResult#Null )
     //success
Else
   $errorMessage := $ss.parseError()
   ALERT ( $errorMessage )
End If
```



## Public Properties <a name="public-properties"></a>

The public properties of this class should be the same as [Google's Spreadsheet Properties](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#Spreadsheet) because...I want to use this structure directly in the calls to Google's API. In some cases, this component's API will populate these fields.

In most cases, these fields are optional, but if you want to specify them for cases where you need them, you can.

Property Name | Sub-property Name | Description
-- | -- | --
sheetData | |Information returned by various commands:<br>[appendValues](#appendvalues)<br>[load](#load)<br>[setValues](#setvalues)
spreadsheet | |
spreadsheetId | **Read-Only** (String). This is embedded in the URL that is sent to Google. It is specified in the **cs.google.spreadsheet** constructor |
properties | [Spreadsheet Properties Object](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#SpreadsheetProperties)|
 sheets | [Sheet Object](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/sheets#Sheet)|
 namedRanges | [Named Range object](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#NamedRange)|
 spreadsheetUrl | **Read-Only** (String). This is the URL that is set in the **cs.google.spreadsheet** constructor. |
 developerMetadata | [Developer Metadata Object](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.developerMetadata#DeveloperMetadata)|
 dataSources | [Data Sources Object](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#DataSource)|
 dataSourceSchedules | [Data Source Refresh Schedule](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#DataSourceRefreshSchedule)|
status| | http status of the request



## Private Properties <a name="private-properties"></a>



#### None of the information in this section is necessary to use the class.  This is for developers who may want to modify the class and submit a PR to the repo.



|Field|Description|
|--|--|
|_auth | **cs.google._auth** object|
|_connectionMethod | "native".<br>Intended to be specified when instantiating the **auth** object, to help the library to decide which networking library to use, but not implemented for the others, yet. |
|_endpoint|the base url for the API to use|
|_request | The request made to the server - useful for debugging|
|_result | Object containing the result of a rest call:<br>* *request* : concat of url and body<br>* *status* : numeric return code<br>* value : whatever the server returns |
|_spreadsheetId|The part of the URL after */spreadsheets/d/*|




## Internal API



### _batchUpdate (request:object ; includeSpreadsheetInResponse:boolean ; responseRanges:string ; responseIncludeGridData:boolean) -> object

***NOTE:  At this time, only the request parameter is implemented***

Sends

`POST https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}:batchUpdate`

The request body contains data with the following structure:

```
		{
		 "requests": [
		  {
		   object (Request)
		  }
		 ],
		 "includeSpreadsheetInResponse": boolean,
		 "responseRanges": [
		  string
		 ],
		 "responseIncludeGridData": boolean
		}
```

#### References

* https://developers.google.com/sheets/api/guides/batchupdate

* https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/batchUpdate

* https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request

  

### _getSheetIDFromURL ( url:TEXT ) -> Text

Grabs the part of the url where the ID of the current sheet (tab) lives



### \_getSpreadsheetIDFromURL ( url:TEXT ) -> Text
Grabs the part of the url where the current spreadsheet lives.  I'm not sure why we have this any longer, since none of the API requires it.



### \_loadIfNotLoaded () -> Boolean
Loads the spreadsheet data with default options if the spreadsheet has not been loaded yet.



### _http ( http_method:TEXT ; url:TEXT; body:TEXT; header:object )

Overrides to ***cs.google._comms._http***: if it gets a specific error that makes it suspect that the token has expired, it force-refreshes the token and then tries again.



### \_queryRange (range:TEXT) -> Text
Builds a range query string in A1 format for use in calls from the class



## References
I have tried to embed references, where appropriate, with each API call, for easier reference.

The API itself is documented at:

https://developers.google.com/sheets/api/reference/rest
