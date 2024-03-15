import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import getAccountDetailsById from '@salesforce/apex/GuestRecordDetailsController.getAccountDetailsById';
import updateAccountRecord from '@salesforce/apex/GuestRecordDetailsController.updateAccountRecord';

const fields = [
    'Account.First_Name__c',
    'Account.Last_Name__c',
    'Account.Phone',
    'Account.Email__c',
    'Account.Shoes_size__c',
    'Account.T_shirt_size__c',
    'Account.Date_of_Birth__c'

];

export default class GuestAccountDetails extends LightningElement {
    accountId;
    accountFields = {};
    error;
    //showSuccessMessage = false;

    tshirtSizeOptions = [
        { label: 'XS', value: 'XS' },
        { label: 'S', value: 'S' },
        { label: 'M', value: 'M' },
        { label: 'L', value: 'L' },
        { label: 'XL', value: 'XL' },
        { label: 'XXL', value: 'XXL' }
    ];

    // Fetch account details based on the recordId
    @wire(getAccountDetailsById, { recordId: '$accountId' })
    wiredAccount({ error, data }) {
        if (data) {
            this.error = undefined;
            this.accountFields = JSON.parse(JSON.stringify(data));
            console.log('Account details fetched successfully:', this.accountFields);
        } else if (error) {
            this.error = error;
            this.accountFields = undefined;
            console.error('Error fetching account details:', error);
        }
    }

    // Handle changes in the input fields
    handleInputChange(event) {
        console.log('event.target.name changed:', event.target.name);
        this.accountFields[event.target.name] = event.target.value;
        console.log('Input field changed:', this.accountFields);

    }

    // Handle save button click
    handleSave() {
        updateAccountRecord({ accountId: this.accountId, fieldsToUpdate: this.accountFields, isProfileCompleted: true })
            .then(() => {
                    const event = new ShowToastEvent({
                        title: 'Success',
                        message: 'Account updated successfully.',
                        variant: 'success'
                    });
                    this.dispatchEvent(event);
                    //this.showSuccessMessage = true;
                console.log('Account updated successfully');
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating account',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
                console.error('Error updating account:', error);
            });
    }

    // Handle changes in the URL parameters
    connectedCallback() {
        // Get the recordId from the URL
        const urlParams = new URLSearchParams(window.location.search);
        this.accountId = urlParams.get('id');
        console.log('Record ID:', this.accountId);
    }
}