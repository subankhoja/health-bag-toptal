/*************************************************************************************************************************************************
Class Name          : AppLogger
Developer           : Suban Khoja 
Purpose             : This Class implements Logging Functionality for Exception Handling.
Last Modified Date  : 23/02/2020
*************************************************************************************************************************************************/

public class AppLogger {

    /* Class Properties START */
    /* Class Properties END */

    /* Class Methods START */
    /*********************************************************************************************************************************************
    * Class Name        : AppLogger
    * Method Name       : createErrorLog
    * Description       : This method Create an record of Log Object with details about Exception
    * Arguments         : [
        String className , 
        String methodName , 
        String message , 
        Integer lineNo
    ]
    * Return Type       : void
    * Author            : Suban Khoja
    *********************************************************************************************************************************************/
    public static void createErrorLog(String className , String methodName , String message , Integer lineNo){
        Log__c log = new Log__c(
            Class_Name__c = className,
            Method_Name__c = methodName,
            Message__c = message,
            Line_Number__c = lineNo
        );
        insert new List<Log__c>{log};
    }


    /* Class Methods END */
}