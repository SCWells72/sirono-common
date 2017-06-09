/**
 * PortalUIConstants class contains all common constants for Portal UI.
 **/

public with sharing class PortalUIConstants {

    public static Map<String, String> yearOptions;
    public static Map<String, String> expMonthOptions;
    public static List<String> states;

    {
        yearOptions = new Map<String, String>();
        Integer currentYear = System.today().year();
        for (Integer i = 0; i <= 10; i++) {
            String value = String.valueOf(currentYear + i);
            yearOptions.put(value, value);
        }

        expMonthOptions = new Map<String, String>();
        expMonthOptions.put('01', '01 (January)');
        expMonthOptions.put('02', '02 (February)');
        expMonthOptions.put('03', '03 (March)');
        expMonthOptions.put('04', '04 (April)');
        expMonthOptions.put('05', '05 (May)');
        expMonthOptions.put('06', '06 (June)');
        expMonthOptions.put('07', '07 (July)');
        expMonthOptions.put('08', '08 (August)');
        expMonthOptions.put('09', '09 (September)');
        expMonthOptions.put('10', '10 (October)');
        expMonthOptions.put('11', '11 (November)');
        expMonthOptions.put('12', '12 (December)');

        List<State__mdt> statesList = [SELECT Label FROM State__mdt ORDER BY Label LIMIT 1000];
        states = new List<String>();
        for (State__mdt state : statesList) {
            states.add(state.Label);
        }
    }
}