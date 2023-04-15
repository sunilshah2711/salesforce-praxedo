public with sharing class Helper {
    public static List<Order__c> resetSkipValidationRules(List<Order__c> orderList,boolean flag) {
        if(flag){ 
            for(Order__c o: orderList) o.SkipValidationRules__c=true;             
        }
        if(!flag){ 
            for(Order__c o: orderList) o.SkipValidationRules__c=false;             
        }        
        return orderList;
    }
    
}
//test
//test2