/*
* ChargeGroupWrapper class used for selection in the UI
*/

public with sharing class ChargeGroupWrapper {

    //Build a list of wrappers from the charge group list associated with the given guarantor
    public static List<ChargeGroupWrapper> buildList(Contact gc) {
        List<ChargeGroupWrapper> cgList = new List<ChargeGroupWrapper>();
        if (gc != null && gc.Charge_Groups__r != null && gc.Charge_Groups__r.size() > 0) {
            for (Charge_Group__c cg : gc.Charge_Groups__r) {
                cgList.add(new ChargeGroupWrapper(cg));
            }
        }
        return cgList;
    }

    public Charge_Group__c cg {get; set;}
    public Boolean isSelected {get; set;}

    public ChargeGroupWrapper(Charge_Group__c cg, Boolean isSelected) {
        this.cg = cg;
        this.isSelected = isSelected;
    }

    public ChargeGroupWrapper(Charge_Group__c cg) {
        this(cg, false);
    }
}