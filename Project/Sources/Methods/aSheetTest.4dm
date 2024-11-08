//%attributes = {}
initializeAuthObject

$testURL:=getPrivateData("testsheet.txt")


//<setup a spreadsheet>
var $s : Object
$s:=Null:C1517
$s:=cs:C1710.spreadsheet.new(<>a; $testURL)
//</setup a spreadsheet>



//<EXAMPLE: get sheet names>
var $sheetNames : Collection
$sheetNames:=$s.getSheetNames()
If ($sheetNames=Null:C1517)
	ALERT:C41("getSheetNames error:\r"+$s.parseError())
	ABORT:C156
End if 
//</EXAMPLE: get sheet names>



//<EXAMPLE: Replace Cell Values>
var $values : Object
$values:=$s.getValues("Sheet1")
If ($values=Null:C1517)
	ALERT:C41("getValues("+$range+")\r"+$s.parseError())
	ABORT:C156
End if 

//<in all occupied cells, replace contents with a sequential number>
$counter:=0
For ($i; 0; ($values.values.length-1))
	For ($j; 0; ($values.values[$i].length-1))
		$values.values[$i][$j]:=String:C10(100-$counter)
		$counter:=$counter+1
	End for 
End for 

var $result : Object
$result:=$s.setValues($s.sheetData.range; $values; "USER_ENTERED")  // fun fact: can get the full range of the sheet from the sheetData.range property
If ($result=Null:C1517)
	ALERT:C41("setValues("+$range+")\r"+$s.parseError())
	ABORT:C156
End if 

//</in all occupied cells, replace contents with a sequential number>

//</EXAMPLE: Replace Cell Values>

TRACE:C157