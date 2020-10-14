import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {getRecord } from 'lightning/uiRecordApi';
import { createRecord } from 'lightning/uiRecordApi';

import SERVICE_REQUEST_OBJECT from '@salesforce/schema/Service_Request__c';

import NAME_FIELD from '@salesforce/schema/Account.Name';
import ID_FIELD from '@salesforce/schema/Account.Id';
import PHONE_FIELD from '@salesforce/schema/Account.Phone';
import BILLINGSTREET_FIELD from '@salesforce/schema/Account.BillingStreet';
import BILLINGCITY_FIELD from '@salesforce/schema/Account.BillingCity';
import BILLINGSTATE_FIELD from '@salesforce/schema/Account.BillingState';
import BILLINGPOSTALCODE_FIELD from '@salesforce/schema/Account.BillingPostalCode';

import SR_ACCOUNT_FIELD from '@salesforce/schema/Service_Request__c.Account__c';
import SR_CITY_FIELD from '@salesforce/schema/Service_Request__c.City__c';
import SR_CUSTOMER_NAME_FIELD from '@salesforce/schema/Service_Request__c.Customer_Name__c';
import SR_POSTAL_CODE_FIELD from '@salesforce/schema/Service_Request__c.Postal_Code__c';
import SR_PHONE_FIELD from '@salesforce/schema/Service_Request__c.Phone__c';
import REQUEST_DETAILS_FIELD from '@salesforce/schema/Service_Request__c.Request_Details__c';
import SR_STATE_FIELD from '@salesforce/schema/Service_Request__c.State__c';
import SR_STREET_FIELD from '@salesforce/schema/Service_Request__c.Street__c';
import SR_COUNTRY_FIELD from '@salesforce/schema/Service_Request__c.Country__c'; 
import SR_STATUS_FIELD from '@salesforce/schema/Service_Request__c.Status__c';

const accountFields = [NAME_FIELD,ID_FIELD,PHONE_FIELD,BILLINGSTREET_FIELD,BILLINGCITY_FIELD,BILLINGSTATE_FIELD,BILLINGPOSTALCODE_FIELD];
export default class ServiceRequest extends LightningElement {

    @api recordId;
    @track acctName;
    @track acctPhone;
    @track acctStreet;
    @track acctCity;
    @track acctState;
    @track acctPostalCode; 
    @track acctCountry = "US";

    
    @wire(getRecord,{recordId: '$recordId', fields: accountFields})
    accountRecord({error, data}) {
        if (error) {
            console.log('error ' + JSON.stringify(error));
           let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading account',
                    message: message,
                    variant: 'error',
                }),
            );
        }
        else if (data) {
            this.acctName = data.fields.Name.value;
            this.acctPhone = data.fields.Phone.value;
            this.acctStreet = data.fields.BillingStreet.value;
            this.acctCity = data.fields.BillingCity.value;
            this.acctState = data.fields.BillingState.value;
            this.acctPostalCode = data.fields.BillingPostalCode.value;
            console.log('acct name ' + this.acctName);
        }

    }


    createServiceRequest() {
        const fields ={};
        const address = this.template.querySelector('lightning-input-address');
        const textArea = this.template.querySelector('lightning-textarea');
        const inputFields = this.template.querySelectorAll('lightning-input');
        inputFields.forEach(element => {
            if (element.name == 'customerName')
            {
                fields[SR_CUSTOMER_NAME_FIELD.fieldApiName] = element.value;
            }
            else if (element.name == 'customerPhone')
            {
                fields[SR_PHONE_FIELD.fieldApiName] = element.value;
            }
        });
        fields[SR_ACCOUNT_FIELD.fieldApiName] = this.recordId;
        fields[REQUEST_DETAILS_FIELD.fieldApiName] = textArea.value;
        fields[SR_STREET_FIELD.fieldApiName] = address.street;
        fields[SR_CITY_FIELD.fieldApiName] = address.city;
        fields[SR_STATE_FIELD.fieldApiName] = address.province;
        fields[SR_POSTAL_CODE_FIELD.fieldApiName] = address.postalCode;
        fields[SR_COUNTRY_FIELD.fieldApiName] = address.country;
        fields[SR_STATUS_FIELD.fieldApiName] = 'New';
        console.log('fields $$ ' + JSON.stringify(fields));
        const recordInput = { apiName: SERVICE_REQUEST_OBJECT.objectApiName, fields}; 
        createRecord(recordInput) 
        .then (sRequest => {
            this.serviceRequestId = sRequest.id;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Service Request Created',
                    variant: 'success',
                }),
            );
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating Service Request',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
    }


    //TODO CLEAR FORM AFTER SUCCESS

}