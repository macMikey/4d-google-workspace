Class extends _comms

Class constructor($oGoogleAuth : Object; $apiKey : Text; $calendar_url : Variant)
	
	Super:C1705("native")  //_comms type
	This:C1470._auth:=$oGoogleAuth
	
	This:C1470._apiKey:=$apiKey
	
	This:C1470.endpoint:="https://www.googleapis.com/calendar/v3/"  // need to do this before call this.setID
	
	
	If (Not:C34(Undefined:C82($calendar_url)))  // url for calendar specified
		This:C1470.setID($calendar_url)
	Else 
		This:C1470.metadata:=New object:C1471()
		This:C1470.metadata.id:=Null:C1517
	End if 
	
	
	// ===============================================================================================================
	
	//                                         C A L E N D A R   F U N C T I O N S
	
	// ===============================================================================================================
	
	
Function createCalendar($name : Text) : Boolean
	//POST https://www.googleapis.com/calendar/v3/calendars
	
/*
the body is
{
  "summary": ""
}
*/
	
	var $oResult : Object
	var $oSummaryBody : Object
	
	
	$url:=This:C1470.endpoint+"calendars"
	$oSummaryBody:=New object:C1471("summary"; $name)
	This:C1470.error:=Null:C1517
	$oResult:=This:C1470._http(HTTP POST method:K71:2; $url; JSON Stringify:C1217($oSummaryBody); This:C1470._auth.getHeader())
	This:C1470.status:=$oResult.status
	
	
	If (This:C1470.status#200)  //fail
		This:C1470.error:=$oResult.value.error
		return False:C215
	End if   //$status#200
	
	This:C1470.metadata:=OB Copy:C1225($oResult.value)
	This:C1470.events.clear()  // clear the events b/c new calendar is default
	return True:C214
	// _______________________________________________________________________________________________________________
	
	
Function eventDelete($eventID : Text) : Boolean
	//DELETE https://www.googleapis.com/calendar/v3/calendars/<calendarId>/events/<eventId>
/*
does not implement any optional parameters
*/
	var $oResult : Object
	
	$url:=This:C1470.endpoint+"calendars/"+This:C1470.metadata.id+"/events/"+$eventId
	This:C1470.error:=Null:C1517
	$oResult:=This:C1470._http(HTTP DELETE method:K71:5; $url; ""; This:C1470._auth.getHeader())
	This:C1470.status:=$oResult.status
	
	
	If (This:C1470.status#204)  //fail
		This:C1470.error:=$oResult.value.error
		return False:C215
	End if   //this.status#204
	
	//<remove from collection>
	$row:=-1
	For each ($event; This:C1470.events) Until ($event.id=$eventID)
		$row:=$row+1
	End for each 
	If ($row#This:C1470.events.length)  //found it
		This:C1470.events.remove($row)
	End if 
	
/*
as of r4 you can't use findIndex with a class function or a super class function.  this code is here for the day when we can.
$row:=This.events.findIndex("_findRowForValue";"id";$1)
If ($row>=0)
This.events.remove($row)
End if 
*/
	//</remove from collection>
	return True:C214
	// _______________________________________________________________________________________________________________
	
	
	
Function getCalendarList() : Variant
	//GET https://www.googleapis.com/calendar/v3/users/me/calendarList
/*
does not implement any of the optional parameters
*/
	
	$url:=This:C1470.endpoint+"users/me/calendarList"
	This:C1470.error:=Null:C1517
	$oResult:=This:C1470._http(HTTP GET method:K71:1; $url; ""; This:C1470._auth.getHeader())
	This:C1470.status:=$oResult.status
	
	
	If (This:C1470.status#200)  //fail
		This:C1470.error:=$oResult.value
		return Null:C1517
	End if   //this.status#200
	
	return $oResult.value
	// _______________________________________________________________________________________________________________
	
	
	
Function setID($id : Text) : Boolean
	// sets the id of the object to the calendar id specified in id and tries to load the calendar metadata
	// returns whether the id is valid or not based on the load result
	
	This:C1470.metadata:=New object:C1471()
	This:C1470.metadata.id:=$id
	This:C1470.events.clear()  // when we change calendars clear the events
	return This:C1470._calendarGet()
	// _______________________________________________________________________________________________________________
	
	
	
	// ===============================================================================================================
	
	//                                           E V E N T S   F U N C T I O N S
	
	// ===============================================================================================================
	
	
Function eventsGet($eventID : Text) : Object
	//GET https://www.googleapis.com/calendar/v3/calendars/<calendarId>/events/<eventId>
/*
Does not implement any optional parameters
*/
	
	return This:C1470._eventsGetList($eventID)
	// _______________________________________________________________________________________________________________
	
	
	
Function eventsInsert($eventObject : Variant) : Variant
	// POST https://www.googleapis.com/calendar/v3/calendars/calendarId/events
	
	$url:=This:C1470.endpoint+"calendars/"+This:C1470.metadata.id+"/events"
	This:C1470.error:=Null:C1517
	$oResult:=This:C1470._http(HTTP POST method:K71:2; $url; JSON Stringify:C1217($eventObject); This:C1470._auth.getHeader())
	This:C1470.result:=$oResult
	This:C1470.status:=$oResult.status
	
	
	If (This:C1470.status#200)  //fail
		This:C1470.error:=$oResult.value.error
		return Null:C1517
	End if   //$status#200
	
	This:C1470.events.push($oResult.value)
	return $oResult.value.id
	// _______________________________________________________________________________________________________________
	
	
	
Function eventsList() : Object
	//GET https://www.googleapis.com/calendar/v3/calendars/<calendarId>/events
/*
Does not implement any optional parameters
*/
	return This:C1470._eventsGetList()
	// _______________________________________________________________________________________________________________
	
	
	
	
	// ===============================================================================================================
	
	//                                        P R I V A T E   F U N C T I O N S
	
	// ===============================================================================================================
	
	
Function _eventsGetList($eventID : Variant)->$oResult : Object
	//GET https://www.googleapis.com/calendar/v3/calendars/<calendarId>/events{/<eventId>}
/*
Does not implement any optional parameters
*/
	var $done : Boolean
	var $url; $urlThisPass; $nextPageToken : Text
	
	$url:=This:C1470.endpoint+"calendars/"+This:C1470.metadata.id+"/events"
	
	If (Count parameters:C259>=1)  // events_get only wants the data for a single event
		$url:=$url+"/"+$eventID
	End if 
	
	This:C1470.error:=Null:C1517
	This:C1470.events:=New collection:C1472()
	$urlThisPass:=$url  // first pass we don't have a page to retrieve
	$done:=False:C215  // multiple passes to get all the events
	$pass:=0  //debugx
	
	While (Not:C34($done))
		$pass:=$pass+1  //debugx
		$oResult:=This:C1470._http(HTTP GET method:K71:1; $urlThisPass; ""; This:C1470._auth.getHeader())
		This:C1470.status:=$oResult.status
		
		If (This:C1470.status#200)  //fail
			$oResult:=Null:C1517
			This:C1470.error:=$oResult.value
			This:C1470.events.clear()  // in case any have been assigned, already
		End if   //$status#200
		
		This:C1470.events:=This:C1470.events.concat($oResult.value.items)
		
		$nextPageToken:=$oResult.value.nextPageToken
		If ($nextPageToken="")  //done
			$done:=True:C214
		Else   // more to come
			$urlThisPass:=$url+"?pageToken="+$nextPageToken
		End if   //$nextPageToken=""
	End while   // not ($done)
	// _______________________________________________________________________________________________________________ 
	
	
	
Function _calendarGet() : Boolean
	// GET https://www.googleapis.com/calendar/v3/calendars/<calendarId>
	var $oResult : Object
	
	
	$url:=This:C1470.endpoint+"calendars/"+This:C1470.metadata.id
	This:C1470.error:=Null:C1517
	$oResult:=This:C1470._http(HTTP GET method:K71:1; $url; ""; This:C1470._auth.getHeader())
	This:C1470.status:=$oResult.status
	
	
	If (This:C1470.status#200)  //fail
		This:C1470.error:=$oResult.value
		return False:C215
	End if   //$status#200
	This:C1470.metadata:=OB Copy:C1225($oResult.value)
	return True:C214
	// _______________________________________________________________________________________________________________ 
	
	
Function _http($http_method : Text; $url : Text; $body : Text; $header : Object)->$oResult : Object
	// returns an object with properties  status:TEXT ; value:TEXT
	//tries the _comms._http.  If it fails, it checks to see if that is because the token expired, and if so, tries again.
	If (Position:C15("?"; $url)>0)  // contains "?", can't use it again
		$connector:="&"
	Else   // doesn't contain "?"
		$connector:="?"
	End if 
	$url:=$url+$connector+"key="+This:C1470._apiKey
	$oResult:=Super:C1706.http($http_method; $url; $body; $header)
	If (OB Is defined:C1231($oResult; "value.error"))  // error occurred
		If (($oResult.value.error.code=401) & ($oResult.value.error.status="UNAUTHENTICATED"))  //token expired, try again with a forced refresh on the token
			$oResult:=Super:C1706.http($http_method; $url; $body; This:C1470._auth.getHeader(True:C214))  // $4 should be this._auth.getHeader()
		End if   //($oResult.value.error.code=401) & ($oResult.value.error.status="UNAUTHENTICATED")
	End if   //(ob is defined($oResult.value.error))
	// _______________________________________________________________________________________________________________ 