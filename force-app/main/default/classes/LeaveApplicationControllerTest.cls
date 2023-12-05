@isTest
private class LeaveApplicationControllerTest {
    @TestSetup
    static void createTestUser() {
        // Create test user
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User employee = new User(
            Username = 'employee123456@test.com',
            Alias = 'empl',
            Email = 'employee@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Employee',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = standardProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            ManagerId = UserInfo.getUserId()
        );
        insert employee;

        // Assign the Leave_Request_permission_set to the test user
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Leave_Request_permission_set' LIMIT 1];
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = employee.Id);
        insert psa;
    }

    static void createTestData() {
        User employee = [SELECT Id FROM User WHERE Username = 'employee123456@test.com' LIMIT 1];
        
        String[] leaveTypes = new List<String>{
            'Annual Leave',
            'Sick Leave',
            'Work from Anywhere',
            'Volunteer Leave',
            'Unpaid Leave',
            'Bereavement Leave'
        };

        // Create a list to hold Leave_Request__c records
        List<Leave_Request__c> leaveRequests = new List<Leave_Request__c>();

        // Iterate over the leave types and create leave request records
        for (String leaveType : leaveTypes) {
            Leave_Request__c leaveRequest = new Leave_Request__c(
                Employee__c = employee.Id,
                Start_Date__c = Date.today(),
                End_Date__c = Date.today().addDays(5),
                Leave_Type__c = leaveType,
                Status__c = 'Approved'
            );
            leaveRequests.add(leaveRequest);
        }

        //Create pending leave request
        Leave_Request__c pendingRequest = new Leave_Request__c(
            Employee__c = employee.Id,
            Start_Date__c = Date.today().addDays(10),
            End_Date__c = Date.today().addDays(15),
            Leave_Type__c = 'Sick Leave',
            Status__c = 'Pending'
        );
        leaveRequests.add(pendingRequest);

        // Insert the leave request records
        insert leaveRequests;

        // Create custom setting
        Leave_Entitlements__c leaveEntitlement = new Leave_Entitlements__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Annual_Leave__c = 120,
            Sick_Leave__c = 80,
            Work_From_Anywhere__c = 10,
            Volunteer_Leave__c = 16,
            Bereavement_Leave__c = 24
        );
        insert leaveEntitlement;
    }

    @isTest
    static void testGetMyLeaves() {
        createTestData();
        // Retrieve the test employee user
        User testEmployee = [SELECT Id FROM User WHERE Username = 'employee123456@test.com' LIMIT 1];

        // Start the test execution context
        System.Test.startTest();

        // Run the code as the test employee
        System.runAs(testEmployee) {
            // Call the method
            List<Leave_Request__c> myLeaves = LeaveApplicationController.getMyLeaves();

            // Perform assertions
            System.assertNotEquals(null, myLeaves, 'The returned list should not be null.');
            // Additional assertions as needed
            // For example, you might want to check the number of leave requests returned
            System.assertEquals(2, myLeaves.size(), 'There should be 2 leave requests for the employee.');
        }

        // Stop the test execution context
        System.Test.stopTest();
    }

    // Test method for getLeaveRequests
    @isTest
    static void testGetLeaveRequests() {
        createTestData();

        System.Test.startTest();

        // Call the method
        List<Leave_Request__c> leaveRequests = LeaveApplicationController.getLeaveRequests();

        // Perform assertions
        System.assertNotEquals(null, leaveRequests, 'The returned list should not be null.');
        // Additional assertions as needed
        System.Test.stopTest();
    }

    // Test method for getLeaveBalance
    @isTest
    static void testGetLeaveBalance() {
        createTestData();

        System.Test.startTest();

        // Retrieve the test employee user
        User testEmployee = [SELECT Id FROM User WHERE Username = 'employee123456@test.com' LIMIT 1];

        // Run the code as the test employee
        System.runAs(testEmployee) {
            // Call the method
            LeaveApplicationController.LeaveBalance balance = LeaveApplicationController.getLeaveBalance();

            // Perform assertions
            System.assertNotEquals(null, balance, 'The returned balance should not be null.');
            // Additional assertions to check if the balance is calculated correctly
        }
        System.Test.stopTest();
    }
}