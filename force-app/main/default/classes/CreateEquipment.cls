public with sharing class CreateEquipment {
    public static String endPoint = 'https://ws-eu9.praxedo.com/eTech/services/cxf/v6/EquipmentManager';
    public static String method = 'POST';
    public static String authorizationToken = 'V1NfU3VudmlnbzpMNlBmOU1YJGtqaWRLRGJq';
    public static String soapAction = 'createEquipments';

    @InvocableMethod
    public static void generateEquipment(List<FlowPraxedoInputModal> praxedoInput) {
        List<String> recordIdList = new List<String>();
        List<Id> recordIdListOrder = new List<Id>();
        for (FlowPraxedoInputModal input: praxedoInput) {
            recordIdList.add(input.pvSystemId);
            recordIdListOrder.add(input.orderId);
            
        }
        Set<String> pvSystemFieldSet = Schema.getGlobalDescribe().get('PV_System__c').getDescribe().fields.getMap().keySet();
        List<String> pvSystemFieldList = new List<String>();
        pvSystemFieldList.addAll(pvSystemFieldSet);
        String pvSystemFields = String.join(pvSystemFieldList, ',');

        String pvSystemIdsStr = String.join(recordIdList, '\',\'');
        String query = 'SELECT ' + pvSystemFields + ', Order__r.Name, Order__r.Account_Name__c, Order__r.HeatTariffShutdownRequired__c, Order__r.Meter_OtherShutdownRequired__c, Order__r.MeterTypeGen__c FROM PV_System__c WHERE Id IN (\'' + pvSystemIdsStr + '\')';
        System.debug('PV_System__c query>>> ' + query);
        List<PV_System__c> PVSystemList = Database.Query(query);
        System.debug('PV_System__c Data>>> ' + PVSystemList);
        
 
        List<Order__c> orderList = new List<Order__c>();
        Set<String> orderFieldSet = Schema.getGlobalDescribe().get('Order__c').getDescribe().fields.getMap().keySet();
        List<String> orderFieldList = new List<String>();
        orderFieldList.addAll(orderFieldSet);
        String orderFields = String.join(orderFieldList, ',');

        String orderIdsStr = String.join(recordIdListOrder, '\',\'');
        String query2 = 'SELECT ' + orderFields + ', Partner_Primary__r.Name,Account_Name__r.Name, Owner.Name, PV_System__r.Battery_Capacity__c, PV_System__r.Battery_Selected__c, PV_System__r.Meter_Box_Euro__c FROM Order__c WHERE Id IN (\'' + orderIdsStr + '\')';        
        orderList = Database.Query(query2);  
        Order__c orderSingle = new Order__c();
        if(orderList.size()>0) orderSingle = orderList.get(0);

        for (PV_System__c pvs: PVSystemList) {
            String bodyValue = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:cus="http://ws.praxedo.com/v6/customermodel">';
            bodyValue += '<soap:Header/>';
            bodyValue += '<soap:Body>';
            bodyValue += '<cus:createEquipments>';
            bodyValue += '<equipments>';
            bodyValue += '<description></description>';
            bodyValue += '<id>' + pvs.Id + '</id>';
            bodyValue += '<location>L-' + orderSingle.Account_Name__c + '</location>';
            bodyValue += '<name>' + pvs.Name + '</name>';
            bodyValue += '<organizationalUnit>'+ orderSingle.Partner_Primary__c +'</organizationalUnit>';
            bodyValue += '<status>active</status>';
            bodyValue += '<type>PV_Anlage</type>';

            bodyValue += '<customAttributes>';
            bodyValue += '<key>PV_System_Power</key>';
            bodyValue += '<value>' + (pvs.PV_System_Power_kWp__c != null ? pvs.PV_System_Power_kWp__c : 0) + '</value>';
            bodyValue += '</customAttributes>';
            bodyValue += '<customAttributes>';
            bodyValue += '<key>all_black_selected</key>';
            bodyValue += '<value>' + (pvs.All_Black_Selected__c == 'Yes' ? 'Ja' : 'Nein') + '</value>';
            bodyValue += '</customAttributes>';
            bodyValue += '<customAttributes>';
            bodyValue += '<key>amount_modules</key>';
            bodyValue += '<value>' + (pvs.Amount_of_Modules__c != null ? string.valueOf(pvs.Amount_of_Modules__c): '') + ' x ' + (pvs.Type_of_Modules__c != null ? pvs.Type_of_Modules__c : '') + '</value>';
            bodyValue += '</customAttributes>';
            bodyValue += '<customAttributes>';
            bodyValue += '<key>Inverter_Main</key>';
            bodyValue += '<value>' + (pvs.Type_Of_Inverter_Main__c != null ? pvs.Type_Of_Inverter_Main__c : '') + (pvs.DC_SPD_Inverter_Main__c != null ? ' ' + pvs.DC_SPD_Inverter_Main__c : '') + '</value>';
            bodyValue += '</customAttributes>';
            bodyValue += '<customAttributes>';
            bodyValue += '<key>Inverter_2</key>';
            bodyValue += '<value>' + (pvs.Type_Of_Inverter_2__c != null ? pvs.Type_Of_Inverter_2__c : '') + (pvs.DC_SPD_Inverter_2__c != null ? ' ' + pvs.DC_SPD_Inverter_2__c : '') + '</value>';
            bodyValue += '</customAttributes>';
            bodyValue += '<customAttributes>';
            bodyValue += '<key>Inverter_3</key>';
            bodyValue += '<value>' + (pvs.Type_Of_Inverter_3__c != null ? pvs.Type_Of_Inverter_3__c : '') + (pvs.DC_SPD_Inverter_3__c != null ? ' ' + pvs.DC_SPD_Inverter_3__c : '') + '</value>';
            bodyValue += '</customAttributes>';
            bodyValue += '<customAttributes>';
            bodyValue += '<key>ems</key>';
            bodyValue += '<value>' + (pvs.Type_of_EMS__c != null ? pvs.Type_of_EMS__c : '') + '</value>';
            bodyValue += '</customAttributes>';
            bodyValue += '<customAttributes>';
            bodyValue += '<key>Battery_types</key>';
            bodyValue += '<value>' + (pvs.Type_of_Battery__c != null ? pvs.Type_of_Battery__c + (pvs.Battery_2__c != null ? ' '+ pvs.Battery_2__c : '') : '') + '</value>';
            bodyValue += '</customAttributes>';
            bodyValue += '<customAttributes>';
            bodyValue += '<key>Wallbox_types</key>';
            bodyValue += '<value>' + (pvs.Type_of_Wallbox__c != null ? pvs.Type_of_Wallbox__c + (pvs.Type_of_Wallbox_2__c != null ? pvs.Type_of_Wallbox_2__c : '') : '')  + '</value>';
            bodyValue += '</customAttributes>';
            bodyValue += '<customAttributes>';
            bodyValue += '<key>meter_type_gen_new</key>';
            bodyValue += '<value>' + (pvs.Order__r.MeterTypeGen__c != null ? pvs.Order__r.MeterTypeGen__c : '') + '</value>';
            bodyValue += '</customAttributes>';
            bodyValue += '<customAttributes>';
            bodyValue += '<key>Heat_tariff_shutdown_required</key>';
            bodyValue += '<value>' + (pvs.Order__r.HeatTariffShutdownRequired__c != null ? pvs.Order__r.HeatTariffShutdownRequired__c : '') + '</value>';
            bodyValue += '</customAttributes>';
            bodyValue += '<customAttributes>';
            bodyValue += '<key>Other_meter_shutdown_required</key>';
            bodyValue += '<value>' + (pvs.Order__r.Meter_OtherShutdownRequired__c != null ? pvs.Order__r.Meter_OtherShutdownRequired__c : '') + '</value>';
            bodyValue += '</customAttributes>';
            bodyValue += '</equipments>';
            bodyValue += '</cus:createEquipments>';
            bodyValue += '</soap:Body>';
            bodyValue += '</soap:Envelope>';

            System.debug('bodyValue>>>' + bodyValue);
            if(!(Test.isRunningTest())){
            System.enqueueJob(new PraxedoAPICallout('PV_System__c', pvs.Id, endPoint, method, authorizationToken, soapAction, bodyValue, praxedoInput));
        	}
        }
    }
}