/*
* ChargeGroupWrapper class used for selection in the UI
*/

public with sharing class ChargeGroupWrapper {

    /*
    * Build a list of wrappers from the charge group list associated with the given contact
    * @param Contact gc - Contact with a list of associated chargegroups
    * @returns List<ChargeGroupWrapper>
    */
    public static List<ChargeGroupWrapper> buildList(Contact gc) {

        if (gc != null && gc.Charge_Groups__r != null) {
            return buildList(gc.Charge_Groups__r);
        }

        return new ChargeGroupWrapper[]{};
    }

    /*
    * Build a list of wrappers from the supplied charge group list
    * @param List<Charge_Group__c> cgs - list of chargegroups
    * @returns List<ChargeGroupWrapper>
    */
    public static List<ChargeGroupWrapper> buildList(List<Charge_Group__c> cgs) {

        List<ChargeGroupWrapper> cgList = new List<ChargeGroupWrapper>();
        if (cgs != null) {
            for (Charge_Group__c cg : cgs) {
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