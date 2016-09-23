public with sharing class ChargeGroupWrapper {
    public Charge_Group__c cg {get; set;}
    public Boolean isSelected {get; set;}

    public ChargeGroupWrapper(Charge_Group__c cg, Boolean isSelected) {
        this.cg = cg;
        this.isSelected = isSelected;
    }
}