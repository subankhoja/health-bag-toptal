import { LightningElement, track } from 'lwc';

export default class App extends LightningElement {

    @track patientData;
    @track specializationData;
    @track appointmentData;
    @track physicianData;

    get showConfirm() {
        return (
            this.patientData && this.specializationData && this.appointmentData && this.physicianData
        );
    }

    handlePatientData(event){
        this.patientData = event.detail;
        console.log(JSON.stringify(this.patientData));
    }

    handleSpecializationData(event){
        this.specializationData = event.detail;
        console.log(JSON.stringify(this.specializationData));
    }

    handleAppointmentData(event){
        this.appointmentData = event.detail;
        console.log(JSON.stringify(this.appointmentData));
    }

    handlePhysicianData(event){
        this.physicianData = event.detail;
        console.log(JSON.stringify(this.physicianData));
    }
}