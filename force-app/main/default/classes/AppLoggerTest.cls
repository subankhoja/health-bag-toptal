/*************************************************************************************************************************************************
Class Name          : AppLoggerTest
Developer           : Suban Khoja 
Purpose             : Test Class For AppLogger
Last Modified Date  : 23/02/2020
*************************************************************************************************************************************************/
@isTest
private class AppLoggerTest{

    /*********************************************************************************************************************************************
    * Class Name        : AppHandlerTest
    * Method Name       : test_createErrorLog
    * Description       : This method test AppHandler.createErrorLog
    * Arguments         : void
    * Return Type       : void
    * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    @isTest
    private static void test_createErrorLog(){
        
        Test.startTest();
        AppLogger.createErrorLog('AppHandler','generateGoogleEventRequest','Exception Message',22);
        Test.stopTest();
        List<Log__c> logList = [Select Id from Log__c];
        System.assertEquals(logList.size(),1);
    }

}