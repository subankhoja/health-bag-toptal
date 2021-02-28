import { LightningElement, track } from 'lwc';

export default class AppointmentForm extends LightningElement {
    @track showAppointmentForm;
    @track appointmentDate;
    @track minDate;
    @track minTime;

    @track btnName;
    selectedTime;

    connectedCallback(){
        this.showAppointmentForm = true;
        this.minDate = new Date().getFullYear()+'-'+(new Date().getMonth()+1)+'-'+new Date().getDate();
        this.minTime = new Date().getHours()+2;
        this.btnName = 'Save';
    }

    onAppointmentTimeSelection(event){
        
        this.resetUiStatus();

        event.currentTarget.classList.add('selected');

        this.selectedTime = event.currentTarget.textContent;

        console.log('selectedTime',this.selectedTime);
        
    }

    resetUiStatus(){
        for(let ele of this.template.querySelectorAll('.time-container > button')){
            ele.classList.remove('selected');
        }
    }

    handleValidation(event){
        
        if(event.currentTarget.checkValidity()){
            this.appointmentDate = event.currentTarget.value;
        }
    }

    saveAppointmentDetails(event){

        this.template.querySelector('.appointmentDate').reportValidity();

        if(this.appointmentDate && this.selectedTime){
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
            
            this.btnName = 'Saved';
            setTimeout(()=>{
                this.btnName = 'Save';
            },1500,this);

        }
        
    }

}