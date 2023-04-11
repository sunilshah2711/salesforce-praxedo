/*
List<FlowPraxedoInputModal> praxedoInputList = new List<FlowPraxedoInputModal>();
FlowPraxedoInputModal praxedoInputSingle = new FlowPraxedoInputModal();
praxedoInputSingle.accountId = '0011x00001eheesAAA';
praxedoInputSingle.pvSystemId='a011x000008H4JNAA0';
praxedoInputSingle.orderId = 'a001x00000B8nj8AAB';
praxedoInputList.add(praxedoInputSingle);
CreateCustomer.generateCustomer(praxedoInputList);
//CreateWorkOrder.generateWorkOrder(praxedoInputList);
*/

List<FlowPraxedoInputModal> praxedoInputList = new List<FlowPraxedoInputModal>();
FlowPraxedoInputModal praxedoInputSingle = new FlowPraxedoInputModal();
Order__c order = new Order__c();
order.Account_Name__c = '0011x00001eheesAAA';
order.Praxedo_Trigger__c = true;
order.Partner_Primary__c ='0011x00001ej55YAAQ';
order.PV_System__c='a011x000008GqlIAAS';
order.ProcessID__c='qwe-128';
order.Quality_Gate_1__c=true;
DateTime dt = System.now();
order.Pre_Installation_Planned__c = dt;
order.Start_of_DC_Installation_Planned__c=dt;
order.StartOfInstallationPlanned__c=Date.today();
order.Start_of_AC_Installation_Planned__c=Date.today();
insert order;
praxedoInputSingle.accountId = '0011x00001eheesAAA';
praxedoInputSingle.pvSystemId='a011x000008GqlIAAS';
praxedoInputSingle.orderId = order.id;
praxedoInputList.add(praxedoInputSingle);
CreateCustomer.generateCustomer(praxedoInputList);
//CreateWorkOrder.generateWorkOrder(praxedoInputList);