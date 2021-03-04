/*************************************************************************************************************************************************
Class Name          : AppHandler
Developer           : Suban Khoja 
Purpose             : This Class implements Functionality Related To Appoitnemts for Health Bag
Last Modified Date  : 23/02/2020
*************************************************************************************************************************************************/

public with sharing class AppHandler{
    
    /* Class Properties START */
    private static final String DEFAULT_MINUTE_STR      = ':00'; // Used to define Defualt Minutes for Appointment Start Time and End Time
    private static final String DEFAULT_SECOND_STR      = ':00'; // Used to define Defualt Second for Appointment Start Time and End Time
    private static final String FIELD_SUFFIX_START_TIME = 'StartTime'; // Business Hour Field Suffix which is used in Combination of Day i.e MondayStartTime
    private static final String FIELD_SUFFIX_END_TIME   = 'EndTime'; // Business Hour Field Suffix which is used in Combination of Day i.e MondayEndTime
    private static final String BUSINESS_HOUR_QUERY_STRING   = 'SELECT Id , {0}, {1} FROM BusinessHours WHERE IsDefault=true'; // Query String to get Business Hour...
    private static final String WEEKDAY_FORMAT   = 'EEEE'; // String Format to Get Week Day from a Date/Time Type
    private static final String EVENT_SUBJECT = 'Appointment with Health Bag'; // Subject of Event...
    private static final Integer SECONDS_PER_MINUTE = 60; // Seconds Per Minute
    private static final Integer MINUTES_PER_HOUR = 60;  // Minutes Per  Hour
    private static final Integer MILLISECONDS_PER_SECOND = 1000; // Milliseconds per Seconds
    
    
    /* Class Properties END */
   
   
    /* Class Methods START */

    /*********************************************************************************************************************************************
    * Class Name        : AppHandler
    * Method Name       : getSpecializations
    * Description       : This method return List of Specializations
    * Arguments         : NA
    * Return Type       : List<Specialization__c>
    * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<Specialization__c> getSpecializations() {
        try{
            List<Specialization__c> specializations = [
            SELECT 
                Id,Name, Price__c 
            FROM 
                Specialization__c 
            LIMIT 
                10
            ]; 
            return specializations;
        }catch(Exception exp){
            AppLogger.createErrorLog('AppHandler','getSpecializations',exp.getMessage(),exp.getLineNumber());
            return new List<Specialization__c>();
        }
        
    }
    
    /*********************************************************************************************************************************************
    * Class Name        : AppHandler
    * Method Name       : getPhysicians
    * Description       : This method return List of Physicians
    * Arguments         : NA
    * Return Type       : List<getPhysicians>
    * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    @AuraEnabled(Cacheable=true)
    public static List<Physician__c> getPhysicians(Id specializationId) {
        try{
            //Get the Physician Records based on Specialization Id
            List<Physician__c> userSpecializations = [
                SELECT 
                    Id , Name , Email__c 
                FROM 
                    Physician__c 
                WHERE 
                    Specialization__c=:specializationId 
                LIMIT 
                    99
            ];

            return userSpecializations;
        }catch(Exception exp){
            AppLogger.createErrorLog('AppHandler','getPhysicians',exp.getMessage(),exp.getLineNumber());
            return new List<Physician__c>();
        }
        
               
    }
    
    /*********************************************************************************************************************************************
    * Class Name        : AppHandler
    * Method Name       : createAppointmentEvent
    * Description       : This method Create an event for the Physician based on Date , Time and Id of the Physician and patient
    * Arguments         : [
        [String] appointmentDate [yyyy-mm-dd]
        [String] appointmentTime [hh:00 - hh:00]
        [String] physicianId - Physician Id 
        [String] patientId - Patient Id 
    ]
    * Return Type       : void
    * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    @AuraEnabled
    public static void createAppointmentEvent(String appointmentDate , String appointmentTime , String physicianId , String patientId) {
        try{
            // Getting Year , Month , Day from appointmentDate String by Splitting using '-'.
            Map<String,Integer> dateElementsMap = getSeperatedDateElements(appointmentDate); // Spliting appointmentDate by '-' to get Seperate Day ,  Month and Year
            Integer year = dateElementsMap.get('year');   // Geting Year from dateElementsMap
            Integer month = dateElementsMap.get('month'); // Geting Month from dateElementsMap 
            Integer day = dateElementsMap.get('day');     // Geting Day from dateElementsMap
            
            // Getting startTimeHour , endTimeHour from appointmentTime String by Splitting using ':'.
            Map<String,Integer> timeElementsMap = getSeperatedTimeElements(appointmentTime);
            Integer startTimeHour =  timeElementsMap.get('startTimeHour');
            Integer endTimeHour   = timeElementsMap.get('endTimeHour');
            
            // Creating Physician Event Record.
            Physician_Event__c appointmentEvent = new Physician_Event__c(
                Subject__c = EVENT_SUBJECT,
                Start_DateTime__c = DateTime.newInstance(year,month,day,startTimeHour,00,00),
                End_DateTime__c = DateTime.newInstance(year,month,day,endTimeHour,00,00),
                Physician__c=physicianId,
                Patient__c=patientId
            );   
            
            //inserting Physician Event
            List<Physician_Event__c> appointmentEvents = new List<Physician_Event__c>{appointmentEvent};
            insert appointmentEvents;
        }catch(Exception exp){
            AppLogger.createErrorLog('AppHandler','createAppointmentEvent',exp.getMessage(),exp.getLineNumber());
        }
        
             
    }

    /*********************************************************************************************************************************************
    * Class Name        : AppHandler
    * Method Name       : getAppointmentEvents
    * Description       : This method return List of Available Time Slots on the Date for the given Physician Id and Patient Id and Min Time
    * Arguments         : [
        [String] appointmentDate [yyyy-mm-dd]
        [String] physicianId - Physician Id 
        [String] patientId -   Patient Id 
        [Integer] minTime - Minimum Time after which Time Interval Should be Present
    ]
    * Return Type       : List<String> [Time Interval i.e 8:00 - 9:00]
    * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    @AuraEnabled
    public static List<String> getAppointmentEvents(String appointmentDate , String physicianId , String patientId , Integer minTime) {
        
        try{
            Map<String,Integer> dateElementsMap = getSeperatedDateElements(appointmentDate); // Spliting appointmentDate by '-' to get Seperate Day ,  Month and Year
            Integer year = dateElementsMap.get('year'); // Geting Year from dateElementsMap
            Integer month = dateElementsMap.get('month'); // Geting Month from dateElementsMap
            Integer day = dateElementsMap.get('day'); // Geting Month from dateElementsMap

            DateTime start_dateTime_GMT = DateTime.newInstance(year,month,day); // Creating Start DateTime Instance from day,month,year
            DateTime end_dateTime_GMT = DateTime.newInstance(year,month,day+1); // Creating End DateTime Instance from day,month,year which will be start_dateTime+1
            
            TimeZone tz = UserInfo.getTimeZone();
            DateTime start_dateTime = start_dateTime_GMT.AddSeconds(tz.getOffset(start_dateTime_GMT)/1000); // Creating Start DateTime Instance from day,month,year
            DateTime end_dateTime = end_dateTime_GMT.AddSeconds(tz.getOffset(end_dateTime_GMT)/1000); // Creating End DateTime Instance from day,month,year which will be start_dateTime+1


            String startDay = start_dateTime.format(WEEKDAY_FORMAT); // Getting Week Day from Date/Time
            
            
            System.debug('APPOINTMENT DATE '+appointmentDate);
            System.debug('patientId  '+patientId);
            
            //Querying Events for User id between start_dateTime and end_dateTime.
            List<Physician_Event__c> events = new List<Physician_Event__c>();
            if(String.isNotBlank(patientId)){
                events = [
                    SELECT 
                            id , Start_DateTime__c ,End_DateTime__c 
                        FROM 
                            Physician_Event__c 
                        WHERE 
                            (
                                Physician__c=:physicianId OR 
                                Patient__c=:patientId
                            ) AND 
                            Start_DateTime__c >=:start_dateTime AND 
                            End_DateTime__c <:end_dateTime
                ];
            }else{
                events = [
                    SELECT 
                        id , Start_DateTime__c ,End_DateTime__c 
                    FROM 
                        Physician_Event__c 
                    WHERE 
                        Physician__c=:physicianId AND 
                        Start_DateTime__c >=:start_dateTime AND 
                        End_DateTime__c <:end_dateTime
                ];
            }
            
            System.debug('events  '+events.size());
            
            // If Mintime is not passed or appointment date is not today set minTime to 0
            if(minTime == null || start_dateTime.Date() != Date.Today()){
                minTime = 0;
            }
            
            List<String> occupiedTimes = new List<String>();    // List which contains Occupied Time interval for given Physician
            List<String> availableTimes = new List<String>();   // List which contains Available Time interval for given Physician
            List<String> timeIntervalList = new List<String>(); // List which contains All Time interval for The appointmentDate
            
            // Looping through Events and putting time Inteval in occupiedTimes
            if(!events.isEmpty()){
                for(Physician_Event__c e : events){
                    String timeStr = generateTimeString(e.Start_DateTime__c.hour(),e.End_DateTime__c.hour()); // generate Time Interval String...
                    occupiedTimes.add(timeStr);
                }
            
            }
            
            // Getting All Time Interval for a Start Day.
            timeIntervalList = generateTimeIntervals(startDay,minTime);
            System.debug('timeIntervalList @@ '+timeIntervalList);
            System.debug('occupiedTimes @@ '+occupiedTimes);
            // if There are no Occupied Slots for that Physician return All Slots for given Day.
            if(occupiedTimes.isEmpty()){
                return timeIntervalList;
            }else{
                System.debug('ELSE @@ ');
                //if Not removing occupied slots from all Solts and Adding it to Available Slots
                for(String timeIntervalString : timeIntervalList){
                    if(occupiedTimes.contains(timeIntervalString)) continue;
                    availableTimes.add(timeIntervalString);
                }
                System.debug('availableTimes @@ '+availableTimes);
                // return available Time Slots.
                return availableTimes;
                
            }
        }catch(Exception exp){
            AppLogger.createErrorLog('AppHandler','getAppointmentEvents',exp.getMessage(),exp.getLineNumber());
            return new List<String>();
        }
        
        
    }
    
    /*********************************************************************************************************************************************
    * Class Name        : AppHandler
    * Method Name       : generateTimeIntervals
    * Description       : This method return List of Time Interval based on Business Start Hour and End Hour based on Day Provided
    * Arguments         : [
        [String] day [i.e Monday , Tuesday etc.]
        [Integer] minTime - Minimum Time after which Time Interval Should be Present
    ]
    * Return Type       : List<String> [Time Interval i.e 8:00 - 9:00]
    * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    public static List<String> generateTimeIntervals(String day , Integer minTime){
        
        try{
            System.debug('minTime =>@@  '+minTime);
            List<String> timeIntervalList = new List<String>(); // List which will contain time Intervals to return
            
            String dayStartTimeFieldName = day+FIELD_SUFFIX_START_TIME; //Reference to DayStartTime Field
            String dayEndTimeFieldName = day+FIELD_SUFFIX_END_TIME; //Reference to DayEndTime Field
            
            Integer startHour; // Reference to Business Start Hour as Integer i.e 8
            Integer endHour; // Reference to Business End Hour as Integer i.e 12
            
            // Formating query with dayStartTimeFieldName and dayEndTimeFieldName
            String queryString  = String.format(BUSINESS_HOUR_QUERY_STRING , new List<String>{dayStartTimeFieldName ,dayEndTimeFieldName });  
            
            // Getting Business Hour based on queryString..
            List<BusinessHours> defaultBusinessHour = Database.query(queryString);
            
            // If defaultBusinessHour is not empty generate 1 hour Gap Time Intervals based on startHour and EndHour
            if(!defaultBusinessHour.isEmpty()){
                startHour = ((Time)defaultBusinessHour[0].get(dayStartTimeFieldName)).hour(); // Business Start Hour
                // If Business Start Hour is Great There Min Time assign Start Hour to Min Time
                if(startHour < minTime){
                    startHour = minTime;
                }
                endHour = ((Time)defaultBusinessHour[0].get(dayEndTimeFieldName)).hour(); // Business End Hour
                System.debug('B START MINUTE => '+((Time)defaultBusinessHour[0].get(dayStartTimeFieldName)).minute());
                System.debug('B END MINUTE => '+((Time)defaultBusinessHour[0].get(dayEndTimeFieldName)).minute());
                
                // Loop From StartHour to End Hour and Generate Time Interval
                // i.e if StartHour is 8 and EndHour is 9 time Interval will be 8:00 - 9:00
                for(Integer index=startHour;index<endHour;index++){
                    timeIntervalList.add(generateTimeString(index,index+1));
                }     
            }
            System.debug('timeIntervalList =>@@  '+timeIntervalList);
            return timeIntervalList;
        }catch(Exception exp){
            AppLogger.createErrorLog('AppHandler','generateTimeIntervals',exp.getMessage(),exp.getLineNumber());
            return new List<String>();
        }
        
    }

    /*********************************************************************************************************************************************
    * Class Name        : AppHandler
    * Method Name       : generateTimeString
    * Description       : This method return formatted Time Interval String Based on StartHour and End Hour
    * Arguments         : [
        [Integer] startHour
        [Integer] endHour 
    ]
    * Return Type       : String [Time Interval i.e 8:00 - 9:00]
    * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    public static String generateTimeString(Integer startHour , Integer endHour){
        try{
            if(startHour == null && endHour == null) return '';
            return startHour+DEFAULT_MINUTE_STR  +' - ' +endHour+DEFAULT_MINUTE_STR;
        }catch(Exception exp){
            AppLogger.createErrorLog('AppHandler','generateTimeString',exp.getMessage(),exp.getLineNumber());
            return '';
        }
        
    }

    /*********************************************************************************************************************************************
    * Class Name        : AppHandler
    * Method Name       : getSeperatedDateElements
    * Description       : This method return Map containing Year , Month , Date
    * Arguments         : [
        [String] appointmentDate [yyyy-mm--dd]
    ]
    * Return Type       : Map<String,Integer>
    * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    public static Map<String,Integer> getSeperatedDateElements(String appointmentDate){
        try{
            List<String> dateArr = appointmentDate.split('-'); // Spliting appointmentDate by '-' to get Seperate Day ,  Month and Year
            return new Map<String,Integer>{
                'year'  => Integer.valueOf(dateArr[0]),
                'month' => Integer.valueOf(dateArr[1]),
                'day'   => Integer.valueOf(dateArr[2])
            };
        }catch(Exception exp){
            AppLogger.createErrorLog('AppHandler','getSeperatedDateElements',exp.getMessage(),exp.getLineNumber());
            return new Map<String,Integer>();
        }
        
    }

    /*********************************************************************************************************************************************
    * Class Name        : AppHandler
    * Method Name       : getSeperatedTimeElements
    * Description       : This method return Map containing Start Hour , End Hour 
    * Arguments         : [
        [String] appointmentDate [yyyy-mm--dd]
    ]
    * Return Type       : Map<String,Integer>
    * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    public static Map<String,Integer> getSeperatedTimeElements(String appointmentTime){
        try{
            List<String> timeArr = appointmentTime.split(' - ');
        
            return new Map<String,Integer>{
                'startTimeHour'  => Integer.valueOf(timeArr[0].split(':')[0]),
                'endTimeHour'  => Integer.valueOf(timeArr[1].split(':')[0])
            };
        }catch(Exception exp){
            AppLogger.createErrorLog('AppHandler','getSeperatedTimeElements',exp.getMessage(),exp.getLineNumber());
            return new Map<String,Integer>();
        }
    }

    /*********************************************************************************************************************************************
    * Class Name        : AppHandler
    * Method Name       : createPatientAppointmentAndEvent
    * Description       : This method will create Patient , Appointment and Physician Event Records
    * Arguments         : [
        [Map<String,Object>] patientDetails
        [Map<String,Object>] physicianDetails
        [Map<String,Object>] appointmentDetails
        [Map<String,Object>] specializationDetails
    ]
    * Return Type       : String [Appointment Id]
    * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    @AuraEnabled
    public static String createPatientAppointmentAndEvent(Map<String,Object> patientDetails , Map<String,Object> physicianDetails , Map<String,Object> appointmentDetails, Map<String,Object> specializationDetails ){
        Savepoint init;
        try{
            // Initial Save Point
            init = Database.setSavepoint();
            // Creating new Patient Record
            Patient__c patientRec = new Patient__c(
                First_Name__c = String.valueOf(patientDetails.get('firstName')),
                Last_Name__c = String.valueOf(patientDetails.get('lastName')),
                Email__c = String.valueOf(patientDetails.get('email')),
                Mobile_No__c = String.valueOf(patientDetails.get('phone'))
            );
            

            // if Patient Id is not Blank set the Id and do upsert
            if(String.isNotBlank(String.valueOf(patientDetails.get('id')))){
                patientRec.Id = String.valueOf(patientDetails.get('id'));
                upsert patientRec;
            }
            // else insert new Patient.
            else{
                insert patientRec;
            }
            

            //Getting Appointment Date from Appointment Data
            String appointmentDate = String.valueOf(((Map<Object,Object>)appointmentDetails.get('appointmentDate')).get('date'));
            //Getting Appointment Time from Appointment Data
            String appointmentTime = String.valueOf(((Map<Object,Object>)appointmentDetails.get('appointmentDate')).get('time'));
            //Getting PhysicianId from Physician Data
            String PhysicianId = String.valueOf(physicianDetails.get('Id'));
            

            // Spliting appointmentDate by '-' to get Seperate Day ,  Month and Year
            Map<String,Integer> dateElementsMap = getSeperatedDateElements(appointmentDate);
            Integer year = dateElementsMap.get('year');   // Geting Year from dateElementsMap
            Integer month = dateElementsMap.get('month'); // Geting Month from dateElementsMap 
            Integer day = dateElementsMap.get('day');     // Geting Day from dateElementsMap

            // Creating new Appointment Record
            Appointment__c appointmentRec = new Appointment__c(
                Appointment_Date__c = Date.newInstance(year,month,day),
                Appointment_Time__c = appointmentTime,
                Physician__c        = PhysicianId,
                Patient__c          = patientRec.Id,
                Patient_Email__c    = String.valueOf(patientDetails.get('email')),
                Specialization__c   = String.valueOf(specializationDetails.get('Id'))
            );

            insert appointmentRec;

            //Creating Event
            createAppointmentEvent(appointmentDate , appointmentTime , PhysicianId,patientRec.Id); 
            return appointmentRec.Id;
            
        }catch(Exception exp){
            AppLogger.createErrorLog('AppHandler','createPatientAppointmentAndEvent',exp.getMessage(),exp.getLineNumber());
            Database.rollback(init);
            return '';
        }
    }

    /*********************************************************************************************************************************************
    * Class Name        : AppHandler
    * Method Name       : getPatientByEmail
    * Description       : This method Search if apatient is exist with given Email if so return Patient Details
    * Arguments         : [
        [String] Patient Email
    ]
    * Return Type       : Map of Containing Status and Patient Details if Found
    * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> getPatientByEmail(String patientEmail){

        //Initializing Result Object
        try{
            Map<String,Object> result = new Map<String,Object>{
                'success' => false,
                'id' => '',
                'firstName' => '',
                'lastName' => '',
                'email' => '',
                'phone' => ''
            };
    
            // If Email is Blank return desult result
            if(String.isBlank(patientEmail)){
                return result;
            }
    
            //Getting patient by email passed
            List<Patient__c> foundPatient = [
                SELECT 
                    id,First_Name__c,Last_Name__c,Email__c,Mobile_No__c
                FROM
                    Patient__c
                WHERE 
                    Email__c =:patientEmail
                LIMIT
                    1
            ];
    
            //If Patient not Found return desult result
            if(foundPatient.isEmpty()){
                return result;
            }
    
    
            // Put Patient Details and return
            result.put('success',true);
            result.put('id',foundPatient[0].Id);
            result.put('firstName',foundPatient[0].First_Name__c);
            result.put('lastName',foundPatient[0].Last_Name__c);
            result.put('email',foundPatient[0].Email__c);
            result.put('phone',foundPatient[0].Mobile_No__c);
    
            return result;
        }catch(Exception exp){
            AppLogger.createErrorLog('AppHandler','getPatientByEmail',exp.getMessage(),exp.getLineNumber());
            return new Map<String,Object>();
        }
        
    }

    /*********************************************************************************************************************************************
    * Class Name        : AppHandler
    * Method Name       : generateGoogleEventRequest
    * Description       : This method Generate Google New Event Request based on Summary startDateTime , endDate Time ,  Time Zone , patient Email , physician Email.
    * Arguments         : [
        [String] summary
        [String] startDateTime
        [String] endDateTime
        [String] timeZone
        [String] patientEmail
        [String] physicianEmail

    ]
    * Return Type       : Stringyfy version of Request JSON
    * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    @AuraEnabled
    public static String generateGoogleEventRequest(String summary,String startDateTime,String endDateTime,String timeZone,String patientEmail,String physicianEmail){
        
        try{
            //initializing Request Map
            Map<String,Object> request = new Map<String,Object>();

            //Populating Summary
            request.put('summary',summary);

            //Populating Event Start Time Details
            Map<String,Object> startEventDetails = new Map<String,Object>();
            startEventDetails.put('dateTime',startDateTime);
            startEventDetails.put('timeZone',timeZone);

            //Populating Event End Time Details
            Map<String,Object> endEventDetails = new Map<String,Object>();
            endEventDetails.put('dateTime',endDateTime);
            endEventDetails.put('timeZone',timeZone);

            // Populating patient Email
            Map<String,Object> attendeePatientEmailDetails = new Map<String,Object>{
                'email' => patientEmail
            };

            // Populating physician Email
            Map<String,Object> attendeePhysicianEmailDetails = new Map<String,Object>{
                'email' => physicianEmail
            };

            //Populating Attandees with Physician Email and Patient Email
            List<Map<String,Object>> attendeesList = new List<Map<String,Object>>{
                attendeePatientEmailDetails,attendeePhysicianEmailDetails
            };

            // Populating request with event StartTime , End Time and Attendees
            request.put('start',startEventDetails);
            request.put('end',endEventDetails);
            request.put('attendees',attendeesList);
            
            //returnig serialize version of Request..
            return JSON.serialize(request);
        }catch(Exception exp){
            AppLogger.createErrorLog('AppHandler','generateGoogleEventRequest',exp.getMessage(),exp.getLineNumber());
            return '';
        }
        

    }

    /*********************************************************************************************************************************************
        * Class Name        : AppHandler
        * Method Name       : configureGoogleEventCallout
        * Description       : This method Generate Request for Google Calender Api to Create Event and Make Callout
                            This method is called from Process Builder {AppointmentMailSender}
        * Arguments         : [
        [List<Appointment__c>] appointmentRec
        ]
        * Return Type       : void
        * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    @InvocableMethod(label='Google Event Creation' description='This will create google event for Physician and patient')
    public static void configureGoogleEventCallout(List<Appointment__c> appointmentRec){   
        try{
            //Seperating Day , Month , Year From Appointment Date
            Integer day = appointmentRec[0].Appointment_Date__c.day();
            Integer month = appointmentRec[0].Appointment_Date__c.month();
            Integer year = appointmentRec[0].Appointment_Date__c.year();

            System.debug('day '+day);
            System.debug('month '+month);
            System.debug('year '+year);

            
            //Getting Start Hour From Appointment Time Interval
            String startHour = appointmentRec[0].Appointment_Time__c.split(' - ')[0].split(':')[0];
            startHour = getStringVersionOfNumber(Integer.valueOf(startHour));

            //Getting End Hour From Appointment Time Interval
            String endHour = appointmentRec[0].Appointment_Time__c.split(' - ')[1].split(':')[0];
            endHour = getStringVersionOfNumber(Integer.valueOf(endHour));
            
            String StartTime = startHour+DEFAULT_MINUTE_STR+DEFAULT_SECOND_STR;
            String endTime = endHour+DEFAULT_MINUTE_STR+DEFAULT_SECOND_STR;
            System.debug('StartHour '+StartHour);
            System.debug('endHour '+endHour);
            
            System.debug('StartTime '+StartTime);
            System.debug('endTime '+endTime);

            // Getting Timezone of Current User.
            TimeZone userTimeZone = UserInfo.getTimeZone();
            System.debug('userTimeZone '+userTimeZone);

            // Getting String Veriosn . i.e Asia/Kolkata [Required for Google Api]
            String TimeZoneStr = String.valueOf(userTimeZone);

            // Getting TimeZone Offset
            Decimal timeZoneOffset = userTimeZone.getOffset(appointmentRec[0].Appointment_Date__c);
            System.debug('timeZoneOffset '+timeZoneOffset);

            // Calculating Offset in form of (+|-)hh:mm format
            Decimal timeZoneOffsetInFraction = (Decimal)(timeZoneOffset/(SECONDS_PER_MINUTE * MINUTES_PER_HOUR * MILLISECONDS_PER_SECOND));
            System.debug('timeZoneOffsetInFraction '+timeZoneOffsetInFraction);
            Integer timeZoneOffsetHour = (Integer)Math.abs(timeZoneOffsetInFraction);
            System.debug('timeZoneOffsetHour '+timeZoneOffsetHour);
            Integer timeZoneOffsetMinute = (Integer)((timeZoneOffsetInFraction - timeZoneOffsetHour)*MINUTES_PER_HOUR);
            System.debug('timeZoneOffsetMinute '+timeZoneOffsetMinute);
            String timeZoneOffsetString = (timeZoneOffset < 0)? '-':'+';
            timeZoneOffsetString += getStringVersionOfNumber(timeZoneOffsetHour) + ':' + timeZoneOffsetMinute;
            System.debug('timeZoneOffsetString '+timeZoneOffsetString);

            // Generate Final Timezone based version of Start Time
            String startDateTime = year+'-'+month+'-'+day+'T'+StartTime+timeZoneOffsetString;
            System.debug('startDateTime '+startDateTime);
            // Generate Final Timezone based version of End Time
            String endDateTime = year+'-'+month+'-'+day+'T'+endTime+timeZoneOffsetString;
            System.debug('endDateTime '+endDateTime);

            String physicianEmail = appointmentRec[0].Physician_Email__c;
            String patientEmail = appointmentRec[0].Patient_Email__c;
            System.debug('@@physicianEmail '+physicianEmail);
            System.debug('@@patientEmail '+patientEmail);
            //String bodyStr = AppHandler.generateGoogleEventRequest('Appointment with HealthBag','2021-03-08T09:00:00+05:30','2021-03-08T10:00:00+05:30','Asia/Kolkata','jatrudorta@nedoz.com','abby.patel.healthbag@gmail.com');     
            String bodyStr = AppHandler.generateGoogleEventRequest(EVENT_SUBJECT,startDateTime,endDateTime,TimeZoneStr,patientEmail,physicianEmail);     
            System.debug(bodyStr);
            sendGoogleEvent(bodyStr);
        }catch(Exception exp){
            AppLogger.createErrorLog('AppHandler','configureGoogleEventCallout',exp.getMessage(),exp.getLineNumber());
        }
        
    }

    /*********************************************************************************************************************************************
        * Class Name        : AppHandler
        * Method Name       : sendGoogleEvent [Future Method]
        * Description       : This method is a future method to make Callout to Google Server to Create Event.

        * Arguments         : [
            [String] requestBody
        ]
        * Return Type       : void
        * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    @future(callout = true)
    public static void sendGoogleEvent(string requestBody) {
        try{
            System.debug('@@requestBody '+requestBody);

            // Initializing Http Request and Response
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HTTPResponse response = new HTTPResponse();
            
            GoogleApiInfo__mdt newEventApi = GoogleApiInfo__mdt.getInstance('Calendar_Event_Create');

            // Configuring Request
            request.setMethod(newEventApi.Method__c);
            request.setEndpoint('callout:'+ newEventApi.SubEndpoint__c);
            request.setBody(requestBody);
            
            //Sending Request...
            response = http.send(request); 
            System.debug(response.getBody());
        }catch(Exception exp){
            AppLogger.createErrorLog('AppHandler','sendGoogleEvent',exp.getMessage(),exp.getLineNumber());
        }
        
    }

    /*********************************************************************************************************************************************
        * Class Name        : AppHandler
        * Method Name       : getStringVersionOfNumber 
        * Description       : This method return 2 character version of passed integer [Only Positive Number is Expected]
                              i.e  7 => '07' , 11 => '11'
        * Arguments         : [
            [Integer] number
        ]
        * Return Type       : String
        * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    public static String getStringVersionOfNumber(Integer num){
        try{    
            // if number is null or negative return blank String
            if(num == null || num < 0 ) return '';

            // generate String Version
            String stringVersion = (num < 10)?('0'+num):String.valueOf(num);
            return stringVersion;
        }catch(Exception exp){
            AppLogger.createErrorLog('AppHandler','getStringVersionOfNumber',exp.getMessage(),exp.getLineNumber());
            return '';
        }
        
    }
    /* Class Methods END */
}