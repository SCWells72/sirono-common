/**
 * This class is use to check Security Scan related Object rights and FLS (Field Level Security).
 **/

public with sharing class SecurityUtils {
    // This class is used to create/generate custom Exception.
    public class SecurityException extends Exception {}

    public static String nsPrefix = null;

    /**
     * When running as a managed package, we need the namespace appended to the field names.
     * Use a known object description to determine what it is. When looking for the match in the objectFields map,
     * it only matches lowercase namespaces (fields seem to be case-insensitive, go figure), so go ahead and lowercase it
     * here
     */
    private static String getNSPrefix() {

        if (nsPrefix == null) {
            DescribeSObjectResult describe = Charge_Group__c.SObjectType.getDescribe();

            String name = describe.getName();
            String localName = describe.getLocalName();
            nsPrefix = name.replace(localName, '').toLowerCase();
        }

        return nsPrefix;
    }

    /**
     * This method is used to check Object rights and Fields Level Permission.
     *
     * @param String objName - That contains Object Name.
     * @param Set<String> fieldsToCheck - That contains Set of Fields for which We need to check permission.
     * @param SecurityContext.ACTION - The action to be performed on the object (Create/Update/Delete/Undelete).
     * @returns boolean - indicating whether or not the action is allowed
     **/
    private static boolean checkObjectCrud(String objName, Set<String> fieldsToCheck, SecurityContext.ACTION objAction) {

        Schema.DescribeSObjectResult objectResult = Schema.getGlobalDescribe().get(objName).getDescribe();

        if (SecurityContext.ACTION.OBJ_DELETE == objAction) {
            if (!objectResult.isDeletable()) {
                throw new SecurityException( UserInfo.getUserName()+' does not have Delete rights for ' + objName);
            }
            return true;
        }

        if (SecurityContext.ACTION.OBJ_CREATE == objAction && !objectResult.isCreateable()) {
            throw new SecurityException(UserInfo.getUserName()+' does not have Create rights on ' + objName);
        }

        if (SecurityContext.ACTION.OBJ_UPDATE == objAction && !objectResult.isUpdateable()) {
            throw new SecurityException(UserInfo.getUserName()+' does not have Update rights on ' + objName);
        }

        if (SecurityContext.ACTION.OBJ_UNDELETE == objAction && !objectResult.isUndeletable()) {
            throw new SecurityException(UserInfo.getUserName()+' does not have Undelete rights on ' + objName);
        }
        
        if (SecurityContext.ACTION.OBJ_UPSERT == objAction) {
            if (!(objectResult.isCreateable() && objectResult.isUpdateable())) {
            	throw new SecurityException(UserInfo.getUserName()+' does not have Upsert rights on ' + objName);
            }
        }

        if (SecurityContext.ACTION.OBJ_READ == objAction && !objectResult.isAccessible()) {
            throw new SecurityException(UserInfo.getUserName()+' does not have Read rights on ' + objName);
        }

        // Get object fields.
        Map<String, Schema.SObjectField> mapObjectFields = objectResult.fields.getMap();

        for (String field : fieldsToCheck) {
            String fieldToCheck = getNSPrefix()+field;

            if (SecurityContext.ACTION.OBJ_CREATE == objAction
                    && !mapObjectFields.get(fieldToCheck).getDescribe().isCreateable()) {
                throw new SecurityException(String.format('{2} does not have Create rights on {0}.{1} field.', new String[]{objName, fieldToCheck, UserInfo.getUserName()}));
            } else if (SecurityContext.ACTION.OBJ_UPDATE == objAction
                    && !mapObjectFields.get(fieldToCheck).getDescribe().isUpdateable()) {
                throw new SecurityException(String.format('{2} does not have Update rights on {0}.{1} field.', new String[]{objName, fieldToCheck,  UserInfo.getUserName()}));
            } else if (SecurityContext.ACTION.OBJ_UPSERT == objAction) {
            	if (!(mapObjectFields.get(fieldToCheck).getDescribe().isCreateable() &&
        				mapObjectFields.get(fieldToCheck).getDescribe().isUpdateable())) {
                    throw new SecurityException(String.format('{2} does not have Upsert rights on {0}.{1} field.', new String[]{objName, fieldToCheck, UserInfo.getUserName()}));
            	}
            } else if (SecurityContext.ACTION.OBJ_READ == objAction
                    && !mapObjectFields.get(fieldToCheck).getDescribe().isAccessible()) {
                throw new SecurityException(String.format('{2} does not have Read rights on {0}.{1} field.', new String[]{objName, fieldToCheck, UserInfo.getUserName()}));
            }
        }
        return true;
    }

    /**
     * This method is use to call checkObjectCrud method based on SecurityContext parameter.
     *
     * @param SecurityContext context - That contains Security Context Class fields.
     * @returns boolean - That contains true when object and fields permission are successfully pass.
     **/
    public static boolean verify(SecurityContext context) {
        return checkObjectCrud(context.getObjectType().getName(), context.fieldsToCheck, context.objectAction);
    }
}