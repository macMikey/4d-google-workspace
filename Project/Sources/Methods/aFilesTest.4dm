//%attributes = {}
var $f : cs:C1710.driveFile
var $fs : cs:C1710.driveFiles
var $oResult : Variant
initializeAuthObject
$fs:=cs:C1710.driveFiles.new(<>a; "$"; "folder")
$fid:=$fs.getID()
$fs:=cs:C1710.driveFiles.new(<>a; ""; ""; $fid)  // get the contents of the $ folder


$fs:=cs:C1710.driveFiles.new(<>a; "myshop-inspection-logs"; "folder")
$fsID:=$fs.getID()
If ($fsID=Null:C1517)  //fail
	$errorMessage:=$fs.parseError()
	return $errorMessage
End if 

$f:=cs:C1710.driveFile.new(<>a; $fsID)
$path:=$f.getPath()

$f2:=cs:C1710.driveFile.new(<>a; "/Quality/myshop-inspection-logs")
$f2ID:=$f2.getId()


ALERT:C41("Done.")