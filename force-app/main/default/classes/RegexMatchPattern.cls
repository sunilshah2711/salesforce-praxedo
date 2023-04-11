public class RegexMatchPattern {
     public static List<String> run(String matchString,String patternString)
    {
        List<String> matchGroups = new List<String>();        
        Pattern p = Pattern.compile(patternString);
        Matcher m = p.matcher(matchString);
        m.find();        
        System.debug(patternString);
        //System.debug(matchString);
        try{
            //System.debug(m.group());
            if(m.group(1)!=null)
            {
                matchGroups.add(m.group(1));
                //matchGroups.add(m.group(2));
            }
        }
        catch(Exception e)
        {
            System.debug(m.group());
            System.debug(e.getMessage());
            return matchGroups;
        }
            
        return matchGroups;
    }
}