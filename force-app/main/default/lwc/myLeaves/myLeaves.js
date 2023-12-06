import { LightningElement, wire } from "lwc";
import getMyLeaves from "@salesforce/apex/LeaveApplicationController.getMyLeaves";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Id from "@salesforce/user/Id";
import { refreshApex } from "@salesforce/apex";

const COLUMNS = [
  {
    label: "Request Id",
    fieldName: "Name",
    cellAttributes: { class: { fieldName: "cellClass" } }
  },
  {
    label: "From Date",
    fieldName: "Start_Date__c",
    cellAttributes: { class: { fieldName: "cellClass" } }
  },
  {
    label: "To Date",
    fieldName: "End_Date__c",
    cellAttributes: { class: { fieldName: "cellClass" } }
  },
  {
    label: "Leave Type",
    fieldName: "Leave_Type__c",
    cellAttributes: { class: { fieldName: "cellClass" } }
  },
  {
    label: "Status",
    fieldName: "Status__c",
    cellAttributes: { class: { fieldName: "cellClass" } }
  },
  {
    label: "Description",
    fieldName: "Description__c",
    cellAttributes: { class: { fieldName: "cellClass" } }
  },
  {
    label: "Approval Comments",
    fieldName: "Approval_Comments__c",
    cellAttributes: { class: { fieldName: "cellClass" } }
  },
  {
    type: "button",
    typeAttributes: {
      label: "Edit",
      name: "Edit",
      title: "Edit",
      value: "edit",
      disabled: { fieldName: "isEditDisabled" }
    },
    cellAttributes: { class: { fieldName: "cellClass" } }
  }
];
export default class MyLeaves extends LightningElement {
  columns = COLUMNS;

  myLeaves = [];
  myLeavesWireResult;
  showModalPopup = false;
  objectApiName = "Leave_Request__c";
  recordId = "";
  currentUserId = Id;
  @wire(getMyLeaves)
  wiredMyLeaves(result) {
    this.myLeavesWireResult = result;
    if (result.data) {
      this.myLeaves = result.data.map((a) => ({
        ...a,
        isEditDisabled: a.Status__c !== "Pending"
      }));
    }
    if (result.error) {
      console.log("Error occured while fetching leaves - ", result.error);
    }
  }

  get noRecordsFound() {
    return this.myLeaves.length == 0;
  }

  newRequestClickHandler() {
    this.showModalPopup = true;
    this.recordId = "";
  }
  popupCloseHandler() {
    this.showModalPopup = false;
  }

  rowActionHandler(event) {
    this.showModalPopup = true;
    this.recordId = event.detail.row.Id;
  }

  successHandler(event) {
    this.showModalPopup = false;
    this.showToast("Data saved successfully");
    refreshApex(this.myLeavesWireResult);
  }
  submitHandler(event) {
    event.preventDefault();
    const fields = { ...event.detail.fields };
    fields.Status__c = "Pending";
    if (new Date(fields.Start_Date__c) > new Date(fields.End_Date__c)) {
      this.showToast(
        "From date should not be grater then to date",
        "Error",
        "error"
      );
    } else if (new Date() > new Date(fields.Start_Date__c)) {
      this.showToast(
        "From date should not be less then Today",
        "Error",
        "error"
      );
    } else {
      this.refs.leaveReqeustFrom.submit(fields);
    }
  }
  showToast(message, title = "success", variant = "success") {
    const event = new ShowToastEvent({
      title,
      message,
      variant
    });
    this.dispatchEvent(event);
  }
}