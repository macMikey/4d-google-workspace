//%attributes = {}
C_TEXT:C284($1)
$file:=File:C1566("/RESOURCES/Private/"+$1)
ASSERT:C1129($file.exists)
$0:=$file.getText()