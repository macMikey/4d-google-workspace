//%attributes = {}
// designed for use with the test/sample methods.
// define interprocess b/c otherwise the object won't survive between tests
// could use a shared object, but i have not written the _auth object to be a singleton, yet, since it must be able to be modified when the token changes

C_OBJECT:C1216(<>a)
If (OB Is empty:C1297(<>a))
	$username:=getPrivateData("testuser.txt")
	$key:=getPrivateData("google-key.json")
	$scopes:=getPrivateData("scopes.txt")
	<>a:=cs:C1710.auth.new($username; $scopes; $key; "native")  //"native" isn't implemented, yet, though.
	If (Not:C34(Undefined:C82(<>a.error)))
		TRACE:C157
		$oError:=<>a.error
		$error:="Status: "+String:C10($oError.status)+"\rError: "+$oError.error+"\rDescription:"+$oError.error_description
		ALERT:C41($error)
		<>a:=Null:C1517
		ABORT:C156
	End if   //(Not(Undefined(<>a.error)))
End if   //(OB Is empty(<>a))