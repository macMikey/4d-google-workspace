//%attributes = {}
$username:=getPrivateData ("testuser.txt")
$key:=getPrivateData ("google-key.json")
$scopes:=getPrivateData ("scopes.txt")

$testURL:=getPrivateData ("testsheet.txt")



  // i am creating the google comms object in an interprocess variable to avoid regenerating the access token every time we run a method.
  // google claims the number of access tokens is finite, whatever that means.



  //<initialize google auth
C_OBJECT:C1216(<>a)  //define interprocess b/c otherwise doesn't survive exiting the execution (IKR?)
If (OB Is empty:C1297(<>a))
	<>a:=cs:C1710.cGoogleAuth.new($username;$scopes;$key;"native")  //"native" isn't implemented, yet, though.
End if 
  //</initialize google auth


  //<setup a spreadsheet>
C_OBJECT:C1216($s)
$s:=Null:C1517
$s:=cs:C1710.cGoogleSpreadsheet.new(<>a;$testURL)
  //</setup a spreadsheet>


If (False:C215)  //<get everything for a spreadsheet>
	C_OBJECT:C1216($spreadsheetData)
	$spreadsheetData:=$s._ss_get
End if   //</get everything for a spreadsheet>


C_OBJECT:C1216($values)
$range:="Sheet1!A1:F99"
$values:=$s._ss_values_get($range)

  //<in all occupied cells, replace contents with a sequential number>
$counter:=0
For ($i;0;($values.values.length-1))
	For ($j;0;($values.values[$i].length-1))
		$values.values[$i][$j]:=String:C10($counter)
		$counter:=$counter+1
	End for 
End for 

C_OBJECT:C1216($result)
$result:=$s._ss_values_update($range;$values;"USER_ENTERED")
  //</in all occupied cells, replace contents with a sequential number>