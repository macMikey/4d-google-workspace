//%attributes = {}
initializeAuthObject

$testURL:=getPrivateData("testsheet.txt")


//<setup a spreadsheet>
C_OBJECT:C1216($s)
$s:=Null:C1517
$s:=cs:C1710.spreadsheet.new(<>a; $testURL)
//</setup a spreadsheet>



//<EXAMPLE: get sheet names>
C_COLLECTION:C1488($sheetNames)
$sheetNames:=$s.getSheetNames()
If ($sheetNames=Null:C1517)
	ALERT:C41("getSheetNames("+$range+")\r"+$s.parseError())
	ABORT:C156
End if 
//</EXAMPLE: get sheet names>



//<EXAMPLE: Replace Cell Values>
C_OBJECT:C1216($values)
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

C_OBJECT:C1216($result)
$result:=$s.setValues($s.sheetData.range; $values; "USER_ENTERED")  // fun fact: can get the full range of the sheet from the sheetData.range property
If ($result=Null:C1517)
	ALERT:C41("setValues("+$range+")\r"+$s.parseError())
	ABORT:C156
End if 

//</in all occupied cells, replace contents with a sequential number>

//</EXAMPLE: Replace Cell Values>

TRACE:C157