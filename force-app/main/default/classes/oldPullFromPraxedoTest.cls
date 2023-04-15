@isTest(SeeAllData=True)
public class PullFromPraxedoTest {

    //Arrange


    // Dummy CRON expression: immediate 
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP =   '0 0 * * * ?';
    static testmethod void testScheduledJob() {
 		Account testacc = new Account(BillingStreet='123 Main St', BillingCity='San Francisco',
                                      FirstName='John', LastName='Smith', PersonMobilePhone='555-555-5555',
                                      PersonEmail='john.smith@example.com', BillingPostalCode='94105');
        insert testacc;
        
        Account testacc1 = new Account();
        testacc1.Name = 'Test';
        testacc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        insert testacc1;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        String useName = 'standarduser' + Math.random() * 1000 + '@testingorg.com';
        User use= new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US',ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName=useName);
        insert use;
        
        /*Order__c testord = new  Order__c(Name = 'test', Account_Name__c = testacc.Id, OwnerId=use.Id, Partner_Primary__c = testacc1.id, 
                                         Quality_Gate_1__c=true, Start_of_DC_Installation_Planned__c=system.today(), 
                                         Pre_Installation_Planned__c=System.today());
        insert testord;*/ 
        
        Order__c testord = [Select ID,Name,Account_Name__c,OwnerId,Partner_Primary__c,Quality_Gate_1__c,Start_of_DC_Installation_Planned__c,Pre_Installation_Planned__c From Order__c Where Name =:'Test Bartosch Belkius' OR Name =:'Bartosch Test'];
        
        PV_System__c testpv = new PV_System__c(Order__c=testord.Id, Battery_Capacity__c=20, Battery_Selected__c='No', Meter_Box_Euro__c=24);
        insert testpv;
        
        testord.PV_System__c=testpv.Id;
        update testord;
 
        /*FlowPraxedoInputModal input = new FlowPraxedoInputModal();
        input.orderId = testord.Id;
        
        List<FlowPraxedoInputModal> inputList = new List<FlowPraxedoInputModal>();
        inputList.add(input);*/
        
        try {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('V1NfU3VudmlnbzpMNlBmOU1YJGtqaWRLRGJq', 'searchEvents', '<resultCode>0</resultCode><id>' + testord.Id + '</id>'));
            Test.startTest();
            String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP,
            new PullfromPraxedo());   
            Test.stopTest();
        } catch (Exception ex) {
            System.debug('ex>>>' + ex);  
        }

        try {
            String body = '<entities><id>W-'+testord.Id+'</id><appointmentDate>2022-11-24T16:29:03.580+01:00</appointmentDate><schedulingDate>2022-11-24T16:29:03.580+01:00</schedulingDate></entities><entities><id>WII-'+testord.Id+'</id><status>VALIDATED</status></entities><entities><id>WBI-'+testord.Id+'</id><status>VALIDATED</status></entities>';
            SearchUpdateWorkOrder.updateWorkOrder(body);
        } catch (Exception ex) {
            System.debug('ex>>>' + ex);
        }
    }
}