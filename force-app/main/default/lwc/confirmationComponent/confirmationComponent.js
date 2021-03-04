import { LightningElement, track ,api,wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import createPatientAppointmentAndEvent from '@salesforce/apex/AppHandler.createPatientAppointmentAndEvent';

export default class ConfirmationComponent extends NavigationMixin(LightningElement){
    
    @track showConfirmationComponent; // defines whether Confirmation Component is Shown or not...
    @track loadSpinner; // variable to toggle Spinner

    @api patientData; // Reference to Patient Data
    @api specializationData; // Reference to Specialization Data
    @api appointmentData; // Reference to Appointment Data
    @api physicianData; // Reference to Physician Data
    

    /**
     * Connectedcall back which initialize below things
     *
     * showConfirmationComponent => false
     * loadSpinner => false
    */
    connectedCallback(){
        this.showConfirmationComponent = true;
        this.loadSpinner = false;
    }

    /**
     * This will be called on click of Confirm Button
     *  > Create Patient Record in Salesforce
     *  > Create Appointment Record in Salesforce
     *  > Create Event Record in Salesforce for Physician
     *  > Navigate to Created Appointment Record.
     * @param {object} event reference
     * @return {NA}
    */
    confirmAppointment(event){
        // Making Button Read only

        let confirmBtnEle = event.currentTarget; //reference to Confrim Button Dom Element..
        confirmBtnEle.classList.add('hb-btn-read-only');
        
        this.loadSpinner = true; // Toggling Spinner to indicate Processing
        
        //Creatimg Pateint , Appointment and Event
        createPatientAppointmentAndEvent(
            {
                patientDetails        : this.patientData,
                appointmentDetails    : this.appointmentData,
                physicianDetails      : this.physicianData,
                specializationDetails : this.specializationData
            }
        ).then(data => {
            //Success.
            this.loadSpinner = false; // Toggle Spinner
            confirmBtnEle.classList.remove('hb-btn-read-only'); // Toggle Button Read only Status
            
            if(data){
                //Navigate to Appointment Record.
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: data,
                        actionName: 'view'
                    }
                });
            }else{
                this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something went wrong! Please try again.',
                    variant: 'Error',
                }),
            );
            }
            
            
        }).
        catch(error => {
            // Event Cration Failed.
            this.loadSpinner = false; // Toggle Spinner
            confirmBtnEle.classList.remove('hb-btn-read-only'); // Toggle Button Read only Status
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while Creating Event',
                    variant: 'error',
                }),
            );
        });
             
    }

    /**
     * This will be called on Click Of Cancel
     *  > Reload the Page
     *  
     * @return {NA}
    */
    cancelAppointment(){
        window.location.reload();
    }
}