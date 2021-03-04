import { LightningElement, track , api , wire} from 'lwc';
import getAppointmentEvents from '@salesforce/apex/AppHandler.getAppointmentEvents';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const DAY_TO_EXCLUDE = [0,6]; // Integer Reference of Weekends i.e Saturday , Sunday

export default class AppointmentForm extends LightningElement {
    
    @track showAppointmentForm; // defines whether Appointment Form is Shown or not...
    @track appointmentDate; // Reference to Selected Appointment Date
    @track minDate; // Minimun Date a user can Select
    @track minTime; // Minimum time user can allow to select
    @track btnName; // Btn Name based on formStatus i.e Save or Edit
    @track timeSlots; // An Array that contains time slots users can select
    @track showSaveButton; // Define whether Save Button is visible or not.


    formStatus; // Form Status defines state of the Form i.e readOnly or Editable
    selectedTime; // Reference to Selected Appointment Date
    _physicianId; // Physician Id based on which time slots are presented
    _patientId; // patient Id based on which time slots are presented
    
    /**
     * Getter Setter for physicianId
     *
    */

    @api
    get physicianId(){
        return this._physicianId;
    }
    set physicianId(val){
        if(val){
            this._physicianId = val;
            this.showAppointmentForm = true;
            this.appointmentDate = null;
            this.timeSlots = null;
            this.showSaveButton = false;
        }
    }

     /**
     * Getter Setter for patientId
     *
    */

    @api
    get patientId(){
        return this._patientId;
    }
    set patientId(val){
        if(val){
            this._patientId = val;
        }
    }

   

    /**
     * Connectedcall back which initialize below things
     *
     * showAppointmentForm => false
     * minDate => today in 'yyyy-mm-dd'
     * minTime => currentHour + 2
     * btnName => Save
     * showSaveButton => false
     * formStatus => false
     * _patientId => ''
    */

    connectedCallback(){
        this.showAppointmentForm = false;
        this.minDate = new Date().getFullYear()+'-'+(new Date().getMonth()+1)+'-'+new Date().getDate();
        this.minTime = new Date().getHours()+2;
        this.btnName = 'Save';
        this.showSaveButton = false
        this.formStatus = false;
        this._patientId = '';
    }

    /**
     * This will be called on selection of Time Slots.
     *  > Add Selected class to DOM Element for Highlighting
     *  > Assign value to selectedTime variable
     * 
     * @param {object} event reference
     * @return {NA}
    */
    onAppointmentTimeSelection(event){
        this.resetUiStatus();
        event.currentTarget.classList.add('selected');
        this.selectedTime = event.currentTarget.textContent;
        this.showSaveButton = true;
    }

    /**
     * This will be called on selection of Time Slots.
     *  > Remove Selected Class from All Time Slots
     *  > Assign value to selectedTime variable
     * 
     * @param  {NA}
     * @return {NA}
    */
    resetUiStatus(){
        for(let ele of this.template.querySelectorAll('.time-container > button')){
            ele.classList.remove('selected');
        }
    }

    /**
     * This will be called on Change Event of Appointment Date Input
     *  > Check if Date is in Past [invalid Scenario]
     *  > Check if Day is Saturday or Sunday [invalid Scenario]
     *  > If Not Above Assign value to appointmentDate
     *  > Call getAppointments to get Time Slots based on Physician Id and appointmentDate
     * @param {object} event reference
     * @return {NA}
    */
    handleValidation(event){
        
        this.timeSlots = null;
        this.showSaveButton = false;
        // If value is Not Blank Check if its Saturday/Sunday Show Custom Message
        if(event.currentTarget.value){
            const selectedDate = new Date(event.currentTarget.value);
            if(DAY_TO_EXCLUDE.includes(selectedDate.getDay())){
                event.currentTarget.setCustomValidity('Appointments can only be booked from Mon to Friday.');
                event.currentTarget.reportValidity();
                this.showSaveButton = false;
            }else{
                //If Selected Date is Not Weekend Remove Above Custom Validation
                event.currentTarget.setCustomValidity('');
                event.currentTarget.reportValidity();
            }
        }
        // Check if Date is Valid based on minDate
        if(event.currentTarget.checkValidity()){
            this.appointmentDate = event.currentTarget.value;
            // Call getAppointmentEvents Apex Methods to get Time Slots
            getAppointmentEvents({appointmentDate:this.appointmentDate,physicianId:this.physicianId,patientId:this.patientId,minTime:this.minTime})
            .then(data => {
                this.timeSlots = data;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: `Error while getting Time Slots. Error => ${error}`,
                        variant: 'Error',
                    }),
                );
                console.error('Error while getting Time Slots => ',error);
            });
        }
    }

    /**
     * This will be called on Click of Save/Edit Button
     *  > If formStatus is false [i.e button Name is Edit] 
     *      > make all the fields editable
     *      > toggle formStatus
     *      > change Button Name to Save
     * 
     *  > If formStatus is true [i.e button Name is Save] 
     *      > Create an custom event appointmentsubmit to pass data to app component
     *      > toggle formStatus.
     *      > change Button Name to Edit.
     *      > Make form Read Only.
     * @param {object} event reference
     * @return {NA}
    */
    saveAppointmentDetails(event){

        // Validate Appointment Date Input
        this.template.querySelector('.appointmentDate').reportValidity();
        //Toggle Form Status
        this.formStatus = !this.formStatus;
        //if FormStatus is False
        if(!this.formStatus) {
            this.btnName = 'Save'; // change Button Name to Save
            this.makeFormReadonly(this.formStatus);// > make all the fields editable
            return;
        }
        //if FormStatus is true
        if(this.appointmentDate && this.selectedTime && this.formStatus){
            //Create an custom event to pass Appointment Date/Time to app component
            const appointmentDetailEvent = new CustomEvent(
                'appointmentsubmit', 
                { 
                    detail: {
                        appointmentDate : {
                            date : this.appointmentDate,
                            time : this.selectedTime
                        }
                    } 
                }
            );
            // Dispatches the event.
            this.dispatchEvent(appointmentDetailEvent);
            // Make All Fields Read Only
            this.makeFormReadonly(this.formStatus);
            this.btnName = 'Edit'; // Change Button Name to Edit

            // Logging Custom Event
            console.log(
                {
                "name":'appointmentsubmit',
                'origin':'AppointmentForm',
                'data': {
                    appointmentDate : {
                        date : this.appointmentDate,
                        time : this.selectedTime
                    }
                }
            });
        }
        
    }

    /**
     *  This function will field Appointment Fields Read Only based on formStatus
     *  
     * @param {boolean} _readOnly 
     * @return {NA}
    */
    makeFormReadonly(_readOnly){
        // Toggling Status of Appointment Date Input
        this.template.querySelector('.appointmentDate').readOnly = _readOnly;
        // getting DOM Reference of TimeSlots
        let timeSlotsEleList = this.template.querySelectorAll('.appointment-btn');
        // Looping through Time Slots DOM Element to change the Status.
        timeSlotsEleList.forEach(timeSlotEle => {
            _readOnly ? timeSlotEle.classList.add('hb-btn-read-only') : timeSlotEle.classList.remove('hb-btn-read-only');
        });
    }

}