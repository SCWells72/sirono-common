/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

//TODO why doesn't this have sharing?
public class AttachmentController {
    
	public Attachment attachment {
	  get {
		  if (attachment == null)
			attachment = new Attachment();
		  return attachment;
		}
	  set;
	  }

	public PageReference upload() {
		attachment.OwnerId = UserInfo.getUserId();
		attachment.ParentId = ApexPages.currentPage().getParameters().get('id'); // the record the file is attached to

		try {
			insert attachment;
		} catch (DMLException e) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
			return null;
		} finally {
			attachment = new Attachment(); 
		}

		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
		return null;
	}
	public PageReference cancel() {
		PageReference p = new PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
		p.setRedirect(true);
		return p;  
    }
}