public with sharing class PraxedoAPICallout implements Queueable, Database.AllowsCallouts {
    public String objectName = '';
    public String rId = '';
    public String endPoint = '';
    public String method = '';
    public String authorizationToken = '';
    public String soapAction = '';
    public List<String> bodyValue = new List<String>();
    public List<FlowPraxedoInputModal> praxedoInput;
    public Integer firstResultIndex=0;
    
    
    
    
    public PraxedoAPICallout(String objectName, String rId, String endPoint, String method, String authorizationToken, String soapAction, String bodyValue, List<FlowPraxedoInputModal> praxedoInput) {
        this.objectName = objectName;
        this.rId = rId;
        this.endPoint = endPoint;
        this.method = method;
        this.authorizationToken = authorizationToken;
        this.soapAction = soapAction;
        this.bodyValue.add(bodyValue);
        this.praxedoInput = praxedoInput;
    }
    
    public PraxedoAPICallout(String objectName, String rId, String endPoint, String method, String authorizationToken, String soapAction, List<String> bodyValue, List<FlowPraxedoInputModal> praxedoInput) {
        this.objectName = objectName;
        this.rId = rId;
        this.endPoint = endPoint;
        this.method = method;
        this.authorizationToken = authorizationToken;
        this.soapAction = soapAction;
        this.bodyValue = bodyValue;
        this.praxedoInput = praxedoInput;
    }
    
    //With First Index
    public PraxedoAPICallout(String objectName, String rId, String endPoint, String method, String authorizationToken, String soapAction, String bodyValue, List<FlowPraxedoInputModal> praxedoInput, Integer firstResultIndex) {
        this.objectName = objectName;
        this.rId = rId;
        this.endPoint = endPoint;
        this.method = method;
        this.authorizationToken = authorizationToken;
        this.soapAction = soapAction;
        this.bodyValue.add(bodyValue);
        this.praxedoInput = praxedoInput;
        this.firstResultIndex=firstResultIndex;
    }

    public void execute(QueueableContext context) {
        
        if (this.bodyValue.size() > 0) {
            string body = this.bodyValue.get(0);
            HTTP h = new HTTP();
            HTTPRequest req = new HTTPRequest();
            req.setEndpoint(this.endPoint);
            req.setMethod(this.method);
            req.setTimeout(120000);

            req.setHeader('Authorization', 'Basic ' + this.authorizationToken);
            req.setHeader('Content-Type', 'text/xml');
            req.setHeader('SOAPAction', this.soapAction);
            
            System.debug('req>>>body>>>' + body);
            req.setBodyAsBlob(Blob.valueOf(body));
            System.debug('Blob48'+Blob.valueOf(body));
            
            //Print firstIndexResult
            System.debug('firstIndexResult>>>>>>'+this.firstResultIndex);
            //Logger__c log72 = new Logger__c();
            //log72.Log_Details__c=String.valueOf(firstResultIndex);
            //insert log72;

            
            HTTPResponse res = h.send(req);
            //System.debug('req50>>' + req);
            String resBody = res.getBody();

            //Print request body to logger
            Logger__c log71 = new Logger__c();
            log71.Log_Details__c=body;
            insert log71;            
        
            /*Logger__c log54 = new Logger__c();
            log54.Log_Details__c=resBody;
            insert log54;*/
            //System.debug('res2>>>body>>>' + resBody);
            System.debug('Inside PraxedoAPICallout.apxc>>>SOAPAction>>>'+this.soapAction);
            Boolean successResult = resBody.containsIgnoreCase('<resultCode>0</resultCode>');
            Boolean successResultWithMorePages = resBody.containsIgnoreCase('<resultCode>200</resultCode>');
            String objectId = resBody.substringBetween('<id>', '</id>');       
            if ((this.soapAction == 'searchEvents') && successResultWithMorePages) {                
                if (this.objectName == 'Order__c') {                    
                    SearchUpdateWorkOrder.updateSalesforce(resBody,this.firstResultIndex, false);                    
                }
            }
            else if (this.soapAction == 'searchEvents') {
                
                if (this.objectName == 'Order__c') {                    
                    SearchUpdateWorkOrder.updateSalesforce(resBody,this.firstResultIndex, true);                    
                    
                }
            } else if (successResult && String.isNotBlank(objectId) && objectId.containsIgnoreCase(this.rId)) {
                if (this.objectName == 'Order__c') {
                    // Order__c ord = new Order__c();
                    // ord.Id = this.rId;
                    if (this.soapAction == 'createServiceOrders') {
                        System.debug('Inside PraxedoAPICallout.apxc>>>Line No. 99>>>'+this.soapAction);
                        CreateWorkOrder.generateWorkOrder(this.praxedoInput);
                        // ord.Is_Service_Order_Craeted__c = true;
                        // update ord;
                    } 
                    // else if (this.soapAction == 'createEvents') {
                    //     ord.Work_Order_Created__c= true;
                    //     update ord;
                    // }
                } else if (this.objectName == 'Account') {
                    if (this.soapAction == 'createCustomers' && !Test.isRunningTest()) {
                        CreateLocation.generateLocation(this.praxedoInput);
                    } else if (this.soapAction == 'createLocations') {
                        CreateEquipment.generateEquipment(this.praxedoInput);
                    }
                } else if (this.objectName == 'PV_System__c') {
                    if (this.soapAction == 'createEquipments') {
                        CreateServiceOrder.generateServiceOrder(this.praxedoInput);
                    }
                }
            }

            //Print response body to Logger
            Logger__c logger = new Logger__c();
            logger.SObject_Type__c = this.objectName;
            if (this.objectName == 'Order__c' && this.soapAction == 'createServiceOrders') {
                logger.Flow_Name__c = 'Create Service Order';
            } else if (this.objectName == 'Order__c' && this.soapAction == 'createEvents') {
                logger.Flow_Name__c = 'Create Work Order';
            } else if (this.objectName == 'Order__c' && this.soapAction == 'searchEvents') {
                logger.Flow_Name__c = 'Search Event';
            } else if (this.objectName == 'Account' && this.soapAction == 'createCustomers') {
                logger.Flow_Name__c = 'Create Customer';
            } else if (this.objectName == 'Account' && this.soapAction == 'createLocations') {
                logger.Flow_Name__c = 'Create Location';
            } else if (this.objectName == 'PV_System__c' && this.soapAction == 'createEquipments') {
                logger.Flow_Name__c = 'Create Equipment';
            }
            if(resBody.length() > 131071){
                logger.Log_Details__c = resBody.substring(0, 131071);
            } else {
                logger.Log_Details__c = resBody;
            }
            
            insert logger;
            this.bodyValue.remove(0);
            if (this.bodyValue.size() > 0) {
                System.enqueueJob(new PraxedoAPICallout(this.objectName, this.rId, this.endPoint, this.method, this.authorizationToken, this.soapAction, this.bodyValue, this.praxedoInput));
            }
        }
        
    }    
}