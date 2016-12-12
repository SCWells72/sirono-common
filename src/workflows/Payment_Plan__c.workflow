<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdatePPcomplete</fullName>
        <field>Completion_Date__c</field>
        <formula>TODAY()</formula>
        <name>UpdatePPcomplete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>PPcomplete</fullName>
        <actions>
            <name>UpdatePPcomplete</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Payment_Plan__c.Status__c</field>
            <operation>equals</operation>
            <value>completed</value>
        </criteriaItems>
        <description>payment plan completion date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
