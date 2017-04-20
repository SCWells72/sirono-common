/**
 * PayEstimateController is a virtual class 
 * that is used by PayEstimateVFController and PayEstimateLightningController classes.
 **/ 
public abstract class PayEstimateController {
    // Page Level Variables.
    public String address {get; set;}
    public String amount {get; set;}
    public String cardHolderName {get; set;}
    public String city {get; set;}
    public String creditCardNumber {get; set;}
    public String cvv {get; set;}
    public List<EncounterWrapper> encounters {get; set;}
    public Boolean encounterSelected {get; set;}
    public String expirationMonth {get; set;}
    public String expirationYear {get; set;}
    public Contact guarantorContact {get; set;}
    public String guarantorName {get; set;}
    public String guarantorRecordId {get; set;}
    public Encounter__c selectedEncounter {get; set;}
    public String state {get; set;}
    public String zip {get; set;}
    public String errorMessages{get;set;}

    // Getter setter of expYearOptions
    public List<SelectOption> expYearOptions {
        get {
            if (expYearOptions == null) {
                expYearOptions = PayStaffWSUtill.expYearOptions;
            }
            return expYearOptions;
        }
        protected set;
    }

    // Getter setter of expMonthOptions
    public List<SelectOption> expMonthOptions {
        get {
            if (expMonthOptions == null) {
                expMonthOptions = PayStaffWSUtill.expMonthOptions;
            }
            return expMonthOptions;
        }
        protected set;
    }

    /**
     * Init method is used to initialize main variables from child constructors
     * @param String recordId - record Id that is used for getting encounters records
     **/
    public void init(String recordId) {
    	errorMessages = '';
    	if (guarantorRecordId != null) {
            // Fetch Guarantor Contact record based on Id.
            guarantorContact = GuarantorDao.getGuarantor(guarantorRecordId);
            // Fetch Guarantor Name based on Contact record.
            guarantorName = GuarantorService.buildGuarantorDetailString(guarantorContact);
            // Call getEncounterRecords method.
            loadEncounters(recordId);
        }
    }

    protected abstract void loadEncounters(String recordId);

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
	        if (isValidCard() && isValidAmount()) {
	        	String transactionId = PaymentService.createNewPayment(guarantorRecordId, Decimal.valueOf(amount), selectedEncounter.Id, System.now(), paymentMethod);
	        	return (paymentMethod == null) ? Constants.PAGE_MESSAGE_CREATED_SUCCESSFULLY : 'Success;' + transactionId + ';$' + amount;
	        }
	        return errorMessages;
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
     * @return Boolean - return result of credit card validation
     **/
	protected abstract Boolean isValidCard();

    /**
     * This method is used to check selected record
     * @return Boolean - return result of amount validation
     **/
    protected abstract Boolean isValidAmount();
}