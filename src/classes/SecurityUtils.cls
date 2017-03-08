/**
 * This class is use to check Security Scan related Object rights and FLS (Field Level Security).
 **/

public with sharing class SecurityUtils {
    // This class is used to create/generate custom Exception.
    public class SecurityException extends Exception {}
    
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
                throw new SecurityException('You do not have Delete rights for ' + objName);
            }
            return true;
        }

        if (SecurityContext.ACTION.OBJ_CREATE == objAction && !objectResult.isCreateable()) {
            throw new SecurityException('You do not have Create rights on ' + objName);
        }

        if (SecurityContext.ACTION.OBJ_UPDATE == objAction && !objectResult.isUpdateable()) {
            throw new SecurityException('You do not have Update rights on ' + objName);
        }

        if (SecurityContext.ACTION.OBJ_UNDELETE == objAction && !objectResult.isUndeletable()) {
            throw new SecurityException('You do not have Undelete rights on ' + objName);
        }
        
        if (SecurityContext.ACTION.OBJ_UPSERT == objAction) {
            if (!objectResult.isCreateable() && !objectResult.isUpdateable()) {
            	throw new SecurityException('You do not have Upsert rights on ' + objName);
            }
        }

        // Get object fields.
        Map<String, Schema.SObjectField> mapObjectFields = objectResult.fields.getMap();

        for (String fieldToCheck: fieldsToCheck) {
            if (SecurityContext.ACTION.OBJ_CREATE == objAction
                    && !mapObjectFields.get(fieldToCheck).getDescribe().isCreateable()) {
                throw new SecurityException('You do not have Create rights on ' + fieldToCheck + ' field.');
            } else if (SecurityContext.ACTION.OBJ_UPDATE == objAction
                    && !mapObjectFields.get(fieldToCheck).getDescribe().isUpdateable()) {
                throw new SecurityException('You do not have Update rights on ' + fieldToCheck + ' field.');
            } else if (SecurityContext.ACTION.OBJ_UPSERT == objAction) {
            	if (!mapObjectFields.get(fieldToCheck).getDescribe().isCreateable() &&
        				!mapObjectFields.get(fieldToCheck).getDescribe().isUpdateable()) {
            	    throw new SecurityException('You do not have Upsert rights on ' + fieldToCheck + ' field.');
            	}
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