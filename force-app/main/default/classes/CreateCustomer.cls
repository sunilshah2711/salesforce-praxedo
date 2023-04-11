public with sharing class CreateCustomer {
    public static String endPoint = 'https://ws-eu9.praxedo.com/eTech/services/cxf/v6/CustomerManager';
    public static String method = 'POST';
    public static String authorizationToken = 'V1NfU3VudmlnbzpMNlBmOU1YJGtqaWRLRGJq';
    public static String soapAction = 'createCustomers';

    
    
    /*
     * List<FlowPraxedoInputModal> praxedoInputList = new List<FlowPraxedoInputModal>();
     * FlowPraxedoInputModal praxedoInputSingle = new FlowPraxedoInputModal();
praxedoInputSingle.accountId = '0011x00001eheesAAA';
praxedoInputSingle.pvSystemId='a011x000008GqlIAAS';
praxedoInputSingle.orderId = 'a001x00000B8nj8AAB';
praxedoInputList.add(praxedoInputSingle);
CreateCustomer.generateCustomer(praxedoInputList);
     * 
     * 
     */
    @InvocableMethod
    public static void generateCustomer(List<FlowPraxedoInputModal> praxedoInput) {
        List<Id> recordIdList = new List<Id>();
        List<Id> recordIdListOrder = new List<Id>();

        for (FlowPraxedoInputModal input: praxedoInput) {
            recordIdList.add(input.accountId);
            recordIdListOrder.add(input.orderId);
        }
        Set<String> accountFieldSet = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().keySet();
        List<String> accountFieldList = new List<String>();
        accountFieldList.addAll(accountFieldSet);
        String accountFields = String.join(accountFieldList, ',');

        String accountIdsStr = String.join(recordIdList, '\',\'');
        String query = 'SELECT ' + accountFields + ' FROM Account WHERE Id IN (\'' + accountIdsStr + '\')';
        System.debug('Account query>>> ' + query);
        List<Account> AccountList = Database.Query(query);
        System.debug('Account Data>>> ' + AccountList);
        
        List<Order__c> orderList = new List<Order__c>();
        Set<String> orderFieldSet = Schema.getGlobalDescribe().get('Order__c').getDescribe().fields.getMap().keySet();
        List<String> orderFieldList = new List<String>();
        orderFieldList.addAll(orderFieldSet);
        String orderFields = String.join(orderFieldList, ',');

        String orderIdsStr = String.join(recordIdListOrder, '\',\'');
        String query2 = 'SELECT ' + orderFields + ', Partner_Primary__r.Name,Account_Name__r.Name, Owner.Name, PV_System__r.Battery_Capacity__c, PV_System__r.Battery_Selected__c, PV_System__r.Meter_Box_Euro__c FROM Order__c WHERE Id IN (\'' + orderIdsStr + '\')';        
        orderList = Database.Query(query2);          
		System.debug('Inside CreateCustomer.apxc>>>Line No. 49>>>'+query2);        
        Order__c orderSingle = new Order__c();
        if(orderList.size()>0) orderSingle = orderList.get(0);
        System.debug('Inside CreateCustomer.apxc>>>Line No. 52>>>'+orderSingle);
        System.debug('Inside CreateCustomer.apxc>>>Line No. 53>>>'+orderSingle.Partner_Primary__c);

        for (Account acc: AccountList) {
            String bodyValue = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cus="http://ws.praxedo.com/v6/customermodel">';
            bodyValue += '<soapenv:Header/>';
            bodyValue += '<soapenv:Body>';
            bodyValue += '<cus:createCustomers>';
            bodyValue += '<customers>';
            bodyValue += '<address>' + acc.BillingStreet + '</address>';
            bodyValue += '<city>' + acc.BillingCity + '</city>';
            bodyValue += '<contact>' + acc.FirstName + ' ' + acc.LastName + '</contact>';
            bodyValue += '<contacts>';
            bodyValue += '<coordinates>' + acc.Phone + '</coordinates>';
            bodyValue += '<label>' + acc.FirstName + ' ' + acc.LastName + '</label>';
            bodyValue += '<type>PHONE</type>';
            bodyValue += '</contacts>';
            bodyValue += '<contacts>';
            bodyValue += '<coordinates>' + acc.PersonEmail + '</coordinates>';
            // bodyValue += '<label>' + acc.FirstName + ' ' + acc.LastName + '</label>';
            bodyValue += '<type>EMAIL</type>';
            bodyValue += '</contacts>';
            bodyValue += '<country>DE</country>';
            bodyValue += '<description>' + (acc.Notes__c != null ? acc.Notes__c : '') + '</description>';
            bodyValue += '<id>' + acc.Id + '</id>';
            bodyValue += '<name>' + acc.FirstName + ' ' + acc.LastName + '</name>';
            bodyValue += '<organizationalUnit>'+ orderSingle.Partner_Primary__c +'</organizationalUnit>';
            bodyValue += '<zipCode>' + acc.BillingPostalCode + '</zipCode>';
            bodyValue += '</customers>';
            bodyValue += '</cus:createCustomers>';
            bodyValue += '</soapenv:Body>';
            bodyValue += '</soapenv:Envelope>';

            System.debug('bodyValue>>>' + bodyValue);
            System.enqueueJob(new PraxedoAPICallout('Account', acc.Id, endPoint, method, authorizationToken, soapAction, bodyValue, praxedoInput));
        }
    }
}