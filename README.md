# 4d-google-workspace

A 4D component for accessing and working on your google workspace services.

This component is designed for 4D v19R5 or later.

This component is designed for use with the [Service Account method of accessing Google Docs](https://developers.google.com/identity/protocols/oauth2#serviceaccount). See below on how to do that.  This technique allows your app to operate from a server, to not require periodic re-authorization, and have access to all google services for all accounds for your domain.
If you are trying to set up an app that will be for individual users and not an entire domain, you would use [one of several other configurations](https://developers.google.com/identity/protocols/oauth2#scenarios).



## Steps
1. [Setup your app in Google](https://github.com/macMikey/4d-google-docs/blob/master/README/Setup%20Google.md).

2. I prefer submoduing this repo so updates to the code base trigger notifications in the repos that use it. I usually put them into a folder like **Submodules** in the parent project, or **Resources/Submodules**, etc. I do that because 4D does not like to have submodules directly in the **Components** folder, but it will be ok with having aliases/shortcuts in that folder.

3. Copy/Alias/Shortcut *google-workspace.4dbase* (which is technically just a folder with the suffix **.4dbase**.) to the parent project's **Components** folder.

   * The **Components** folder and the **Project** folder should be at the same level.

   * I have included both the **.4dbase** file and the **Source** folder in the repo for completeness/ease-of-use. If you have not used a component before, you can also turn the **Source** folder into a component, and use that, instead:

     1. Duplicate the **Source** folder

     2. Rename the copied **Source** folder to something like **google.4dbase**. You now have a component. Copy/alias/shortcut that, if you like.

   * If this has worked, when you go into your parent project, in the 4D Explorer, you should see **google-workspace** and its methods and classes in the **Component Methods** section.



## Notes

* The classes are available via the **cs.google** namespace

* Check out the `aTest` method for a very basic sample.

* Documentation for the classes is available in the 4D Explorer and in the **Source** folder.

* Use caution with turning any of the objects (**Auth**, for instance) into shared objects, as they must be modified. **Auth** needs to have the token object updated periodically, for example.





## Reference
- [Using OAuth 2.0 to Access Google APIs](https://developers.google.com/identity/protocols/oauth2)
- [Using OAuth 2.0 for Server to Server Applications](https://developers.google.com/identity/protocols/oauth2/service-account#httprest)
- [Control G Suite API access with domain-wide delegation](https://support.google.com/a/answer/162106)
- [API Quotas](https://developers.google.com/sheets/api/limits)

