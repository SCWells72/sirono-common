/**
 * UIUtils class contains all common methods for UI.
 **/

public with sharing class UIUtils {
    
    // This variable is use to set years list for drop down.
    public static List<SelectOption> expYearOptions {
        get {
            if (expYearOptions == null) {
                expYearOptions = new List<SelectOption>();
                Integer currentYear = System.today().year();
                for (Integer i = 0; i <= 10; i++) {
                    String value = String.valueOf(currentYear + i);
                    expYearOptions.add(new SelectOption(value, value));
                }
            }
            return expYearOptions;
        }
        protected set;
    }

    // This variable is use to set months list for drop down.
    public static List<SelectOption> expMonthOptions {
        get {
            if (expMonthOptions == null) {
                expMonthOptions = new List<SelectOption>();
                expMonthOptions.add(new SelectOption('01', '01 (January)'));
                expMonthOptions.add(new SelectOption('02', '02 (February)'));
                expMonthOptions.add(new SelectOption('03', '03 (March)'));
                expMonthOptions.add(new SelectOption('04', '04 (April)'));
                expMonthOptions.add(new SelectOption('05', '05 (May)'));
                expMonthOptions.add(new SelectOption('06', '06 (June)'));
                expMonthOptions.add(new SelectOption('07', '07 (July)'));
                expMonthOptions.add(new SelectOption('08', '08 (August)'));
                expMonthOptions.add(new SelectOption('09', '09 (September)'));
                expMonthOptions.add(new SelectOption('10', '10 (October)'));
                expMonthOptions.add(new SelectOption('11', '11 (November)'));
                expMonthOptions.add(new SelectOption('12', '12 (December)'));
            }
            return expMonthOptions;
        }
        protected set;
    }
}