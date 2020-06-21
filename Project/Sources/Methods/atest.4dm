//%attributes = {}
$username:=getPrivateData ("testuser.txt")
$key:=getPrivateData ("google-key.json")
$scopes:=getPrivateData ("scopes.txt")

$testURL:=getPrivateData ("testsheet.txt")



  //<initialize google auth object>
C_OBJECT:C1216(<>a)  //define interprocess b/c otherwise doesn't survive exiting the execution (IKR?)
If (OB Is empty:C1297(<>a))
	<>a:=cs:C1710.cGoogleAuth.new($username;$scopes;$key;"native")  //"native" isn't implemented, yet, though.
End if 
  //</initialize google auth object>



  //<setup a spreadsheet>
C_OBJECT:C1216($s)
$s:=Null:C1517
$s:=cs:C1710.cGoogleSpreadsheet.new(<>a;$testURL)
  //</setup a spreadsheet>



  //<EXAMPLE: get sheet names>
C_COLLECTION:C1488($sheetNames)
$sheetNames:=$s.getSheetNames()
  //</EXAMPLE: get sheet names>



  //<EXAMPLE: Replace Cell Values>
C_OBJECT:C1216($values)
$range:="Sheet1!A1:F99"
$values:=$s.getValues($range)

  //<in all occupied cells, replace contents with a sequential number>
$counter:=0
For ($i;0;($values.values.length-1))
	For ($j;0;($values.values[$i].length-1))
		$values.values[$i][$j]:=String:C10(100-$counter)
		$counter:=$counter+1
	End for 
End for 

C_OBJECT:C1216($result)
$result:=$s.setValues($range;$values;"USER_ENTERED")
  //</in all occupied cells, replace contents with a sequential number>

  //</EXAMPLE: Replace Cell Values>

TRACE:C157