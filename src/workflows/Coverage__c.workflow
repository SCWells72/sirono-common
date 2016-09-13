<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Coverage_Name</fullName>
        <field>Name</field>
        <formula>Payor__r.Name</formula>
        <name>Coverage Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Coverage Name</fullName>
        <actions>
            <name>Coverage_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Payor__c &lt;&gt; null</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
