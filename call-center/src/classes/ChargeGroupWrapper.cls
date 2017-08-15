/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * ChargeGroupWrapper class used for selection in the UI
 **/
public with sharing class ChargeGroupWrapper {

    /*
    * Build a list of wrappers from the charge group list associated with the given contact
    * @param Contact gc - Contact with a list of associated chargegroups
    * @returns List<ChargeGroupWrapper>
    */
    public static List<ChargeGroupWrapper> buildList(Contact gc) {

        if (gc != null) {
            return buildList(gc.Charge_Groups__r);
        }

        return new ChargeGroupWrapper[] {};
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

    /**
     * Prepare a list of selected charge group ids based on charge group wrapper list.
     *
     * @param List<ChargeGroupWrapper> chargeGroupList - That contains charge group list.
     * @returns List<String> - That contains list of selected charge group ids.
     **/
    public static List<String> getSelectedChargeGroupIds(List<ChargeGroupWrapper> chargeGroupList) {
        Set<String> idSet = new Set<String>();
        for (ChargeGroupWrapper cgw : chargeGroupList) {
            if (cgw.isSelected) {
                idSet.add(cgw.cg.Sirono_ID__c.toPlainString());
            }
        }
        return new List<String>(idSet);
    }

    public Charge_Group__c cg { get; set; }
    public Boolean isSelected { get; set; }

    public ChargeGroupWrapper(Charge_Group__c cg, Boolean isSelected) {
        this.cg = cg;
        this.isSelected = isSelected;
    }

    public ChargeGroupWrapper(Charge_Group__c cg) {
        this(cg, false);
    }
}