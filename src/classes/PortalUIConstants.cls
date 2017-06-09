/**
 * PortalUIConstants class contains common constants for Portal UI.
 **/

public with sharing class PortalUIConstants {

    public static Map<String, String> getYears() {
        Map<String, String>  yearMap = new Map<String, String>();
        Integer currentYear = System.today().year();
        for (Integer i = 0; i <= 10; i++) {
            String value = String.valueOf(currentYear + i);
            yearMap.put(value, value);
        }
        return yearMap;
    }

    public static Map<String, String> getExpMonths() {
        Map<String, String> expMonths = new Map<String, String>();
        expMonths.put('01', '01 (January)');
        expMonths.put('02', '02 (February)');
        expMonths.put('03', '03 (March)');
        expMonths.put('04', '04 (April)');
        expMonths.put('05', '05 (May)');
        expMonths.put('06', '06 (June)');
        expMonths.put('07', '07 (July)');
        expMonths.put('08', '08 (August)');
        expMonths.put('09', '09 (September)');
        expMonths.put('10', '10 (October)');
        expMonths.put('11', '11 (November)');
        expMonths.put('12', '12 (December)');
        return expMonths;
    }

    public static List<String> getStates() {
        List<State__mdt> statesList = [SELECT Label FROM State__mdt ORDER BY Label LIMIT 1000];
        List<String> states = new List<String>();
        for (State__mdt state : statesList) {
            states.add(state.Label);
        }
        return states;
    }
}