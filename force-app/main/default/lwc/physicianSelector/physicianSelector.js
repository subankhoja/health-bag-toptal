import { LightningElement ,track,wire,api} from 'lwc';
import getPhysicians from '@salesforce/apex/AppHandler.getPhysicians';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class PhysicianSelector extends LightningElement {

    @track showPhysicians; // defines whether Physician Form is Shown or not...
    
    physicians; // reference to List of Physician
    _specializationId; // Reference Specialization Id
    

     /**
     * Getter Setter for specializationId
     *
    */

    @api
    get specializationId(){
        return this._specializationId;
    }
    set specializationId(val){
        if(val){
            this._specializationId = val;
        }
    }

    
    /**
     * Connectedcall back which initialize below things
     *
     * showPhysicians => false
    */
    connectedCallback(){
        this.showPhysicians = false;
    }

    /**
     * Wire Service to get Physicians based on Specialization.
     * 
     * @param {ApexMethod} getPhysicians
     * @param {object} specializationId
     * @return {NA}
    */

    @wire(getPhysicians , {specializationId:'$_specializationId'})
    getPhysiciansCallout({ error, data }) {
        if (data) {
            this.physicians = data;
            this.showPhysicians = true;
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: `Error while Retieving Physicians. Error => ${error}`,
                    variant: 'Error',
                }),
            );
        }
    }

    /**
     * This will be called on Click of Physician
     *  > Fire a Custom Event to Pass Physician Data to App Component
     * @param {object} event reference
     * @return {NA}
    */
    onPhysicianSelection(event){
        
        // Deselct All Previously Selected Physicians..
        this.resetUiStatus();
        // Add selected class to highlight
        event.currentTarget.classList.add('selected');

        // Physician Salesforce Id
        const selectedPhysicianId = event.currentTarget.dataset.id;
        // Filtering Selcted Physician Data
        const selectedPhysician = this.physicians.filter(physician => physician.Id === selectedPhysicianId);
        
        // Creating Custom Event to pass Data to App Component
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
    }

    /**
     * This will be called on selection of Physician
     *  > Remove Selected Class from All Physician
     * 
     * @param  {NA}
     * @return {NA}
    */
    resetUiStatus(){
        for(let ele of this.template.querySelectorAll('.physicians-container > button')){
            ele.classList.remove('selected');
        }
    }
}