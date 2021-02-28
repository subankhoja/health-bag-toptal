import { LightningElement ,track,wire} from 'lwc';
import getPhysicians from '@salesforce/apex/AppHandler.getPhysicians';
export default class PhysicianSelector extends LightningElement {

    physicians;
    specialization = 'Cardiology';
    @track showPhysicians;

    connectedCallback(){
        this.showPhysicians = true;
    }

    @wire(getPhysicians , {specialization:'$specialization'})
    getPhysiciansCallout({ error, data }) {
        if (data) {
            this.physicians = data;
            console.log('=> physicians',this.physicians.length);
        } else if (error) {
            // @todo Error Handling
        }
    }

    onPhysicianSelection(event){
        this.resetUiStatus();

        event.currentTarget.classList.add('selected');

        const selectedPhysicianId = event.currentTarget.dataset.id;
        const selectedPhysician = this.physicians.filter(physician => physician.Id === selectedPhysicianId);
        
        if(selectedPhysician && selectedPhysician.length){
            const PhysicianDetailEvent = new CustomEvent(
                'physiciansubmit', 
                { 
                    detail: selectedPhysician[0]
                }
            );
            // Dispatches the event.
            this.dispatchEvent(PhysicianDetailEvent);
        }

        console.log('selectedPhysician',selectedPhysician);
        
    }

    resetUiStatus(){
        for(let ele of this.template.querySelectorAll('.physicians-container > button')){
            ele.classList.remove('selected');
        }
    }
}