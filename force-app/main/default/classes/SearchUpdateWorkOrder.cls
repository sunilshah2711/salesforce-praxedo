public without sharing class SearchUpdateWorkOrder implements Schedulable {

    public static String endPoint = 'https://ws-eu9.praxedo.com/eTech/services/cxf/v6/BusinessEventManager';
    public static String method = 'POST';
    public static String authorizationToken = 'V1NfU3VudmlnbzpMNlBmOU1YJGtqaWRLRGJq';
    public static String soapAction = 'searchEvents';
    public Integer firstResultIndex=0;


    public static void searchWorkOrder() {
        System.debug('Called>>>SearchUpdateWorkOrder.searchWorkOrder()');

        String bodyValue = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:bus="http://ws.praxedo.com/v6/businessEvent">';
        bodyValue += '<soap:Header/>';
        bodyValue += '<soap:Body>';
        bodyValue += '<bus:searchEvents>';
        bodyValue += '<request>';
        bodyValue += '<dateConstraints>';
        //bodyValue += '<dateRange>'+ Datetime.now().addHours(-1).format('yyyy-MM-dd\'T\'HH:mm:ss') + '</dateRange>';
        //bodyValue += '<dateRange>'+ Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss') + '</dateRange>';
        bodyValue += '<dateRange>'+ Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss') + '</dateRange>';
        bodyValue += '<dateRange>'+ Datetime.now().addDays(1).format('yyyy-MM-dd\'T\'HH:mm:ss') + '</dateRange>';
        bodyValue += '<name>lastModificationDate</name>';
        bodyValue += '</dateConstraints>';
        bodyValue += '</request>';
        bodyValue += '<batchSize>50</batchSize>';
        bodyValue += '<firstResultIndex>0</firstResultIndex>';
        bodyValue += '<options>';
        bodyValue += '<key>businessEvent.populate.coreData</key>';
        bodyValue += '</options>';
        bodyValue += '<options>';
        bodyValue += '<key>businessEvent.populate.qualificationData</key>';
        bodyValue += '</options>';
        bodyValue += '<options>';
        bodyValue += '<key>businessEvent.populate.completionData.items</key>';
        bodyValue += '</options>';
        bodyValue += '<options>';
        bodyValue += '<key>businessEvent.populate.completionData.items</key>';
        bodyValue += '</options>';
        bodyValue += '<options>';
        bodyValue += '<key>businessEvent.populate.schedulingData</key>';
        bodyValue += '</options>';
        bodyValue += '<options>';
        bodyValue += '<key>businessEvent.populate.completionData.excludeBinaryData</key>';
        bodyValue += '</options>';
        bodyValue += '<options>';
        bodyValue += '<key>businessEvent.feature.status.cancelled</key>';
        bodyValue += '</options>';
        bodyValue += '<options>';
        bodyValue += '<key>businessEvent.populate.completionData.fields</key>';
        bodyValue += '</options>';
        bodyValue += '</bus:searchEvents>';
        bodyValue += '</soap:Body>';
        bodyValue += '</soap:Envelope>';
        if(!Test.isRunningTest()){
            System.enqueueJob(new PraxedoAPICallout('Order__c','', endPoint, method, authorizationToken, soapAction, bodyValue, null));
        }
    }
    
    public static void updateWorkOrder(String body) {
        try {
            
            
            Logger__c log54 = new Logger__c();

            /*
            Logger__c logger = new Logger__c();
            logger.SObject_Type__c = this.objectName;
            if (this.objectName == 'Order__c' && this.soapAction == 'createServiceOrders') {
                logger.Flow_Name__c = 'Create Service Order';
            }
            */

           //System.debug('body57'+body);
            List<String> splitBody = body.split('</entities><entities>');
            //You can find number of work orders by number of occurences of ', <completionData>' OR '</extensions><id>'

            //System.debug('Inside SearchUpdateWorkOrder>>>line75>>>splitBody>>>'+splitBody);
            for (String entity : splitBody) {
                //System.debug('Inside SearchUpdateWorkOrder>>>line77>>>entity>>>'+entity);
            }
            List<Order__c> orderList = new List<Order__c>();
            
            //log54.Log_Details__c=body;
            //log54.Log_Details__c=StriorderList;
            //insert log54;
            Map<Id, PV_System__c> orderIdWithPVSystem = new Map<Id, PV_System__c>();
            List<Logger__c> loggerList = new List<Logger__c>();

            List<String> siteVisitList = new List<String>();
            List<String> inverterInstallationList = new List<String>();
            List<String> batteryInstallationList = new List<String>();
            Integer logcreated = 0;
            List<String> matches = new List<String>();
            for (String entity : splitBody) {
                System.debug('Inside SearchUpdateWorkOrder>>>line95>>>entity>>>'+entity);
                
                
                //Search for Site Visit Work Order
                try{
                    //matches = RegexMatchPattern.run(entity,'<id>([a-z0-9- ]*).*Site Visit</id>');
                    matches = RegexMatchPattern.run(entity,'<id>([a-z0-9-]*) .*Site Visit</id>');
                }
                catch(Exception e)
                {
                
                }
                System.debug('Inside SearchUpdateWorkOrder>>>line101>>>matches>>>'+matches);                
                if(matches.size()>0)    
                {
                    System.debug('Inside SearchUpdateWorkOrder>>>line111>>>matches>>>'+matches);
                    String siteVisitSingle = matches[0];                                                    
                    siteVisitList.add(siteVisitSingle);
                    System.debug('Inside SearchUpdateWorkOrder>>>line114>>>matches>>>'+matches);
                    continue;
                }

                //Search for Inverter Installation Work Order
                try{
                    matches = RegexMatchPattern.run(entity,'<id>([a-z0-9-]*) .*Inverter Installation</id>');
                }   
                catch (Exception e){

                }             
                System.debug('Inside SearchUpdateWorkOrder>>>line112>>>matches>>>'+matches);                
                if(matches.size()>0)    
                {
                    String inverterInstallationSingle = matches[0];
                    inverterInstallationList.add(inverterInstallationSingle);
                    System.debug('Inside SearchUpdateWorkOrder>>>line117>>>matches>>>'+matches);
                    continue;
                }

                //Search for Battery Installation Work Order
                try{
                    matches = RegexMatchPattern.run(entity,'<id>([a-z0-9-]*) .*Battery Installation</id>');
                }
                catch (Exception e){

                }
                System.debug('Inside SearchUpdateWorkOrder>>>line125>>>matches>>>'+matches);                
                if(matches.size()>0)    
                {
                    String batteryInstallationSingle = matches[0];                                                                   
                    batteryInstallationList.add(batteryInstallationSingle);
                    System.debug('Inside SearchUpdateWorkOrder>>>line129>>>matches>>>'+matches);
                    continue;
                }                
            }

            Map<String, Order__c> siteVisitMap = new Map<String, Order__c>([SELECT Id, Name,ProcessID__c FROM Order__c WHERE ProcessID__c IN: siteVisitList]);
            Map<String, Order__c> inverterInstallationMap = new Map<String, Order__c>([SELECT Id, Name,ProcessID__c FROM Order__c WHERE ProcessID__c IN: inverterInstallationList]);
            Map<String, Order__c> batteryInstallationMap = new Map<String, Order__c>([SELECT Id, Name,ProcessID__c FROM Order__c WHERE ProcessID__c IN: batteryInstallationList]);

            
            /*
            //old code related to find work orders based on order id            
            List<Id> orderIds = new List<Id>();
            List<Id> inverterOrderIds = new List<Id>();
            List<Id> batteryOrderIds = new List<Id>();
            for (String a : splitBody) {
                string orderId = a.substringBetween('<id>W-', '</id>');
                orderIds.add(orderId);

                string inverterOrderId = a.substringBetween('<id>WII-', '</id>');
                inverterOrderIds.add(inverterOrderId);

                string batteryOrderId = a.substringBetween('<id>WBI-', '</id>');
                batteryOrderIds.add(batteryOrderId);
            }
            
            Map<Id, Order__c> orderMap = new Map<Id, Order__c>([SELECT Id, Name FROM Order__c WHERE Id IN: orderIds]);
            Map<Id, Order__c> inverterOrderMap = new Map<Id, Order__c>([SELECT Id, Name FROM Order__c WHERE Id IN: inverterOrderIds]);
            Map<Id, Order__c> batteryOrderMap = new Map<Id, Order__c>([SELECT Id, Name FROM Order__c WHERE Id IN: batteryOrderIds]);

            ------Implemented to this point------

            for (String a : splitBody) {
                string orderId = a.substringBetween('<id>W-', '</id>');
                string appointmentDate = a.substringBetween('<appointmentDate>', '</appointmentDate>');
                string schedulingDate= a.substringBetween('<schedulingDate>', '</schedulingDate>');
    
                if (orderId != null && orderId.length() == 18 && !orderMap.isEmpty() && orderMap.containsKey(orderId)) {
                    System.debug('Order71'+orderId);
                    Order__c orderItem = new Order__c();
                    orderItem.Id = orderId;
                    if(appointmentDate != null){
                        string dateV = appointmentDate.split('T')[0];
                        string timev = appointmentDate.substring(appointmentDate.indexOf('T')+1, appointmentDate.indexOf('+'));
                        orderItem.Pre_Installation_Planned__c = DateTime.valueOf(dateV + ' ' + timeV);
                        System.debug('Inside appointment date if block>>>>>'+orderItem.Id+orderItem.Pre_Installation_Planned__c);
                    }
                                         
                    orderList.add(orderItem);                                     
                }

                string inverterOrderId = a.substringBetween('<id>WII-', '</id>');
                string status = a.substringBetween('<status>', '</status>');

                if (inverterOrderId != null && status == 'VALIDATED' && inverterOrderId.length() == 18 && !inverterOrderMap.isEmpty() && inverterOrderMap.containsKey(inverterOrderId)) {
                    PV_System__c pvsystem = new PV_System__c();
                    
                    if (orderIdWithPVSystem.containsKey(inverterOrderId)) {
                        pvsystem = orderIdWithPVSystem.get(inverterOrderId);
                    }
                    string ac_huawei_inverter_1_seriennummer = a.substringBetween('<id>ac_huawei_inverter_1_seriennummer</id>', '</fields>');
                    if (String.isNotBlank(ac_huawei_inverter_1_seriennummer)) {
                        ac_huawei_inverter_1_seriennummer = ac_huawei_inverter_1_seriennummer.substringBetween('<value>', '</value>');
                    }
                    string ac_huawei_inverter_2_seriennummer = a.substringBetween('<id>ac_huawei_inverter_2_seriennummer</id>', '</fields>');
                    if (String.isNotBlank(ac_huawei_inverter_2_seriennummer)) {
                        ac_huawei_inverter_2_seriennummer = ac_huawei_inverter_2_seriennummer.substringBetween('<value>', '</value>');
                    }
                    string ac_fronius_inverter_1_seriennummer = a.substringBetween('<id>ac_fronius_inverter_1_seriennummer</id>', '</fields>');
                    if (String.isNotBlank(ac_fronius_inverter_1_seriennummer)) {
                        ac_fronius_inverter_1_seriennummer = ac_fronius_inverter_1_seriennummer.substringBetween('<value>', '</value>');
                    }
                    string ac_fronius_inverter_2_seriennummer = a.substringBetween('<id>ac_fronius_inverter_2_seriennummer</id>', '</fields>');
                    if (String.isNotBlank(ac_fronius_inverter_2_seriennummer)) {
                        ac_fronius_inverter_2_seriennummer = ac_fronius_inverter_2_seriennummer.substringBetween('<value>', '</value>');
                    }
                    if (String.isNotBlank(ac_fronius_inverter_1_seriennummer)) {
                        pvsystem.Serial_Number_Inverter_Main__c = ac_fronius_inverter_1_seriennummer;
                    } else if (String.isNotBlank(ac_huawei_inverter_1_seriennummer)) {
                        pvsystem.Serial_Number_Inverter_Main__c = ac_huawei_inverter_1_seriennummer;
                    }
                    if (String.isNotBlank(ac_fronius_inverter_2_seriennummer)) {
                        pvsystem.Serial_Number_Inverter_2__c = ac_fronius_inverter_2_seriennummer;
                    } else if (String.isNotBlank(ac_huawei_inverter_2_seriennummer)) {
                        pvsystem.Serial_Number_Inverter_2__c = ac_huawei_inverter_2_seriennummer;
                    }
                    orderIdWithPVSystem.put(inverterOrderId, pvsystem);
                }

                string batteryOrderId = a.substringBetween('<id>WBI-', '</id>');
                string batteryOrderStatus = a.substringBetween('<status>', '</status>');

                if (batteryOrderId != null && batteryOrderStatus == 'VALIDATED' && batteryOrderId.length() == 18 && !batteryOrderMap.isEmpty() && batteryOrderMap.containsKey(batteryOrderId)) {
                    PV_System__c pvsystem = new PV_System__c();
                    
                    if (orderIdWithPVSystem.containsKey(batteryOrderId)) {
                        pvsystem = orderIdWithPVSystem.get(batteryOrderId);
                    }
                    string serial_number_BCU_huawei_1 = a.substringBetween('<id>serial_number_BCU_huawei_1</id>', '</fields>');
                    if (String.isNotBlank(serial_number_BCU_huawei_1)) {
                        serial_number_BCU_huawei_1 = serial_number_BCU_huawei_1.substringBetween('<value>', '</value>');
                    }
                    string serial_number_BCU_byd_1 = a.substringBetween('<id>serial_number_BCU_byd_1</id>', '</fields>');
                    if (String.isNotBlank(serial_number_BCU_byd_1)) {
                        serial_number_BCU_byd_1 = serial_number_BCU_byd_1.substringBetween('<value>', '</value>');
                    }
                    if (String.isNotBlank(serial_number_BCU_byd_1)) {
                        pvsystem.Serial_Number_Battery__c = serial_number_BCU_byd_1;
                    } else if (String.isNotBlank(serial_number_BCU_huawei_1)) {
                        pvsystem.Serial_Number_Battery__c = serial_number_BCU_huawei_1;
                    }
                    
                    orderIdWithPVSystem.put(batteryOrderId, pvsystem);
                }
            }
            if (!orderList.isEmpty()) {
            	System.debug('Inside SearchUpdateWorkOrder>>>Line No. 198>>>orderList>>>'+orderList);	                
                update orderList;
            }
            if (!loggerList.isEmpty()) {
                insert loggerList;
            }
            if (!orderIdWithPVSystem.isEmpty()) {
                system.debug('>> '+orderIdWithPVSystem.keySet());

                List<Order__c> ordList = [Select Id, PV_System__c FROM Order__c WHERE Id IN: orderIdWithPVSystem.keySet()];
                if (!ordList.isEmpty()) {
                    List<PV_System__c> updatePVList = new List<PV_System__c>();
                    for (Order__c ord : ordList) {
                        if (orderIdWithPVSystem.containsKey(ord.Id)) {
                            PV_System__c pv = orderIdWithPVSystem.get(ord.Id);
                            pv.Id = ord.PV_System__c;
                            updatePVList.add(pv);
                        }
                    }
                    if (!updatePVList.isEmpty()) {
                        update updatePVList;
                    }
                }
            }
            */


            



            if (!loggerList.isEmpty()) {
                insert loggerList;
            }
            
        } catch(DmlException ex) {
            Logger__c logger = new Logger__c();
            logger.SObject_Type__c = 'Order__c';
            logger.Flow_Name__c = 'Inside SearchUpdateWorkOrder.cls>>>updateWorkOrder>>>Line No. 297';
            logger.Log_Details__c = 'Exception Found: ' + ex.getMessage() + ' Line No: ' + ex.getLineNumber();
            logger.Log_Details_2__c = body;
            insert logger;
        } catch (Exception ex) {
            Logger__c logger = new Logger__c();
            logger.SObject_Type__c = 'Order__c';
            logger.Flow_Name__c = 'Inside SearchUpdateWorkOrder.cls>>>updateWorkOrder>>>Line No. 303';
            logger.Log_Details__c = 'Exception Found: ' + ex.getMessage() + ' Line No: ' + ex.getLineNumber();
            logger.Log_Details_2__c = body;
            insert logger;
        }
    }
    
    
    //For paginated responses
    public static void searchWorkOrders(Integer firstResultIndex) {
        String bodyValue = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:bus="http://ws.praxedo.com/v6/businessEvent">';
        bodyValue += '<soap:Header/>';
        bodyValue += '<soap:Body>';
        bodyValue += '<bus:searchEvents>';
        bodyValue += '<request>';
        bodyValue += '<dateConstraints>';
        //bodyValue += '<dateRange>'+ Datetime.now().addHours(-1).format('yyyy-MM-dd\'T\'HH:mm:ss') + '</dateRange>';
        //bodyValue += '<dateRange>'+ Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss') + '</dateRange>';
        bodyValue += '<dateRange>'+ Datetime.now().addDays(-1).format('yyyy-MM-dd\'T\'HH:mm:ss') + '</dateRange>';
        bodyValue += '<dateRange>'+ Datetime.now().addDays(1).format('yyyy-MM-dd\'T\'HH:mm:ss') + '</dateRange>';
        bodyValue += '<name>lastModificationDate</name>';
        bodyValue += '</dateConstraints>';
        bodyValue += '</request>';
        bodyValue += '<batchSize>50</batchSize>';
        bodyValue += '<firstResultIndex>'+firstResultIndex+'</firstResultIndex>';
        bodyValue += '<options>';
        bodyValue += '<key>businessEvent.populate.coreData</key>';
        bodyValue += '</options>';
        bodyValue += '<options>';
        bodyValue += '<key>businessEvent.populate.qualificationData</key>';
        bodyValue += '</options>';
        bodyValue += '<options>';
        bodyValue += '<key>businessEvent.populate.completionData.items</key>';
        bodyValue += '</options>';
        bodyValue += '<options>';
        bodyValue += '<key>businessEvent.populate.completionData.items</key>';
        bodyValue += '</options>';
        bodyValue += '<options>';
        bodyValue += '<key>businessEvent.populate.schedulingData</key>';
        bodyValue += '</options>';
        bodyValue += '<options>';
        bodyValue += '<key>businessEvent.populate.completionData.excludeBinaryData</key>';
        bodyValue += '</options>';
        bodyValue += '<options>';
        bodyValue += '<key>businessEvent.feature.status.cancelled</key>';
        bodyValue += '</options>';
        bodyValue += '<options>';
        bodyValue += '<key>businessEvent.populate.completionData.fields</key>';
        bodyValue += '</options>';
        bodyValue += '</bus:searchEvents>';
        bodyValue += '</soap:Body>';
        bodyValue += '</soap:Envelope>';
        if(!Test.isRunningTest()){
            System.enqueueJob(new PraxedoAPICallout('Order__c','', endPoint, method, authorizationToken, soapAction, bodyValue, null,firstResultIndex));
        }
    }
    
    //For paginated responses 
    public static void updateSalesforce(String body, Integer firstResultIndex, Boolean lastBatch) {
        try {
            Logger__c log54 = new Logger__c();
           System.debug('body57'+body);
            List<String> splitBody = body.split('</entities><entities>');
            System.debug('59'+splitBody);
            List<Order__c> orderList = new List<Order__c>();
            
            //log54.Log_Details__c=body;
            //log54.Log_Details__c=StriorderList;
            //insert log54;
            Map<Id, PV_System__c> orderIdWithPVSystem = new Map<Id, PV_System__c>();
            List<Logger__c> loggerList = new List<Logger__c>();

            List<Id> orderIds = new List<Id>();
            List<Id> inverterOrderIds = new List<Id>();
            List<Id> batteryOrderIds = new List<Id>();
            for (String a : splitBody) {
                string orderId = a.substringBetween('<id>W-', '</id>');
                orderIds.add(orderId);

                string inverterOrderId = a.substringBetween('<id>WII-', '</id>');
                inverterOrderIds.add(inverterOrderId);

                string batteryOrderId = a.substringBetween('<id>WBI-', '</id>');
                batteryOrderIds.add(batteryOrderId);
            }
            
            if(orderIds.Size()>0) System.debug('orderIDs>>>>'+orderIds);
			
            log54.Log_Details__c = orderIds.toString()+' xxx '+inverterOrderIds.toString()+' xxx '+batteryOrderIds.toString();
			insert log54;
            
            Map<Id, Order__c> orderMap = new Map<Id, Order__c>([SELECT Id, Name FROM Order__c WHERE Id IN: orderIds]);
            Map<Id, Order__c> inverterOrderMap = new Map<Id, Order__c>([SELECT Id, Name FROM Order__c WHERE Id IN: inverterOrderIds]);
            Map<Id, Order__c> batteryOrderMap = new Map<Id, Order__c>([SELECT Id, Name FROM Order__c WHERE Id IN: batteryOrderIds]);

            for (String a : splitBody) {
                string orderId = a.substringBetween('<id>W-', '</id>');
                string appointmentDate = a.substringBetween('<appointmentDate>', '</appointmentDate>');
                string schedulingDate= a.substringBetween('<schedulingDate>', '</schedulingDate>');
                System.debug('appointmentdate>>>>'+appointmentDate);
                System.debug('schedulingDate>>>>'+schedulingDate);
   
                if (orderId != null && orderId.length() == 18 && !orderMap.isEmpty() && orderMap.containsKey(orderId)) {
                    Order__c orderItem = new Order__c();
                    orderItem.Id = orderId;
                    if(appointmentDate != null){
                        string dateV = appointmentDate.split('T')[0];
                        string timev = appointmentDate.substring(appointmentDate.indexOf('T')+1, appointmentDate.indexOf('+'));
                        // orderItem.Pre_Installation_Actual__c = DateTime.valueOf(dateV + ' ' + timeV);
                        orderItem.Pre_Installation_Planned__c = DateTime.valueOf(dateV + ' ' + timeV);
                        orderItem.Praxedo_Trigger__c=false;
                    	System.debug('Inside appointment date if block>>>>>'+orderItem.Id+orderItem.Pre_Installation_Planned__c);                        
                    }
                   
                    
                    orderList.add(orderItem);
                    
                    Logger__c logger = new Logger__c();
                    logger.SObject_Type__c = 'Order__c';
                    logger.Flow_Name__c = 'Update Order from Praxedo Work Order';
                    // logger.Log_Details__c = 'Order ID'+ orderItem.Id + 'Pre Planned' + orderItem.Pre_Installation_Planned__c + 'Pre Actual'+orderItem.Pre_Installation_Actual__c;
                    logger.Log_Details__c = 'Order ID'+ orderItem.Id + 'Pre Planned' + orderItem.Pre_Installation_Planned__c;

                    loggerList.add(logger);
                }
				
                string inverterOrderId = a.substringBetween('<id>WII-', '</id>');
                string status = a.substringBetween('<status>', '</status>');

                if (inverterOrderId != null && status == 'VALIDATED' && inverterOrderId.length() == 18 && !inverterOrderMap.isEmpty() && inverterOrderMap.containsKey(inverterOrderId)) {
                    PV_System__c pvsystem = new PV_System__c();
                    
                    if (orderIdWithPVSystem.containsKey(inverterOrderId)) {
                        pvsystem = orderIdWithPVSystem.get(inverterOrderId);
                    }
                    // string ac_huawei_inverter_1_seriennummer = a.substringBetween('<id>ac_huawei_inverter_1_seriennummer</id><value>', '</value>');
                    // string ac_huawei_inverter_2_seriennummer = a.substringBetween('<id>ac_huawei_inverter_2_seriennummer</id><value>', '</value>');
                    // string ac_fronius_inverter_1_seriennummer = a.substringBetween('<id>ac_fronius_inverter_1_seriennummer</id><value>', '</value>');
                    // string ac_fronius_inverter_2_seriennummer = a.substringBetween('<id>ac_fronius_inverter_2_seriennummer</id><value>', '</value>');
                    string ac_huawei_inverter_1_seriennummer = a.substringBetween('<id>ac_huawei_inverter_1_seriennummer</id>', '</fields>');
                    if (String.isNotBlank(ac_huawei_inverter_1_seriennummer)) {
                        ac_huawei_inverter_1_seriennummer = ac_huawei_inverter_1_seriennummer.substringBetween('<value>', '</value>');
                    }
                    string ac_huawei_inverter_2_seriennummer = a.substringBetween('<id>ac_huawei_inverter_2_seriennummer</id>', '</fields>');
                    if (String.isNotBlank(ac_huawei_inverter_2_seriennummer)) {
                        ac_huawei_inverter_2_seriennummer = ac_huawei_inverter_2_seriennummer.substringBetween('<value>', '</value>');
                    }
                    string ac_fronius_inverter_1_seriennummer = a.substringBetween('<id>ac_fronius_inverter_1_seriennummer</id>', '</fields>');
                    if (String.isNotBlank(ac_fronius_inverter_1_seriennummer)) {
                        ac_fronius_inverter_1_seriennummer = ac_fronius_inverter_1_seriennummer.substringBetween('<value>', '</value>');
                    }
                    string ac_fronius_inverter_2_seriennummer = a.substringBetween('<id>ac_fronius_inverter_2_seriennummer</id>', '</fields>');
                    if (String.isNotBlank(ac_fronius_inverter_2_seriennummer)) {
                        ac_fronius_inverter_2_seriennummer = ac_fronius_inverter_2_seriennummer.substringBetween('<value>', '</value>');
                    }
                    if (String.isNotBlank(ac_fronius_inverter_1_seriennummer)) {
                        pvsystem.Serial_Number_Inverter_Main__c = ac_fronius_inverter_1_seriennummer;
                    } else if (String.isNotBlank(ac_huawei_inverter_1_seriennummer)) {
                        pvsystem.Serial_Number_Inverter_Main__c = ac_huawei_inverter_1_seriennummer;
                    }
                    if (String.isNotBlank(ac_fronius_inverter_2_seriennummer)) {
                        pvsystem.Serial_Number_Inverter_2__c = ac_fronius_inverter_2_seriennummer;
                    } else if (String.isNotBlank(ac_huawei_inverter_2_seriennummer)) {
                        pvsystem.Serial_Number_Inverter_2__c = ac_huawei_inverter_2_seriennummer;
                    }
                    orderIdWithPVSystem.put(inverterOrderId, pvsystem);
                }

                string batteryOrderId = a.substringBetween('<id>WBI-', '</id>');
                string batteryOrderStatus = a.substringBetween('<status>', '</status>');

                if (batteryOrderId != null && batteryOrderStatus == 'VALIDATED' && batteryOrderId.length() == 18 && !batteryOrderMap.isEmpty() && batteryOrderMap.containsKey(batteryOrderId)) {
                    PV_System__c pvsystem = new PV_System__c();
                    if (orderIdWithPVSystem.containsKey(batteryOrderId)) {
                        pvsystem = orderIdWithPVSystem.get(batteryOrderId);
                    }
                    string serial_number_BCU_huawei_1 = a.substringBetween('<id>serial_number_BCU_huawei_1</id>', '</fields>');
                    if (String.isNotBlank(serial_number_BCU_huawei_1)) {
                        serial_number_BCU_huawei_1 = serial_number_BCU_huawei_1.substringBetween('<value>', '</value>');
                    }
                    string serial_number_BCU_byd_1 = a.substringBetween('<id>serial_number_BCU_byd_1</id>', '</fields>');
                    if (String.isNotBlank(serial_number_BCU_byd_1)) {
                        serial_number_BCU_byd_1 = serial_number_BCU_byd_1.substringBetween('<value>', '</value>');
                    }
                    if (String.isNotBlank(serial_number_BCU_byd_1)) {
                        pvsystem.Serial_Number_Battery__c = serial_number_BCU_byd_1;
                    } else if (String.isNotBlank(serial_number_BCU_huawei_1)) {
                        pvsystem.Serial_Number_Battery__c = serial_number_BCU_huawei_1;
                    }
                    
                    orderIdWithPVSystem.put(batteryOrderId, pvsystem);
                }
            }
            
            //Print Order Records to Update
            System.debug(orderList);
            
            if (!orderList.isEmpty()) {
            	System.debug('427>>>>>>'+orderList);                
                update orderList;
            }
            System.debug('430>>>>>>'+orderList);                

            Order__c testorder = [Select id,Pre_Installation_Planned__c from Order__c where id='a001x00000B8nj8AAB'];
            System.debug('433>>>>>>'+testorder);
            
            if (!loggerList.isEmpty()) {
                insert loggerList;
            }
            if (!orderIdWithPVSystem.isEmpty()) {
                system.debug('>> '+orderIdWithPVSystem.keySet());

                List<Order__c> ordList = [Select Id, PV_System__c FROM Order__c WHERE Id IN: orderIdWithPVSystem.keySet()];
                if (!ordList.isEmpty()) {
                    List<PV_System__c> updatePVList = new List<PV_System__c>();
                    for (Order__c ord : ordList) {
                        if (orderIdWithPVSystem.containsKey(ord.Id)) {
                            PV_System__c pv = orderIdWithPVSystem.get(ord.Id);
                            pv.Id = ord.PV_System__c;
                            updatePVList.add(pv);
                        }
                    }
                    if (!updatePVList.isEmpty()) {
                        update updatePVList;
                    }
                }
            }
            //this.firstResultIndex = 0;
            firstResultIndex = firstResultIndex+50;
            //Get next batch
            if(!lastBatch) searchWorkOrders(firstResultIndex);
            
        } catch(DmlException ex) {
            Logger__c logger = new Logger__c();
            logger.SObject_Type__c = 'Order__c';
            logger.Flow_Name__c = 'Inside SearchUpdateWorkOrder.cls>>>updateWorkOrder2>>>Line No. 537';
            logger.Log_Details__c = 'Exception Found: ' + ex.getMessage() + ' Line No: ' + ex.getLineNumber();
            logger.Log_Details_2__c = body;
            insert logger;
        } catch (Exception ex) {
            Logger__c logger = new Logger__c();
            logger.SObject_Type__c = 'Order__c';
            logger.Flow_Name__c = 'Inside SearchUpdateWorkOrder.cls>>>updateWorkOrder2>>>Line No. 544';
            logger.Log_Details__c = 'Exception Found: ' + ex.getMessage() + ' Line No: ' + ex.getLineNumber();
            logger.Log_Details_2__c = body;
            insert logger;
        }
    }
    public void execute(SchedulableContext sc){       
        searchWorkOrders(0);
    }
}