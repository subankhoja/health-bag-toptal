import { LightningElement, track } from 'lwc';

export default class App extends LightningElement {

    @track patientData; // reference to Patient Details
    @track specializationData; // reference to Specialization Details
    @track appointmentData; // reference to Appointment Details
    @track physicianData; // reference to Physician Details
    @track specializationId; // reference to Specialization Salesforce Id
    @track physicianId; // reference to Physician Salesforce Id
    @track patientId;

    /**
     * Getter of showConfirm which will define whether confirmation-component is Shown on not
     * @return {boolean} true/false
     */

    get showConfirm() {
        return (
            this.patientData && this.specializationData && this.appointmentData && this.physicianData
        );
    }

    /**
     * An Event Hanler for patientsubmit Custom Event
     *
     * @param {object} event reference
     * @return {NA}
    */
    handlePatientData(event){
        this.patientData = event.detail;
        this.patientId = this.patientData.id;
    }

    /**
     * An Event Hanler for specializationsubmit Custom Event
     *
     * @param {object} event reference
     * @return {NA}
    */
    handleSpecializationData(event){
        this.specializationData = event.detail;
        this.specializationId = this.specializationData.Id;
    }

    /**
     * An Event Hanler for appointmentsubmit Custom Event
     *
     * @param {object} event reference
     * @return {NA}
    */
    handleAppointmentData(event){
        this.appointmentData = event.detail;
    }

    /**
     * An Event Hanler for physiciansubmit Custom Event
     *
     * @param {object} event reference
     * @return {NA}
    */
    handlePhysicianData(event){
        this.physicianData = event.detail;
        this.physicianId = this.physicianData.Id;
    }
}