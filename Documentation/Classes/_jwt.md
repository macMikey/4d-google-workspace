# (Private) Class _jwt

This class is private, and is not directly accessible outside of the component. It is documented in the event that a developer wishes to work on the component, and issue a pull request back to the project repo.

This class was written by 4D, Inc. It is released via the [4D-License](../../4D-LICENSE.md).

I have included it, instead of a binary plugin as we can, with straight 4D, generate the JWT we need.



## Constructor Parameters

|Name|Datatype|Required|Properties|
|--|--|--|--|
| Settings | Object | Yes | **type** : "RSA" or "ECDSA" to generate new keys. "PEM" to load an existing key from *settings.pem*<br>**size** : size of RSA key to generate (2048 by default)<br>**curve** : curve of ECDSA to generate ("prime256v1" for ES256 (default), "secp384r1" for ES384, "secp521r1" for ES512)<br>**pem** : PEM definition of an encryption key to load<br>**secret** : default password to use for HS@ algorithm |



4D did not document this class. While the individual functions are syntax-documented, internally, I am not going to write full documentation for the class.