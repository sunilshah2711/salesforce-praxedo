AND(NOT(ISBLANK({!$Record.Grid_Inquiry_Submitted__c})),OR(ISNEW(),ISCHANGED(!$Record.Grid_Inquiry_Submitted__c)))

AND(NOT(ISBLANK({!$Record.Grid_Inquiry_Submitted__c})),OR(ISNEW(),ISCHANGED({!$Record.Grid_Inquiry_Submitted__c})))

