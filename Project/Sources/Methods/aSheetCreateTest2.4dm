//%attributes = {}
// create spreadsheet by "copying" another spreadsheet's sheet
// what we're really doing is grabbing the sheet data, then using it as the data for a new sheet in a new spreadsheet.



//create a spreadsheet named "test sheet", with the "TEMPLATE" sheet from the "TEMPLATE" spreadsheet.

initializeAuthObject

var $properties; $sheet1; $sheet2 : Object
var $s : cs:C1710.spreadsheet
var $oResult : Object
var $errorMessage : Text
var $ssID : Text
var $ssf : cs:C1710.driveFile
var $fs : cs:C1710.driveFiles
var $numMatches : Integer
var $folderID : Text
var $success : Boolean
var $newSheet : Object


//<create spreadsheet>
$s:=cs:C1710.spreadsheet.new(<>a)

$properties:=New object:C1471("title"; "test sheet")
$s.spreadsheet:=New object:C1471("properties"; $properties)

$templateURL:=getPrivateData("ipc-template-url.txt")
$templateSS:=cs:C1710.spreadsheet.new(<>a; $templateURL)
$templateSS.load("TEMPLATE"; True:C214)
$s.spreadsheet.sheets:=$templateSS.sheetData.sheets

$success:=$s.createSpreadsheet()
If (Not:C34($success))  //fail
	$errorMessage:=$s.parseError()
	ALERT:C41($errorMessage)
End if 
//</create spreadsheet>



//<bonus: move the spreadsheet from the root folder to a different location>
$ssID:=$s._spreadsheetId
$ssf:=cs:C1710.driveFile.new(<>a; $ssID)  // the spreadsheet file

$fs:=cs:C1710.driveFiles.new(<>a; "myshop-inspection-logs"; "folder")  // find the folder with the name
$numMatches:=$fs.files.length
ASSERT:C1129($numMatches=1)

$folderID:=$fs.getID()
If ($folderID=Null:C1517)  //fail
	$errorMessage:=$fs.parseError()
	ALERT:C41($errorMessage)
	TRACE:C157
	ABORT:C156
End if 

$success:=$ssf.moveTo($folderID)
ASSERT:C1129($success)
//</bonus: move the spreadsheet from the root folder to a different location>

ALERT:C41("Done.")