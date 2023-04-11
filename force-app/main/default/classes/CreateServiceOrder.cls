public without sharing class CreateServiceOrder {
    public static String endPoint = 'https://ws-eu9.praxedo.com/eTech/services/cxf/v6/ServiceOrderManager';
    public static String method = 'POST';
    public static String authorizationToken = 'V1NfU3VudmlnbzpMNlBmOU1YJGtqaWRLRGJq';
    public static String soapAction = 'createServiceOrders';

    @InvocableMethod
    public static void generateServiceOrder(List<FlowPraxedoInputModal> praxedoInput) {
        List<String> recordIdList = new List<String>();
        for (FlowPraxedoInputModal input: praxedoInput) {
            recordIdList.add(input.orderId);
        }
        Set<String> orderFieldSet = Schema.getGlobalDescribe().get('Order__c').getDescribe().fields.getMap().keySet();
        List<String> orderFieldList = new List<String>();
        orderFieldList.addAll(orderFieldSet);
        String orderFields = String.join(orderFieldList, ',');

        String orderIdsStr = String.join(recordIdList, '\',\'');
        String query = 'SELECT ' + orderFields + ', Partner_Primary__r.Name,Account_Name__r.Name, Owner.Name, PV_System__r.Battery_Capacity__c, PV_System__r.Battery_Selected__c, PV_System__r.Meter_Box_Euro__c FROM Order__c WHERE Id IN (\'' + orderIdsStr + '\')';
        System.debug('Order query>>> ' + query);
        List<Order__c> OrderList = Database.Query(query);
        System.debug('Order Data>>> ' + OrderList);

        for (Order__c order: OrderList) {
            String bodyValue = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:bus="http://ws.praxedo.com/v6/businessEvent">';
            bodyValue += '<soap:Header/>';
            bodyValue += '<soap:Body>';
            bodyValue += '<bus:createServiceOrders>';
            bodyValue += '<serviceOrders>';
            bodyValue += '<id>' + order.Id + '</id>';
            bodyValue += '<coreData>';

			//Start PSS-141            
			bodyValue += '<organizationalUnitId>'+order.Partner_Primary__c+'</organizationalUnitId>';
			//bodyValue += '<organizationalUnitId>'+order.Partner_Primary__r.Name+'</organizationalUnitId>';
			//bodyValue += '<organizationalUnitId>0010900001VMuQsAAL</organizationalUnitId>';
			//End PSS-141

            // bodyValue += '<organizationalUnitId>SUN</organizationalUnitId>';
            bodyValue += '<description>'+ order.Quality_Gate_1_Handover_Note__c + '</description>';
            bodyValue += '<referentialData xsi:type="q1:praxedoReferentialData" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:q1="http://ws.praxedo.com/v6/businessEvent">';
            bodyValue += '<customerId>' + order.Account_Name__c + '</customerId>';
            bodyValue += '<locationId>L-' + order.Account_Name__c + '</locationId>';
            bodyValue += '<equipmentId>' + order.PV_System__c + '</equipmentId>';
            bodyValue += '</referentialData>';
            bodyValue += '</coreData>';
            bodyValue += '<qualificationData>';
            bodyValue += '<type>';
            bodyValue += '<duration>1</duration>';
            bodyValue += '<id>project</id>';
            bodyValue += '</type>';
            bodyValue += '<instructions xsi:type="bus:reportField" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:q1="http://ws.praxedo.com/v6/businessEvent">';
            bodyValue += '<id>meter_box_budget</id>';
            bodyValue += '<value>' + order.Meter_Box_Budget__c + '</value>';
            bodyValue += '</instructions>';
            bodyValue += '<instructions xsi:type="bus:reportField" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:q1="http://ws.praxedo.com/v6/businessEvent">';
            bodyValue += '<id>meter_box_cost</id>';
            bodyValue += '<value>' + order.PV_System__r.Meter_Box_Euro__c + '</value>';
            bodyValue += '</instructions>'; 
            bodyValue += '<instructions xsi:type="bus:reportField" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:q1="http://ws.praxedo.com/v6/businessEvent">';
            bodyValue += '<id>process_id</id>';
            bodyValue += '<value>' + order.ProcessID__c + '</value>';
            bodyValue += '</instructions>'; 
            bodyValue += '</qualificationData>';
            bodyValue += '</serviceOrders>';
            bodyValue += '<options xmlns:ns3="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns3:wsValuedEntry">';
            bodyValue += '<key>serviceOrder.create.onExisting</key>';
            bodyValue += '<value>update</value>';
            bodyValue += '</options>';
            bodyValue += '</bus:createServiceOrders>';
            bodyValue += '</soap:Body>';
            bodyValue += '</soap:Envelope>';
            system.debug('bodyValue>>>' + bodyValue);
            System.enqueueJob(new PraxedoAPICallout('Order__c', order.Id, endPoint, method, authorizationToken, soapAction, bodyValue, praxedoInput));
        }
    }
}