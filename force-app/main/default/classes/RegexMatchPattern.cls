public class RegexMatchPattern {
    public static List<String> find(String matchString,String patternString)
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
            
        if(!matchGroups.isEmpty()){
            return matchGroups;
        }
        else{
            return null;
        }
    }

    public static String findOne(String matchString,String patternString)
    {
        List<String> matchGroups = new List<String>();        
        Pattern p = Pattern.compile(patternString);
        Matcher m = p.matcher(matchString);        
        Boolean found = m.find();
        System.debug(patternString);
        //System.debug(matchString);
        try{
            if(found) {
                try{
                //System.debug(m.group());
                if(m.group(1)!=null)
                {
                    return m.group(1);                
                }
                return null;
                }
                catch(Exception e)
                {
                    return null;
                    /*
                    System.debug(m.group());
                    System.debug(e.getMessage());
                    return null;
                    */
                }
            }
            else{
                return null;
            }
        }
        catch(Exception e)
        {
                    System.debug(e.getMessage());
                    return null;
        }

    }
}