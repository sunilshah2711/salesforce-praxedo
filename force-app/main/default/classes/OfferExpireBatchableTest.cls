@isTest
public with sharing class OfferExpireBatchableTest {
    public static testMethod void unitTestMethod() {
        Account acc = new Account();
        acc.FirstName = 'FirstName';
        acc.LastName = 'LastName-' + String.valueOf(datetime.now());
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        acc.PersonEmail = 'test@test.test';
        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'test-opp-' + String.valueOf(datetime.now());
        opp.AccountId = acc.Id;
        opp.StageName = 'Qualified';
        opp.CloseDate = Date.today().addDays(25);
        opp.Street__c = 'Industriestr. 161';
        opp.ZIP_Code__c = '50999';
        opp.City__c = 'Köln';
        opp.Consultation_Date__c = Date.Today().addDays(-19);
        insert opp;

        Test.startTest();
        try {
            List<List<Opportunity>> OpportunityList = new List<List<Opportunity>>();
            List<Opportunity> OppList = new List<Opportunity>();
            OppList.add(opp);
            OpportunityList.add(OppList);
            OfferExpireBatchable.callOpportunityBatch(OpportunityList);
        } catch (Exception ex) {
            System.debug('ex>>>' + ex);
        }
        Test.stopTest();
    }
}