//%attributes = {}
$username:=getPrivateData ("testuser.txt")
$key:=getPrivateData ("google-key.json")
$scopes:=getPrivateData ("scopes.txt")

$testURL:=getPrivateData ("testsheet.txt")



  //define interprocess b/c otherwise doesn't survive exiting the execution (IKR?)
C_OBJECT:C1216(<>a)
If (OB Is empty:C1297(<>a))  //create
	<>a:=cs:C1710.cGoogleComms.new($username;$scopes;$key;"native")
End if 


C_OBJECT:C1216(<>s)
If (OB Is empty:C1297(<>s))
	<>s:=cs:C1710.cGoogleSpreadsheet.new(<>a;$testSheet)
	<>s.setAccess(<>a.getAccess())  //copy access from a to s.  wouldn't it be cool to do this with pointers, like pass a pointer to the comms object and use that every time?
End if 
$spreadsheet:=<>s.getSpreadsheet()
