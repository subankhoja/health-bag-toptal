import { LightningElement, track } from 'lwc';

export default class PatientForm extends LightningElement {

    @track firstName;
    @track lastName;
    @track email;
    @track phone;
    @track submitLabel;
    isValid = false;
    @track isSubmitted;

    formStatus = {
        firstName : false,
        lastName : false,
        email : false,
        phone : false,
    }

    connectedCallback(){
        this.firstName = '';
        this.lastName = '';
        this.email = '';
        this.phone = '';
        this.submitLabel = 'Save'
        this.isSubmitted = false;
    }

    cancelPatientForm(event){
        this.resetForm();
    }
    
    savePatientForm(event){
        //fire Event with details
        if(this.checkValidity()){
            this.isSubmitted = !this.isSubmitted;
            this.submitLabel = (this.isSubmitted)?'Edit':'Save';
            
            const patientDetailEvent = new CustomEvent(
                'patientsubmit', 
                { 
                    detail: {
                        firstName : this.firstName,
                        lastName : this.lastName,
                        email : this.email,
                        phone : this.phone
                    } 
                }
            );

            // Dispatches the event.
            this.dispatchEvent(patientDetailEvent);
        }
        
    }

    resetForm(){
        
        this.firstName = '';
        this.lastName = '';
        this.email = '';
        this.phone = '';
        this.isSubmitted = false;
        this.submitLabel = 'Save';
    }

    handleChange(event){

        if(event.currentTarget.value){
            if(event.currentTarget.name === 'phone'){
                if(event.currentTarget.value.match(/(7|8|9)\d{9}/)){
                    this[event.currentTarget.name] = event.currentTarget.value;
                    event.currentTarget.classList.remove('error');
                    this.formStatus[event.currentTarget.name] = true;
                }else{
                    this.formStatus[event.currentTarget.name] = false;
                    event.currentTarget.classList.add('error');
                }
            }else if(event.currentTarget.name === 'email'){
                if(event.currentTarget.value.match(/^[a-zA-Z]+[a-zA-Z0-9.+_-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,5}$/)){
                    this[event.currentTarget.name] = event.currentTarget.value;
                    event.currentTarget.classList.remove('error');
                    this.formStatus[event.currentTarget.name] = true;
                }else{
                    this.formStatus[event.currentTarget.name] = false;
                    event.currentTarget.classList.add('error');
                }
            }else{
                event.currentTarget.classList.remove('error');
                this.formStatus[event.currentTarget.name] = true;
                this[event.currentTarget.name] = event.currentTarget.value;
            }
        }else{
            this.formStatus[event.currentTarget.name] = false;
            this.isValid = false;
        }
    }

    checkValidity(){
        let isValid = true;
        for(let field in this.formStatus){
            this.formStatus[field] ? 
                this.template.querySelector(`input[name=${field}]`).classList.remove('error') :
                this.template.querySelector(`input[name=${field}]`).classList.add('error') 
            isValid = isValid && this.formStatus[field];
        }

        return isValid;
    }

}