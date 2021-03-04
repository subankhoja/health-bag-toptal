/*************************************************************************************************************************************************
Class Name          : AppHandlerTest
Developer           : Suban Khoja 
Purpose             : Test Class For AppHandler
Last Modified Date  : 23/02/2020
*************************************************************************************************************************************************/

@isTest
private class AppHandlerTest {
    
    /*********************************************************************************************************************************************
    * Class Name        : AppHandlerTest
    * Method Name       : setupAppData
    * Description       : This method used to create Test Data for Test Methods
    * Arguments         : void
    * Return Type       : void
    * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    @testSetup
    private static void setupAppData(){
        
        /* Creating Specializations */
        Specialization__c cardiology = new Specialization__c(
            Name = 'Cardiology',
            Price__c = 300 
        );
        Specialization__c endocrinology = new Specialization__c(
            Name = 'Endocrinology',
            Price__c = 200 
        );
        Specialization__c generalPractice = new Specialization__c(
            Name = 'General Practice',
            Price__c = 100 
        );
        Specialization__c rheumatology = new Specialization__c(
            Name = 'Rheumatology',
            Price__c = 250 
        );
        
        insert new List<Specialization__c>{cardiology , endocrinology , generalPractice , rheumatology };
        
        /* Creating Physicians */
        Physician__c ammy_patel_physician = new Physician__c(
             Name = 'Ammy Patel',
             Email__c = 'ammy.patel@gmail.com',
             Specialization__c = cardiology.Id
        );
        
        Physician__c kit_noble_physician = new Physician__c(
             Name = 'Kit Noble',
             Email__c = 'kit.noble@gmail.com',
             Specialization__c = endocrinology.Id
        );

      
        
        insert new List<Physician__c>{ammy_patel_physician ,kit_noble_physician };
        
        /* Creating Patient */
        Patient__c patientRec = new Patient__c(
            First_Name__c = 'Scott',
            Last_Name__c = 'Burgo',
            Email__c = 'Scott@mail.com',
            Mobile_No__c = '7887887887'
        );

        insert new List<Patient__c>{patientRec};

        // Creating Physician Event Record.
        Physician_Event__c appointmentEvent = new Physician_Event__c(
            Subject__c = 'Subject',
            Start_DateTime__c = DateTime.newInstance(2021,02,11,8,00,00),
            End_DateTime__c = DateTime.newInstance(2021,02,11,9,00,00),
            Physician__c=ammy_patel_physician.Id,
            Patient__c=patientRec.Id
        );   
        
        insert new List<Physician_Event__c>{appointmentEvent};
    }
    
    /*********************************************************************************************************************************************
    * Class Name        : AppHandlerTest
    * Method Name       : test_getSpecializations
    * Description       : This method test AppHandler.getSpecializations
    * Arguments         : void
    * Return Type       : void
    * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    @isTest
    private static void test_getSpecializations(){
        
        Test.startTest();
        List<Specialization__c> specializationList = AppHandler.getSpecializations();
        Test.stopTest();
        System.assertEquals(specializationList.size(),4);
    }

    /*********************************************************************************************************************************************
    * Class Name        : AppHandlerTest
    * Method Name       : test_getPhysicians
    * Description       : This method test AppHandler.getPhysicians
    * Arguments         : void
    * Return Type       : void
    * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    @isTest    
    private static void test_getPhysicians(){
        
        Specialization__c cardiology = [SELECT id FROM Specialization__c WHERE Name = 'Cardiology'];
        Test.startTest();
        List<Physician__c> physicianList = AppHandler.getPhysicians(cardiology.Id);
        Test.stopTest();
        System.assertEquals(physicianList.size(),1);
       
    }
    
    /*********************************************************************************************************************************************
    * Class Name        : AppHandlerTest
    * Method Name       : test_createAppointmentEvent
    * Description       : This method test AppHandler.createAppointmentEvent
    * Arguments         : void
    * Return Type       : void
    * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    @isTest
    private static void test_createAppointmentEvent(){
        
        String appointmentDate = '2021-02-22';
        String appointmentTime = '8:00 - 9:00';
        Id userId = [SELECT id FROM Physician__c WHERE Name = 'Ammy Patel' LIMIT 1].Id;
        
        List<Patient__c> existingPatient = [SELECT id From Patient__c WHERE Email__c = 'Scott@mail.com'];
        Test.startTest();
        AppHandler.createAppointmentEvent(appointmentDate,appointmentTime,userId,existingPatient[0].Id);
        Test.stopTest();
      
        List<Physician_Event__c> appointmentEvent = [SELECT Id, Start_DateTime__c , End_DateTime__c  FROM Physician_Event__c WHERE Physician__c =:userId AND Patient__c =: existingPatient[0].Id];
        
        System.assertEquals(appointmentEvent.size(),2);
        System.assertEquals(appointmentEvent[0].Start_DateTime__c.day(),11);
        System.assertEquals(appointmentEvent[0].Start_DateTime__c.month(),2);
        System.assertEquals(appointmentEvent[0].Start_DateTime__c.year(),2021);
        System.assertEquals(appointmentEvent[0].Start_DateTime__c.hour(),8);
        System.assertEquals(appointmentEvent[0].End_DateTime__c.hour(),9);
    
    }
    
    /*********************************************************************************************************************************************
    * Class Name        : AppHandlerTest
    * Method Name       : test_getAppointmentEvents
    * Description       : This method test AppHandler.getAppointmentEvents
    * Arguments         : void
    * Return Type       : void
    * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    @isTest
    private static void test_getAppointmentEvents(){
        
        String appointmentDate = '2021-02-11';
        
        Id ammy_patel_user_Id = [SELECT id FROM Physician__c WHERE Name = 'Ammy Patel' LIMIT 1].Id;
        Id kit_noble_user_Id = [SELECT id FROM Physician__c WHERE Name = 'Kit Noble' LIMIT 1].Id;
        
        List<Patient__c> existingPatient = [SELECT id From Patient__c WHERE Email__c = 'Scott@mail.com'];
        Test.startTest();
        List<String> AppointmentSlotsForAmmyPatel = AppHandler.getAppointmentEvents(appointmentDate,ammy_patel_user_Id,existingPatient[0].Id,9);
        List<String> AppointmentSlotsForKitNoble = AppHandler.getAppointmentEvents(appointmentDate,kit_noble_user_Id,null,null);
        Test.stopTest();
        
        List<String> expectedTimeSlotsForAmmyPatel = new List<String>{'9:00 - 10:00','10:00 - 11:00','11:00 - 12:00','12:00 - 13:00','13:00 - 14:00','14:00 - 15:00','15:00 - 16:00'};
        System.assertEquals(AppointmentSlotsForAmmyPatel , expectedTimeSlotsForAmmyPatel );
        List<String> expectedTimeSlotsForKitNoble = new List<String>{'8:00 - 9:00','9:00 - 10:00','10:00 - 11:00','11:00 - 12:00','12:00 - 13:00','13:00 - 14:00','14:00 - 15:00','15:00 - 16:00'};
        System.assertEquals(AppointmentSlotsForKitNoble , expectedTimeSlotsForKitNoble );
    }

    /*********************************************************************************************************************************************
    * Class Name        : AppHandlerTest
    * Method Name       : test_createPatientAppointmentAndEvent
    * Description       : This method test AppHandler.createPatientAppointmentAndEvent
    * Arguments         : void
    * Return Type       : void
    * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    @isTest
    private static void test_createPatientAppointmentAndEvent(){
        
        String validAppointmentDate = '2021-02-22';
        String invalidAppointmentDate = '20-22-99';
        
        Map<String,Object> patientData = new Map<String,Object>{
            'firstName' => 'Suban',
            'lastName' => 'Khoja',
            'email' => 'Suban.khoja@mail.com',
            'phone' => '7887887788'
        };

        //Getting Existing Patient
        List<Patient__c> existingPatient = [SELECT id From Patient__c WHERE Email__c = 'Scott@mail.com'];

        Map<String,Object> existingPatientData = new Map<String,Object>{
            'id' => existingPatient[0].Id,
            'firstName' => 'Scott',
            'lastName' => 'Burgo',
            'email' => 'Scott@mail.com',
            'phone' => '7887887788'
        };

        Map<String,Object> validAppointmentDetails = new Map<String,Object>{
            'appointmentDate' => new Map<Object,Object>{
                'time' => '8:00 - 9:00',
                'date' => validAppointmentDate
            }
        };
        Map<String,Object> invalidAppointmentDetails = new Map<String,Object>{
            'appointmentDate' => new Map<Object,Object>{
                'time' => '8:00 - 9:00',
                'date' => invalidAppointmentDate 
            }
        };

        Specialization__c generalPractice = [SELECT id FROM Specialization__c WHERE Name = 'General Practice' LIMIT 1];

        Map<String,Object> specializationDetails = new Map<String,Object>{
            'Id' => generalPractice.Id
        };

        Physician__c Physician = [Select id FROM Physician__c Where Name = 'Ammy Patel'];
        //User Physician = [SELECT id FROM User WHERE FirstName = 'Ammy' AND LastName = 'Patel' LIMIT 1];

        Map<String,Object> physicianDetails = new Map<String,Object>{
            'Id' => Physician.Id
        };
    
        Test.startTest();
        String success_result_id = AppHandler.createPatientAppointmentAndEvent(patientData , physicianDetails , validAppointmentDetails, specializationDetails);
        String success_result_existing_id = AppHandler.createPatientAppointmentAndEvent(existingPatientData , physicianDetails , validAppointmentDetails, specializationDetails);
        String failure_result = AppHandler.createPatientAppointmentAndEvent(patientData , physicianDetails , invalidAppointmentDetails , specializationDetails);
        Test.stopTest();
        
        List<Appointment__c> newAppointment = [SELECT id FROM Appointment__c WHERE Physician__c =:Physician.Id AND Patient__c !=:existingPatient[0].Id];
        List<Appointment__c> newAppointmentForExistingPatient = [SELECT id FROM Appointment__c WHERE Physician__c =:Physician.Id AND Patient__c =: existingPatient[0].Id];
        
        System.assertEquals(success_result_id,newAppointment[0].Id);
        System.assertEquals(success_result_existing_id,newAppointmentForExistingPatient[0].Id);
        System.assertEquals(failure_result,'');

    }

    /*********************************************************************************************************************************************
    * Class Name        : AppHandlerTest
    * Method Name       : test_getPatientByEmail
    * Description       : This method test AppHandler.getPatientByEmail
    * Arguments         : void
    * Return Type       : void
    * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    @isTest
    private static void test_getPatientByEmail(){

        String patientEmail = 'Scott@mail.com';
        String worngEmail = 'abc@mail.com';
        Test.startTest();
        Map<String,Object> success_result = AppHandler.getPatientByEmail(patientEmail);
        Map<String,Object> fail_result = AppHandler.getPatientByEmail(worngEmail);
        Map<String,Object> blank_result = AppHandler.getPatientByEmail('');
        Test.stopTest();

        System.assertEquals(String.valueOf(success_result.get('firstName')),'Scott');
        System.assertEquals(String.valueOf(success_result.get('lastName')),'Burgo');

        System.assertEquals(String.valueOf(fail_result.get('firstName')),'');
        System.assertEquals(String.valueOf(fail_result.get('lastName')),'');
        
        System.assertEquals(String.valueOf(blank_result.get('firstName')),'');
        System.assertEquals(String.valueOf(blank_result.get('lastName')),'');
        

    }

}