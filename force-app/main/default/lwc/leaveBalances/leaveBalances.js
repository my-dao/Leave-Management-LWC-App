import { LightningElement, wire } from "lwc";
import getLeaveBalance from "@salesforce/apex/LeaveApplicationController.getLeaveBalance";

export default class LeaveBalances extends LightningElement {
    balance = {};

    @wire(getLeaveBalance)
    wiredLeaveBalance(result) {
        console.log("-----> balance", result);
        this.balance = result.data ? result.data : {};
    }

    // Here you would typically load the actual leave balances from the server using an @wire service or an imperative call to an Apex method
}