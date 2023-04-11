List<FlowPraxedoInputModal> praxedoInputList = new List<FlowPraxedoInputModal>();
FlowPraxedoInputModal praxedoInputSingle = new FlowPraxedoInputModal();
praxedoInputSingle.accountId = '0011x00001eheesAAA';
praxedoInputSingle.pvSystemId='a011x000008H4JNAA0';
praxedoInputSingle.orderId = 'a001x00000B8nj8AAB';
praxedoInputList.add(praxedoInputSingle);
CreateCustomer.generateCustomer(praxedoInputList);
//CreateWorkOrder.generateWorkOrder(praxedoInputList);