@isTest
public class PraxedoAPICalloutTest {
    @isTest   
    static void testmethod1(){
        Account testacc = new Account(BillingStreet='123 Main St', BillingCity='San Francisco',
                                      FirstName='John', LastName='Smith', PersonMobilePhone='555-555-5555',
                                      PersonEmail='john.smith@example.com', BillingPostalCode='94105');
        insert testacc;
        Order__c testord = new  Order__c(Name = 'test', Account_Name__c = testacc.Id);
        insert testord;
        System.debug('test'+testord.Id);
        PV_System__c testpv = new PV_System__c(Order__c=testord.Id);
        insert testpv;
        FlowPraxedoInputModal input = new FlowPraxedoInputModal();
        input.pvSystemId = testpv.Id;
        List<FlowPraxedoInputModal> inputList = new List<FlowPraxedoInputModal>();
        inputList.add(input);
       try {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('V1NfU3VudmlnbzpMNlBmOU1YJGtqaWRLRGJq', 'createEquipments', '<resultCode>0</resultCode><id>' + testpv.Id + '</id>'));

            CreateEquipment.generateEquipment(inputList);   
        } catch (Exception ex) {
            System.debug('ex>>>' + ex);
        }
                    
    }
    @isTest 
    static void testmethod2(){
        Account testacc = new Account(BillingStreet='123 Main St', BillingCity='San Francisco',
                                      FirstName='John', LastName='Smith', PersonMobilePhone='555-555-5555',
                                      PersonEmail='john.smith@example.com', BillingPostalCode='94105');
        insert testacc;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        String useName = 'standarduser' + Math.random() * 1000 + '@testingorg.com';
        User use= new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US',ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName=useName);
        insert use;
        
        Order__c testord = new  Order__c(Name = 'test', Account_Name__c = testacc.Id, OwnerId=use.Id);
        insert testord;
        
        PV_System__c testpv = new PV_System__c(Order__c=testord.Id, Battery_Capacity__c=20, Battery_Selected__c='No', Meter_Box_Euro__c=24);
        insert testpv;
        
        testord.PV_System__c=testpv.Id;
        Update testord;
        
        
        FlowPraxedoInputModal input = new FlowPraxedoInputModal();
        input.orderId = testord.Id;
        List<FlowPraxedoInputModal> inputList = new List<FlowPraxedoInputModal>();
        inputList.add(input);
        try {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('V1NfU3VudmlnbzpMNlBmOU1YJGtqaWRLRGJq', 'createServiceOrders', '<resultCode>0</resultCode><id>' + testord.Id + '</id>'));
            CreateServiceOrder.generateServiceOrder(inputList);   
        } catch (Exception ex) {
            System.debug('ex>>>' + ex);
        }
                   
    }
    @isTest
     static void testmethod3(){
                Account testAccount = new Account(BillingStreet='123 Main St', BillingCity='San Francisco',
                                      FirstName='John', LastName='Smith', PersonMobilePhone='555-555-5555',
                                      PersonEmail='john.smith@example.com', BillingPostalCode='94105');
        insert testAccount;
        FlowPraxedoInputModal input = new FlowPraxedoInputModal();
        input.accountId = testAccount.Id;
        List<FlowPraxedoInputModal> inputList = new List<FlowPraxedoInputModal>();
        inputList.add(input);

        try {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('V1NfU3VudmlnbzpMNlBmOU1YJGtqaWRLRGJq', 'createLocations', '<resultCode>0</resultCode><id>' + testAccount.Id + '</id>'));

            CreateLocation.generateLocation(inputList);   
        } catch (Exception ex) {
            System.debug('ex>>>' + ex);
        }
    }
    @isTest
    static void testmethod4() {
        Account testAccount = new Account(BillingStreet='123 Main St', BillingCity='San Francisco',
                                      FirstName='John', LastName='Smith', PersonMobilePhone='555-555-5555',
                                      PersonEmail='john.smith@example.com', BillingPostalCode='94105');
        insert testAccount;
        
        FlowPraxedoInputModal input = new FlowPraxedoInputModal();
        input.accountId = testAccount.Id;
        
        List<FlowPraxedoInputModal> inputList = new List<FlowPraxedoInputModal>();
        inputList.add(input);

        try {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('V1NfU3VudmlnbzpMNlBmOU1YJGtqaWRLRGJq', 'createCustomers', '<resultCode>0</resultCode><id>' + testAccount.Id + '</id>'));
            CreateCustomer.generateCustomer(inputList);   
        } catch (Exception ex) {
            System.debug('ex>>>' + ex);
        }
    }
    @isTest
    static void testmethod5(){
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
                                         Pre_Installation_Planned__c=System.today());
        insert testord;                
        
        PV_System__c testpv = new PV_System__c(Order__c=testord.Id, Battery_Capacity__c=20, Battery_Selected__c='No', Meter_Box_Euro__c=24);
        insert testpv;
        
        testord.PV_System__c=testpv.Id;
        Update testord;
 
        FlowPraxedoInputModal input = new FlowPraxedoInputModal();
        input.orderId = testord.Id;
        
        List<FlowPraxedoInputModal> inputList = new List<FlowPraxedoInputModal>();
        inputList.add(input);
        try {
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('V1NfU3VudmlnbzpMNlBmOU1YJGtqaWRLRGJq', 'createEvents', '<resultCode>0</resultCode><id>' + testord.Id + '</id>'));           
 				            
               CreateWorkOrder.generateWorkOrder(inputList); 
                
        } 
        
        catch (Exception ex) {
            System.debug('ex>>>' + ex);
        }
                   
    }
}