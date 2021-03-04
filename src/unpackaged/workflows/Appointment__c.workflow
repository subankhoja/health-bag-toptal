<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Appointment_Email_Alert</fullName>
        <description>Appointment Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Patient_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>suban.khoja.work@gmail.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Appointment_Email_Template</template>
    </alerts>
</Workflow>
