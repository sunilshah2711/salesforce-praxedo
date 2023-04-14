public without sharing class PullfromPraxedo implements Schedulable {

    public static String endPoint = 'https://ws-eu9.praxedo.com/eTech/services/cxf/v6/BusinessEventManager';
    public static String method = 'POST';
    public static String authorizationToken = 'V1NfU3VudmlnbzpMNlBmOU1YJGtqaWRLRGJq';
    public static String soapAction = 'searchEvents';
    public Integer firstResultIndex=0;
    public static String errorTemplate = 'Inside PullfromPraxedo.cls>>>Line No. ';

    //Search for Work Orders that are modified since last pull
    public static String prepareRequest(Integer firstResultIndex) {
        String bodyValue = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:bus="http://ws.praxedo.com/v6/businessEvent">';
        bodyValue += '<soap:Header/>';
        bodyValue += '<soap:Body>';
        bodyValue += '<bus:searchEvents>';
        bodyValue += '<request>';
        bodyValue += '<dateConstraints>';
        //bodyValue += '<dateRange>'+ Datetime.now().addHours(-1).format('yyyy-MM-dd\'T\'HH:mm:ss') + '</dateRange>';
        //bodyValue += '<dateRange>'+ Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss') + '</dateRange>';
        bodyValue += '<dateRange>'+ Datetime.now().addDays(-4).format('yyyy-MM-dd\'T\'HH:mm:ss') + '</dateRange>';
        bodyValue += '<dateRange>'+ Datetime.now().addDays(-2).format('yyyy-MM-dd\'T\'HH:mm:ss') + '</dateRange>';
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
        return bodyValue;
        
    }
    
    //Update Salesforce based on the data in modified Work Orders in Praxedo
    public static void updateSalesforce(String body, Integer firstResultIndex, Boolean moreBatches) {

        System.debug('Inside PullfromPraxedo>>>Line No.>>>61');

        try {
            
            //Split the response into entities as each entity corresponds to a work order            
            List<String> entityList = body.split('</entities><entities>');
            System.debug(entityList);
            //You can find number of work orders by number of occurences of ', <completionData>' OR '</extensions><id>'
            
            //Prepare the Process ID list that can be used in the next step to fetch the related Orders, to avoid multiple read API calls
            List<String> processIdList = new List<String>();            
            processIdList = prepareProcessIdList(entityList);
            System.debug(errorTemplate+'Line No. 73'+processIdList);
            /*
            (qwe-128, qwe-127, qwe-126, qwe-125, qwe-124, qwe-123, null)
            */


            //Fetch all the Orders based on the Process ID List
            List<Order__c> orderList = OrderModel.findByProcessId(processIdList);
            System.debug(orderList);
            /*
            (Order__c:{Id=a001x00000CSIZtAAP, Name=a001x00000CSIZt, ProcessID__c=qwe-123}, Order__c:{Id=a001x00000CSIaDAAX, Name=a001x00000CSIaD, ProcessID__c=qwe-124}, Order__c:{Id=a001x00000CSIaXAAX, Name=a001x00000CSIaX, ProcessID__c=qwe-126}, Order__c:{Id=a001x00000CSIaIAAX, Name=a001x00000CSIaI, ProcessID__c=qwe-125}, Order__c:{Id=a001x00000CSIbLAAX, Name=a001x00000CSIbL, ProcessID__c=qwe-128}, Order__c:{Id=a001x00000CSIbBAAX, Name=a001x00000CSIbB, ProcessID__c=qwe-127})
            */


            //Loop through Entity List again to Update the Order and PV System Records fetched from Salesforce based on the modified data in Praxedo
            updateOrderPVSystemRecords(entityList,orderList);                                               

            //Increase the index by 50 to fetch the next batch
            firstResultIndex = firstResultIndex+50;

            //Fetch the next set of Work Orders
            if(moreBatches) {

                //Prepare Request
                String request = prepareRequest(firstResultIndex);
                
                //Call Praxedo API
                if(!Test.isRunningTest()){
                    System.enqueueJob(new PraxedoAPICallout('Order__c','', endPoint, method, authorizationToken, soapAction, request, null,firstResultIndex));
                }
            }
        } catch(DmlException ex) {
            Logger__c logger = new Logger__c();
            logger.SObject_Type__c = 'Order__c';
            logger.Flow_Name__c = 'Inside PullfromPraxedo.cls>>>updateWorkOrder>>>Line No. 297';
            logger.Log_Details__c = 'Exception Found: ' + ex.getMessage() + ' Line No: ' + ex.getLineNumber();
            logger.Log_Details_2__c = body;
            insert logger;
        } catch (Exception ex) {
            Logger__c logger = new Logger__c();
            logger.SObject_Type__c = 'Order__c';
            logger.Flow_Name__c = 'Inside PullfromPraxedo.cls>>>updateWorkOrder>>>Line No. 303';
            logger.Log_Details__c = 'Exception Found: ' + ex.getMessage() + ' Line No: ' + ex.getLineNumber();
            logger.Log_Details_2__c = body;
            insert logger;
        }
    }
    
   
    
    public void execute(SchedulableContext sc){       
        //Prepare Request
        String request = prepareRequest(0);
            
        //Call Praxedo API
        if(!Test.isRunningTest()){
            System.enqueueJob(new PraxedoAPICallout('Order__c','', endPoint, method, authorizationToken, soapAction, request, null,firstResultIndex));
        }
    }

    public static void executeStatic(Integer firstResultIndex){       
        //Prepare Request
        String request = prepareRequest(firstResultIndex);
            
        //Call Praxedo API
        if(!Test.isRunningTest()){
            System.enqueueJob(new PraxedoAPICallout('Order__c','', endPoint, method, authorizationToken, soapAction, request,null,firstResultIndex));
        }
    }

    public static List<String> prepareProcessIdList(List<String> entityList)
    {   
        List<String> outputList = new List<String>();
        List<String> siteVisitList = new List<String>();
        List<String> inverterInstallationList = new List<String>();
        List<String> batteryInstallationList = new List<String>();
        Integer logcreated = 0;
        String match;


        for (String entity : entityList) {                       
            //Search for Site Visit Work Order
            try{
                //matches = RegexMatchPattern.run(entity,'<id>([a-z0-9- ]*).*Site Visit</id>');
                match = RegexMatchPattern.findOne(entity,'<id>([a-z0-9-]*) .*Site Visit</id>');
                if(!outputList.contains(match)) outputList.add(match);
                continue;
            }
            catch(Exception e)
            {
                
            }

            //Search for Inverter Installation Work Order
            try{
                match = RegexMatchPattern.findOne(entity,'<id>([a-z0-9-]*) .*Inverter Installation</id>');
                if(!outputList.contains(match)) outputList.add(match);
                continue;
            }   
            catch (Exception e){

            }     

            //Search for Battery Installation Work Order
            try{
                match = RegexMatchPattern.findOne(entity,'<id>([a-z0-9-]*) .*Battery Installation</id>');
                if(!outputList.contains(match)) outputList.add(match);
                continue;                
            }
            catch (Exception e){

            }                       
        }

        //Return Output List
        return outputList;
    }

    public static Order__c fetchOrder(List<Order__c> orderList,String processId)
    {        
        //System.debug(errorTemplate+'168'+orderList+processId);
        for(Order__c order:orderList)
        {
            if(order.ProcessID__c==processId){
                System.debug(errorTemplate+'172>>>match found');
                return order;
            }            
            
        }
        return null;
    }   

    public static void updateOrderPVSystemRecords(List<String> entityList, List<Order__c> orderListArg)
    {
        List<String> outputList = new List<String>();
        List<String> siteVisitList = new List<String>();
        List<String> inverterInstallationList = new List<String>();
        List<String> batteryInstallationList = new List<String>();
        Integer logcreated = 0;

        //Initialize the Order record list for updating if need be
        List<Order__c> orderList = new List<Order__c>();

        //Initialize the PV System record list for updating if need be
        List<PV_System__c> pvSystemList = new List<PV_System__c>();


        for (String entity : entityList) {   
            String processId;
            String appointmentDate;
            String schedulingDate;
            String status;
            string ac_huawei_inverter_1_seriennummer;
            string ac_huawei_inverter_2_seriennummer;
            string ac_fronius_inverter_1_seriennummer;
            string ac_fronius_inverter_2_seriennummer;
            Order__c orderSingle = new Order__c();
            PV_System__c pvSystem = new PV_System__c();

                    
            try{

                //Search for Site Visit Work Order
                processId = RegexMatchPattern.findOne(entity,'<id>([a-z0-9-]*) .*Site Visit</id>');                
                appointmentDate = RegexMatchPattern.findOne(entity,'<appointmentDate>(.*)</appointmentDate>');                
                schedulingDate = RegexMatchPattern.findOne(entity,'<schedulingDate>(.*)</schedulingDate>');                

                if(processId.length()>0 &&  appointmentDate.length()>0)
                {
                    processId = RegexMatchPattern.findOne(entity,'<id>([a-z0-9-]*) .*Site Visit</id>');                

                    //Create a Single Order record to be added to list
                    orderSingle.Id = fetchOrderId(orderListArg,processId);

                    
                    string dateV = appointmentDate.split('T')[0];
                    string timev = appointmentDate.substring(appointmentDate.indexOf('T')+1, appointmentDate.indexOf('+'));
                    orderSingle.Pre_Installation_Planned__c = DateTime.valueOf(dateV + ' ' + timeV);                                            
                    
                    //Add to orderList to be updated after the for loop
                    orderList.add(orderSingle); 
                    System.debug(errorTemplate+'254'+orderList);
                    continue;
                }
            } 

            catch (Exception e){}
            
            
            //Search for Inverter Installation Work Order
            try{
            processId = RegexMatchPattern.findOne(entity,'<id>([a-z0-9-]*) .*Inverter Installation</id>');
            status = RegexMatchPattern.findOne(entity,'<status>(.*)</status>');
            //System.debug(errorTemplate+'266'+processId+status+pvSystemList);                         
            if (processId.length()>0 && status == 'VALIDATED') {
                System.debug(errorTemplate+'268'+processId+status+pvSystemList);             
                //Create a Single Order record to be added to list
                orderSingle = new Order__c();
                orderSingle = fetchOrder(orderListArg,processId); 
                System.debug(errorTemplate+'272'+orderSingle);                
                pvSystem = new PV_System__c();
                pvSystem.Id = orderSingle.PV_System__c;
                System.debug(errorTemplate+'274'+pvSystem);             
                ac_huawei_inverter_1_seriennummer = RegexMatchPattern.findOne(entity,'<id>ac_huawei_inverter_1_seriennummer</id>.*?<value>(.*?)</value>.*?</fields>');                    
                ac_huawei_inverter_2_seriennummer = RegexMatchPattern.findOne(entity,'<id>ac_huawei_inverter_2_seriennummer</id>.*?<value>(.*)</value>.*?</fields>');
                ac_fronius_inverter_1_seriennummer = RegexMatchPattern.findOne(entity,'<id>ac_fronius_inverter_1_seriennummer</id>.*?<value>(.*)</value>.*?</fields>');
                ac_fronius_inverter_2_seriennummer = RegexMatchPattern.findOne(entity,'<id>ac_fronius_inverter_2_seriennummer</id>.*?<value>(.*?)</value>.*?</fields>');
                
                if (ac_fronius_inverter_1_seriennummer.length()>0) pvSystem.Serial_Number_Inverter_Main__c = ac_fronius_inverter_1_seriennummer;
                if (ac_huawei_inverter_1_seriennummer.length()>0 && !(ac_fronius_inverter_1_seriennummer.length()>0))  pvSystem.Serial_Number_Inverter_Main__c = ac_huawei_inverter_1_seriennummer;                    
                if (ac_fronius_inverter_2_seriennummer.length()>0) pvSystem.Serial_Number_Inverter_2__c = ac_fronius_inverter_2_seriennummer;
                if (ac_huawei_inverter_2_seriennummer.length()>0 && !(ac_fronius_inverter_2_seriennummer.length()>0))  pvSystem.Serial_Number_Inverter_2__c = ac_huawei_inverter_2_seriennummer;

                //Update PV System Record List
                pvSystemList.add(pvsystem);
                System.debug(errorTemplate+'285'+pvSystemList);
                continue;
            }
            }
            catch (Exception e){}     

                    
            //Search for Battery Installation Work Order
            try {
                processId = RegexMatchPattern.findOne(entity,'<id>([a-z0-9-]*) .*Battery Installation</id>');
                status = RegexMatchPattern.findOne(entity,'<status>(.*)</status>');
                //System.debug(errorTemplate+'298'+processId+status+pvSystemList);                         
                if (processId.length()>0 && status == 'VALIDATED') {
                    System.debug(errorTemplate+'300'+processId+status+pvSystemList);                         
                    //Create a Single Order record to be added to list
                    orderSingle = new Order__c();
                    orderSingle = fetchOrder(orderListArg,processId); 
                    pvSystem = new PV_System__c();
                    pvSystem.Id = orderSingle.PV_System__c;
                    System.debug(errorTemplate+'306'+pvSystem);             
                    string serial_number_BCU_huawei_1 = RegexMatchPattern.findOne(entity,'<id>serial_number_BCU_huawei_1</id>.*?<value>(.*?)</value>.*?</fields>');                    
                    string serial_number_BCU_byd_1 = RegexMatchPattern.findOne(entity,'<id>serial_number_BCU_byd_1</id>.*?<value>(.*?)</value>.*?</fields>');
                    
                    if (serial_number_BCU_huawei_1.length()>0) pvSystem.Serial_Number_Battery__c = serial_number_BCU_huawei_1;
                    if (serial_number_BCU_byd_1.length()>0 && !(serial_number_BCU_huawei_1.length()>0))  pvSystem.Serial_Number_Battery__c = serial_number_BCU_byd_1;

                    //Update PV System Record List
                    pvSystemList.add(pvsystem);       
                    System.debug(errorTemplate+'313'+pvSystemList);             
                    continue;                
                }                                
            }
            catch (Exception e){}                       
        }


        
        System.debug('Inside PullfromPraxedo.cls>>>Line 283>>>orders to be updated>>>'+orderList);

         //Update Order records as per the latest data in Praxedo
         if(!orderList.isEmpty()) OrderModel.updateRecords(orderList);

         //Update PV System records as per the latest data in Praxedo
         if(!pvSystemList.isEmpty()) PVSystemModel.updateRecords(pvSystemList);
    }



    /*
    //For paginated responses 
    public static void updateSalesforceOld(String body, Integer firstResultIndex, Boolean lastBatch) {
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
            logger.Flow_Name__c = 'Inside PullfromPraxedo.cls>>>updateWorkOrder2>>>Line No. 537';
            logger.Log_Details__c = 'Exception Found: ' + ex.getMessage() + ' Line No: ' + ex.getLineNumber();
            logger.Log_Details_2__c = body;
            insert logger;
        } catch (Exception ex) {
            Logger__c logger = new Logger__c();
            logger.SObject_Type__c = 'Order__c';
            logger.Flow_Name__c = 'Inside PullfromPraxedo.cls>>>updateWorkOrder2>>>Line No. 544';
            logger.Log_Details__c = 'Exception Found: ' + ex.getMessage() + ' Line No: ' + ex.getLineNumber();
            logger.Log_Details_2__c = body;
            insert logger;
        }
    }
    */

    /*
    public static void searchWorkOrder() {
        System.debug('Called>>>PullfromPraxedo.searchWorkOrder()');

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
    */





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
            	System.debug('Inside PullfromPraxedo>>>Line No. 198>>>orderList>>>'+orderList);	                
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
}
