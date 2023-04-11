public without sharing class CreateWorkOrder {
    public static String endPoint = 'https://ws-eu9.praxedo.com/eTech/services/cxf/v6/BusinessEventManager';
    public static String method = 'POST';
    public static String authorizationToken = 'V1NfU3VudmlnbzpMNlBmOU1YJGtqaWRLRGJq';
    public static String soapAction = 'createEvents';

    @InvocableMethod
    public static void generateWorkOrder(List<FlowPraxedoInputModal> praxedoInput) {
        List<String> recordIdList = new List<String>();
        for (FlowPraxedoInputModal input: praxedoInput) {
            recordIdList.add(input.orderId);
        }
        Set<String> orderFieldSet = Schema.getGlobalDescribe().get('Order__c').getDescribe().fields.getMap().keySet();
        List<String> orderFieldList = new List<String>();
        orderFieldList.addAll(orderFieldSet);
        String orderFields = String.join(orderFieldList, ',');

        String orderIdsStr = String.join(recordIdList, '\',\'');    
        String query = 'SELECT ' + orderFields + ', Account_Name__r.Name, Account_Name__r.PersonMobilePhone, Account_name__r.LastName, Account_Name__r.PersonEmail, Owner.Name, PV_System__r.Battery_Capacity__c, PV_System__r.Battery_Selected__c, PV_System__r.Wallbox_Selected__c, Partner_Primary__r.Name FROM Order__c WHERE Id IN (\'' + orderIdsStr + '\')';
        System.debug('Order query>>> ' + query);
        List<Order__c> OrderList = Database.Query(query);
        System.debug('Order Data>>> ' + OrderList);

        for (Order__c order: OrderList) {
            List<String> sendBodyValue = new List<String>();
		    System.debug('Inside CreateWorkOrder>>>Line No. 26>>> ' + order.Quality_Gate_1__c);                                        
            if (order.Quality_Gate_1__c == True) {
		        System.debug('Inside CreateWorkOrder>>>Line No. 28>>>' + order.Quality_Gate_1__c);                            
                
                
                // Start - Create Sub Construction Order
                String bodyValue = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:bus="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
                bodyValue += '<soap:Header />';
                bodyValue += '<soap:Body>';
                bodyValue += '<bus:createEvents>';
                bodyValue += '<events>';
                //PSS-150
                //bodyValue += '<id>WSC-' + order.Id + '</id>';
                bodyValue += '<id>'+order.ProcessID__c+' '+ order.Account_name__r.LastName+' Sub Construction</id>';
                bodyValue += '<coreData>';
                // bodyValue += '<organizationalUnitId>' + order.Partner_Primary__c + '</organizationalUnitId>';
                // bodyValue += '<organizationalUnitId>SUN</organizationalUnitId>';
                bodyValue += '<description></description>';
                bodyValue += '<referentialData xsi:type="bus:praxedoReferentialData">';
                bodyValue += '<customerId>' + order.Account_Name__c + '</customerId>';
                bodyValue += '<locationId>L-' + order.Account_Name__c + '</locationId>';
                bodyValue += '<equipmentId>' + order.PV_System__c + '</equipmentId>';
                bodyValue += '</referentialData>';
                bodyValue += '<contacts>';
                bodyValue += '<coordinates>' + order.Account_Name__r.PersonMobilePhone + '</coordinates>';
                bodyValue += '<label>' + order.Account_Name__r.Name + '</label>';
                bodyValue += '<type>MOBILE</type>';
                bodyValue += '</contacts>';
                bodyValue += '<contacts>';
                bodyValue += '<coordinates>' + order.Account_Name__r.PersonEmail + '</coordinates>';
                bodyValue += '<label>' + order.Account_Name__r.Name + '</label>';
                bodyValue += '<type>EMAIL</type>';
                bodyValue += '</contacts>';
                bodyValue += '<serviceOrder xmlns:ns3="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns3:serviceOrderInsertion">';
                bodyValue += '<id>'+ order.Id + '</id>';
                bodyValue += '</serviceOrder>';
                bodyValue += '</coreData>';
                bodyValue += '<qualificationData>';
                bodyValue += '<type>';
                bodyValue += '<duration>120</duration>';
                bodyValue += '<id>sub_construction</id>';
                bodyValue += '</type>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>Project_ID</id>';
                bodyValue += '<value>' + order.Name + '</value>';
                bodyValue += '</instructions>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>Subconstruction_by_Partner</id>';
                bodyValue += '<value>' + order.Subconstruction_by_partner__c + '</value>';
                bodyValue += '</instructions>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>material_delivery_date</id>';
                bodyValue += '<value>' + (order.Subconstruction_Delivery_Date__c != null ? order.Subconstruction_Delivery_Date__c.year() + '-' +  order.Subconstruction_Delivery_Date__c.month() + '-' + order.Subconstruction_Delivery_Date__c.day() + 'T00:00:00' : (order.MaterialDelivery__c != null ? order.MaterialDelivery__c.year() + '-' +  order.MaterialDelivery__c.month() + '-' + order.MaterialDelivery__c.day() + 'T00:00:00' : '')) + '</value>';
                bodyValue += '</instructions>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>delivery_recipient</id>';
                bodyValue += '<value>' + order.Delivery_Recipient__c + '</value>';
                bodyValue += '</instructions>'; 
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>Ansprechpartner</id>';
                bodyValue += '<value>' + order.Owner.Name + '</value>';
                bodyValue += '</instructions>'; 
                bodyValue += '</qualificationData>';
                if (order.Start_of_DC_Installation_Planned__c != null) {
                    bodyValue += '<schedulingData>';
                    // bodyValue += '<agentId  xsi:type="bus:externalEntityId" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
                    // bodyValue += '<id>' + order.Primary_Field_Resource__c + '</id>';
                    // // bodyValue += '<id>Test</id>';
                    // bodyValue += '</agentId>';
                    // bodyValue += '<schedulingDate>'+ (order.Start_of_DC_Installation_Planned__c != null ? order.Start_of_DC_Installation_Planned__c.format('yyyy-MM-dd\'T\'HH:mm:ss') : '') +'</schedulingDate>';
                    bodyValue += '<appointmentDate>'+ order.Start_of_DC_Installation_Planned__c.format('yyyy-MM-dd\'T\'HH:mm:ss') +'</appointmentDate>';
                    bodyValue += '<useSchedulingHour>true</useSchedulingHour>';
                    bodyValue += '</schedulingData>';
                }
                bodyValue += '</events>';
                bodyValue += '<options xmlns:ns3="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns3:wsValuedEntry">';
                bodyValue += '<key>businessEvent.create.onExisting</key>';
                bodyValue += '<value>update</value>';
                bodyValue += '</options>';
                bodyValue += '</bus:createEvents>';
                bodyValue += '</soap:Body>';
                bodyValue += '</soap:Envelope>';

                system.debug('bodyValue>>>' + bodyValue);
                sendBodyValue.add(bodyValue);

                // End - Create Sub Construction Order

                // Start - Modules & Cabeling Installation 
                bodyValue = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:bus="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
                bodyValue += '<soap:Header />';
                bodyValue += '<soap:Body>';
                bodyValue += '<bus:createEvents>';
                bodyValue += '<events>';
                //PSS-150
                //bodyValue += '<id>WMCI-' + order.Id + '</id>';
                bodyValue += '<id>'+order.ProcessID__c+' '+ order.Account_name__r.LastName+' Modules and Cabeling Installation</id>';                
                bodyValue += '<coreData>';
                // bodyValue += '<organizationalUnitId>' + order.Partner_Primary__c + '</organizationalUnitId>';
                // bodyValue += '<organizationalUnitId>SUN</organizationalUnitId>';
                bodyValue += '<description></description>';
                bodyValue += '<referentialData xsi:type="bus:praxedoReferentialData">';
                bodyValue += '<customerId>' + order.Account_Name__c + '</customerId>';
                bodyValue += '<locationId>L-' + order.Account_Name__c + '</locationId>';
                bodyValue += '<equipmentId>' + order.PV_System__c + '</equipmentId>';
                bodyValue += '</referentialData>';
                bodyValue += '<contacts>';
                bodyValue += '<coordinates>' + order.Account_Name__r.PersonMobilePhone + '</coordinates>';
                bodyValue += '<label>' + order.Account_Name__r.Name + '</label>';
                bodyValue += '<type>MOBILE</type>';
                bodyValue += '</contacts>';
                bodyValue += '<contacts>';
                bodyValue += '<coordinates>' + order.Account_Name__r.PersonEmail + '</coordinates>';
                bodyValue += '<label>' + order.Account_Name__r.Name + '</label>';
                bodyValue += '<type>EMAIL</type>';
                bodyValue += '</contacts>';
                bodyValue += '<serviceOrder xmlns:ns3="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns3:serviceOrderInsertion">';
                bodyValue += '<id>'+ order.Id + '</id>';
                bodyValue += '</serviceOrder>';
                bodyValue += '</coreData>';
                bodyValue += '<qualificationData>';
                bodyValue += '<type>';
                bodyValue += '<duration>120</duration>';
                bodyValue += '<id>pv_panel_installation</id>';
                bodyValue += '</type>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>Project_ID</id>';
                bodyValue += '<value>' + order.Name + '</value>';
                bodyValue += '</instructions>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>material_delivery_date</id>';
                bodyValue += '<value>' + (order.MaterialDelivery__c != null ? order.MaterialDelivery__c.year() + '-' +  order.MaterialDelivery__c.month() + '-' + order.MaterialDelivery__c.day() + 'T00:00:00' : '') + '</value>';
                bodyValue += '</instructions>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>Ansprechpartner</id>';
                bodyValue += '<value>' + order.Owner.Name + '</value>';
                bodyValue += '</instructions>'; 
                bodyValue += '</qualificationData>';
                if (order.Start_of_DC_Installation_Planned__c != null) {
                    bodyValue += '<schedulingData>';
                    // bodyValue += '<agentId  xsi:type="bus:externalEntityId" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
                    // bodyValue += '<id>' + order.Primary_Field_Resource__c + '</id>';
                    // // bodyValue += '<id>Test</id>';
                    // bodyValue += '</agentId>';
                    // bodyValue += '<schedulingDate>'+ (order.Start_of_DC_Installation_Planned__c != null ? order.Start_of_DC_Installation_Planned__c.format('yyyy-MM-dd\'T\'HH:mm:ss') : '') +'</schedulingDate>';
                    bodyValue += '<appointmentDate>'+ order.Start_of_DC_Installation_Planned__c.format('yyyy-MM-dd\'T\'HH:mm:ss') +'</appointmentDate>';
                    bodyValue += '<useSchedulingHour>true</useSchedulingHour>';
                    bodyValue += '</schedulingData>';
                }
                bodyValue += '</events>';
                bodyValue += '<options xmlns:ns3="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns3:wsValuedEntry">';
                bodyValue += '<key>businessEvent.create.onExisting</key>';
                bodyValue += '<value>update</value>';
                bodyValue += '</options>';
                bodyValue += '</bus:createEvents>';
                bodyValue += '</soap:Body>';
                bodyValue += '</soap:Envelope>';

                system.debug('bodyValue>>>' + bodyValue);
                sendBodyValue.add(bodyValue);

                // End - Modules & Cabeling Installation 

                // Start - Inverter Installation
                bodyValue = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:bus="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
                bodyValue += '<soap:Header />';
                bodyValue += '<soap:Body>';
                bodyValue += '<bus:createEvents>';
                bodyValue += '<events>';
                //PSS-150
                //bodyValue += '<id>WII-' + order.Id + '</id>';
                bodyValue += '<id>'+order.ProcessID__c+' '+ order.Account_name__r.LastName+' Inverter Installation</id>';                
                bodyValue += '<coreData>';
                // bodyValue += '<organizationalUnitId>' + order.Partner_Primary__c + '</organizationalUnitId>';
                // bodyValue += '<organizationalUnitId>SUN</organizationalUnitId>';
                bodyValue += '<description></description>';
                bodyValue += '<referentialData xsi:type="bus:praxedoReferentialData">';
                bodyValue += '<customerId>' + order.Account_Name__c + '</customerId>';
                bodyValue += '<locationId>L-' + order.Account_Name__c + '</locationId>';
                bodyValue += '<equipmentId>' + order.PV_System__c + '</equipmentId>';
                bodyValue += '</referentialData>';
                bodyValue += '<contacts>';
                bodyValue += '<coordinates>' + order.Account_Name__r.PersonMobilePhone + '</coordinates>';
                bodyValue += '<label>' + order.Account_Name__r.Name + '</label>';
                bodyValue += '<type>MOBILE</type>';
                bodyValue += '</contacts>';
                bodyValue += '<contacts>';
                bodyValue += '<coordinates>' + order.Account_Name__r.PersonEmail + '</coordinates>';
                bodyValue += '<label>' + order.Account_Name__r.Name + '</label>';
                bodyValue += '<type>EMAIL</type>';
                bodyValue += '</contacts>';
                bodyValue += '<serviceOrder xmlns:ns3="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns3:serviceOrderInsertion">';
                bodyValue += '<id>'+ order.Id + '</id>';
                bodyValue += '</serviceOrder>';
                bodyValue += '</coreData>';
                bodyValue += '<qualificationData>';
                bodyValue += '<type>';
                bodyValue += '<duration>120</duration>';
                bodyValue += '<id>inverter_installation</id>';
                bodyValue += '</type>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>Project_ID</id>';
                bodyValue += '<value>' + order.Name + '</value>';
                bodyValue += '</instructions>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>Ansprechpartner</id>';
                bodyValue += '<value>' + order.Owner.Name + '</value>';
                bodyValue += '</instructions>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>material_delivery_date</id>';
                bodyValue += '<value>' + (order.Inverter_Delivery_Date__c != null ? order.Inverter_Delivery_Date__c.year() + '-' +  order.Inverter_Delivery_Date__c.month() + '-' + order.Inverter_Delivery_Date__c.day() + 'T00:00:00' : (order.MaterialDelivery__c != null ? order.MaterialDelivery__c.year() + '-' +  order.MaterialDelivery__c.month() + '-' + order.MaterialDelivery__c.day() + 'T00:00:00' : '')) + '</value>';
                bodyValue += '</instructions>'; 
                bodyValue += '</qualificationData>';
                 if (order.StartOfInstallationPlanned__c != null) {
                    bodyValue += '<schedulingData>';
                    // bodyValue += '<agentId  xsi:type="bus:externalEntityId" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
                    // bodyValue += '<id>' + order.Primary_Field_Resource__c + '</id>';
                    // // bodyValue += '<id>Test</id>';
                    // bodyValue += '</agentId>';
                    //bodyValue += '<schedulingDate>'+ order.StartOfInstallationPlanned__c +'</schedulingDate>';
                   
                    bodyValue += '<appointmentDate>'+ order.StartOfInstallationPlanned__c.year() + '-' +  order.StartOfInstallationPlanned__c.month() + '-' + order.StartOfInstallationPlanned__c.day() + 'T00:00:00'+'</appointmentDate>';
                    bodyValue += '<useSchedulingHour>true</useSchedulingHour>';
                    bodyValue += '</schedulingData>';
                }
                bodyValue += '</events>';
                bodyValue += '<options xmlns:ns3="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns3:wsValuedEntry">';
                bodyValue += '<key>businessEvent.create.onExisting</key>';
                bodyValue += '<value>update</value>';
                bodyValue += '</options>';
                bodyValue += '</bus:createEvents>';
                bodyValue += '</soap:Body>';
                bodyValue += '</soap:Envelope>';

                system.debug('bodyValue>>>' + bodyValue);
                sendBodyValue.add(bodyValue);

                // End - Inverter Installation

                // Start - Battery Installation
	    // PSS-142 | Only create Work Order if Battery Installation selected is Yes
	    if(order.PV_System__r.Battery_Selected__c == 'Yes')
   {	
                bodyValue = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:bus="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
                bodyValue += '<soap:Header />';
                bodyValue += '<soap:Body>';
                bodyValue += '<bus:createEvents>';
                bodyValue += '<events>';
                //PSS-150
                //bodyValue += '<id>WBI-' + order.Id + '</id>';
                bodyValue += '<id>'+order.ProcessID__c+' '+ order.Account_name__r.LastName+' Battery Installation</id>';                
                bodyValue += '<coreData>';
                // bodyValue += '<organizationalUnitId>' + order.Partner_Primary__c + '</organizationalUnitId>';
                // bodyValue += '<organizationalUnitId>SUN</organizationalUnitId>';
                bodyValue += '<description></description>';
                bodyValue += '<referentialData xsi:type="bus:praxedoReferentialData">';
                bodyValue += '<customerId>' + order.Account_Name__c + '</customerId>';
                bodyValue += '<locationId>L-' + order.Account_Name__c + '</locationId>';
                bodyValue += '<equipmentId>' + order.PV_System__c + '</equipmentId>';
                bodyValue += '</referentialData>';
                bodyValue += '<contacts>';
                bodyValue += '<coordinates>' + order.Account_Name__r.PersonMobilePhone + '</coordinates>';
                bodyValue += '<label>' + order.Account_Name__r.Name + '</label>';
                bodyValue += '<type>MOBILE</type>';
                bodyValue += '</contacts>';
                bodyValue += '<contacts>';
                bodyValue += '<coordinates>' + order.Account_Name__r.PersonEmail + '</coordinates>';
                bodyValue += '<label>' + order.Account_Name__r.Name + '</label>';
                bodyValue += '<type>EMAIL</type>';
                bodyValue += '</contacts>';
                bodyValue += '<serviceOrder xmlns:ns3="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns3:serviceOrderInsertion">';
                bodyValue += '<id>'+ order.Id + '</id>';
                bodyValue += '</serviceOrder>';
                bodyValue += '</coreData>';
                bodyValue += '<qualificationData>';
                bodyValue += '<type>';
                bodyValue += '<duration>120</duration>';
                bodyValue += '<id>batterie_installation</id>';
                bodyValue += '</type>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>Project_ID</id>';
                bodyValue += '<value>' + order.Name + '</value>';
                bodyValue += '</instructions>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>Ansprechpartner</id>';
                bodyValue += '<value>' + order.Owner.Name + '</value>';
                bodyValue += '</instructions>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>material_delivery_date</id>';
                bodyValue += '<value>' + (order.Battery_Delivery_Date__c != null ? order.Battery_Delivery_Date__c.year() + '-' +  order.Battery_Delivery_Date__c.month() + '-' + order.Battery_Delivery_Date__c.day() + 'T00:00:00' : (order.MaterialDelivery__c != null ? order.MaterialDelivery__c.year() + '-' +  order.MaterialDelivery__c.month() + '-' + order.MaterialDelivery__c.day() + 'T00:00:00' : '')) + '</value>';
                bodyValue += '</instructions>';
                bodyValue += '</qualificationData>';
       			 if (order.StartOfInstallationPlanned__c != null) {
                    bodyValue += '<schedulingData>';
                    // bodyValue += '<agentId  xsi:type="bus:externalEntityId" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
                    // bodyValue += '<id>' + order.Primary_Field_Resource__c + '</id>';
                    // // bodyValue += '<id>Test</id>';
                    // bodyValue += '</agentId>';
                    //bodyValue += '<schedulingDate>'+ order.StartOfInstallationPlanned__c +'</schedulingDate>';
                   
                    bodyValue += '<appointmentDate>'+ order.StartOfInstallationPlanned__c.year() + '-' +  order.StartOfInstallationPlanned__c.month() + '-' + order.StartOfInstallationPlanned__c.day() + 'T00:00:00'+'</appointmentDate>';
                    bodyValue += '<useSchedulingHour>true</useSchedulingHour>';
                    bodyValue += '</schedulingData>';
                }
                bodyValue += '</events>';
                bodyValue += '<options xmlns:ns3="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns3:wsValuedEntry">';
                bodyValue += '<key>businessEvent.create.onExisting</key>';
                bodyValue += '<value>update</value>';
                bodyValue += '</options>';
                bodyValue += '</bus:createEvents>';
                bodyValue += '</soap:Body>';
                bodyValue += '</soap:Envelope>';

                system.debug('bodyValue>>>' + bodyValue);
                sendBodyValue.add(bodyValue);
	}
                // End - Battery Installation

                // Start - Meter Placement 
                bodyValue = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:bus="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
                bodyValue += '<soap:Header />';
                bodyValue += '<soap:Body>';
                bodyValue += '<bus:createEvents>';
                bodyValue += '<events>';
                //PSS-150
                //bodyValue += '<id>WMP-' + order.Id + '</id>';
                bodyValue += '<id>'+order.ProcessID__c+' '+ order.Account_name__r.LastName+' Meter Placement</id>';                
                bodyValue += '<coreData>';
                // bodyValue += '<organizationalUnitId>' + order.Partner_Primary__c + '</organizationalUnitId>';
                // bodyValue += '<organizationalUnitId>SUN</organizationalUnitId>';
                bodyValue += '<description></description>';
                bodyValue += '<referentialData xsi:type="bus:praxedoReferentialData">';
                bodyValue += '<customerId>' + order.Account_Name__c + '</customerId>';
                bodyValue += '<locationId>L-' + order.Account_Name__c + '</locationId>';
                bodyValue += '<equipmentId>' + order.PV_System__c + '</equipmentId>';
                bodyValue += '</referentialData>';
                bodyValue += '<contacts>';
                bodyValue += '<coordinates>' + order.Account_Name__r.PersonMobilePhone + '</coordinates>';
                bodyValue += '<label>' + order.Account_Name__r.Name + '</label>';
                bodyValue += '<type>MOBILE</type>';
                bodyValue += '</contacts>';
                bodyValue += '<contacts>';
                bodyValue += '<coordinates>' + order.Account_Name__r.PersonEmail + '</coordinates>';
                bodyValue += '<label>' + order.Account_Name__r.Name + '</label>';
                bodyValue += '<type>EMAIL</type>';
                bodyValue += '</contacts>';
                bodyValue += '<serviceOrder xmlns:ns3="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns3:serviceOrderInsertion">';
                bodyValue += '<id>'+ order.Id + '</id>';
                bodyValue += '</serviceOrder>';
                bodyValue += '</coreData>';
                bodyValue += '<qualificationData>';
                bodyValue += '<type>';
                bodyValue += '<duration>120</duration>';
                bodyValue += '<id>meter_placement</id>';
                bodyValue += '</type>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>Project_ID</id>';
                bodyValue += '<value>' + order.Name + '</value>';
                bodyValue += '</instructions>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>status_erzeugungsmessung</id>';
                bodyValue += '<value>' + order.Preparation_Erzeugungsmessung_completed__c + '</value>';
                bodyValue += '</instructions>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>Ansprechpartner</id>';
                bodyValue += '<value>' + order.Owner.Name + '</value>';
                bodyValue += '</instructions>'; 
                bodyValue += '</qualificationData>';
                /*
                if (order.StartOfInstallationPlanned__c != null) {
                    bodyValue += '<schedulingData>';
                    // bodyValue += '<agentId  xsi:type="bus:externalEntityId" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
                    // bodyValue += '<id>' + order.Primary_Field_Resource__c + '</id>';
                    // // bodyValue += '<id>Test</id>';
                    // bodyValue += '</agentId>';
                    //bodyValue += '<schedulingDate>'+ order.StartOfInstallationPlanned__c +'</schedulingDate>';
                   
                    bodyValue += '<appointmentDate>'+ order.StartOfInstallationPlanned__c.year() + '-' +  order.StartOfInstallationPlanned__c.month() + '-' + order.StartOfInstallationPlanned__c.day() + 'T00:00:00'+'</appointmentDate>';
                    bodyValue += '<useSchedulingHour>true</useSchedulingHour>';
                    bodyValue += '</schedulingData>';
                }
                */
                bodyValue += '</events>';
                bodyValue += '<options xmlns:ns3="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns3:wsValuedEntry">';
                bodyValue += '<key>businessEvent.create.onExisting</key>';
                bodyValue += '<value>update</value>';
                bodyValue += '</options>';
                bodyValue += '</bus:createEvents>';
                bodyValue += '</soap:Body>';
                bodyValue += '</soap:Envelope>';

                system.debug('bodyValue>>>' + bodyValue);
                sendBodyValue.add(bodyValue);

                // End - Meter Placement 

	            // Start - Wallbox Installation

	            // PSS-142 | Only create Work Order if Wallbox selected is Yes
                if( order.PV_System__r.Wallbox_Selected__c == 'Yes')
	            {
 
                bodyValue = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:bus="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
                bodyValue += '<soap:Header />';
                bodyValue += '<soap:Body>';
                bodyValue += '<bus:createEvents>';
                bodyValue += '<events>';                
                //PSS-150
                //bodyValue += '<id>WWI-' + order.Id + '</id>';
                bodyValue += '<id>'+order.ProcessID__c+' '+ order.Account_name__r.LastName+' Wallbox Installation</id>';                
                bodyValue += '<coreData>';
                // bodyValue += '<organizationalUnitId>' + order.Partner_Primary__c + '</organizationalUnitId>';
                // bodyValue += '<organizationalUnitId>SUN</organizationalUnitId>';
                bodyValue += '<description></description>';
                bodyValue += '<referentialData xsi:type="bus:praxedoReferentialData">';
                bodyValue += '<customerId>' + order.Account_Name__c + '</customerId>';
                bodyValue += '<locationId>L-' + order.Account_Name__c + '</locationId>';
                bodyValue += '<equipmentId>' + order.PV_System__c + '</equipmentId>';
                bodyValue += '</referentialData>';
                bodyValue += '<contacts>';
                bodyValue += '<coordinates>' + order.Account_Name__r.PersonMobilePhone + '</coordinates>';
                bodyValue += '<label>' + order.Account_Name__r.Name + '</label>';
                bodyValue += '<type>MOBILE</type>';
                bodyValue += '</contacts>';
                bodyValue += '<contacts>';
                bodyValue += '<coordinates>' + order.Account_Name__r.PersonEmail + '</coordinates>';
                bodyValue += '<label>' + order.Account_Name__r.Name + '</label>';
                bodyValue += '<type>EMAIL</type>';
                bodyValue += '</contacts>';
                bodyValue += '<serviceOrder xmlns:ns3="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns3:serviceOrderInsertion">';
                bodyValue += '<id>'+ order.Id + '</id>';
                bodyValue += '</serviceOrder>';
                bodyValue += '</coreData>';
                bodyValue += '<qualificationData>';
                bodyValue += '<type>';
                bodyValue += '<duration>120</duration>';
                bodyValue += '<id>wallbox_installation</id>';
                bodyValue += '</type>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>Project_ID</id>';
                bodyValue += '<value>' + order.Name + '</value>';
                bodyValue += '</instructions>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>Ansprechpartner</id>';
                bodyValue += '<value>' + order.Owner.Name + '</value>';
                bodyValue += '</instructions>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>material_delivery_date</id>';
                bodyValue += '<value>' + (order.Wallbox_Delivery_Date__c != null ? order.Wallbox_Delivery_Date__c.year() + '-' +  order.Wallbox_Delivery_Date__c.month() + '-' + order.Wallbox_Delivery_Date__c.day() + 'T00:00:00' : (order.MaterialDelivery__c != null ? order.MaterialDelivery__c.year() + '-' +  order.MaterialDelivery__c.month() + '-' + order.MaterialDelivery__c.day() + 'T00:00:00' : '')) + '</value>';
                bodyValue += '</instructions>'; 
                bodyValue += '</qualificationData>';
                if (order.StartOfInstallationPlanned__c != null) {
                    bodyValue += '<schedulingData>';
                    // bodyValue += '<agentId  xsi:type="bus:externalEntityId" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
                    // bodyValue += '<id>' + order.Primary_Field_Resource__c + '</id>';
                    // // bodyValue += '<id>Test</id>';
                    // bodyValue += '</agentId>';
                    //bodyValue += '<schedulingDate>'+ order.StartOfInstallationPlanned__c +'</schedulingDate>';
                   
                    bodyValue += '<appointmentDate>'+ order.StartOfInstallationPlanned__c.year() + '-' +  order.StartOfInstallationPlanned__c.month() + '-' + order.StartOfInstallationPlanned__c.day() + 'T00:00:00'+'</appointmentDate>';
                    bodyValue += '<useSchedulingHour>true</useSchedulingHour>';
                    bodyValue += '</schedulingData>';
                }                
                bodyValue += '</events>';
                bodyValue += '<options xmlns:ns3="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns3:wsValuedEntry">';
                bodyValue += '<key>businessEvent.create.onExisting</key>';
                bodyValue += '<value>update</value>';
                bodyValue += '</options>';
                bodyValue += '</bus:createEvents>';
                bodyValue += '</soap:Body>';
                bodyValue += '</soap:Envelope>';

                system.debug('bodyValue>>>' + bodyValue);
                sendBodyValue.add(bodyValue);
                }
                // End - Wallbox Installation

                // Start - Meter Box Installation
                bodyValue = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:bus="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
                bodyValue += '<soap:Header />';
                bodyValue += '<soap:Body>';
                bodyValue += '<bus:createEvents>';
                bodyValue += '<events>';
                //PSS-150
                //bodyValue += '<id>WMBI-' + order.Id + '</id>';
                bodyValue += '<id>'+order.ProcessID__c+' '+ order.Account_name__r.LastName+' Meter Box Installation</id>';                
                bodyValue += '<coreData>';
                // bodyValue += '<organizationalUnitId>' + order.Partner_Primary__c + '</organizationalUnitId>';
                // bodyValue += '<organizationalUnitId>SUN</organizationalUnitId>';
                bodyValue += '<description></description>';
                bodyValue += '<referentialData xsi:type="bus:praxedoReferentialData">';
                bodyValue += '<customerId>' + order.Account_Name__c + '</customerId>';
                bodyValue += '<locationId>L-' + order.Account_Name__c + '</locationId>';
                bodyValue += '<equipmentId>' + order.PV_System__c + '</equipmentId>';
                bodyValue += '</referentialData>';
                bodyValue += '<contacts>';
                bodyValue += '<coordinates>' + order.Account_Name__r.PersonMobilePhone + '</coordinates>';
                bodyValue += '<label>' + order.Account_Name__r.Name + '</label>';
                bodyValue += '<type>MOBILE</type>';
                bodyValue += '</contacts>';
                bodyValue += '<contacts>';
                bodyValue += '<coordinates>' + order.Account_Name__r.PersonEmail + '</coordinates>';
                bodyValue += '<label>' + order.Account_Name__r.Name + '</label>';
                bodyValue += '<type>EMAIL</type>';
                bodyValue += '</contacts>';
                bodyValue += '<serviceOrder xmlns:ns3="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns3:serviceOrderInsertion">';
                bodyValue += '<id>'+ order.Id + '</id>';
                bodyValue += '</serviceOrder>';
                bodyValue += '</coreData>';
                bodyValue += '<qualificationData>';
                bodyValue += '<type>';
                bodyValue += '<duration>120</duration>';
                bodyValue += '<id>meter_box_ac_setup</id>';
                bodyValue += '</type>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>Project_ID</id>';
                bodyValue += '<value>' + order.Name + '</value>';
                bodyValue += '</instructions>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>meter_type_gen_new</id>';
                bodyValue += '<value>' + order.MeterTypeGen__c + '</value>';
                bodyValue += '</instructions>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>meter_shutdown_reqguired</id>';
                bodyValue += '<value>' + (order.HeatTariffShutdownRequired__c == 'Yes' ||  order.Meter_OtherShutdownRequired__c == 'Yes' ? true : false) + '</value>';
                bodyValue += '</instructions>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>Status_Erzeugungsmessung</id>';
                bodyValue += '<value>' + (order.Preparation_Erzeugungsmessung_completed__c == 'Field occupied(other meter in place)' ? false : true) + '</value>';
                bodyValue += '</instructions>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>meter_type_old_new</id>';
                bodyValue += '<value>' + (order.MeterTypeHH__c != order.OldProviderHH_MeterType__c ? 'Zählerplatz erst anpassen, dann vorbereiten' : 'nur Vorbereitung nötig') + '</value>';
                bodyValue += '</instructions>';
                bodyValue += '<instructions xsi:type="bus:reportField">';
                bodyValue += '<id>Ansprechpartner</id>';
                bodyValue += '<value>' + order.Owner.Name + '</value>';
                bodyValue += '</instructions>'; 
                bodyValue += '</qualificationData>';
                 if (order.Start_of_AC_Installation_Planned__c != null) {
                    bodyValue += '<schedulingData>';
                    // bodyValue += '<agentId  xsi:type="bus:externalEntityId" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
                    // bodyValue += '<id>' + order.Primary_Field_Resource__c + '</id>';
                    // bodyValue += '<id>Test</id>';
                    // bodyValue += '</agentId>';
                    //bodyValue += '<schedulingDate>'+ order.Start_of_AC_Installation_Planned__c +'</schedulingDate>';
                   
                    bodyValue += '<appointmentDate>'+ order.Start_of_DC_Installation_Planned__c.format('yyyy-MM-dd\'T\'HH:mm:ss') +'</appointmentDate>';
                    bodyValue += '<useSchedulingHour>true</useSchedulingHour>';
                    bodyValue += '</schedulingData>';
                }
                bodyValue += '</events>';
                bodyValue += '<options xmlns:ns3="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns3:wsValuedEntry">';
                bodyValue += '<key>businessEvent.create.onExisting</key>';
                bodyValue += '<value>update</value>';
                bodyValue += '</options>';
                bodyValue += '</bus:createEvents>';
                bodyValue += '</soap:Body>';
                bodyValue += '</soap:Envelope>';

                system.debug('bodyValue>>>' + bodyValue);
                sendBodyValue.add(bodyValue);
                
                //FYI - Need to check again for "eHz Anschlusskassette notwendig"
                // End - Meter Box Installation

            } 

            //Start - Site Visit Work Order
            String bodyValue = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:bus="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
            bodyValue += '<soap:Header />';
            bodyValue += '<soap:Body>';
            bodyValue += '<bus:createEvents>';
            bodyValue += '<events>';
            //PSS-150
            //bodyValue += '<id>W-' + order.Id + '</id>';
            bodyValue += '<id>'+order.ProcessID__c+' '+ order.Account_name__r.LastName+' Site Visit</id>';                
            // bodyValue += '<organizationalUnitId>' + order.Partner_Primary__c + '</organizationalUnitId>';            
            // bodyValue += '<organizationalUnitId>SUN</organizationalUnitId>';
            bodyValue += '<coreData>';
            bodyValue += '<description></description>';
            bodyValue += '<referentialData xsi:type="bus:praxedoReferentialData">';
            bodyValue += '<customerId>' + order.Account_Name__c + '</customerId>';
            bodyValue += '<locationId>L-' + order.Account_Name__c + '</locationId>';
            bodyValue += '<equipmentId>' + order.PV_System__c + '</equipmentId>';
            bodyValue += '</referentialData>';
            bodyValue += '<contacts>';
            bodyValue += '<coordinates>' + order.Account_Name__r.PersonMobilePhone + '</coordinates>';
            bodyValue += '<label>' + order.Account_Name__r.Name + '</label>';
            bodyValue += '<type>MOBILE</type>';
            bodyValue += '</contacts>';
            bodyValue += '<contacts>';
            bodyValue += '<coordinates>' + order.Account_Name__r.PersonEmail + '</coordinates>';
            bodyValue += '<label>' + order.Account_Name__r.Name + '</label>';
            bodyValue += '<type>EMAIL</type>';
            bodyValue += '</contacts>';
            bodyValue += '<serviceOrder xmlns:ns3="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns3:serviceOrderInsertion">';
            bodyValue += '<id>'+ order.Id + '</id>';
            bodyValue += '</serviceOrder>';
            bodyValue += '</coreData>';
            bodyValue += '<qualificationData>';
            bodyValue += '<type>';
            bodyValue += '<duration>120</duration>';
            bodyValue += '<id>VO</id>';
            bodyValue += '</type>';
            bodyValue += '<instructions xsi:type="bus:reportField">';
            bodyValue += '<id>Project_ID</id>';
            bodyValue += '<value>' + order.Name + '</value>';
            bodyValue += '</instructions>';
            bodyValue += '<instructions xsi:type="bus:reportField">';
            bodyValue += '<id>Ansprechpartner</id>';
            bodyValue += '<value>' + order.Owner.Name + '</value>';
            bodyValue += '</instructions>'; 
            bodyValue += '</qualificationData>';
            if (order.Pre_Installation_Planned__c != null) {
                bodyValue += '<schedulingData>';
                // bodyValue += '<agentId  xsi:type="bus:externalEntityId" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
                // bodyValue += '<id>' + order.Primary_Field_Resource__c + '</id>';
                // // bodyValue += '<id>Test</id>';
                // bodyValue += '</agentId>';
                //bodyValue += '<schedulingDate>'+ (order.Pre_Installation_Planned__c != null ? order.Pre_Installation_Planned__c.format('yyyy-MM-dd\'T\'HH:mm:ss') : '') +'</schedulingDate>';
                bodyValue += '<appointmentDate>'+ order.Pre_Installation_Planned__c.format('yyyy-MM-dd\'T\'HH:mm:ss') +'</appointmentDate>';
                // bodyValue += '<useSchedulingHour>true</useSchedulingHour>';
                bodyValue += '</schedulingData>';
            }
            bodyValue += '</events>';
            bodyValue += '<options xmlns:ns3="http://ws.praxedo.com/v6/businessEvent" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns3:wsValuedEntry">';
            bodyValue += '<key>businessEvent.create.onExisting</key>';
            bodyValue += '<value>update</value>';
            bodyValue += '</options>';
            bodyValue += '</bus:createEvents>';
            bodyValue += '</soap:Body>';
            bodyValue += '</soap:Envelope>';
            sendBodyValue.add(bodyValue);
        
            
            system.debug('bodyValue>>>' + sendBodyValue);
            //You can’t chain queueable jobs in an Apex test. Doing so results in an error. 
            //To avoid getting an error, you can check 
            //if Apex is running in test context by calling Test.isRunningTest() before chaining jobs.
            //Line number 567 added by Preeti 
            if(!Test.isRunningTest())
            System.enqueueJob(new PraxedoAPICallout('Order__c', order.Id, endPoint, method, authorizationToken, soapAction, sendBodyValue, praxedoInput));
        }
    }
    
    
}