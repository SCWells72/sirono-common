/**
 * This class is use to set variables for Object Name, Fields and Action (Insert/Update/Delete/Undelete)
 **/

public abstract with sharing class SecurityContext {

    // Create Enum for Create, Update, Delete and Undelete
    public enum ACTION {
        OBJ_CREATE, OBJ_UPDATE, OBJ_DELETE, OBJ_UNDELETE, OBJ_UPSERT
    }

    public abstract System.Type getObjectType();
    public abstract Boolean deleteActionAllowed();
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
