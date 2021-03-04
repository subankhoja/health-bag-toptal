import { LightningElement, track ,wire} from 'lwc';
import getSpecializations from '@salesforce/apex/AppHandler.getSpecializations';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class SpecializationForm extends LightningElement {
    
    @track showSpecializations; // defines whether specialization Form is Shown or not...
    @track specializations; // reference to List of Specializations
    
    /**
     * Connectedcall back which initialize below things
     *
     * showSpecializations => false
    */
    connectedCallback(){
        this.showSpecializations = true;
    }

     /**
     * Wire Service to get specialization.
     * 
     * @param {ApexMethod} getSpecializations
     * @return {NA}
    */
    @wire(getSpecializations)
    wiredAccounts({ error, data }) {
        if (data) {
            this.specializations = data;
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: `Error while retrieving Specializations. Error => ${error}`,
                    variant: 'Error',
                }),
            );
        }
    }

    /**
     * This will be called on Click of Specialization Select
     * Fire Custom Event to pass specialization Data to App Component 
     *  
     * @param {object} event reference
     * @return {NA}
    */
    onSpecializationSelection(event) {
        // Deselct All Previously Selected Specialization..
        this.resetUiStatus();

        // Changing Button Text to Selected.
        event.currentTarget.textContent = 'Selected';
        // Add selected class to highlight
        event.currentTarget.classList.add('selected');

        //Specialization Salesforce Id
        const selectedSpecializationId = event.currentTarget.dataset.id
        // Filering Selected Specialization Data
        const selectedSpecialization = this.specializations.filter(specialization => specialization.Id === selectedSpecializationId);
        
        // Creating Custom event to pass Data to App Component
        if(selectedSpecialization && selectedSpecialization.length === 1){
            const specializationDetailEvent = new CustomEvent(
                'specializationsubmit', 
                { 
                    detail: selectedSpecialization[0]
                }
            );

            // Dispatches the event.
            this.dispatchEvent(specializationDetailEvent);
        }
    }

    /**
     * This will be called on selection of Specialization
     *  > Remove Selected Class from All Specialization
     * 
     * @param  {NA}
     * @return {NA}
    */
    resetUiStatus(){
        for(let card of this.template.querySelectorAll('.hb-card')){
            card.querySelector('.hb-info-container > button').classList.remove('selected');
        }
    }
}