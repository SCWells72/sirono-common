/*
   Request information about the given phone number from NumVerify:
   Valid numbers must contain 10 or 11 digits (US or international number format is allowed)
   Possible lineType values are 'landline', 'mobile' & 'Invalid'

*/
public class NumVerifyValidator  {

    public static final String LANDLINE = 'landline';
    public static final String MOBILE = 'mobile';
    public static final String INVALID = 'Invalid';

    private static final String NUM_VERIFY_URL = 'http://apilayer.net/api/validate?access_key={0}&country_code={1}&format={2}&number={3}';
    private static final Integer LENGTH_TOO_SHORT = 9;
    private static final Integer LENGTH_TOO_LONG = 12;

    private class NumVerifyResponse {
        Boolean valid;
        String phone_number;
        String local_format;
        String international_format;
        String country_prefix;
        String country_code;
        String country_name;
        String location;
        String carrier;
        String line_type;
    }

    public class VerifiedNumber {
        protected String rawPhoneNumber;
        protected String cleanedPhoneNumber;
        protected boolean valid;
        protected String lineType;

        @TestVisible
        private VerifiedNumber(String phoneNumber) {
            this.lineType = INVALID;
            this.valid = false;
            this.rawPhoneNumber = phoneNumber;            
            setCleanedNumber();
        }

        //Does this number meet the criteria to send it to NumVerify
        public boolean isValid() {
            return valid;
        }

        //The line type returned from NumVerify, or INVALID
        public String getLineType() {
            return lineType;
        }

        private void setCleanedNumber() {
            if (rawPhoneNumber != null) {
                String cleanString = rawPhoneNumber.replaceAll('[^0-9]', '');
                if (LENGTH_TOO_SHORT < cleanString.length() && cleanString.length() < LENGTH_TOO_LONG) {
                    cleanedPhoneNumber = cleanString;
                }
            }
            valid = !String.isEmpty(cleanedPhoneNumber);
        }
    }

    @TestVisible
    private static HttpRequest buildRequest(VerifiedNumber nbr) {
        //TODO replace with SironoSettingsUtil.getOrgSettings()
        Sirono_Settings__c ss = Sirono_Settings__c.getOrgDefaults();

        //TODO do country_code & format belong in settings or just in the url constant?
        List<String> params = new String[]{ss.Apikey__c, ss.Country_Code__c, ss.Format__c.format(), nbr.cleanedPhoneNumber};
        String endPointURL = String.format(NUM_VERIFY_URL, params);

        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(endPointURL);
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(1000);

        return request;
    }

    /*
	  Make the NumVerify Phone Verification Api request and get response for valid number.
    */
    public static VerifiedNumber verifyPhoneNumber(String p) {
        VerifiedNumber nbr = new VerifiedNumber(p);

        if (nbr.isValid()) {
            try {
                HttpRequest request = buildRequest(nbr);
                HttpResponse response = new Http().send(request);

                JSONParser parser = JSON.createParser(response.getBody());
                parser.nextToken();

                NumVerifyResponse resp = (NumVerifyResponse) parser.readValueAs(NumVerifyResponse.class);

                nbr.lineType = resp.line_type == null ? INVALID : resp.line_type;
            } catch (Exception e) {
                System.debug('caught exception:' + e.getMessage());                
            }
        }
        return nbr;
    }
}