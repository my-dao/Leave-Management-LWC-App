import { LightningElement, wire } from "lwc";
import getLeaveBalance from "@salesforce/apex/LeaveApplicationController.getLeaveBalance";

export default class LeaveBalances extends LightningElement {
  balance = {};

  @wire(getLeaveBalance)
  wiredLeaveBalance(result) {
    this.balance = result.data ? result.data : {};
  }
}
