//%attributes = {}
//create a spreadsheet named "test sheet", with two sheets, called "Test1" and "Test2"

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

// define two sheets to add
$s.spreadsheet.sheets:=New collection:C1472()
$sheet1:=New object:C1471("properties"; New object:C1471("title"; "Test1"; "index"; 1))
$sheet2:=New object:C1471("properties"; New object:C1471("title"; "Test2"; "index"; 2))
$s.spreadsheet.sheets.push($sheet1)
$s.spreadsheet.sheets.push($sheet2)

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



//<double-bonus: copy the TEMPLATE sheet from a different spreadsheet to the new spreadsheet>
$templateURL:=getPrivateData("ipc-template-url.txt")
$templateSS:=cs:C1710.spreadsheet.new(<>a; $templateURL)
$newSheet:=$templateSS.copySheetToSpreadsheet("TEMPLATE"; $ssID)
ASSERT:C1129($newSheet#Null:C1517)
//</double-bonus: copy the TEMPLATE sheet from a different spreadsheet to the new spreadsheet>



//<triple-bonus: rename the "Copy of TEMPLATE" sheet to "TEMPLATE">
$success:=$s.renameSheet($newSheet.sheetId; "TEMPLATE")
ASSERT:C1129($success)
//<triple-bonus: rename the "Copy of Template" sheet>


ALERT:C41("Done.")