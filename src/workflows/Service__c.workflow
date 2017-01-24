<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Service_Name</fullName>
        <field>Name</field>
        <formula>Service_Rollup__r.Name &amp; &apos; - &apos; 
 &amp; TEXT(MONTH(Service_Date__c)) &amp; &apos;/&apos;
 &amp; TEXT(DAY(Service_Date__c)) &amp; &apos;/&apos;
 &amp; TEXT(YEAR(Service_Date__c))</formula>
        <name>Service Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Service Name</fullName>
        <actions>
            <name>Service_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Service_Rollup__c &lt;&gt; null</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
