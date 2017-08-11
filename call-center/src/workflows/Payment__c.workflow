<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Payment_Name_Update</fullName>
        <description>Update Payment Name

&gt;&gt;&gt;
IF( ISBLANK(Deposit_Date__c), &apos;Patient Payment&apos; , &quot;Patient Payment - &quot; &amp;  TEXT(MONTH(DATEVALUE(Deposit_Date__c))) &amp; &quot;/&quot; &amp; TEXT(DAY(DATEVALUE(Deposit_Date__c))) &amp; &quot;/&quot; &amp; TEXT(YEAR(DATEVALUE(Deposit_Date__c))))</description>
        <field>Name</field>
        <formula>Display_Name__c</formula>
        <name>Payment Name Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Payment_Name_Update</fullName>
        <actions>
            <name>Payment_Name_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Payment Name.</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
