/*
Construct a jwt object.

MobileAppServer .new( settings ) -> jwt

settings.type: "RSA" or "ECDSA" to generate new keys. "PEM" to load an existing key from settings.pem
settings.size: size of RSA key to generate (2048 by default)
settings.curve: curve of ECDSA to generate ("prime256v1" for ES256 (default), "secp384r1" for ES384, "secp521r1" for ES512)
settings.pem: PEM definition of an encryption key to load
settings.secret: default password to use for HS@ algorithm
*/
Class constructor
	C_OBJECT($1)
	
	If (Count parameters()>0)
		
		This.secret:=String($1.secret)  // for HMAC
		This.key:=4D.CryptoKey.new($1)  // load a pem or generate a new ECDSA/RSA key
		
	Else 
		
		This.secret:=""
		This.key:=Null
		
	End if 
	
	
	
	// _______________________________________________________________________________________________________________
	
/*
Builds a JSON Web token from its payload.
	
jwt.sign( payloadObject ; options) -> tokenString
	
options.algorithm: a JWT algorithm ES256, ES384, RS256, HS256, etc...
options.secret : password for HS@ algorithms
*/
Function sign
	C_OBJECT($1)  // header
	C_OBJECT($2)  // payload
	C_OBJECT($3)  // options
	C_TEXT($0)  // token
	
	C_OBJECT($options; $signOptions)
	$options:=$3
	
	C_TEXT($header; $payload; $signature; $hash)
	BASE64 ENCODE(JSON Stringify($1); $header; *)
	BASE64 ENCODE(JSON Stringify($2); $payload; *)
	$signature:=""
	$hash:=This._hashFromAlgorithm($options.algorithm)
	
	Case of 
			
			//________________________________________
		: ($options.algorithm="ES@")\
			 | ($options.algorithm="RS@")\
			 | ($options.algorithm="PS@")
			
			// need a private key
			If (Asserted(This.key#Null))
				
				$signOptions:=New object(\
					"hash"; $hash; \
					"pss"; $options.algorithm="PS@"; \
					"encoding"; "Base64URL")
				$signature:=This.key.sign($header+"."+$payload; $signOptions)
				
			End if 
			
			//________________________________________
		: ($options.algorithm="HS@")
			
			C_TEXT($secret)
			$secret:=Choose($options.secret=Null; String(This.secret); String($options.secret))
			$signature:=This.HMAC($secret; $header+"."+$payload; $hash)
			
			//________________________________________
		Else 
			
			ASSERT(False; "unknown algorithm")
			
			//________________________________________
	End case 
	
	$0:=$header+"."+$payload+"."+$signature
	
	
	
	// _______________________________________________________________________________________________________________
/*
Verify and decode a JSON Web token.
	
jwt.verify( tokenString ; options) -> status
	
options.secret : password for HS@ algorithms
	
status.success : true if token is valid
status.header: token header object
status.payload : token payload object
*/
Function verify
	C_TEXT($1)  // token
	C_OBJECT($2)  // options
	C_OBJECT($0)
	C_TEXT($token; $header; $payload; $signature; $hash; $alg; $verifiedSignature)
	C_TEXT($headerDecoded; $payloadDecoded)
	C_LONGINT($pos1; $pos2)
	C_OBJECT($headerObject; $payloadObject; $options; $signOptions)
	C_BOOLEAN($verified)
	
	$token:=$1
	$options:=$2
	$pos1:=Position("."; $token; *)
	
	If ($pos1>0)
		
		$header:=Substring($token; 1; $pos1-1)
		$pos2:=Position("."; $token; $pos1+1; *)
		
		If ($pos2>0)
			
			$payload:=Substring($token; $pos1+1; $pos2-$pos1-1)
			$signature:=Substring($token; $pos2+1; Length($token))
			
		End if 
	End if 
	
	BASE64 DECODE($header; $headerDecoded; *)
	BASE64 DECODE($payload; $payloadDecoded; *)
	
	$headerObject:=JSON Parse($headerDecoded)
	$payloadObject:=JSON Parse($payloadDecoded)
	
	If (Value type($headerObject)=Is object)\
		 & (Value type($payloadObject)=Is object)
		
		$alg:=String($headerObject.alg)
		$hash:=This._hashFromAlgorithm($alg)
		
		Case of 
				
				//________________________________________
			: ($alg="HS@")  // HMAC
				
				C_TEXT($secret)
				$secret:=Choose($options.secret=Null; String(This.secret); String($options.secret))
				$verifiedSignature:=This.HMAC($secret; $header+"."+$payload; $hash)
				$verified:=(Length($signature)=Length($verifiedSignature)) & (Position($signature; $verifiedSignature; *)=1)
				
				//________________________________________
			: ($alg="ES@")\
				 | ($alg="RS@")\
				 | ($alg="PS@")
				
				If (Asserted(This.key#Null))
					
					$signOptions:=New object(\
						"hash"; $hash; \
						"pss"; $alg="PS@"; \
						"encoding"; "Base64URL")
					$verified:=This.key.verify($header+"."+$payload; $signature; $signOptions).success
					
				End if 
				
				//________________________________________
		End case 
	End if 
	
	$0:=New object(\
		"success"; $verified; \
		"header"; $headerObject; \
		"payload"; $payloadObject)
	// _______________________________________________________________________________________________________________
	
	
	
Function HMAC
	C_VARIANT($1; $2)  // key and message
	C_TEXT($3)  // 'SHA1' 'SHA256' or 'SHA512'
	C_TEXT($0)  // hexa result
	
	// accept blob or text for key and message
	C_BLOB($key; $message)
	
	Case of 
			
			//________________________________________
		: (Value type($1)=Is text)
			
			TEXT TO BLOB($1; $key; UTF8 text without length)
			
			//________________________________________
		: (Value type($1)=Is BLOB)
			
			$key:=$1
			
			//________________________________________
	End case 
	
	Case of 
			
			//________________________________________
		: (Value type($2)=Is text)
			
			TEXT TO BLOB($2; $message; UTF8 text without length)
			
			//________________________________________
		: (Value type($2)=Is BLOB)
			
			$message:=$2
			
			//________________________________________
	End case 
	
	C_BLOB($outerKey; $innerKey; $b)
	C_LONGINT($blockSize; $i; $byte; $algo)
	C_TEXT($algoName)
	$algoName:=$3
	
	Case of 
			
			//________________________________________
		: ($algoName="SHA1")
			
			$algo:=SHA1 digest
			$blockSize:=64
			
			//________________________________________
		: ($algoName="SHA256")
			
			$algo:=SHA256 digest
			$blockSize:=64
			
			//________________________________________
		: ($algoName="SHA512")
			
			$algo:=SHA512 digest
			$blockSize:=128
			
			//________________________________________
		Else 
			
			ASSERT(False; "bad hash algo")
			
			//________________________________________
	End case 
	
	If (BLOB size($key)>$blockSize)
		
		BASE64 DECODE(Generate digest($key; $algo; *); $key; *)
		
	End if 
	
	If (BLOB size($key)<$blockSize)
		
		SET BLOB SIZE($key; $blockSize; 0)
		
	End if 
	
	ASSERT(BLOB size($key)=$blockSize)
	
	SET BLOB SIZE($outerKey; $blockSize)
	SET BLOB SIZE($innerKey; $blockSize)
	
	//%r-
	For ($i; 0; $blockSize-1; 1)
		
		$byte:=$key{$i}
		$outerKey{$i}:=$byte ^| 0x005C
		$innerKey{$i}:=$byte ^| 0x0036
		
	End for 
	
	//%r+
	
	// append $message to $innerKey
	COPY BLOB($message; $innerKey; 0; $blockSize; BLOB size($message))
	BASE64 DECODE(Generate digest($innerKey; $algo; *); $b; *)
	
	// append hash(innerKey + message) to outerKey
	COPY BLOB($b; $outerKey; 0; $blockSize; BLOB size($b))
	$0:=Generate digest($outerKey; $algo; *)
	// _______________________________________________________________________________________________________________
	
	
	
Function _hashFromAlgorithm
	C_TEXT($0; $1)
	
	Case of 
			
			//________________________________________
		: ($1="@256")
			
			$0:="SHA256"
			
			//________________________________________
		: ($1="@384")
			
			$0:="SHA384"
			
			//________________________________________
		: ($1="@512")
			
			$0:="SHA512"
			
			//________________________________________
	End case 