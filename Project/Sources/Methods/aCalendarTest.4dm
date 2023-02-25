//%attributes = {}
initializeAuthObject

$apiKey:=getPrivateData("calendar-apikey.txt")

var $c : cs:C1710.calendar


$c:=cs:C1710.calendar.new(<>a; $apiKey)


// get the list of calendars
TRACE:C157
$calendarList:=$c.getCalendarList()
$id:=$calendarList.items[0].id

// assign the calendar we are going to work with to the first calendar in the list
TRACE:C157
$success:=$c.setID($id)  // assign the calendar to the id of the first calendar


// grab first n events for the calendar
TRACE:C157
$success:=$c.eventsGet()


// create a new calendar called 'test'
TRACE:C157
$success:=$c.createCalendar("test")  // create a new calendar called "test"
// Now $c.metadata is assigned to the new calendar


// create a new event
TRACE:C157
$tz:="America/New_York"
$d:=Current date:C33
$ds:=String:C10(Year of:C25($d); "0000")+"-"+String:C10(Month of:C24($d); "00")+"-"+String:C10(Day of:C23($d); "00")  //YYYY-MM-DD

var $event : Object
$event:=New object:C1471()
$event.start:=New object:C1471()
$event.start.dateTime:=$ds+"T09:00:00"
$event.start.timeZone:=$tz
$event.end:=New object:C1471()
$event.end.dateTime:=$ds+"T10:00:00"
$event.end.timeZone:=$tz
$event.summary:="Test Event"
$event.description:=$event.summary+". Should run from "+$event.start.dateTime+" "+$event.start.timeZone+" to "+$event.end.dateTime+" "+$event.end.timeZone+"."

$eventID:=$c.eventsInsert($event)
If ($eventID=Null:C1517)
	ALERT:C41("Insert failed "+String:C10($c.error.code)+" - "+$c.error.message+". "+$c.error.status)
	TRACE:C157
End if 

