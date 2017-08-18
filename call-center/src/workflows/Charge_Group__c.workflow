<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Original_SelfPay_Balance</fullName>
        <field>Original_Balance__c</field>
        <formula>Balance__c</formula>
        <name>Original SelfPay Balance</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>OriginalSelfPay</fullName>
        <actions>
            <name>Original_SelfPay_Balance</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Charge_Group__c.Account_Status__c</field>
            <operation>equals</operation>
            <value>Billed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
