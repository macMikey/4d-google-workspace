<!--
getPrivateData ( short filename with extension : TEXT ) -> contentsOfFile : TEXT
 -->

 ﻿# function getPrivateData



## Description

* Provides an easy way for you to store things like your key, scopes, and url's near your project

* Assumes you are using a structure like the following, keeping your keys, sheet urls, etc. in a folder called **Private**.

  ```
  └── myProject
      ├── Private
      │   ├── app key
      │   ├── app scopes
      │   ├── sheet1 url
      │   └── sheet2 url
      └── repo
          ├── .git
          ├── .gitattributes
          ├── .gitignore
          ├── Documentation
          ├── Plugins
          ├── Project
          └──etc.
  ```

* Returns the contents of the file **omitting any double-slash embedded 4D comments



## Parameters
| Name | Datatype |Description |
|--|--|--|
|$1|Text|Short filename with extension|
|$0|Text|Contents of file|



## NOTE!

* Even if you use the structure like the above, you still should add the following line to your *.gitignore* file, just in case someone puts your **Private** folder inside of your repo:

` **/[Pp]rivate`

The double-asterisk means regardless of where the folder appears in the repo, it should be ignored, and the `[Pp]` means regardless of case.



## Example

```4d
$username:=getPrivateData("testuser.txt")
$key:=getPrivateData("google-key.json")
$scopes:=getPrivateData("scopes.txt")
$apiKey:=getPrivateData("calendar-apikey.txt")

$auth:=cs.Auth.new($username; $scopes; $key; "native")
$c:=cs.Calendar.new($auth; $apiKey)

```
