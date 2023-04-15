public with sharing class OrderModel {

    Static String errorTemplate = 'Inside OrderModel.cls>>>Line No.>>>';

    public static List<Order__c> findByProcessId(List <String> processIdList) {        
        return [SELECT Id, Name,ProcessID__c,PV_System__c FROM Order__c WHERE ProcessID__c IN: processIdList];        
    }

    public static void updateRecords(List<Order__c> orderList) 
    {
        try{
            Helper.resetSkipValidationRules(orderList,true);
            update orderList;
            Helper.resetSkipValidationRules(orderList,false);            
            System.debug(errorTemplate+'12>>>Update Successful');            
        }
        catch (Exception e) {System.debug(errorTemplate+e.getMessage());}
    }    
}