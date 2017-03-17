/**
 * Created by mmartin on 3/14/17.
 */

public with sharing class GuarantorDao extends AbstractDao {

    public static Contact getGuarantorBySironoId(String sironoId) {
        Contact gt = [
                SELECT Id, RecordTypeId, Profile_Pointer_ID__c
                FROM Contact
                WHERE RecordTypeId =: RecordTypeUtil.guarantorRt
                AND Profile_Pointer_Id__c =: Decimal.valueOf(sironoId)
                LIMIT 1];
        return gt;
    }
}