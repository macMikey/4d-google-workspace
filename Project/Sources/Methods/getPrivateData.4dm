//%attributes = {}
#DECLARE($filename : Text)->$result : Text

$file:=File:C1566("/RESOURCES/Private/"+$filename)
ASSERT:C1129($file.exists)
$fileData:=$file.getText()

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