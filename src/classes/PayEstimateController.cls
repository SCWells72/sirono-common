/**
 * PayEstimateController is a virtual class 
 * that is used by PayEstimateVFController and PayEstimateLightningController classes.
 **/ 
public virtual class PayEstimateController {
    // Page Level Variables.
    public String            		address {get; set;}
    public String                   amount {get; set;}
    public String                   cardHolderName {get; set;}
    public String                   city {get; set;}
    public String                   creditCardNumber {get; set;}
    public String                   cvv {get; set;}
    public List<EncounterWrapper>	encounters {get; set;}
    public Boolean                  encounterSelected {get; set;}
    public String                   expirationMonth {get; set;}
    public String                   expirationYear {get; set;}
    public Contact                  guarantorContact {get; set;}
    public String                   guarantorName {get; set;}
    public String                   guarantorRecordId {get; set;}
    public Encounter__c             selectedEncounter {get; set;}
    public String                   state {get; set;}
    public String                   zip {get; set;}
    public String                   errorMessages{get;set;}

    // Getter setter of expYearOptions
    public List<SelectOption> expYearOptions {
        get {
            if (expYearOptions == null) {
                expYearOptions = new List<SelectOption>();
                Integer currentYear = System.today().year();
                for (Integer i = 0; i <= 10; i++) {
                    String value = String.valueOf(currentYear++);
                    expYearOptions.add(new SelectOption(value, value));
                }
            }
            return expYearOptions;
        }
        protected set;
    }

    // Getter setter of expMonthOptions
    public List<SelectOption> expMonthOptions {
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

    // Constant variable.
    public static final String PAYMENTNAME = 'Payment';

    /**
     * Init method is used to initialize main variables from child constructors
     * @param String objectType - object name of record Id that is used for getting encounters records
     * @param String recordId - record Id that is used for getting encounters records
     **/
    public void init(String objectType, String recordId) {
    	errorMessages = '';
    	if (guarantorRecordId != null) {
            // Fetch Guarantor Contact record based on Id.
            guarantorContact = GuarantorDao.getGuarantor(guarantorRecordId);
            // Fetch Guarantor Name based on Contact record.
            guarantorName = GuarantorService.buildGuarantorDetailString(guarantorContact);
            // Call getEncounterRecords method.
            encounters = getEncounterRecords(objectType, recordId);
        }
    }

    /**
     * This method is used to get selected record
     **/
    public void doNext() {
        EncounterWrapper checkEncounter = checkNext(encounters);
        selectedEncounter = (checkEncounter.en != null) ? checkEncounter.en : selectedEncounter;
        encounterSelected = checkEncounter.isSelected;
    }

    /**
     * This method is use/call from VF page.
     * This method fill the data based on Contact in VF page.
     **/
    public void fillNameAndAddress() {
        cardHolderName = guarantorContact.name;
        address = guarantorContact.MailingStreet;
        city = guarantorContact.MailingCity;
        state = guarantorContact.MailingState;
        zip = guarantorContact.MailingPostalCode;
    }

    /**
     * This method is use to Create/Insert Payment record based on Encounter, Contact and Amount.
     * It is create record if all validations are successfully pass out.
     * @param String paymentMethod - payment method
     * @return String - success/error message
     **/
	public String addPayment(String paymentMethod) {
        try {
	        if (getCardAmountValidations()) {
	        	PaymentService.createNewPayment(PAYMENTNAME, guarantorRecordId, Decimal.valueOf(amount), selectedEncounter.Id, System.now(), paymentMethod);
	        	return (paymentMethod == null) ? Constants.PAGE_MESSAGE_CREATED_SUCCESSFULLY : 'Success;' + '0851' + ';$' + amount;
	        }
	        return null;
        } catch (Exception e) {
        	return 'ERROR: ' + e.getMessage();
        }
	}

    /**
     * This method is used to check selected record
     * @param List<EncounterWrapper> encounters - list of EncounterWrapper records
     * @return EncounterWrapper - selected EncounterWrapper record
     **/
    private EncounterWrapper checkNext(List<EncounterWrapper> encounters) {
    	Encounter__c selectedEncounter;
    	Boolean encounterSelected = false;
        Integer count = 0;
        if (encounters != null && encounters.size() > 0) {
            for (EncounterWrapper enw: encounters) {
                if (enw.isSelected) {
                    count++;
                    selectedEncounter = enw.en;
                }
            }
            if (count == 1) {
                encounterSelected = true;
            }
        }
        return new EncounterWrapper(selectedEncounter, encounterSelected);
    }

    /**
     * This method is used to check selected record
     * @return Boolean - return result of credit card and amount validation
     **/
	private Boolean getCardAmountValidations() {
		// Call creditCardValidation method that validate all informations/values for Credit Card.
        Boolean blnIsCCError = VisualForceValidations.creditCardValidation(creditCardNumber, expirationYear, expirationMonth,
                zip, cardHolderName, cvv, address);
        // Call amountValidation method that validate amount.
        Boolean blnIsAmountError = VisualForceValidations.amountValidation(amount, String.valueOf(selectedEncounter.Balance__c));
        return (!blnIsCCError && !blnIsAmountError);
	}

    /**
     * This method is use to get Encounter Records based on Guarantor Id or Id and Balance is greater than zero.
     * These records add into List of Encounter Wrapper Class.
     * @param String idType - object name for where condition
     * @param String condId - record Id
     * @return List<EncounterWrapper> - list of encounter wrapper records
     **/
	private List<EncounterWrapper> getEncounterRecords(String idType, String condId) {
		List<EncounterWrapper> encounters = new List<EncounterWrapper>();
        List<Encounter__c> encounterList = EncounterDao.getEncounterRecordsById(idType, condId);
        for (Encounter__c en : encounterList) {
            encounters.add(new EncounterWrapper(en, false));
        }
        return encounters;
	}
	
    /**
     * This Wrapper class is use to check how many Encounters select or which encounter select for Payment Process.
     **/
    public class EncounterWrapper {
        public Encounter__c en {get; set;}
        public Boolean isSelected {get; set;}

        /**
         * Constructor of Wrapper Class.
         *
         * @param Encounter__c en - encounter record
         * @param Boolean isSelected - check if record is selected or not
         **/
        public EncounterWrapper(Encounter__c en, Boolean isSelected) {
            this.en = en;
            this.isSelected = isSelected;
        }
    }
}