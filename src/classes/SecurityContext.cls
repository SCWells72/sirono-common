/**
 * This class is use to set variables for Object Name, Fields and Action (Insert/Update/Delete/Undelete)
 **/

public virtual with sharing class SecurityContext {

    // Create Enum for Create, Update, Delete and Undelete
    public enum ACTION {
        OBJ_CREATE, OBJ_UPDATE, OBJ_DELETE, OBJ_UNDELETE, OBJ_UPSERT
    }

    /**
     * This method is use to get object type.
     * It is override in child class.
     *
     * @returns System.Type - That contains object type.
     **/
    public virtual System.Type getObjectType(){
    	throw new SecurityException('getObjectType() not implemented in SecurityContext subclass');
    	return null;
    }
    
    /**
     * This method is use to check delete action allowed or not.
     * It is override in child class.
     *
     * @returns boolean - That contains true or false based on delete access.
     **/
    public virtual Boolean deleteActionAllowed(){
    	throw new SecurityException('deleteActionAllowed() not implemented in SecurityContext subclass');
    	return false;
    }
    
    public Set<String> fieldsToCheck { get; set; }
    public ACTION objectAction { get; set; }

    /**
     * This method is use to call Verify method of Security Util Class.
     *
     * @returns boolean - That contains true or false based on Object/Fields Permission.
     **/
    public boolean actionAllowed() {
        return SecurityUtils.verify(this);
    }
}
