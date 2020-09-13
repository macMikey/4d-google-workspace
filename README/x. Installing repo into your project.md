# Installing the 4d-google-docs repo into your project

The 4d-google-docs repo is designed to be used as a submodule in a 4D project.

  

1. Add the repo as a submodule to your project.

	I would suggest placing it in *Project/Submodules/4d-google-docs*. If you put it somewhere else, change your *.gitignore* file in the next step.

2. **Copy** the files in *Submodules/4d-google-docs/Sources/Classes* to *Sources/Classes* so that your 4D project can access them.  Leave the originals in *Submodules/4d-google-docs/Sources/Classes* so **git** can keep track of them.

3. **Copy** the files in *Submodules/4d-google-docs/Plugins* to your *Plugins* folder.  Leave the originals in *Submodules/Plugins* so **git** can keep track of them.

4. *Optional:* **Copy** the files in *Project/Submodules/4d-google-docs/Documentation/Classes/* to your Project's *Project/Documentation/Classes/* folder.  Leave the originals in *Submodules/4d-google-docs/Documentation/Classes* so **git** can keep track of them.

5. Remember that updating the submodule simply means that your */Project/Submodules/4d-google-docs*, so you will have to copy the new versions of the files to their respective locations each time.
