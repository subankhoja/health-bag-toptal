import { LightningElement, track ,wire} from 'lwc';
import getSpecializations from '@salesforce/apex/AppHandler.getSpecializations';

export default class SpecializationForm extends LightningElement {
    
    @track showSpecializations;
    @track specializations;
    connectedCallback(){
        this.showSpecializations = true;
    }

    @wire(getSpecializations)
    wiredAccounts({ error, data }) {
        if (data) {
            this.specializations = data;
            console.log('=> ',this.specializations.length);
        } else if (error) {
            // @todo Error Handling
        }
    }

    onSpecializationSelection(event) {

        this.resetUiStatus();

        event.currentTarget.textContent = 'Selected';
        event.currentTarget.classList.add('selected');

        const selectedSpecializationId = event.currentTarget.dataset.id
        const selectedSpecialization = this.specializations.filter(specialization => specialization.Id === selectedSpecializationId);
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

    resetUiStatus(){
        for(let card of this.template.querySelectorAll('.hb-card')){
            card.querySelector('.hb-info-container > button').classList.remove('selected');
        }
    }
}

