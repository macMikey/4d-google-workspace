//%attributes = {}
#DECLARE($filename : Text)->$fileData : Text


$folder:=Folder:C1567(Folder:C1567("/PACKAGE/").platformPath; fk platform path:K87:2).parent.folder("Private")  //oliver's idea from https://discuss.4d.com/t/windows-where-to-store-your-settings-json-files/30759/7?u=mikey
$file:=File:C1566($folder.path+$1)
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