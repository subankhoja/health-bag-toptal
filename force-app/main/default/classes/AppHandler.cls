public class AppHandler{
    
    @AuraEnabled(Cacheable=true)
    public static List<Specialization__c> getSpecializations() {
        return [SELECT Id,Name, Price__c FROM Specialization__c LIMIT 10];        
    }
}