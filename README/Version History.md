# Version History



## v. 0.1.0

It's been working for almost two years, so it probably deserves 1.0.0, but not everything that could be implemented, either.

* General
    * Reorganize a bit so it can just be a component
    * move _URL_Escape from cGoogleAuth to cGoogleComms
    * updated setup google readme with instructions for creating the api key that calendar needs
    * move some test methods around since we're doing more than just sheets
    * _http now checks  uses "&" instead of "?" for appending the API key if the url already has a "?" in it
    * exponential backoff
    * .findIndex() does not accept class functions as parameters.  Rewrote code that was using _findRowForValue
    * Update test code
    * Use returned errors more correctly
    * Google Comms can ignore some chars in a sequence to escape
    * working on submoduling/component-ing
    * Moved to the newer native 4D JWT/Cryptokey implementation from the JWT plugin
    * de-tokenize
    
* Sheets
    * fix sheet names not being escaped
    * sheet names should be escaped as well as quoted in query ranges b/c they can contain characters that might break the url, e.g. "/"
    * Added more logging potential by adding the http request to the spreadsheet object in this.request

* Calendar
  * Got a calendar demo and partial feature set implemented. Hopefully, whomever was interested in this feature can figure out how to pick up the ball, now that the hard part's done.