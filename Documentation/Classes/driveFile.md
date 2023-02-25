# Class driveFile
Class for handling Google Drive [files](https://developers.google.com/drive/api/v3/reference/files)

* The primary difference between this class and the **driveFiles** class is that each instance of this class will only operate on a single file, and in order to do so, you must pass the **id** of the file in the constructor.

* Extends the *_comms* class.
* Requires access to one of the linked [scopes](https://developers.google.com/drive/api/v3/reference/permissions/list#auth)
* Computes some properties which cannot be retrieved from metadata (such as path). See [Public Properties](#public-properties), which include properties that are retrieved and computed.

Wherever appropriate, I have copied/pasted information directly from Google's documentation. In some cases I have paraphrased or rewritten for clarity.



## Contents

[Vocabulary](#vocabulary)

[Constructor Parameters](#constructor-parameters)

[API](#api)

[Public Properties](#public-properties)

[Supported Filetypes](#supported-filetypes)

[Private Properties](#private-properties)

[Internal API](#internal-api)

[Reference](#reference)



## Vocabulary <a name="vocabulary"></a>

Terms that might mean something else in the Google context



| Term | Description                                                  |
| ---- | ------------------------------------------------------------ |
| file | a drive "object" - folders are files, for example, so retrieving properties of them work the same way as it would for any other...file. |



## Constructor Parameters <a name="constructor-parameters"></a>

Parameter name | Mandatory | Datatype | Description
--|--|--|--
authObject | True | Object | The auth object you created from the **cs.google.auth** class 
idOrPath | True | Text | Google's id for the file **OR**<br>You can also use **root** for the root of the user's **My Drive** **OR**<br>You can pass the path of a file 
metadataToRetrieve | False | Variant | * An asterisk (*****) indicates that all properties should be retrieved<br>* Comma-delimited list of [file properties](https://developers.google.com/drive/api/v3/reference/files)<br>* (Default) Retrieves a minimum default collection of properties. At this time, those properties are<br>    * *id*<br>    * *kind*<br>    * *mimeType*<br>    * *name* 



## API <a name="api"></a>

Function Name | Parameters | Description
--|--|--
[getID](#getid) | N/A | Returns the id of the file 
[getName](#getname) | N/A | * Retrieves the name of the file from Google<br>* Sets the *This.name* property<br>* Returns the name.
[getPath](#getpath)|N/A|Returns the path (within Google Drive) of the file<br>* Sets *This._path*
[getType](#gettype)|N/A| * Retrieves the mimeType of the file from Google<br>* Returns the [short type of the file](#supported-filetypes) (the last dot-segment of the mime-type) 
[moveFile](#move-file) | id of the target folder |Moves **This** file to the target folder



### getID () -> $id : Text <a name="getid"></a>

Returns the id of the file



### getName () -> $name : Text <a name="getname"></a>

* Retrieves the name of the file from Google
* Sets *This.name*



### getPath () -> $path : Text <a name = "getpath"></a>

* First char is always a forward slash (/)
* *root* and *My Drive* are omitted
* Sets *This._path*
* Returns the path



### getType () -> $shortType : Text  <a name = "gettype"></a>

* Retrieves the mimeType from Google
* Sets *This._type* to the [short type of the file](#supported-filetypes)
* Returns the value




### moveFile ( $targetFolderID : Text) -> $success : Boolean <a name="move-file"></a>
* Moves **This** to *$targetFolderID*.
* If successful, returns **True**, otherwise, returns **False**



#### Example

After creating a spreadsheet, Google leaves the file in the user's root folder. This example moves it to another folder.

```4d
$ssID := $s._spreadsheetId // assumes $s is a spreadsheet object
$spreadsheetFile := cs.google.driveFile.new ( auth ; $ssID)  // the spreadsheet file. This is the object we will be moving.

//<find the folder and get its ID>
$fs : = cs.driveFiles.new ( auth ; "logs"; "folder" )  // find the folder with the name
$numMatches := $fs.files.length
ASSERT ( $numMatches = 1 ) // replace this with a Case if you want to handle 0 or >1 matches

$folderID := $fs.getID()
ASSERT ( $folderID # Null ) // if $numMatches =0 or >1, $folderID will be Null
//</find the folder and get its ID>

$success := $spreadsheetFile.moveTo ( $folderID )
ASSERT ( $success )
```



#### Reference

[files:update](https://developers.google.com/drive/api/v3/reference/files/update)



## Public Properties <a name="public-properties"></a>

Property Name | Datatype | Description
--|--|--
error | Text |If an error occurs during an operation, it will be contained in this property
metadata | Object | All of the metadata obtained






## Supported Filetypes <a name="supported-filetypes"></a>

Per [Google Workspace & Google Drive supported MIME types](https://developers.google.com/drive/api/guides/mime-types), as of this writing, the following filetypes are supported in Google Drive.

When specifying the type of a file to the class, use the "short type".



| "short type" | Name                 | MIME Type                                |
| ------------ | -------------------- | ---------------------------------------- |
| audio        |                      | application/vnd.google-apps.audio        |
| document     | Google Docs          | application/vnd.google-apps.document     |
| drive-sdk    | Third-party shortcut | application/vnd.google-apps.drive-sdk    |
| drawing      | Google Drawings      | application/vnd.drawing                  |
| file         | Google Drive file    | application/vnd.google-apps.file         |
| folder       | Google Drive folder  | application/vnd.google-apps.folder       |
| form         | Google Forms         | application/vnd.google-apps.form         |
| fusiontable  | Google Fusion Tables | application/vnd.google-apps.fusiontable  |
| jam          | Google Jamboard      | application/vnd.google-apps.jam          |
| map          | Google My Maps       | application/vnd.google-apps.map          |
| photo        | Google Photos        | application/vnd.google-apps.photo        |
| presentation | Google Slides        | application/vnd.google-apps.presentation |
| script       | Google Apps Script   | application/vnd.google-apps.script       |
| shortcut     | Shortcut             | application/vnd.google-apps.shortcut     |
| site         | Google Sites         | application/vnd.google-apps.site         |
| spreadsheet  | Google Sheets        | application/vnd.google-apps.spreadsheet  |
| unknown      |                      | application/vnd.google-apps.unknown      |
| video        |                      | application/vnd.google-apps.video        |





---



## Private Properties <a name="private-properties"></a>


#### None of the information in this section is necessary to use the class.  This is for developers who may want to modify the class and submit a PR to the repo.



| Field          | Description                                           |
| -------------- | ----------------------------------------------------- |
| _auth          | **cs.google._auth** object                            |
| _endpoint      | the base url for the API to use (https://www.googleapis.com/drive/v3/files) |
| _dirty|Whether the metadata has been fetched or refreshed since the id was set|
|_id | Text |
| _metadataToRetrieve| The parameter passed by the dev. **Note:** If the class needs to obtain different metadata, it will ignore this property (example, if obtaining the path of the file)|
|_mimePrefix|`application/vnd.google-apps.` Used as the prefix to  whatever the dev sent in for the filetype when setting the **_mimeType**|
|_name | Text |
|_path | Text |



## Internal API <a name="internal-api"></a>

Function Name | Parameters | Return Value | Description
--|--|--| --
_getPath| N/A | Path : Text |* Recursively walks UP the tree to the root folder, and returns the path<br>* Structured this way b/c the public [getPath](#getpath) saves both *This.dirty* and *This.metadata* and restores them after **_getPath** achieves.
_getProp | property name : Text | Value : Variant |* If *This.dirty*, <br>    * Loads the metadata for the file<br>    * Assigns *This.metadata.<property name>* to *This._<property name>*<br>* Returns *This._<property name>* 
_getMetadata | metadata fields : Variant | Success : Boolean | Retrieves metadata fields for *This*. If *metadata* is omitted, there is a default list of fields that are obtained:<br>   * *id*<br/>    * *kind*<br/>    * *mimeType*<br/>    * *name* 
_http | HTTP Method: Text<br>URL : Text<br>Body : Text ||Handles comms




## Reference <a name="reference"></a>

[Overview](https://developers.google.com/drive)

[Guides](https://developers.google.com/drive/api/guides/about-sdk)

[Reference](https://developers.google.com/drive/api/v3/reference)

[Samples](https://developers.google.com/drive/api/samples)

[Recognized File Types](https://developers.google.com/drive/api/guides/mime-types)
