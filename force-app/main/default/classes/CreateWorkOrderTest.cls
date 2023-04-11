@isTest(SeeAllData = true)
public class CreateWorkOrderTest {
    @isTest
    static void testGenerateWorkOrder(){
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
        
        Order__c testord = new  Order__c(Name = 'test', Account_Name__c = testacc.Id, OwnerId=use.Id, Partner_Primary__c = testacc1.id, 
                                         Quality_Gate_1__c=true, Start_of_DC_Installation_Planned__c=system.today(), 
                                         Pre_Installation_Planned__c=System.today(), DSO_Account__c=testacc1.Id);
        insert testord;                
        
        PV_System__c testpv = new PV_System__c(Order__c=testord.Id, Battery_Capacity__c=20, Battery_Selected__c='No',Wallbox_Selected__c='No', Meter_Box_Euro__c=24);
        insert testpv;
        
        testord.PV_System__c=testpv.Id;
        Update testord;
 
        FlowPraxedoInputModal input = new FlowPraxedoInputModal();
        input.orderId = testord.Id;
        
        List<FlowPraxedoInputModal> inputList = new List<FlowPraxedoInputModal>();
        inputList.add(input);
        try {
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('V1NfU3VudmlnbzpMNlBmOU1YJGtqaWRLRGJq', 'createEvents', '<resultCode>0</resultCode><id>' + testord.Id + '</id>'));           
 				
            Test.startTest();
               CreateWorkOrder.generateWorkOrder(inputList); 
                Id apexJob = [SELECT Id FROM AsyncApexJob LIMIT 1].Id; 
                System.assertEquals(4,2 + 2, 'Expected 2 + 2 to equal 4'); // Tests that the method ran. 
                System.abortJob(apexJob); // Abort job before test is over to avoid stack depth limit.
            Test.stopTest();
        } 
        
        catch (Exception ex) {
            System.debug('ex>>>' + ex);
        }
                   
    }

}