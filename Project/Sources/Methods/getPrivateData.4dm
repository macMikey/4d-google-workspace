//%attributes = {}
#DECLARE($filename : Text)->$result : Text

//<get path, which is the parent of the repo + /Private/>
$folder:=Folder:C1567("/PACKAGE/")
$path:=$folder.platformPath
$delimiter:=$folder.platformPath[[Length:C16($path)]]
$path:=Substring:C12($path; 1; Length:C16($path)-1)
While ($path[[Length:C16($path)]]#$delimiter)
	$path:=Substring:C12($path; 1; Length:C16($path)-1)
End while 
$path+="Private"+$delimiter
$folder:=Folder:C1567($path; fk platform path:K87:2)
//<get path, which is the parent of the repo + /Private/>


//<bypass comment header line, if it exists>
If (Substring:C12($fileData; 1; 2)="//")
	$eol:=Position:C15("\r\n"; $fileData)
	If ($eol=0)
		$eol:=Position:C15("\r"; $fileData)
		If ($eol=0)
			$eol:=Position:C15("\n"; $fileData)
		End if 
	End if 
	
	$fileData:=Substring:C12($fileData; ($eol+1); Length:C16($fileData))
End if   //(Substring($fileData;1;2)="//")
//</bypass comment header line, if it exists>

$result:=$fileData
