# Installing the 4d-google-docs repo into your project
The 4d-google-docs repo is designed to be used as a submodule in a 4D project.

1. Add the repo as a submodule to your project.
  I would suggest placing it in *Project/Submodules/4d-google-docs*.  If you put it somewhere else, change your *.gitignore* file in the next step.
2. **Copy** the files in *Project/Submodules/4d-google-docs/Sources/Classes* to *Project/Sources/Classes* so that your 4D project can access them.  Leave the originals in *Project/Submodules/4d-google-docs/Sources/Classes* so **git** can keep track of them.
3. Update your *.gitignore* file to keep the (copied)submodule code from being committed to your repo (otherwise every time the *4d-google-docs* repo is updated, you will have to commit all the individual files to your repo, instead of just a reference to the update)
  Add the following to your .gitignore:
  ```
        Project/Sources/Classes/cGoogleSpreadsheet.4dm
        Project/Sources/Classes/cGoogleComms.4dm
        Project/Sources/Classes/cGoogleAuth.4dm
  ```
4. Remember that updating the submodule simply means that your */Project/Submodules/4d-google-docs*, so you will have to copy the new versions of the files to your *Project/Sources/Classes* folder.