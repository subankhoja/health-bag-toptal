import { LightningElement, track ,api} from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import APPOINTMENT_OBJECT from '@salesforce/schema/Appointment__c';
import APPOINTMENT_DATE_FIELD from '@salesforce/schema/Appointment__c.Appointment_Date__c';
import APPOINTMENT_TIME_FIELD from '@salesforce/schema/Appointment__c.Appointment_Time__c';
import PATIENT_ID_FIELD from '@salesforce/schema/Appointment__c.Patient__c';
import PHYSICIAN_NAME_FIELD from '@salesforce/schema/Appointment__c.Physician_Name__c';
import PATIENTS_EMAIL_FIELD from '@salesforce/schema/Appointment__c.Patient_Email__c';

import PATIENT_OBJECT from '@salesforce/schema/Patient__c';
import PATIENT_EMAIL_FIELD from '@salesforce/schema/Patient__c.Email__c';
import PATIENT_FIRSTNAME_FIELD from '@salesforce/schema/Patient__c.First_Name__c';
import PATIENT_LASTNAME_FIELD from '@salesforce/schema/Patient__c.Last_Name__c';
import PATIENT_MOBILE_FIELD from '@salesforce/schema/Patient__c.Mobile_No__c';

export default class ConfirmationComponent extends NavigationMixin(LightningElement){
    @track showConfirmationComponent;

    @api patientData;
    @api specializationData;
    @api appointmentData;
    @api physicianData;

    connectedCallback(){
        this.showConfirmationComponent = true;
    }

    confirmAppointment(event){

        const PATIENT_FIELDS = {};
        PATIENT_FIELDS[PATIENT_EMAIL_FIELD.fieldApiName] = this.patientData.email;
        PATIENT_FIELDS[PATIENT_FIRSTNAME_FIELD.fieldApiName] = this.patientData.firstName;
        PATIENT_FIELDS[PATIENT_LASTNAME_FIELD.fieldApiName] = this.patientData.lastName;
        PATIENT_FIELDS[PATIENT_MOBILE_FIELD.fieldApiName] = this.patientData.phone;

        createRecord({apiName:PATIENT_OBJECT.objectApiName,fields:PATIENT_FIELDS})
            .then(patient => {
                console.log('patient => ',patient.id);
                const APPOINTMENT_FIELDS = {};
                APPOINTMENT_FIELDS[APPOINTMENT_DATE_FIELD.fieldApiName] = this.appointmentData.appointmentDate.date;
                APPOINTMENT_FIELDS[APPOINTMENT_TIME_FIELD.fieldApiName] = this.appointmentData.appointmentDate.time;
                APPOINTMENT_FIELDS[PATIENT_ID_FIELD.fieldApiName] = patient.id;
                APPOINTMENT_FIELDS[PHYSICIAN_NAME_FIELD.fieldApiName] = this.physicianData.Id;
                APPOINTMENT_FIELDS[PATIENTS_EMAIL_FIELD.fieldApiName] = this.patientData.email;
                createRecord({apiName:APPOINTMENT_OBJECT.objectApiName,fields:APPOINTMENT_FIELDS})
                .then(appointment => {
                    console.log('appointment => ',appointment.id);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: appointment.id,
                            actionName: 'view'
                        }
                    });
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error while Booking Appointment',
                            variant: 'error',
                        }),
                    );
                })
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while Creating Patient Record',
                        variant: 'error',
                    }),
                );
            });

        /*
        const APPOINTMENT_FIELDS = {};
        APPOINTMENT_FIELDS[APPOINTMENT_DATE_FIELD.fieldApiName] = appointmentData.appointmentDate.date;
        APPOINTMENT_FIELDS[END_TIME_FIELD.fieldApiName] = appointmentData.appointmentDate.time.split(' - ')[1];
        APPOINTMENT_FIELDS[PATIENT_ID_FIELD.fieldApiName] = patientData.Id;
        APPOINTMENT_FIELDS[PHYSICIAN_NAME_FIELD.fieldApiName] = physicianData.Id;
        APPOINTMENT_FIELDS[START_TIME_FIELD.fieldApiName] = appointmentData.appointmentDate.time.split(' - ')[0];
        */
           
    }
    

    cancelAppointment(event){
        window.location.reload();
    }
}