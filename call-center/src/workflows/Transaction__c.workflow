<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Name</fullName>
        <description>Set the transaction&apos;s name</description>
        <field>Name</field>
        <formula>Txn_Method__c + &quot; - &quot; +   TEXT(Sirono_Id__c)</formula>
        <name>Set Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>TransactionName</fullName>
        <actions>
            <name>Set_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set the name when the transaction is created</description>
        <formula>Sirono_Id__c  &lt;&gt; 0</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
