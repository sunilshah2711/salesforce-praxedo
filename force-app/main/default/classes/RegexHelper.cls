public class RegexHelper {
	public static void Regex()
    {
        Logger__c log = new Logger__c();
        //https://sunvigo--leadfilter.sandbox.lightning.force.com/lightning/r/Logger__c/a1O1x0000057MpREAU/view
        log = [Select log_details__c from Logger__c where id='a1O1x0000057MpREAU'];
        System.debug('test');
        String s = '(das Verhalten).*?<\\/table>.*?<\\/table>(.*)<table';
        String matchString = '<span style="font-weight: 600"> <i18n-string data-key="mixins.label" data-locale-at-render="en">... das Verhalten?</i18n-string> </span><table border="0" cellpadding="0" cellspacing="0" width="100%" style="font-size: 0; height: 10px; width: 100%; min-width: 100%; line-height: 0;"><tbody><tr><td height="10"><span style="-webkit-text-size-adjust:100%; -ms-text-size-adjust:100%; color: transparent; background: none; user-select: none; -moz-user-select: none; -ms-user-select:none; -webkit-user-select:none; text-overflow: ellipsis; opacity: 0; width:100%; min-width: 100%; height:1; overlfow:hidden; margin: -1px 0 0 0; padding:0; font-size: 0;"> &nbsp;</span></td></tr></tbody></table><table cellpadding="0" border="0" cellspacing="0" width="100%" style="color: #425b76; background-color: ; font-size: 20px; width: 100%; margin: initial; min-width: 100%; font-size: 0px"><tbody><tr><td align="left" valign="middle" style="padding: 0; "></td></tr></tbody></table>5/5<table border="0" cellpadding="0" cellspacing="0" width="100%" style="font-size: 0; height: 30px; width: 100%; min-width: 100%; line-height: 0;"><table';
        String s2 = '<span>';
        pattern myPattern = pattern.compile(s); 
        matcher myMatcher = myPattern.matcher(matchString);
        //matcher myMatcher = myPattern.matcher(log.Log_Details__c);
        System.debug(myMatcher.matches());      
        //System.debug(myMatcher.hitEnd());      
        System.debug(myMatcher.groupCount());      
        //System.debug(myMatcher.group(0));      
        //System.debug(myMatcher.group(1));      

        //System.assert(myMatcher.matches() && myMatcher.hitEnd());      
        //System.assert(myMatcher.groupCount() == 2 &&
//                      myMatcher.group(0) == 'aba' && 
  //                    myMatcher.group(1) == 'b');
         
    }
}