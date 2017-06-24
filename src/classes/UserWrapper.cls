/**
 * Wrapper for the User object.
 */

public with sharing class UserWrapper {

  @AuraEnabled public Id contactId {get;set;}
  @AuraEnabled public Id id {get;set;}
  @AuraEnabled public String firstName {get;set;}
  @AuraEnabled public Decimal profilePointerId {get;set;}
  @AuraEnabled public String sironoId {get;set;}

  public UserWrapper(User user) {
    this.id = user.Id;
    this.firstName = user.Contact.FirstName;
    this.contactId = user.ContactId;
    this.profilePointerId = user.Contact.Profile_Pointer_ID__c;

    if (this.profilePointerId != null) {
      this.sironoId = this.profilePointerId.toPlainString();
    }
  }
}