# Leave Management LWC App

## Overview

The Leave Management LWC App is a personal project and demo application for learning purposes. It's a basic yet functional tool for handling leave requests, tailored to demonstrate the essentials of a leave management system within an organization. The app, designed with user-friendliness in mind, serves to illustrate how employees and managers can interact with leave balances and requests. Structured as a Salesforce Lightning Web Component (LWC), this application offers a practical example of LWC capabilities in implementing core features of a leave management system.

![Leave Management App Screenshot](/images/leave_management.png)

## App LWC Structure

The app is built on a Lightning App Page and includes the following components:

1. **Leave Balances**: Displays the current user's leave balance.
2. **Leave Requests**: Divided into two sub-components:
   - **My Requests**: Shows the leave requests of the current user.
   - **My Team's Requests**: Displays the leave requests of the current user's team members.

Notes: Credit to [Leave Tracker App](https://github.com/forcefellow/Leave-Tracker-App) which is used as a base for my Leave Requests component.

## Data Model

The app incorporates the following objects to manage its data:

1. **Leave Requests**: This object has a lookup relationship to the User object via the `Employee` lookup field.
2. **User**: The User object contains a lookup to a manager User through the `Manager` lookup field.
3. **Leave Entitlements**: Implemented as a hierarchical custom setting, this object defines the leave entitlements for each user.

## App Logic

1. When a user submits a leave request, its status is set to `Pending`. This request becomes visible to the user's manager, who can then approve or reject it.
2. Upon approval, the user's leave balances are updated accordingly. The leave balance calculation is dynamic and occurs when the Leave Management App page is loaded.

## Permissions and Data Access

1. Access to the Leave Request object and its fields is managed through the `Leave_Request_permission_set`:
   - Object permissions: Read, Create, Edit, Delete.
   - Field permissions: Read and Edit All Fields.
2. The Org-Wide Default (OWD) setting for the Leave Request object is set to `Private`.
3. A role hierarchy should be established to allow managers access to their team members' leave requests.

## Notes

- This application is a demo and implements only the most basic flow of a leave management system.
- It does not include validations such as checking if the user has sufficient leave balances.
- In this demo version, all users are assigned the same leave entitlements.
