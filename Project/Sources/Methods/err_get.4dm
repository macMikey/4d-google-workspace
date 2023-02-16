//%attributes = {}
ARRAY LONGINT:C221($aCodes; 0)
ARRAY TEXT:C222($aInternalComponents; 0)
ARRAY TEXT:C222($aMessages; 0)

var errorMessage : Text
var vErrorBool : Boolean

vErrorBool:=True:C214  // notifies anyone watching that we had an error in case we want to do something besides just log the error

$error:=String:C10(Error)
$errorMethod:=Error method
$errorLine:=String:C10(Error line)
$errorFormula:=Error formula

errorMessage:="Error: "+$error+"\r"+\
"Method: "+$errorMethod+"\r"+\
"Line: "+$errorLine+"\r"+\
"Code: "+$errorFormula+"\r"

GET LAST ERROR STACK:C1015($aCodes; $aInternalComponents; $aMessages)

For ($i; 1; Size of array:C274($aCodes))
/* WAS, but I don't know where I got this code from, and at least as of now, vErrorContext is not defined
					$message:=$message+"\r"+\
										"Error: "+vErrorContext+"\r"+\
										"Code: "+String($aCodes{$i})+"\r"+\
										"4D Internal Components: "+$aInternalComponents{$i}+"\r"+\
										$aMessages{$i}+"\r"+"\r"
*/
	errorMessage:=errorMessage+"\r"+\
		"Code: "+String:C10($aCodes{$i})+"\r"+\
		"4D Internal Components: "+$aInternalComponents{$i}+"\r"+\
		$aMessages{$i}+"\r\r"
End for 