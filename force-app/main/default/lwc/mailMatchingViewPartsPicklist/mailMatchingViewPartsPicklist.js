import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import getFieldNames from '@salesforce/apex/MailMatchingGetChoiceListForFlow.getFieldNames';

export default class MailMatchingViewPartsPicklist extends LightningElement {
  @api objectName;
  @api selectedLabel;
  @api value = '';
  @api label = 'フィールド名';
  @api required = false;

  selectOptions = [];

  connectedCallback() {
    getFieldNames({
      ObjectName: this.objectName
    }).then(data => {
      const jsonData = JSON.parse(data);
      this.selectOptions = [{label:'----', value:undefined}, ...jsonData];
      this.value = this.value.toLowerCase();
      this.selectedLabel = this.value;
    });
  }

  handleSelectChange(e) {
    this.selectedLabel = e.target.value;
  }

  handleNext() {
    if (this.availableActions.find(action => action === 'NEXT')) {
      const navigateNextEvent = new FlowNavigationNextEvent();
      this.dispatchEvent(navigateNextEvent);
    }
  }
}