<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateName</fullName>
        <field>Name</field>
        <formula>Custom_Name__c</formula>
        <name>UpdateName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CustomizeName</fullName>
        <actions>
            <name>UpdateName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Name  &lt;&gt;  Custom_Name__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
