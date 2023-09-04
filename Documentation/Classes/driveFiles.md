# Class driveFiles
Class for handling Google Drive [files](https://developers.google.com/drive/api/v3/reference/files)

* The primary difference between this class and the **drive_file** class is that this class is intended to do searching, etc., and obtaining a collection of files that match the parameters passed in. For example, there may be multiple files that match the name passed in.
* Extends the *_comms* class.
* Requires access to one of the linked [scopes](https://developers.google.com/drive/api/v3/reference/permissions/list#auth)

Wherever appropriate, I have copied/pasted information directly from Google's documentation. In some cases I have paraphrased or rewritten for clarity.

Extra spaces added in the examples to make them easier to read.



## Contents

[Vocabulary](#vocabulary)

[Constructor Parameters](#constructor-parameters)

[API](#api)

[Public Properties](#public-properties)

[Private Properties](#private-properties)

[Internal API](#internal-api)

[Reference](#reference)



## Vocabulary <a name="vocabulary"></a>

Words mean things, just not always what we think they mean.



| Term | Description                                                  |
| ---- | ------------------------------------------------------------ |
| file | a drive "object" - folders are files, for example, so retrieving properties of them work the same way as it would for any other...file. |



## Constructor Parameters<a name="constructor-parameters"></a>

| Parameter name | Datatype | Mandatory | Description              |
| -------------- |-------- | ------------------------ | --|
| authorization | **cs.google.auth** | Yes | The authorization object |
| name | Text | No | The name to match |
| file type | Text | No |One of the [Supported Filetypes](#supported-filetypes)|
| parentID | Text | No | If specified, only files that are in the *parentID* folder are considered.<br>This is helpful when trying to traverse a path, for example. |



### Examples

```4d
$files := cs.google.driveFiles.new ( "Death Star Plans" ; "folder" ) // returns a collection of all folders with that name
```

```4d
$files := cs.google.driveFiles.new ( $auth ; "Death Star Plans" ; "folder" )
$secretPlans := cs.google.driveFiles.new ( $auth ; "" ; "" ; $files.getID() ) // all the files in the Death Star Plans folder
```





## API<a name="api"></a>



Function Name | Parameters | Description
--|--|--
[getID]($getid) | N/A | If only a single file matches, its id is returned<br>Otherwise **Null** is returned



### getID () -> $id : Text <a name="getid"></a>

* Returns the ID of the file specified in the constructor, **if there is only one file that matches the name and the type**
* Returns **Null** otherwise



## Public Properties<a name="public-properties"></a>

| Property Name | Datatype   | Description                                                  |
| ------------- | ---------- | ------------------------------------------------------------ |
| error         | Text       | If an error occurs during an operation, it will be contained in this property |
| files         | Collection | A collection of objects that match the name and the short type set when *This* was instantiated. |



## Private Properties<a name="private-properties"></a>



#### None of the information in this section is necessary to use the class.  This is for developers who may want to modify the class and submit a PR to the repo.





| Field               | Description                                                  |
| ------------------- | ------------------------------------------------------------ |
| _auth               | **cs.google._auth** object                                   |
| _endpoint           | the base url for the API to use (https://www.googleapis.com/drive/v3/files) |
| _dirty              | Whether the metadata has been fetched or refreshed since the id was set |
| _mimePrefix         | application/vnd.google-apps.|
| _mimeType | *This._mimePrefix* plus the type passed in the constructor|
| _name               | Text                                                         |
| _path               | Text                                                         |




## Supported Filetypes<a name="supported-filetypes"></a>

Per [Google Workspace & Google Drive supported MIME types](https://developers.google.com/drive/api/guides/mime-types), as of this writing, the following filetypes are supported in Google Drive.

When specifying the type of a file to the class, use the "short type".



FIletype Name|Common Name | MIME Type
--|--|--
audio| | application/vnd.google-apps.audio
document|Google Docs|application/vnd.google-apps.document
drive-sdk|Third-party shortcut|application/vnd.google-apps.drive-sdk
drawing|Google Drawings|application/vnd.drawing
file|Google Drive file|application/vnd.google-apps.file
folder|Google Drive folder|application/vnd.google-apps.folder
form|Google Forms|application/vnd.google-apps.form
fusiontable|Google Fusion Tables|application/vnd.google-apps.fusiontable
jam|Google Jamboard|application/vnd.google-apps.jam
map|Google My Maps|application/vnd.google-apps.map
photo|Google Photos|application/vnd.google-apps.photo
presentation|Google Slides|application/vnd.google-apps.presentation
script|Google Apps Script|application/vnd.google-apps.script
shortcut|Shortcut|application/vnd.google-apps.shortcut
site|Google Sites|application/vnd.google-apps.site
spreadsheet|Google Sheets|application/vnd.google-apps.spreadsheet
unknown| |application/vnd.google-apps.unknown
video| |application/vnd.google-apps.video



## Internal API<a name="internal-api"></a>

| Function Name | Parameters| Description                                                  |
| ------------- | ---------------------------------------------- | ------------------------------------------------------------ |
| _http         | HTTP Method: Text<br>URL : Text<br>Body : Text | Handles comms                                                |
| [_getFiles](#getfiles)      | N/A | * Searches for files that match the name and/or type passed in the constructor<br>* Assigns *This.files* to the collection<br>* Returns a boolean indicating success




### _getFiles () -> $success : Boolean <a name="getfiles"></a>

* Searches for files that match the name and/or type passed in the constructor for *This*

* Does not process more than a single page (>100) of results.

* Implements [files:list](https://developers.google.com/drive/api/v3/reference/files/list), with [search](https://developers.google.com/drive/api/guides/search-files)

* If successful:
  * *$success* = True
  * *This.files* will contain a collection of file objects that are folders which match.



#### This.files (Collection)

```
├── .length
└── [0]..[n]
    ├── id       : uuid
    ├── kind     : e.g. drive#file
    ├── mimeType : e.g. application/vnd.google-apps.folder for a folder
    └── name     : short name
```



#### Example



#### Reference

[files:list](https://developers.google.com/drive/api/v3/reference/files/list)

[query terms](https://developers.google.com/drive/api/guides/ref-search-terms)

[restricting search to folders only](https://developers.google.com/drive/api/guides/search-files)

[return specific fields](https://developers.google.com/drive/api/guides/fields-parameter)



## Reference <a name="reference"></a>

[Overview](https://developers.google.com/drive)

[Guides](https://developers.google.com/drive/api/guides/about-sdk)

[Reference](https://developers.google.com/drive/api/v3/reference)

[Samples](https://developers.google.com/drive/api/samples)

[Recognized File Types](https://developers.google.com/drive/api/guides/mime-types)
