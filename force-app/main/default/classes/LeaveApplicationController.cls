/**
 * This class provides functionality related to managing leave applications.
 * It includes methods for retrieving leave requests, calculating leave balances,
 * and handling different types of leaves such as annual, sick, and volunteer leaves.
 */
public with sharing class LeaveApplicationController {
    // Constants representing different types of leaves
    public static final String ANNUAL_LEAVE = 'Annual Leave';
    public static final String SICK_LEAVE = 'Sick Leave';
    public static final String WORK_FROM_ANYWHERE = 'Work from Anywhere';
    public static final String VOLUNTEER_LEAVE = 'Volunteer Leave';
    public static final String UNPAID_LEAVE = 'Unpaid Leave';
    public static final String BEREAVEMENT_LEAVE = 'Bereavement Leave';
    public static final String APPROVED_STATUS = 'Approved';

    /**
     * Retrieves the current user's leave requests from the Leave_Request__c object.
     * @return A list of Leave_Request__c records for the current user.
     */
    @AuraEnabled(cacheable=true)
    public static List<Leave_Request__c> getMyLeaves() {
        try {
            // Query to fetch leave requests for the current user
            return [
                SELECT
                    Id,
                    Name,
                    Start_Date__c,
                    End_Date__c,
                    Leave_Type__c,
                    Description__c,
                    Approval_Comments__c,
                    Status__c
                FROM Leave_Request__c
                WHERE Employee__c = :UserInfo.getUserId()
                ORDER BY CreatedDate DESC
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Retrieves leave requests for the subordinates of the current user.
     * @return A list of Leave_Request__c records for the current user's subordinates.
     */
    @AuraEnabled(cacheable=true)
    public static List<Leave_Request__c> getLeaveRequests() {
        try {
            // Query to fetch leave requests for subordinates of the current user
            return [
                SELECT
                    Id,
                    Name,
                    Start_Date__c,
                    End_Date__c,
                    Leave_Type__c,
                    Description__c,
                    Approval_Comments__c,
                    Status__c,
                    Employee__r.ManagerId,
                    Employee__r.Name
                FROM Leave_Request__c
                WHERE Employee__r.ManagerId = :UserInfo.getUserId()
                ORDER BY CreatedDate DESC
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Retrieves and calculates the current user's leave balance.
     * @return An instance of LeaveBalance with calculated leave hours.
     */
    @AuraEnabled(cacheable=true)
    public static LeaveBalance getLeaveBalance() {
        LeaveBalance balance = new LeaveBalance();
        try {
            // Load leave entitlements and deduct approved leaves from the balance
            balance.loadLeaveEntitlement();
            for (Leave_Request__c request : getMyLeaves()) {
                balance.deductApprovedLeaveHours(request);
            }
            return balance;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Inner class to handle leave balance calculation.
     */
    public class LeaveBalance {
        @AuraEnabled
        public Decimal annualLeaveHours { get; set; }
        @AuraEnabled
        public Decimal sickLeaveHours { get; set; }
        @AuraEnabled
        public Decimal workFromAnywhere { get; set; }
        @AuraEnabled
        public Decimal volunteerLeave { get; set; }
        @AuraEnabled
        public Decimal unpaidLeave { get; set; }
        @AuraEnabled
        public Decimal bereavementLeave { get; set; }

        /**
         * Loads leave entitlements from a custom setting or object.
         */
        public void loadLeaveEntitlement() {
            Leave_Entitlements__c leaveEntitlement = Leave_Entitlements__c.getInstance();
            // Assign leave entitlements from custom settings
            annualLeaveHours = leaveEntitlement.Annual_Leave__c;
            sickLeaveHours = leaveEntitlement.Sick_Leave__c;
            workFromAnywhere = leaveEntitlement.Work_From_Anywhere__c;
            volunteerLeave = leaveEntitlement.Volunteer_Leave__c;
            unpaidLeave = 0; // No entitlement value for unpaid leave
            bereavementLeave = leaveEntitlement.Bereavement_Leave__c;
        }

        /**
         * Deducts approved leave hours from the user's leave balance based on the type of leave.
         * @param request The Leave_Request__c record to deduct hours from.
         */
        public void deductApprovedLeaveHours(Leave_Request__c request) {
            if (request.Status__c != LeaveApplicationController.APPROVED_STATUS) {
                return; // Skip if the leave request is not approved
            }

            // Calculate the number of weekdays and hours to deduct
            Integer daysToDeduct = calculateTotalWeekdays(request.Start_Date__c, request.End_Date__c);
            Decimal hoursToDeduct = daysToDeduct * 8; // Assuming 8 hours per weekday

            // Deduct hours based on the type of leave
            String leaveType = request.Leave_Type__c;
            if (leaveType == LeaveApplicationController.ANNUAL_LEAVE) {
                annualLeaveHours -= hoursToDeduct;
            } else if (leaveType == LeaveApplicationController.SICK_LEAVE) {
                sickLeaveHours -= hoursToDeduct;
            } else if (leaveType == LeaveApplicationController.WORK_FROM_ANYWHERE) {
                workFromAnywhere -= daysToDeduct;
            } else if (leaveType == LeaveApplicationController.VOLUNTEER_LEAVE) {
                volunteerLeave -= hoursToDeduct;
            } else if (leaveType == LeaveApplicationController.UNPAID_LEAVE) {
                unpaidLeave += hoursToDeduct;
            } else if (leaveType == LeaveApplicationController.BEREAVEMENT_LEAVE) {
                bereavementLeave -= hoursToDeduct;
            }
        }

        /**
         * Helper method to calculate the total number of weekdays between two dates.
         * @param startDate The start date of the period.
         * @param endDate The end date of the period.
         * @return The total number of weekdays in the given date range.
         */
        private Integer calculateTotalWeekdays(Date startDate, Date endDate) {
            Integer totalWeekdays = 0;
            Date currentDate = startDate;
            while (currentDate <= endDate) {
                // Check if the current date is a weekday
                DateTime currentDateTime = DateTime.newInstance(currentDate, Time.newInstance(0, 0, 0, 0));
                String dayOfWeek = currentDateTime.format('E');
                if (dayOfWeek != 'Sat' && dayOfWeek != 'Sun') {
                    totalWeekdays++;
                }
                currentDate = currentDate.addDays(1);
            }
            return totalWeekdays;
        }
    }
}