/**
 * JSONParser for the charge group responses form the Sirono service.
 */

public with sharing class ChargeGroupJSONParser extends AbstractSironoJSONParser {
    public class Patient_data {
        //noinspection ApexUnusedDeclaration
        public String mrn;
        //noinspection ApexUnusedDeclaration
        public String patient_name;
    }

    public class Invoice {
        //noinspection ApexUnusedDeclaration
        public String invoice_date;
        //noinspection ApexUnusedDeclaration
        public String due_date;
    }

    public String url;
    //noinspection ApexUnusedDeclaration
    public String account_type;
    //noinspection ApexUnusedDeclaration
    public String account_number;
    public Boolean active;
    //noinspection ApexUnusedDeclaration
    public String status;
    //noinspection ApexUnusedDeclaration
    public String extended_status;
    //noinspection ApexUnusedDeclaration
    public String pas_specific_origin_code;
    //noinspection ApexUnusedDeclaration
    public Integer balance;
    //noinspection ApexUnusedDeclaration
    public Invoice invoice;
    //noinspection ApexUnusedDeclaration
    public Boolean bad_debt_status;
    //noinspection ApexUnusedDeclaration
    public String date_of_service_start;
    //noinspection ApexUnusedDeclaration
    public String date_of_service_end;
    //noinspection ApexUnusedDeclaration
    public Boolean charges_since_paymentplan;
    //noinspection ApexUnusedDeclaration
    public String mapped_location_or_provider;
    //noinspection ApexUnusedDeclaration
    public String processed_charges_details;
    //noinspection ApexUnusedDeclaration
    public Patient_data patient_data;
    //noinspection ApexUnusedDeclaration
    public Guarantor_data guarantor_data;
    public String account_status;
    public String account_sub_status;
    public String paymentplan;

    public class Guarantor_data {
        //noinspection ApexUnusedDeclaration
        public String display_id;
        //noinspection ApexUnusedDeclaration
        public String url;
        //noinspection ApexUnusedDeclaration
        public String full_name;
    }

    public static ChargeGroupJSONParser parse(String json) {
        return (ChargeGroupJSONParser) System.JSON.deserialize(json, ChargeGroupJSONParser.class);
    }


    public static String testResponse() {
        String json = '{' +
            '' +
            '   "url": "https://toledo.stage.sirono.com/paystaff/api/chargegroups/1113401/",' +
            '' +
            '   "account_type": "HB",' +
            '' +
            '   "account_number": "A1322100179",' +
            '' +
            '   "active": true,' +
            '' +
            '   "status": "Paid",' +
            '' +
            '   "extended_status": "Paid",' +
            '' +
            '   "pas_specific_origin_code": "HBO",' +
            '' +
            '   "balance": 0,' +
            '' +
            '   "invoice": {' +
            '' +
            '      "invoice_date": "2015-08-20",' +
            '' +
            '      "due_date": "2015-09-10"' +
            '' +
            '   },' +
            '' +
            '   "bad_debt_status": false,' +
            '' +
            '   "date_of_service_start": "2013-08-09",' +
            '' +
            '   "date_of_service_end": "2013-08-09",' +
            '' +
            '   "charges_since_paymentplan": false,' +
            '' +
            '   "mapped_location_or_provider": "UT Ruppert Health Center",' +
            '' +
            '   "processed_charges_details": "Paramount has finished processing these charges.",' +
            '' +
            '   "patient_data": {' +
            '' +
            '      "mrn": "A01026426",' +
            '' +
            '      "patient_name": "PEYTON BROWN"' +
            '' +
            '   },' +
            '' +
            '   "guarantor_data": {' +
            '' +
            '      "display_id": "TD157913",' +
            '' +
            '      "url": "https://toledo.stage.sirono.com/paystaff/api/guarantors/157913/",' +
            '' +
            '      "full_name": "Ruth Fiser"' +
            '' +
            '   },' +
            '' +
            '   "services_by_description": {' +
            '' +
            '      "Clinic": {' +
            '' +
            '         "784005775": {' +
            '' +
            '            "code_description": "PED-INITIAL PREV NEW PT 1-4YRS",' +
            '' +
            '            "service_description": "Clinic",' +
            '' +
            '            "charge": -10400,' +
            '' +
            '            "code": "784005775",' +
            '' +
            '            "quantity": 1' +
            '' +
            '         }' +
            '' +
            '      }' +
            '' +
            '   },' +
            '"account_status":"Billed",' +
            '"account_sub_status":"Paid",' +
            '"paymentplan":"https://toledo.stage.sirono.com/paystaff/api/paymentplan/3133/"' +
            '' +
            '}';

        return json;
    }
}