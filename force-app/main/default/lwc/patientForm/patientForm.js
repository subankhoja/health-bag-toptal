import { LightningElement, track } from 'lwc';
import getPatientByEmail from '@salesforce/apex/AppHandler.getPatientByEmail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class PatientForm extends LightningElement {

    @track firstName; // First Name of Patient 
    @track lastName; // Last Name of Patient
    @track email; // Email of Patient
    @track phone; // Phone of Patient
    @track patientId; // Salesforce Id of Existing Patient
    @track submitLabel; // text of Save Button
    @track isSubmitted; // Reference to Form is Submitted or Not.
    @track showSearchForm; // Boolean to define whether show search form or not
    @track showInputForm; // Boolean to define whether show input form or not
    @track searchEmail; // Reference Search Email Input Value
    isValid = false; // reference to  patient Form Valid Sataus
    
    // Form Status Object Reference to Each Field Validation Status
    formStatus = {
        firstName : false,
        lastName : false,
        email : false,
        phone : false,
    }

    /**
     * Connectedcall back which initialize below things
     *
     * isSubmitted => false
     * showSearchForm => false
     * showInputForm => true
     * firstName => ''
     * lastName => ''
     * email => ''
     * phone => ''
     * patientId => '
     * searchEmail => ''
     * submitLabel => 'Save'
    */
    connectedCallback(){
        this.firstName = '';
        this.lastName = '';
        this.email = '';
        this.phone = '';
        this.searchEmail = '';
        this.patientId = ''
        this.submitLabel = 'Save'
        this.isSubmitted = false;
        this.showInputForm = false;
        this.showSearchForm = true;
    }

    /**
     * This will be called on click of Clear Button
     * This will Call resetForm function which will Clear All Field Values
     * 
     * @param {object} event reference
     * @return {NA}
    */
    cancelPatientForm(event){
        this.resetForm();
    }
    
    /**
     * This will be called on click of Save Button
     * Create a custom Event to pass data to App Component
     * 
     * @param {object} event reference
     * @return {NA}
    */
    savePatientForm(event){
        //fire Event with details
        if(this.checkValidity()){

            // Toggle form submission Status
            this.isSubmitted = !this.isSubmitted; 
            //Change button Label to Save or Edit based on Form Status
            this.submitLabel = (this.isSubmitted)?'Edit':'Save'; 
            
            // Create Custom Event with Patient Data
            const patientDetailEvent = new CustomEvent(
                'patientsubmit', 
                { 
                    detail: {
                        id : this.patientId,
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

    /**
     * This will Clear All Field Values
     * Set Form Submmision Status to False
     * Set Button Label to Save
     * 
     * @param {NA}
     * @return {NA}
    */
    resetForm(){
        this.patientId = '';
        this.firstName = '';
        this.lastName = '';
        this.email = '';
        this.phone = '';
        this.isSubmitted = false;
        this.submitLabel = 'Save';
    }

    /**
     * This will be called on change of Input Fields
     * validate Fields value based on Field Type
     *  
     * @param {object} event reference
     * @return {NA}
    */
    handleChange(event){
        // If Field Has Value
        if(event.currentTarget.value){
            // If Field is Phone Check if its Valid Number
            if(event.currentTarget.name === 'phone'){
                // If Field has Valid Value Remove Erros from Fields and change Field Validation Status to true
                if(event.currentTarget.value.match(/(7|8|9)\d{9}/)){
                    this[event.currentTarget.name] = event.currentTarget.value;
                    event.currentTarget.classList.remove('error');
                    if(this.formStatus.hasOwnProperty(event.currentTarget.name))
                        this.formStatus[event.currentTarget.name] = true;
                }
                // If Field has inValid  Value Add Erros from Fields and change Field Validation Status to false
                else{
                    if(this.formStatus.hasOwnProperty(event.currentTarget.name))
                        this.formStatus[event.currentTarget.name] = false;
                    event.currentTarget.classList.add('error');
                }
            }
            // If Field is Email Check if its Valid Number
            else if(event.currentTarget.name === 'email' || event.currentTarget.name === 'searchEmail'){
                // If Field has Valid Value Remove Erros from Fields and change Field Validation Status to true
                if(event.currentTarget.value.match(/^[a-zA-Z]+[a-zA-Z0-9.+_-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,5}$/)){
                    this[event.currentTarget.name] = event.currentTarget.value;
                    event.currentTarget.classList.remove('error');
                    if(this.formStatus.hasOwnProperty(event.currentTarget.name))
                        this.formStatus[event.currentTarget.name] = true;
                }
                // If Field has inValid  Value Add Erros from Fields and change Field Validation Status to false
                else{
                    if(this.formStatus.hasOwnProperty(event.currentTarget.name))
                        this.formStatus[event.currentTarget.name] = false;
                    event.currentTarget.classList.add('error');
                }
            }
            // Else Remove Erros from Fields and change Field Validation Status to true
            else{
                event.currentTarget.classList.remove('error');
                if(this.formStatus.hasOwnProperty(event.currentTarget.name))
                    this.formStatus[event.currentTarget.name] = true;
                this[event.currentTarget.name] = event.currentTarget.value;
            }
        }
        // If Field is Blank Add Errors and change Field Validation Status to false
        else{
            if(this.formStatus.hasOwnProperty(event.currentTarget.name))
                this.formStatus[event.currentTarget.name] = false;
            this.isValid = false;
        }
    }

    /**
     *  checks whether all Fields Are valid or not by looping through FormStatus Object.
     * 
     * @param {NA}
     * @return {boolean} true if form is valid or false
    */
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

     /**
     *  Show Input Form or Search Form based on Form Type
     * 
     * @param {formToShow} String
     * @return {NA}
    */
    toggleForm(formToShow){

        let inputBtnRef = this.template.querySelector('.input-toggle-btn'); // Reference to New Button
        let searchBtnRef = this.template.querySelector('.search-toggle-btn'); // Reference to Existing Button
        

        // If formType is INPUT show Input form and Highlight New Button
        if(formToShow === 'INPUT'){
            inputBtnRef.classList.add('selected');
            searchBtnRef.classList.remove('selected');
        }
        // If formType is SEARCH show SEarch form and Highlight Existing Button
        else if(formToShow === 'SEARCH'){
            inputBtnRef.classList.remove('selected');
            searchBtnRef.classList.add('selected');
        }
    }

    /**
     *  Show Input Form and Hide Search Form
     * 
     * @param {NA}
     * @return {NA}
    */
    toggleInputForm(event){
        this.showSearchForm = false;
        this.showInputForm = true;
        this.toggleForm('INPUT');
    }

    /**
     *  Show Search Form and Hide Input Form.
     * 
     * @param {NA}
     * @return {NA}
    */
    toggleSearchForm(event){
        this.showInputForm = false;
        this.showSearchForm = true;
        this.toggleForm('SEARCH');
    }

    /**
     *  Search Patient by Email.if Found toggle inputForm with value Populated
     * 
     * @param {object} event reference
     * @return {NA}
    */
    searchPatient(event){
        if(!this.searchEmail) return; // If Email is Blank

        //If Email is not blank search Patient by Email 
        getPatientByEmail({patientEmail:this.searchEmail})
        .then(data => {
            // If patient Found Populate Firld and navigate to Input Form
            if(data.success){
                this.firstName = data.firstName;
                this.lastName = data.lastName;
                this.email = data.email;
                this.phone = data.phone;
                this.patientId = data.id;
                this.formStatus.firstName = true;
                this.formStatus.lastName = true;
                this.formStatus.email = true;
                this.formStatus.phone = true;
                this.toggleInputForm();
            }
            // If patient Not Found Show error
            else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: `No patient found with email : ${this.searchEmail}`,
                        variant: 'error',
                    }),
                );
            }
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: `Error while Getting Patient Details. ERROR => ${error}`,
                    variant: 'error',
                }),
            );
        });
    }


}