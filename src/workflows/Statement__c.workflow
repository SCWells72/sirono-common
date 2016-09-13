<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Statement_Name</fullName>
        <field>Name</field>
        <formula>TEXT( Large_Statement_ID__c ) &amp; &apos;-&apos; &amp; TEXT( Small_Statement_ID__c )</formula>
        <name>Statement Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Statement Name</fullName>
        <actions>
            <name>Statement_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
