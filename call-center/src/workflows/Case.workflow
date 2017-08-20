<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
<!--
    <alerts>
        <fullName>Internal_Case_Assignment</fullName>
        <description>Internal Case Assignment</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_To__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sirono_PRS/SUPPORTNewassignmentnotificationSAMPLE</template>
    </alerts>
-->
<!--
    <alerts>
        <fullName>Internal_Case_Notification</fullName>
        <ccEmails>david@CloudCoOp.io, andy.davidson@cloudcoop.io</ccEmails>
        <description>Internal Case Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sirono_PRS/Internal_Case_Creation</template>
    </alerts>
-->
<!--
    <alerts>
        <fullName>Internal_Case_Status_Update</fullName>
        <description>Internal Case Status Update</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_To__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sirono_PRS/Internal_Case_Comment_Update</template>
    </alerts>
-->
    <fieldUpdates>
        <fullName>Case_Escalation</fullName>
        <field>IsEscalated</field>
        <literalValue>1</literalValue>
        <name>Case Escalation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Case Escalation</fullName>
        <actions>
            <name>Case_Escalation</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CASE_ESCALATION</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Reason</field>
            <operation>equals</operation>
            <value>VIP Called</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
<!--
    <rules>
        <fullName>Internal Case - Assignment</fullName>
        <actions>
            <name>Internal_Case_Assignment</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Notify_Assign_To__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
-->
<!--
    <rules>
        <fullName>Internal Case - Status Change</fullName>
        <actions>
            <name>Internal_Case_Status_Update</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>On Hold,Working,Review,Investigating,Escalated,Completed,Cancelled</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
-->
<!--
    <rules>
        <fullName>Internal Case Creation</fullName>
        <actions>
            <name>Internal_Case_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Internal Case</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
-->
    <tasks>
        <fullName>CASE_ESCALATION</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>CASE ESCALATION</subject>
    </tasks>
</Workflow>
