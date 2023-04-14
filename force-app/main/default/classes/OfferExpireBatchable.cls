public with sharing class OfferExpireBatchable implements Database.Batchable<SObject> {

    @InvocableMethod
    public static void callOpportunityBatch(List<List<Opportunity>> OpportunityList) {
        try {
            if (!OpportunityList.isEmpty()) {
                Database.executeBatch(new OfferExpireBatchable(OpportunityList[0]), 10);
            }
        } catch (Exception ex) {
            throw ex;
        }
        
    }

    public List<Opportunity> OpportunityList = new List<Opportunity>();
    public OfferExpireBatchable(List<Opportunity> OpportunityList) {
        try {
            if (!OpportunityList.isEmpty()) {
                this.OpportunityList = OpportunityList;   
            }
        } catch (Exception ex) {
            throw ex;
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        try {
            List<String> oppIds = new List<String>();
            if (!this.OpportunityList.isEmpty()) {
                for (Opportunity opp: this.OpportunityList) {
                    oppIds.add(opp.Id);
                }
            }
            String query = 'SELECT Id, Name, AccountId, OwnerId, Owner.Email, Offer_Expiry_Date__c, Account.PersonContactId, Account.PersonEmail FROM Opportunity WHERE Id IN: oppIds';
            return Database.getQueryLocator(query);
        } catch (Exception ex) {
            throw ex;
        }
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> oppList) {
        try {
            
            Map<String, String> owdMap = new Map<String, String>();
            for (OrgWideEmailAddress owd: [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress]) {
                owdMap.put(owd.Address, owd.Id);
            }

            List<Task> taskList = new List<Task>();
            for (Opportunity opp: oppList) {
                Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'C_Reminder_Expiration_Date_1656064340608'].Id;
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId, opp.Account.PersonContactId, opp.Id);
                email.setToAddresses(new List<String>{opp.Account.PersonEmail});
                email.setWhatId(opp.Id);
                if (owdMap.containsKey(opp.Owner.Email)) {
                    email.setOrgWideEmailAddressId(owdMap.get(opp.Owner.Email));
                } else if (owdMap.containsKey('exciting@sunvigo.de')) {
                    email.setOrgWideEmailAddressId(owdMap.get('exciting@sunvigo.de'));
                }
                try {
                    List<Messaging.SendEmailResult> sendResult = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
                    System.debug('sendResult>>>' + sendResult);
                } catch (Exception ex) {
                    System.debug('ex>>>' + ex);
                }
            }
        } catch (Exception ex) {
            throw ex;
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}