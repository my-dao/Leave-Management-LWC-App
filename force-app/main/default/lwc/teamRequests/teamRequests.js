import { api, LightningElement, wire } from "lwc";
import getLeaveRequests from "@salesforce/apex/LeaveApplicationController.getLeaveRequests";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Id from "@salesforce/user/Id";
import { refreshApex } from "@salesforce/apex";

const COLUMNS = [
    { label: "Request Id", fieldName: "Name", cellAttributes: { class: { fieldName: "cellClass" } } },
    { label: "From Date", fieldName: "Start_Date__c", cellAttributes: { class: { fieldName: "cellClass" } } },
    { label: "To Date", fieldName: "End_Date__c", cellAttributes: { class: { fieldName: "cellClass" } } },
    { label: "Leave Type", fieldName: "Leave_Type__c", cellAttributes: { class: { fieldName: "cellClass" } } },
    { label: "Status", fieldName: "Status__c", cellAttributes: { class: { fieldName: "cellClass" } } },
    { label: "Description", fieldName: "Description__c", cellAttributes: { class: { fieldName: "cellClass" } } },
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
export default class TeamRequests extends LightningElement {
    columns = COLUMNS;

    leavesReqeusts = [];
    leavesRequestsWireResult;
    showModalPopup = false;
    objectApiName = "Leave_Request__c";
    recordId = "";
    currentUserId = Id;
    @wire(getLeaveRequests)
    wiredMyLeaves(result) {
        this.leavesRequestsWireResult = result;
        if (result.data) {
            this.leavesReqeusts = result.data.map((a) => ({
                ...a,
                userName: a.Employee__r.Name,
                isEditDisabled: a.Status__c !== "Pending"
            }));
        }
        if (result.error) {
            console.log("Error occured while fetching my leaves- ", result.error);
        }
    }

    get noRecordsFound() {
        return this.leavesReqeusts.length == 0;
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
        this.refreshGrid();
    }

    @api
    refreshGrid() {
        refreshApex(this.leavesRequestsWireResult);
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