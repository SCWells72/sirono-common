/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Superclass for all JSON Parsers for Sirono JSON responses
 */
public virtual class AbstractSironoJSONParser {

    public static Decimal convertToDollars(Decimal amount) {
        Decimal dollarAmount = (amount != null ? (amount / 100) : amount);
        System.debug('converted cent amount: ' + amount + ' to dollars: '+ dollarAmount);
        return dollarAmount;
    }

    // Convert Transaction amounts to dollars.
    public static Decimal convertToDollarsNegative(Decimal amount) {
        Decimal dollarAmount = (amount != null ? (amount / -100) : amount);
        System.debug('converted cent amount: ' + amount + ' to negative dollars: '+ dollarAmount);
        return dollarAmount;
    }

    /*
     * Helper to convert the given String to a Date
     */
    public static Date parseDate(String dateStr) {
        if (!String.isBlank(dateStr)) {
            return Date.valueOf(dateStr);
        }
        return null;
    }

    //Split the given URL and return the last number which is the external sirono id
    public static String parseSironoId(String url, String splitWith) {
        String[] sironoId = url.split(splitWith);
        return sironoId[sironoId.size() - 1].replaceAll('/', '');
    }

    /**
     * Convert the given list of strings to a set of decimals. Particularly useful for converting a list
     * of string sirono ids to a set of Decimal values that can be used in SOQL
     */
    public static Set<Decimal> asDecimalSet(List<String> stringList) {

        Set<Decimal> decimalSet = new Set<Decimal>();
        if (stringList != null) {
            for (String str : stringList) {
                if (!String.isBlank(str) && str.isNumeric()) {
                    decimalSet.add(Decimal.valueOf(str));
                }
            }
        }
        return decimalSet;
    }

    /**
     * Take the given jsonBody and make sure it is formatted as a JSON List
     *
     * @param jsonBody - the json that needs to be a list
     */
    public static String ensureJsonList(String jsonBody) {
        String json = jsonBody;
        if (!json.endsWith(']')) {
            json = json + ']';
        }

        if (!json.startsWith('[')) {
            json = '[' + json;
        }
        return json;
    }
}