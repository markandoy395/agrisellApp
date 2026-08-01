# Complete Standalone Rider Implementation Prompts

## Important Usage Rule

Send only **one phase at a time**.

After each phase:

1. Review the implementation report.
2. Run and manually test the application.
3. Fix errors found in that phase.
4. Continue only when the current phase works correctly.

Do not send all phases in a single implementation request.

---

# PHASE 0 — COMPLETE RIDER CODEBASE AUDIT

## Copy and Paste This Prompt

Act as a senior mobile application architect and full-stack developer.

I am expanding the existing Rider role into a complete production-ready delivery system. Before implementing anything, inspect the current project and create a complete Rider module audit.

Read and strictly follow all instructions inside `agent.md` before inspecting or changing anything.

## Important Restrictions

Do not modify any files during this phase.

Do not recreate or redesign these already implemented areas:

- Rider registration
- Rider personal information
- Rider verification
- Rider document upload
- Rider vehicle information
- Rider profile information
- Admin features
- Farmer features
- Buyer features

Focus only on understanding the current Rider delivery system.

Preserve the existing:

- Project architecture
- Folder structure
- State-management solution
- Backend integration
- Design system
- Navigation design
- Reusable components
- Coding conventions
- Database structure where possible

## Audit the Following Rider Areas

Inspect:

- Rider Home dashboard
- Rider availability status
- Nearby delivery requests
- Delivery request details
- Delivery acceptance
- Active delivery workflow
- Pickup confirmation
- Delivery confirmation
- Delivery progress timeline
- Delivery history
- Map implementation
- GPS and location services
- Route calculation
- Route caching
- Live location sharing
- Offline storage
- App lifecycle restoration
- Messages
- Notifications
- Earnings
- Cash-on-delivery handling
- Ratings and performance
- Cancellation
- Failed delivery
- Product return
- Reassignment
- Safety tools
- Problem reporting
- Rider navigation
- Existing tests

## Classify Every Feature

Classify each Rider feature as:

- Fully implemented
- Partially implemented
- UI only
- Using local data
- Using mock data
- Backend connected
- Broken
- Missing
- Duplicated
- Needs refactoring
- Not applicable

## Inspect the Technical Architecture

Identify:

- Rider-related directories
- Rider screens
- Rider widgets or components
- Rider controllers, providers, blocs, stores, or view models
- Models
- Repositories
- Services
- API clients
- Database collections or tables
- Route-management services
- Location-management services
- Offline-storage services
- Notification services
- Messaging services
- Payment and earning services
- Existing test files

Determine the current:

- Mobile framework
- Backend framework
- Database
- Authentication system
- State-management solution
- Map provider
- Routing provider
- GPS provider
- Local-storage solution
- Push-notification provider
- Real-time messaging provider
- Image or file-storage solution

## Identify Existing Status Definitions

Document the current Rider availability statuses.

Document the current delivery statuses.

Identify whether statuses are:

- Hardcoded in UI files
- Repeated in multiple files
- Stored as strings
- Stored as enums
- Validated on the backend
- Validated only on the client

Identify invalid or missing delivery transitions.

## Inspect Existing Mock Data

Create an inventory of:

- Mock Rider requests
- Mock active deliveries
- Mock earnings
- Mock messages
- Mock notifications
- Mock ratings
- Mock map markers
- Mock histories

For each mock-data source, identify:

- File path
- Purpose
- Screen using it
- Whether a real backend replacement exists
- When it can safely be removed

Do not remove mock data during this phase.

## Security and Privacy Audit

Check for:

- Exposed Farmer or Buyer contact information
- Public Rider documents
- Insecure local token storage
- Hardcoded credentials
- Hardcoded confirmation codes
- Client-only delivery acceptance
- Client-only payment validation
- Missing backend authorization
- Unprotected location data
- Sensitive data written to logs
- Missing role checks
- Raw backend errors shown to users

## Required Audit Output

Produce a structured report containing:

### 1. Project Summary

Explain the project architecture and technologies currently used.

### 2. Rider File Map

List every important Rider-related file and explain its responsibility.

### 3. Current Feature Matrix

For every Rider feature, show:

- Current implementation status
- Relevant files
- Backend connection status
- Problems found
- Recommended action

### 4. Existing Status Architecture

List Rider availability states, delivery states, and transition problems.

### 5. Mock-Data Inventory

List every mock-data location and its replacement requirement.

### 6. Backend and Database Inventory

List existing Rider endpoints, collections, tables, functions, and subscriptions.

### 7. Missing Requirements

List the Rider requirements that are not implemented.

### 8. Architecture Problems

Identify duplication, tight coupling, hardcoded logic, and inconsistent models.

### 9. Security and Privacy Problems

List risks and recommended fixes.

### 10. Dependencies

Identify current dependencies and any additional dependency that may be needed.

Do not recommend adding a package when the project already has a suitable solution.

### 11. Implementation Risks

Identify features that may affect existing Farmer, Buyer, or shared order workflows.

### 12. Recommended Implementation Sequence

Map the work to the next Rider implementation phases.

### 13. Test Strategy

Recommend unit, integration, widget, UI, backend, concurrency, offline, and manual tests.

## Completion Conditions

This phase is complete only when:

- No project files were modified.
- The entire Rider module was inspected.
- Existing and missing functionality are separated.
- Mock and real data sources are identified.
- Important file paths are documented.
- Risks and dependencies are listed.
- The next implementation phases can use the audit as their technical reference.

Stop after producing the audit.

Do not implement any feature yet.

---

# PHASE 1 — RIDER DELIVERY FOUNDATION AND STATUS ARCHITECTURE

## Copy and Paste This Prompt

Act as a senior mobile and backend developer.

Implement the Rider delivery foundation and centralized status architecture.

Read and strictly follow `agent.md` before making changes.

Use the Rider audit from the previous phase as your technical reference. Inspect the existing implementation again before creating or modifying files.

## Scope Restrictions

Implement only the delivery foundation.

Do not implement complete:

- Nearby requests
- Delivery acceptance
- Pickup workflow
- Delivery workflow
- Map navigation
- Offline synchronization
- Messaging
- Notifications
- Earnings
- Cash on delivery
- Batch deliveries

Do not recreate or redesign:

- Rider registration
- Rider information
- Rider verification
- Rider documents
- Vehicle registration
- Rider profile
- Admin features
- Farmer features
- Buyer features

Reuse existing models, repositories, services, and state-management patterns.

## Rider Availability States

Create or centralize typed Rider availability states for:

- Offline
- Online and Available
- Reviewing Delivery Request
- Delivery Reserved
- Going to Pickup
- Waiting at Pickup
- Product Picked Up
- Going to Buyer
- Waiting at Delivery Location
- On Break
- Temporarily Unavailable
- Emergency

Avoid repeating raw status strings in multiple files.

Provide:

- Internal typed value
- Backend serialization value
- User-facing label
- Optional icon or presentation mapping
- Status helper functions

Keep presentation details separate from business logic.

## Delivery States

Create or centralize typed delivery statuses for:

- Available
- Reserved
- Accepted
- Going to Pickup
- Arrived at Pickup
- Waiting for Product
- Pickup Confirmation Required
- Product Picked Up
- Going to Buyer
- Arrived at Delivery Location
- Waiting for Buyer
- Delivery Confirmation Required
- Product Delivered
- Delivery Completed
- Cancelled
- Failed
- Returned
- Reassigned
- Disputed

## Delivery Transition Validator

Create one centralized status-transition validator.

Define valid transitions explicitly.

At minimum, enforce:

- Available → Reserved
- Reserved → Accepted
- Accepted → Going to Pickup
- Going to Pickup → Arrived at Pickup
- Arrived at Pickup → Waiting for Product
- Waiting for Product → Pickup Confirmation Required
- Pickup Confirmation Required → Product Picked Up
- Product Picked Up → Going to Buyer
- Going to Buyer → Arrived at Delivery Location
- Arrived at Delivery Location → Waiting for Buyer
- Waiting for Buyer → Delivery Confirmation Required
- Delivery Confirmation Required → Product Delivered
- Product Delivered → Delivery Completed

Terminal or special states must be handled carefully:

- Completed delivery cannot be modified by the Rider.
- Cancelled delivery cannot return to normal delivery without an authorized workflow.
- Failed delivery must continue through an approved resolution.
- Returned delivery must contain return proof.
- Reassigned delivery must preserve its history.
- Disputed delivery must not erase previous delivery events.

## Typed Models

Create or improve typed models for:

- Delivery request
- Delivery assignment
- Delivery product
- Product-handling requirement
- Pickup location
- Delivery destination
- Delivery status event
- Delivery proof
- Pickup proof
- Rider availability
- Rider location
- Route information
- Fee breakdown
- Waiting-time record
- Delivery problem
- Cancellation record
- Failed-delivery record
- Offline queued action

Avoid creating duplicate models.

Extend existing models when they are already suitable.

## Delivery Status Event

Every status event must support:

- Unique event ID
- Delivery ID
- Previous status
- New status
- Rider ID
- Timestamp
- Latitude
- Longitude
- Location accuracy
- Rider note
- Reason code
- Proof reference
- Online or offline source
- Synchronization status

## Service and Repository Interfaces

Create or improve clear interfaces for:

- Rider availability repository
- Delivery request repository
- Active delivery repository
- Delivery status repository
- Delivery proof repository
- Rider location repository
- Offline queue repository

Do not place API or database calls directly inside screens or UI widgets.

Use dependency injection or the existing project pattern.

## Basic Persistence

Persist:

- Current Rider availability
- Active delivery ID
- Current delivery status
- Current delivery summary
- Pending offline action count
- Last synchronization time

Restore the basic state after app restart.

Do not implement the complete offline synchronization engine yet.

## Backward Compatibility

Existing mock screens and existing working features must continue to compile and run.

Add temporary mapping adapters when old models differ from the new centralized model.

Do not delete old mock data until the real integration is completed in later phases.

## Error Handling

Create typed or centralized domain errors for:

- Invalid status transition
- Delivery not found
- Delivery no longer available
- Rider unavailable
- Network unavailable
- Unauthorized operation
- Invalid proof
- Synchronization conflict

Do not expose raw backend exceptions to UI screens.

## Tests

Add tests for:

- Every valid status transition
- Important invalid transitions
- Completed delivery immutability
- Serialization and deserialization
- Existing backend-value compatibility
- Basic active-delivery persistence
- Rider availability persistence

Run:

- Formatting
- Linting
- Type checking
- Unit tests
- Existing related tests

## Completion Conditions

This phase is complete only when:

- Rider availability statuses are centralized.
- Delivery statuses are centralized.
- Status strings are not unnecessarily duplicated.
- Valid and invalid transitions are tested.
- Important Rider delivery models are typed.
- Repository and service interfaces exist.
- Basic active-delivery state survives app restart.
- Existing Rider screens still work.
- No future-phase features were implemented unnecessarily.

## Required Final Report

At the end, report:

1. What was implemented
2. Files created
3. Files modified
4. Models added or changed
5. Status transitions supported
6. Backend compatibility changes
7. Tests added
8. Tests executed and results
9. Mock data still used
10. Known limitations
11. Manual testing steps
12. Work intentionally left for Phase 2

Stop after completing Phase 1.

---

# PHASE 2 — RIDER AVAILABILITY AND HOME DASHBOARD

## Copy and Paste This Prompt

Act as a senior mobile and backend developer.

Implement the Rider availability system and connect the Rider Home dashboard to reliable application state.

Read and strictly follow `agent.md`.

Inspect the existing Rider Home screen, current availability implementation, location service, connectivity service, state management, and backend before changing files.

## Scope Restrictions

Implement only:

- Rider Online and Offline behavior
- Rider current work status
- Home dashboard data and states
- Availability persistence and synchronization

Do not implement:

- Full nearby request matching
- Delivery acceptance
- Pickup confirmation
- Delivery completion
- Full map routing
- Offline delivery queue
- Messaging
- Earnings calculation
- Batch delivery

Do not recreate registration, verification, documents, vehicle, profile, or Admin features.

## Rider Availability Rules

Implement these availability states using the centralized definitions:

- Offline
- Online and Available
- Reviewing Delivery Request
- Delivery Reserved
- Going to Pickup
- Waiting at Pickup
- Product Picked Up
- Going to Buyer
- Waiting at Delivery Location
- On Break
- Temporarily Unavailable
- Emergency

Implement an Online and Offline control.

Rules:

- Offline Riders must not receive new delivery requests.
- Rider cannot go Online without internet.
- Rider must receive a clear warning when GPS is disabled.
- Rider cannot go Online when required location permission is denied.
- Poor GPS accuracy must show a warning.
- Rider with an active delivery must not be automatically marked Offline.
- Rider availability must survive app restart.
- Availability changes must synchronize with the backend.
- Prevent repeated availability-toggle requests.
- Show loading while the status is being updated.
- Revert the UI when the backend update fails.
- Do not create conflicting local and server status values.
- Automatically restore the authoritative server state after reconnection.

When the Rider logs out, handle availability using the project’s expected business rule without losing active-delivery data.

## Home Dashboard

Reuse and improve the existing Home screen.

Display:

- Rider greeting
- Rider profile image when already available
- Online or Offline toggle
- Current work status
- GPS status
- Internet status
- Active delivery summary
- Nearby-request count or summary
- Today’s completed-delivery count
- Today’s estimated earnings
- Unread message count
- Unread notification count
- Performance summary
- Safety and support shortcut

Do not recreate the Rider profile.

## Dashboard States

Support:

- Initial loading
- Refreshing
- No nearby requests
- No active delivery
- GPS disabled
- Permission denied
- Poor location accuracy
- No internet
- Synchronizing
- Partial-data state
- Server error
- Retry state

Display clear user-friendly messages.

Do not show raw backend errors.

## Dashboard Performance

- Preserve dashboard state when switching tabs.
- Avoid requesting all dashboard data every time the Rider returns to Home.
- Refresh only stale or changed sections.
- Prevent duplicate network calls.
- Cancel or ignore outdated requests.
- Use the current project’s caching or state-management approach.
- Add manual pull-to-refresh when appropriate.
- Keep the UI responsive during synchronization.

## Backend Integration

Use real backend data when available.

If a section still requires mock data:

- Keep the mock data isolated.
- Clearly mark it in code as temporary.
- Do not mix mock and production records silently.
- Keep loading and empty states working.

## Tests

Add tests for:

- Offline to Online transition
- Online to Offline transition
- GPS-disabled warning
- Permission-denied handling
- No-internet behavior
- Failed status synchronization
- Repeated toggle taps
- App restart restoration
- Active delivery preventing incorrect Offline behavior
- Dashboard loading, empty, and error states
- Tab switching without unnecessary reload

Run formatting, linting, type checking, and relevant tests.

## Completion Conditions

- Online and Offline status works reliably.
- Backend and local state remain synchronized.
- Status is restored after app restart.
- GPS, permission, and connectivity restrictions work.
- The dashboard displays real state or clearly isolated temporary data.
- Tab changes do not cause unnecessary full reloads.
- Existing navigation and design remain intact.

## Required Final Report

Report:

1. Availability logic implemented
2. Dashboard sections implemented
3. Files created
4. Files modified
5. Backend changes
6. Persistence changes
7. Tests added
8. Test results
9. Mock dashboard data still remaining
10. Known limitations
11. Manual testing instructions
12. Work intentionally left for Phase 3

Stop after Phase 2.

---

# PHASE 3 — NEARBY DELIVERY REQUESTS, FILTERING, AND MATCHING

## Copy and Paste This Prompt

Act as a senior mobile and backend developer.

Implement real nearby Rider delivery requests, request filtering, sorting, Rider eligibility matching, and complete request details.

Read and strictly follow `agent.md`.

Inspect the current request list, request cards, delivery data source, Rider vehicle information, Rider service area, current location service, and backend query structure before changing files.

## Scope Restrictions

Implement only:

- Available delivery request list
- Request cards
- Filtering
- Sorting
- Eligibility matching
- Request details
- Estimated Rider earnings display

Do not implement final acceptance or reservation. That belongs to Phase 4.

Keep the Accept button disabled, prepared, or connected only to a non-final placeholder until Phase 4.

Do not recreate Rider registration, verification, vehicle registration, profile, or Admin features.

## Eligible Delivery Requests

Show only requests that are:

- Ready for pickup
- Available
- Not expired
- Not assigned
- Within the Rider’s allowed service area
- Compatible with the registered vehicle
- Within vehicle load capacity
- Compatible with product-handling requirements
- Reachable before the pickup deadline
- Reachable before the delivery deadline
- Allowed by the active-delivery limit

The backend must remain the final authority for eligibility.

## Hide Requests When

- Rider is Offline.
- Internet is unavailable.
- GPS is unavailable.
- Location accuracy is unusable.
- Request is already accepted.
- Request has expired.
- Product exceeds vehicle capacity.
- Vehicle type is incompatible.
- Rider cannot reach pickup in time.
- Rider reached the delivery limit.
- Request is outside the Rider service area.
- Product requirements are not supported.

## Request Card

Each request card must show:

- Product image
- Product name
- Product category
- Quantity
- Total weight
- Farmer or seller name
- Pickup location
- Delivery location
- Distance from Rider to pickup
- Estimated pickup travel time
- Estimated full trip distance
- Estimated full trip time
- Pickup deadline
- Delivery deadline
- Delivery priority
- Estimated Rider earning
- Required vehicle
- Product-handling labels
- View Details action
- Accept action prepared for Phase 4
- Hide or decline action when supported

Use the current application design system.

## Delivery Priority

Support clear labels for:

- Normal
- Scheduled
- Urgent
- Perishable
- Same Day

Do not use confusing or excessive colors.

## Sorting

Implement:

- Nearest pickup
- Highest estimated earning
- Most urgent
- Earliest pickup deadline
- Earliest delivery deadline

## Filtering

Implement:

- Urgent
- Scheduled
- Perishable
- Vehicle compatible
- Weight compatible
- Within service area
- Pickup time range
- Delivery fee range when appropriate

Provide a clear Reset Filters action.

## Search

Allow Rider to search available requests by:

- Product name
- Pickup location
- Delivery location
- Farmer or seller name when privacy rules allow

## Request Details Screen

Before acceptance, show:

- Product image
- Product name
- Category
- Quantity
- Weight
- Product-handling instructions
- Pickup address
- Delivery address
- Farmer or seller summary
- Buyer summary with privacy protection
- Pickup time window
- Pickup deadline
- Delivery deadline
- Distance to pickup
- Pickup-to-delivery distance
- Total estimated travel time
- Estimated Rider earning
- Fee breakdown summary
- Payment method
- Required vehicle
- Capacity requirement
- Cancellation conditions
- Route preview when existing map support allows it

Do not expose:

- Full private phone numbers
- Sensitive address details beyond operational need
- Private account information
- Unnecessary Buyer or Farmer profile data

## Refresh Behavior

Update available requests when:

- Rider goes Online
- Rider location changes meaningfully
- Request availability changes
- Manual refresh occurs
- Backend real-time update arrives

Avoid continuous unnecessary refreshes.

## Empty and Error States

Support:

- No nearby requests
- No compatible requests
- No requests in selected filter
- Rider Offline
- GPS unavailable
- No internet
- Loading
- Refreshing
- Server error
- Request expired while viewing
- Request removed by another Rider

## Tests

Add tests for:

- Vehicle compatibility
- Weight-capacity filtering
- Expired-request filtering
- Service-area filtering
- Deadline filtering
- Offline Rider behavior
- Sorting
- Filters
- Search
- Protected contact information
- Request-detail loading and error state

## Completion Conditions

- Only eligible requests are shown.
- Sorting, filtering, and search work.
- Request cards contain required operational information.
- Request detail is complete.
- Private information is protected.
- Real backend data is used where available.
- Mock data remains isolated where real integration is not ready.
- Final acceptance is not yet implemented.

## Required Final Report

Report:

1. Request-list features implemented
2. Matching rules implemented
3. Filters and sorting implemented
4. Files created
5. Files modified
6. Backend query changes
7. Tests added
8. Test results
9. Remaining mock request data
10. Known limitations
11. Manual testing instructions
12. Work intentionally left for Phase 4

Stop after Phase 3.

---

# PHASE 4 — TRANSACTION-SAFE DELIVERY ACCEPTANCE

## Copy and Paste This Prompt

Act as a senior mobile and backend developer.

Implement secure and transaction-safe Rider delivery acceptance.

Read and strictly follow `agent.md`.

Inspect the existing backend, database, request repository, Rider eligibility logic, active-delivery model, and current request UI before changing files.

## Scope Restrictions

Implement only:

- Acceptance confirmation
- Backend eligibility revalidation
- Transaction-safe reservation
- Delivery assignment
- Duplicate-tap prevention
- Concurrency handling
- Active-delivery creation
- Rider status update after acceptance

Do not implement complete pickup, navigation, proof, offline acceptance, or batch delivery.

Do not recreate Rider registration, verification, vehicle, profile, or Admin features.

## Acceptance Workflow

When the Rider taps Accept:

1. Show a confirmation dialog.
2. Show the delivery summary and estimated earning.
3. Ask the Rider to confirm acceptance.
4. Disable Accept immediately after confirmation.
5. Prevent repeated taps.
6. Send one uniquely identifiable request.
7. Revalidate Rider eligibility on the backend.
8. Revalidate delivery availability.
9. Reserve or lock the request atomically.
10. Assign the first eligible Rider.
11. Create the active-delivery record.
12. Update the delivery status.
13. Update Rider work status.
14. Remove the request from available lists.
15. Open the Active Delivery screen.

## Backend Validation

The backend must confirm:

- Delivery exists.
- Delivery is still available.
- Delivery is not expired.
- Product is still ready.
- Delivery is not already assigned.
- Rider account is allowed to deliver.
- Rider is Online and Available.
- Rider location is acceptable.
- Rider service area is compatible.
- Vehicle type is compatible.
- Vehicle capacity is sufficient.
- Rider has not reached the active-delivery limit.
- Rider does not already have a conflicting assignment.

Do not trust client-provided eligibility values without validation.

## Atomic Assignment

Use the strongest supported mechanism:

- Database transaction
- Atomic conditional write
- Compare-and-set update
- Server-side lock
- Secure backend function

The assignment must guarantee that only one Rider succeeds.

Do not rely on:

- Hiding the button
- Local state
- Client timestamps
- Client-only checks

## Idempotency

Create an idempotency key or equivalent protection so repeated network requests cannot create duplicate assignments.

## Other Rider Updates

After successful acceptance:

- Remove the request from other Riders.
- Broadcast or publish the assignment change.
- Show a clear unavailable state if another Rider wins.
- Do not expose the assigned Rider’s private information unnecessarily.

## Error Handling

Handle:

- Already accepted
- Expired
- Product no longer ready
- Rider Offline
- Rider no longer eligible
- Vehicle capacity mismatch
- Active-delivery limit reached
- Network timeout
- Server error
- Transaction conflict
- Unknown error

After failure:

- Do not create a local active delivery.
- Re-enable the Accept action when appropriate.
- Refresh request status.
- Show a user-friendly message.
- Do not show raw backend exceptions.

## UI Behavior

During acceptance:

- Show processing state.
- Disable repeated actions.
- Prevent navigation away from creating duplicate requests.
- Restore safe UI state after failure.
- Show success only after backend confirmation.

## Tests

Add:

- Two Riders accepting simultaneously
- Same Rider tapping repeatedly
- Duplicate network request
- Expired request
- Already-assigned request
- Eligibility changed before acceptance
- Vehicle capacity changed
- Rider became Offline
- Backend transaction failure
- Network timeout
- Successful active-delivery creation
- Correct Rider status update

## Completion Conditions

- Only one Rider can accept a delivery.
- Duplicate taps create one request.
- Duplicate backend requests create one assignment.
- Failed acceptance does not create false local state.
- Successful acceptance creates the correct active delivery.
- Rider status updates.
- Other Riders stop seeing the request.
- Concurrency tests pass.

## Required Final Report

Report:

1. Acceptance workflow implemented
2. Atomic-assignment method used
3. Backend validation implemented
4. Idempotency protection
5. Files created
6. Files modified
7. Backend or database changes
8. Tests added
9. Concurrency test results
10. Known limitations
11. Manual two-Rider testing steps
12. Work intentionally left for Phase 5

Stop after Phase 4.

---

# PHASE 5 — ACTIVE DELIVERY WORKFLOW AND PROGRESS TIMELINE

## Copy and Paste This Prompt

Act as a senior mobile and backend developer.

Implement the complete core active-delivery status workflow and Rider progress timeline.

Read and strictly follow `agent.md`.

Inspect the centralized statuses, active-delivery state, existing Active screen, backend delivery events, and navigation structure before changing files.

## Scope Restrictions

Implement only the core successful delivery status journey and timeline.

Do not implement complete:

- Pickup proof
- Delivery proof
- Map optimization
- Offline synchronization
- Cancellation
- Failed delivery
- Product return
- Reassignment
- Payments

Use prepared placeholders or disabled actions for proof requirements until their phases.

## Core Delivery Journey

Implement these statuses:

1. Accepted
2. Going to Pickup
3. Arrived at Pickup
4. Waiting for Product
5. Pickup Confirmation Required
6. Product Picked Up
7. Going to Buyer
8. Arrived at Delivery Location
9. Waiting for Buyer
10. Delivery Confirmation Required
11. Product Delivered
12. Delivery Completed

## Status Event Recording

Every status update must record:

- Event ID
- Delivery ID
- Previous status
- New status
- Rider ID
- Timestamp
- Latitude
- Longitude
- Accuracy
- Rider note
- Reason code when required
- Proof reference when available
- Online or offline source
- Synchronization state

## Transition Rules

Enforce:

- Accepted must precede Going to Pickup.
- Going to Pickup must precede Arrived at Pickup.
- Arrival requires valid location or approved manual override.
- Pickup Confirmation Required must occur before Product Picked Up.
- Product Picked Up must occur before Going to Buyer.
- Going to Buyer must precede Arrived at Delivery Location.
- Delivery Confirmation Required must occur before Product Delivered.
- Product Delivered must precede Delivery Completed.
- Completed delivery cannot be edited by the Rider.
- Invalid transitions must be rejected on both client and backend.

## Active Delivery Screen

Reuse or improve the current Active Delivery screen.

Display:

- Product summary
- Current status
- Next allowed action
- Pickup location
- Delivery location
- Farmer or seller summary
- Buyer summary
- Delivery deadline
- Estimated earning
- Product-handling instructions
- Route shortcut
- Message shortcut
- Problem-report shortcut
- Safety shortcut
- Delivery progress timeline

## Progress Timeline

Show:

- Accepted
- Going to pickup
- Arrived at pickup
- Waiting for product
- Product picked up
- Going to Buyer
- Arrived at destination
- Waiting for Buyer
- Product delivered
- Delivery completed

Each completed stage must show:

- Status
- Timestamp
- Location when available
- Proof indicator
- Note indicator
- Completion marker

Use a modern road-style or logistics-style design matching the application.

## Active Delivery Persistence

Restore after app restart:

- Active delivery
- Current status
- Timeline
- Next action
- Relevant delivery summary

Do not create a second active delivery after restoration.

## Refresh and Real-Time Updates

Handle:

- Backend status update
- Delivery cancelled by another authorized party
- Delivery reassigned
- Server-side correction
- Stale local state

Use server state as authoritative while preserving unsynchronized actions for the offline phase later.

## Tests

Add tests for:

- Every valid transition
- Every important invalid transition
- Status event creation
- Timeline order
- App restart restoration
- Completed-delivery immutability
- Stale-state refresh
- Duplicate status-action prevention
- Server rejection

## Completion Conditions

- Core status workflow works.
- Invalid transitions are blocked.
- Timeline displays correct events.
- Active delivery survives restart.
- Repeated action taps are prevented.
- Completed delivery is immutable.
- Existing navigation remains stable.

## Required Final Report

Report:

1. Status workflow implemented
2. Active Delivery UI changes
3. Timeline implementation
4. Files created
5. Files modified
6. Backend changes
7. Persistence changes
8. Tests added
9. Test results
10. Known limitations
11. Manual end-to-end status test
12. Work intentionally left for Phase 6

Stop after Phase 5.

---

# PHASE 6 — PICKUP CONFIRMATION AND PRODUCT CONDITION CHECKING

## Copy and Paste This Prompt

Act as a senior mobile and backend developer.

Implement the complete Rider pickup confirmation and product-condition workflow.

Read and strictly follow `agent.md`.

Inspect the existing confirmation-code logic, image upload, QR support, signature support, delivery models, and current pickup UI before changing files.

## Scope Restrictions

Implement only:

- Pickup arrival actions
- Pickup confirmation
- Pickup proof
- Product condition
- Quantity and weight verification
- Pickup issue reporting
- Successful pickup status update

Do not implement final delivery proof, full offline proof synchronization, payment, return, or batch delivery.

Do not recreate Rider information, documents, vehicle information, profile, or Admin features.

## Pickup Arrival

When the Rider reaches the pickup location:

- Allow Arrived at Pickup only within the configured radius.
- Show GPS accuracy.
- Notify the Farmer or seller.
- Display pickup instructions.
- Start the pickup waiting timer.
- Show product and package requirements.

Allow manual arrival override only when:

- GPS accuracy is poor, or
- Location cannot be verified for a valid reason.

Manual override must save:

- Reason
- Coordinates
- Accuracy
- Timestamp
- Rider ID

## Pickup Confirmation Methods

Support the methods configured by the backend:

- Pickup confirmation code
- QR code
- Farmer confirmation
- Product photo
- Package photo
- Quantity confirmation
- Weight confirmation
- Farmer signature

Do not require every method when only selected methods are configured.

## Confirmation Code

Implement:

- Secure input
- Validation
- Limited repeated attempts when required
- Loading state
- Incorrect-code message
- Expired-code handling
- Already-used-code handling
- Backend validation

Do not store or log the plain confirmation code unnecessarily.

## Product Condition Checklist

Require the Rider to confirm:

- Correct product
- Correct quantity
- Correct weight
- Packaging is secure
- Product is not visibly damaged
- Product matches the request
- Product fits the vehicle
- Handling instructions were received

Support handling labels:

- Perishable
- Fragile
- Keep Dry
- Temperature Sensitive
- Do Not Stack
- Handle Carefully

## Pickup Problems

Allow reporting:

- Product not ready
- Wrong product
- Incorrect quantity
- Incorrect weight
- Damaged product
- Poor packaging
- Product exceeds vehicle capacity
- Farmer unavailable
- Confirmation problem
- Other

Allow:

- Notes
- Photos
- Location
- Timestamp

When a blocking issue exists:

- Do not mark Product Picked Up.
- Preserve the active delivery.
- Create a problem report.
- Display the proper next steps.
- Allow support communication.

## Successful Pickup

After all required checks pass:

- Save pickup proof.
- Save location.
- Save timestamp.
- Save condition checklist.
- Update status to Product Picked Up.
- Notify the Buyer.
- Prepare navigation to the Buyer.
- Update the timeline.
- Prevent duplicate pickup completion.

## Security

Protect uploaded proof.

Only authorized delivery participants and support roles should access it.

Do not expose proof through public file URLs when protected storage is available.

## Tests

Add tests for:

- Correct pickup code
- Incorrect pickup code
- Expired code
- Used code
- Missing required proof
- Product condition problem
- Capacity exceeded
- Duplicate completion tap
- Successful pickup
- Proof upload failure
- Farmer unavailable
- Manual arrival override

## Completion Conditions

- Pickup cannot complete without required proof.
- Confirmation codes are validated securely.
- Product-condition problems block normal pickup.
- Pickup proof is stored.
- Timeline is updated.
- Buyer is notified.
- Duplicate pickup completion is prevented.

## Required Final Report

Report:

1. Pickup methods implemented
2. Condition checklist implemented
3. Problem scenarios handled
4. Files created
5. Files modified
6. Backend changes
7. Storage changes
8. Tests added
9. Test results
10. Known limitations
11. Manual pickup testing steps
12. Work intentionally left for Phase 7

Stop after Phase 6.

---

# PHASE 7 — MAP, GPS, ROUTING, AND LIVE RIDER LOCATION

## Copy and Paste This Prompt

Act as a senior mobile mapping and backend developer.

Implement and optimize Rider maps, GPS accuracy, road-following routing, arrival detection, route caching, and live Rider location sharing.

Read and strictly follow `agent.md`.

Inspect the current map library, location library, route API, existing map controller, tab-navigation behavior, and backend location storage before changing files.

## Scope Restrictions

Implement only:

- GPS and permission handling
- Rider map state
- Pickup and delivery routes
- Route selection
- Route recalculation
- Arrival validation
- Live location sharing
- Basic latest-route caching

Do not implement the full offline synchronization queue yet.

Do not replace the map provider unless the existing provider cannot meet the requirements and the replacement is clearly justified.

## GPS Requirements

Use device GPS or fused location services.

Handle:

- Precise location permission
- Approximate location only
- GPS disabled
- Poor accuracy
- Weak signal
- Location timeout
- Temporary location loss
- Background-location restriction
- Battery-saving mode
- Mock-location detection where supported

Each location update must include:

- Latitude
- Longitude
- Accuracy
- Speed
- Heading
- Timestamp

Show location quality clearly.

Do not allow critical arrival actions when accuracy is clearly invalid unless the Rider uses an approved manual override.

## Map Content

Display:

- Current Rider marker
- Pickup marker
- Buyer destination marker
- Active route
- Route alternatives when supported
- Remaining distance
- Estimated arrival time
- Route progress
- Turn instructions when available

Use actual road geometry.

Do not draw only a straight line between Rider, pickup, and destination.

## Route Modes

Support available modes such as:

- Fastest route
- Shortest route
- Alternative route
- Highway preferred
- Highway avoided

Only display modes actually supported by the route provider.

## Map Performance

- Do not recreate the entire map every time the Rider changes tabs.
- Preserve the map controller.
- Preserve camera position.
- Preserve zoom.
- Preserve active markers.
- Preserve route lines.
- Reuse loaded route data.
- Load only necessary markers.
- Avoid excessive rebuilds.
- Avoid continuous route API calls.
- Cache the latest active route.
- Provide manual Refresh Route.

## Route Recalculation

Recalculate when:

- Rider moves a meaningful distance
- Rider leaves the current route
- Pickup or destination changes
- Current route becomes invalid
- Rider manually refreshes

Do not recalculate on every small GPS change.

Use throttling, debouncing, or distance thresholds.

## Pickup and Delivery Navigation

Before pickup:

- Route to Farmer or seller
- Show pickup ETA
- Show pickup distance
- Update route progress

After pickup:

- Switch route to Buyer
- Show delivery ETA
- Show remaining distance
- Notify Buyer about estimated arrival when appropriate

## Arrival Detection

Enable arrival actions only within the configured radius.

Use:

- Distance
- Accuracy
- Timestamp freshness

Manual override requires:

- Reason
- Current coordinates
- Accuracy
- Timestamp

## Live Location Sharing

Share Rider location only during:

- Going to Pickup
- Waiting at Pickup
- Product Picked Up
- Going to Buyer
- Waiting at Delivery Location

Stop sharing after:

- Completed
- Cancelled
- Failed
- Returned
- Reassigned

Only authorized delivery participants may access live tracking.

## Battery Efficiency

Use:

- Lower-frequency updates when no active delivery exists
- Higher-frequency updates only during navigation
- Distance filters
- Appropriate accuracy settings
- Background tracking only when operationally required

## Tests

Add tests for:

- Permission granted
- Permission denied
- GPS disabled
- Poor accuracy
- Location timeout
- Route generation
- Route switching after pickup
- Route recalculation threshold
- Tab switching without map reload
- Manual route refresh
- Arrival radius
- Manual arrival override
- Location sharing start
- Location sharing stop
- Unauthorized tracking access

## Completion Conditions

- GPS status is reliable.
- Routes follow roads.
- Map state survives tab changes.
- Route API usage is controlled.
- Arrival actions use distance and accuracy.
- Live tracking is available only during valid stages.
- Tracking stops in terminal states.
- Battery usage is reasonable.

## Required Final Report

Report:

1. Map provider and route provider used
2. GPS behavior implemented
3. Route modes implemented
4. Performance improvements
5. Files created
6. Files modified
7. Backend location changes
8. Tests added
9. Test results
10. Known limitations
11. Manual route testing steps
12. Work intentionally left for Phase 8

Stop after Phase 7.

---

776# PHASE 8 — DELIVERY CONFIRMATION, COMPLETION, AND HISTORY

## Copy and Paste This Prompt

Act as a senior mobile and backend developer.

Implement Rider arrival at the Buyer, proof of delivery, final delivery completion, and delivery history.

Read and strictly follow `agent.md`.

Inspect the current delivery-code implementation, proof storage, Active Delivery screen, earnings placeholder, timeline, and history screen before changing files.

## Scope Restrictions

Implement only:

- Delivery arrival
- Delivery confirmation
- Proof of delivery
- Final successful completion
- Delivery history
- Dashboard completion counters

Do not implement final earnings calculation, cash on delivery, complete offline proof synchronization, cancellation, return, or reassignment.

## Buyer Arrival

When the Rider approaches the destination:

- Detect proximity.
- Validate GPS accuracy.
- Enable Arrived at Delivery Location only within the allowed radius.
- Notify the Buyer.
- Start delivery waiting time.
- Show delivery instructions.
- Show Buyer communication actions.
- Allow Rider to report that the destination cannot be found.

Allow manual arrival override only for valid GPS problems.

Save:

- Reason
- Coordinates
- Accuracy
- Timestamp

## Delivery Confirmation Methods

Support methods configured by the backend:

- Delivery confirmation code
- QR code
- Buyer confirmation
- Buyer signature
- Product handover photo
- Recipient name
- Delivery notes
- GPS location
- Timestamp

Do not force all methods when only selected proof is required.

## Confirmation Code Rules

Handle:

- Correct code
- Incorrect code
- Expired code
- Already-used code
- Too many invalid attempts
- Network error
- Server validation

Do not log the plain code.

## Proof Upload

Store delivery proof securely.

Protect:

- Photos
- Signatures
- Recipient details
- GPS coordinates

Prevent duplicate proof submission.

## Successful Completion

After proof succeeds:

1. Mark Product Delivered.
2. Save proof.
3. Save final location and timestamp.
4. Mark Delivery Completed.
5. Update timeline.
6. Notify Farmer.
7. Notify Buyer.
8. Stop live location sharing.
9. Remove active route.
10. Move delivery to history.
11. Update today’s completed count.
12. Clear active delivery only after persistence succeeds.
13. Return Rider to Online and Available when appropriate.

Do not calculate final complex earnings yet unless the existing backend already does so.

## Delivery History

Use categories:

- Completed
- Cancelled
- Failed
- Returned
- Disputed

Only Completed will be fully populated during this phase. Prepare the others for later exception phases.

Support filtering by:

- Date
- Status
- Product
- Farmer or seller
- Buyer
- Pickup location
- Delivery location
- Payment status

Each history item must show:

- Delivery ID
- Product
- Date
- Pickup location
- Delivery location
- Final status
- Final or pending earning
- Proof indicator
- Rating indicator when available

## History Details

Show:

- Complete timeline
- Product summary
- Pickup and delivery locations
- Proof summary
- Delivery notes
- Final status
- Earning status

Do not allow the Rider to edit a completed delivery.

## Tests

Add tests for:

- Buyer arrival radius
- Manual arrival override
- Correct delivery code
- Incorrect code
- Missing proof
- Duplicate completion
- Successful completion
- Live tracking stops
- Route cleared
- Active state cleared
- History entry created
- Completed delivery immutability
- Dashboard count update

## Completion Conditions

- Delivery cannot complete without required proof.
- Proof is secure.
- Completion is transactionally safe.
- Live location stops.
- Route clears.
- Active delivery clears only after successful persistence.
- Delivery appears in history.
- Completed delivery cannot be edited.

## Required Final Report

Report:

1. Delivery proof methods implemented
2. Completion workflow
3. History features
4. Files created
5. Files modified
6. Backend changes
7. Storage changes
8. Tests added
9. Test results
10. Known limitations
11. Manual delivery-completion test
12. Work intentionally left for Phase 9

Stop after Phase 8.

---

# PHASE 9 — OFFLINE QUEUE, SYNCHRONIZATION, AND APP RESTORATION

## Copy and Paste This Prompt

Act as a senior offline-first mobile and backend developer.

Implement reliable offline queuing, synchronization, conflict handling, and app lifecycle restoration for active Rider deliveries.

Read and strictly follow `agent.md`.

Inspect the existing local-storage solution, networking layer, active-delivery persistence, background behavior, location service, message service, and proof storage before changing files.

## Scope Restrictions

Implement only:

- Offline action queue
- Location queue
- Proof queue
- Message queue foundation
- Synchronization engine
- App restart restoration
- Conflict handling

Do not allow offline acceptance of new deliveries.

Do not implement advanced messaging UI, finance, or batch deliveries.

## Queued Action Model

Every queued action must include:

- Unique local ID
- Idempotency key
- Rider ID
- Delivery ID
- Action type
- Payload
- Original timestamp
- Created timestamp
- Retry count
- Maximum retry policy
- Current status
- Dependency or sequence number
- Last error
- Last attempt timestamp

Statuses may include:

- Pending
- Synchronizing
- Synchronized
- Failed
- Requires Attention
- Cancelled

## Offline Actions

Support queuing for:

- Delivery status updates
- Pickup proof
- Delivery proof
- Photos
- Rider notes
- Location records
- Messages
- Problem reports
- Failed-delivery reports
- Safety reports

## Rules

- Preserve original timestamps.
- Process actions in the correct order.
- Prevent duplicate submissions.
- Use idempotency keys.
- Remove local actions only after backend confirmation.
- Retry automatically after reconnection.
- Use safe retry delays.
- Do not retry permanent validation errors endlessly.
- Show synchronization status to the Rider.
- Allow safe manual retry.
- Preserve failed evidence for review.

## Offline Location Queue

When offline:

- Save unsent location points.
- Preserve their timestamps.
- Store chronologically.
- Prevent duplicate upload.
- Keep the latest important location.
- Limit storage size.
- Compress or remove unnecessary old points safely.
- Remove confirmed points only after server acknowledgment.

## Proof Queue

When proof upload fails:

- Preserve the local file securely.
- Store metadata.
- Mark it pending.
- Retry automatically.
- Prevent duplicate upload.
- Do not clear the active delivery before required proof is synchronized or safely acknowledged.

## App Lifecycle Restoration

Preserve and restore:

- Active delivery
- Current status
- Delivery timeline
- Current route
- Map camera position
- Waiting timer
- Confirmation progress
- Pending proof
- Draft report
- Unsent messages
- Unsent locations
- Offline queue
- Last synchronization status

Restore after:

- Backgrounding
- Foregrounding
- App restart
- Device restart when supported
- Navigation-tab changes
- Internet loss
- Process recreation

## Conflict Handling

Handle:

- Delivery cancelled while Rider was offline
- Delivery reassigned while offline
- Server status newer than local status
- Proof already uploaded
- Duplicate status update
- Delivery already completed
- Queued action no longer valid
- Payment or delivery requirement changed

Do not blindly overwrite server state.

Use conflict rules and display actions requiring Rider attention.

## Connectivity

Detect connectivity changes.

Do not assume that network connection means the backend is reachable.

Verify actual service availability where appropriate.

## UI

Show:

- Live
- Offline
- Waiting to synchronize
- Synchronizing
- Synchronized
- Failed
- Requires attention

Do not block the entire app unnecessarily.

## Tests

Add tests for:

- Offline status update
- Offline proof
- Offline photo
- Offline location
- Offline message
- Correct synchronization order
- Duplicate prevention
- App restart with pending actions
- Reconnection
- Backend unavailable despite internet
- Permanent validation error
- Conflict with cancelled delivery
- Conflict with completed delivery
- Safe queue cleanup

## Completion Conditions

- Important Rider actions survive restart.
- Actions synchronize in order.
- Duplicate requests are prevented.
- Proof files are preserved.
- Locations synchronize safely.
- Conflicts do not corrupt delivery state.
- Rider sees clear synchronization status.
- Offline acceptance is blocked.

## Required Final Report

Report:

1. Offline queue architecture
2. Supported queued actions
3. Conflict rules
4. Files created
5. Files modified
6. Local-storage changes
7. Backend idempotency changes
8. Tests added
9. Test results
10. Known limitations
11. Manual offline test steps
12. Work intentionally left for Phase 10

Stop after Phase 9.

---

# PHASE 10 — WAITING, CANCELLATION, FAILED DELIVERY, RETURN, AND REASSIGNMENT

## Copy and Paste This Prompt

Act as a senior logistics-system mobile and backend developer.

Implement Rider waiting-time management and delivery exception workflows.

Read and strictly follow `agent.md`.

Inspect the existing delivery status architecture, problem reports, proof system, route system, offline queue, notification service, and Farmer or Buyer integration points before changing files.

## Scope Restrictions

Implement only:

- Waiting time
- Rider cancellation
- Failed delivery
- Product return
- Reassignment
- Product transfer proof

Do not redesign Admin features.

Do not implement batch delivery.

## Waiting-Time Management

Track waiting at:

- Pickup location
- Delivery location

Record:

- Arrival time
- Waiting start time
- Current duration
- Final duration
- Free waiting allowance
- Chargeable waiting time
- Waiting fee placeholder or calculated value when backend already supports it
- Waiting reason

Reasons:

- Product not ready
- Farmer unavailable
- Buyer unavailable
- Incorrect location
- Access blocked
- Buyer preparing payment
- Confirmation code unavailable
- Unsafe waiting area
- Other

Notify the relevant user when waiting exceeds configured thresholds.

Preserve the timer after app restart.

## Rider Cancellation

Allow cancellation reasons:

- Vehicle breakdown
- Accident
- Emergency
- Unsafe pickup
- Unsafe destination
- Product exceeds capacity
- Product damaged
- Prohibited product
- Incorrect product information
- Farmer unavailable
- Buyer unavailable
- Wrong address
- Severe route problem
- Other

Require:

- Reason
- Notes for Other
- Current delivery stage
- Location
- Timestamp
- Supporting photos when required

Rules:

- Before pickup, cancellation may release or reassign the request.
- After pickup, do not use normal cancellation because the Rider has custody of the product.
- After pickup, use Failed Delivery, Return, or Reassignment.

## Failed Delivery

Allow reasons:

- Buyer unavailable
- Invalid address
- Buyer refuses product
- Buyer refuses payment
- Delivery code unavailable
- Product damaged
- Unsafe destination
- Access impossible
- Cash collection failure

Require:

- Reason
- Notes
- Location
- Timestamp
- Proof when required

Determine next action:

- Retry
- Wait
- Contact support
- Deliver to approved alternate recipient
- Return product
- Transfer to another Rider

## Product Return

Create a Return workflow.

Show:

- Return reason
- Return destination
- Return route
- Return deadline
- Return fee status
- Farmer communication
- Product condition requirements

Require configured proof:

- Product photo
- Farmer confirmation
- Return code
- Signature
- Notes
- GPS
- Timestamp

Do not resolve the failed delivery before return or another approved resolution is complete.

## Reassignment

Allow reassignment request for:

- Breakdown
- Emergency
- Accident
- Safety concern
- Technical issue
- Capacity problem

Display:

- Request status
- Support instructions
- Whether Rider must wait
- Transfer destination
- New Rider status when authorized
- Product-transfer requirements

## Product Transfer

When another Rider receives the product, require:

- Transfer code or QR
- Product photo
- Product condition
- Receiving Rider confirmation
- Location
- Timestamp

Preserve chain of custody.

## Timeline and History

Every cancellation, failure, return, reassignment, and transfer must appear in:

- Delivery timeline
- Delivery history
- Status event log

Do not erase previous events.

## Offline Support

Use the offline queue from Phase 9 for:

- Cancellation request
- Failure report
- Return proof
- Reassignment request
- Transfer proof

Apply safe restrictions when server approval is required.

## Tests

Add tests for:

- Waiting timer
- App restart during waiting
- Pre-pickup cancellation
- Post-pickup cancellation rejection
- Failed delivery
- Buyer unavailable
- Return creation
- Return proof
- Reassignment
- Product transfer
- Chain of custody
- Offline exception report
- Duplicate exception action
- Timeline and history updates

## Completion Conditions

- Waiting time is reliable.
- Valid cancellations work.
- Invalid post-pickup cancellation is blocked.
- Failed deliveries receive controlled next actions.
- Returns require proof.
- Reassignment preserves product custody.
- Exception events are recorded.
- Offline queue supports permitted reports.

## Required Final Report

Report:

1. Waiting features
2. Cancellation workflow
3. Failed-delivery workflow
4. Return workflow
5. Reassignment workflow
6. Files created
7. Files modified
8. Backend changes
9. Tests added
10. Test results
11. Known limitations
12. Manual exception testing steps
13. Work intentionally left for Phase 11

Stop after Phase 10.

---

# PHASE 11 — MESSAGING, NOTIFICATIONS, SAFETY, AND PROBLEM REPORTING

## Copy and Paste This Prompt

Act as a senior real-time mobile and backend developer.

Implement Rider delivery messaging, notifications, safety tools, and non-emergency problem reporting.

Read and strictly follow `agent.md`.

Inspect the current message UI, notification service, backend real-time solution, file upload, offline queue, active-delivery screen, and support integration before changing files.

## Scope Restrictions

Implement only Rider-facing:

- Delivery conversations
- Support conversations
- Notifications
- Safety reports
- Delivery problem reports

Do not redesign Admin, Farmer, or Buyer screens.

Only modify shared communication logic when required for Rider delivery communication.

## Rider Conversations

Support conversations with:

- Farmer or seller
- Buyer
- Support

Only allow access when:

- Conversation belongs to the Rider’s active delivery
- Conversation belongs to Rider delivery history
- Support conversation is authorized

## Message Features

Support:

- Text
- Photo
- Location sharing
- Delivery update message
- Quick replies
- Sent status
- Delivered status
- Read status
- Pending status
- Failed status
- Retry
- Offline queue
- Unread count

Quick replies:

- I am on the way.
- I have arrived at the pickup location.
- Please prepare the product.
- I am waiting at the pickup location.
- The product has been picked up.
- I am near the delivery location.
- I have arrived.
- Please send the confirmation code.
- I cannot find the location.
- The route is delayed.
- Please contact support.

## Privacy

- Do not expose unnecessary phone numbers.
- Protect shared locations.
- Limit conversation access to authorized users.
- Secure uploaded photos.
- Do not allow unrelated Riders to access conversations.
- Preserve message history according to the project policy.

## Notifications

Support:

- New nearby request
- Urgent request
- Request accepted
- Request expired
- Request accepted by another Rider
- Pickup reminder
- Delivery deadline reminder
- Farmer message
- Buyer message
- Support message
- Delivery cancellation
- Reassignment
- Product ready
- Payment update
- Earnings adjustment
- Rating
- Dispute
- Safety update
- Offline synchronization result

Allow Rider to:

- Mark one as read
- Mark all as read
- Delete a notification when permitted
- Open related delivery
- Open related conversation
- Open related earnings record
- Open related report

Prevent duplicate notifications using a stable event or notification ID.

## Safety Tools

Add a visible Safety action during active delivery.

Allow reports for:

- Unsafe pickup
- Unsafe destination
- Suspicious product
- Suspicious customer
- Accident
- Vehicle breakdown
- Theft
- Harassment
- Medical emergency
- Road closure
- Severe weather
- Other

Save:

- Delivery ID
- Rider ID
- Current stage
- Location
- Accuracy
- Timestamp
- Category
- Description
- Attachments

Provide actions:

- Contact support
- Share location with support
- Request reassignment
- Request cancellation
- Continue delivery when safe

Do not automatically expose safety details to unrelated users.

## Delivery Problem Reports

Support:

- Product not ready
- Wrong product
- Incorrect quantity
- Incorrect weight
- Damaged product
- Farmer unavailable
- Buyer unavailable
- Wrong address
- Route blocked
- Confirmation-code issue
- Payment issue
- App issue
- Map issue
- Other

Allow:

- Notes
- Photos
- Location
- Timestamp

Display report status in the Active Delivery screen:

- Submitted
- Under review
- Waiting for information
- Resolved
- Rejected
- Escalated

## Offline Support

Use the Phase 9 queue for:

- Messages
- Photos
- Safety reports
- Problem reports
- Location attachments

Prevent duplicates after reconnection.

## Tests

Add tests for:

- Authorized conversation access
- Unauthorized access
- Send text
- Send photo
- Send location
- Offline message
- Retry failed message
- Read status
- Unread count
- Notification deep link
- Duplicate notification prevention
- Safety report
- Problem report
- Offline safety report
- Report-status update

## Completion Conditions

- Delivery conversations work.
- Offline messages synchronize.
- Privacy rules are enforced.
- Notification deep links work.
- Duplicate notifications are prevented.
- Safety reports contain operational information.
- Problem-report status appears in active delivery.

## Required Final Report

Report:

1. Messaging features
2. Notification features
3. Safety features
4. Problem-reporting features
5. Files created
6. Files modified
7. Backend changes
8. Tests added
9. Test results
10. Known limitations
11. Manual communication and safety test
12. Work intentionally left for Phase 12

Stop after Phase 11.

---

# PHASE 12 — EARNINGS, CASH ON DELIVERY, RATINGS, PERFORMANCE, AND FINAL RIDER TESTING

## Copy and Paste This Prompt

Act as a senior mobile, backend, and payment-integration developer.

Implement Rider earnings, delivery-fee display, cash-on-delivery handling, ratings, performance statistics, remaining Rider mock-data migration, and final complete Rider testing.

Read and strictly follow `agent.md`.

Inspect the current earnings screen, fee logic, payment records, order payment methods, ratings, performance calculations, mock data, and existing tests before changing files.

## Scope Restrictions

Implement only Rider-facing finance and performance features plus final Rider integration.

Do not recreate Rider registration, verification, documents, vehicle information, profile information, or Admin features.

Do not implement batch delivery in this phase.

## Delivery Fee Display

Before acceptance, display configured fee components:

- Base fee
- Pickup-distance fee
- Delivery-distance fee
- Product-weight fee
- Vehicle adjustment
- Urgency fee
- Perishable-product fee
- Waiting fee
- Return fee
- Additional-stop fee
- Incentive
- Bonus
- Deduction
- Penalty

The backend or domain service must calculate fees.

Do not hardcode fee calculations inside screens or UI components.

## Final Earnings

After completion, show:

- Estimated earning
- Final earning
- Waiting adjustment
- Return adjustment
- Bonus
- Incentive
- Deduction
- Penalty
- Net earning
- Payment status

## Earnings Screen

Support filters:

- Today
- Yesterday
- This week
- This month
- Custom date range

Display:

- Gross earnings
- Net earnings
- Completed-delivery earnings
- Waiting fees
- Return fees
- Bonuses
- Incentives
- Deductions
- Pending earnings
- Paid earnings

Each earning record must link to the related delivery.

## Cash on Delivery

When the order is COD, show:

- Amount to collect
- Payment status
- Amount received
- Collection confirmation
- Remittance requirement
- Rider cash responsibility
- Payment notes

Do not mark the delivery completed until:

- Correct amount is recorded, or
- An authorized payment exception exists.

Allow Rider to report:

- Buyer has insufficient cash
- Buyer refuses payment
- Amount mismatch
- Collection failed
- Buyer paid using another approved method

Prevent the Rider from changing server-authoritative payment totals.

## Ratings and Performance

Display:

- Average rating
- Total ratings
- Completed deliveries
- Acceptance rate
- Completion rate
- Cancellation rate
- On-time pickup rate
- On-time delivery rate
- Average waiting time
- Failed-delivery rate
- Customer reviews

Update performance after delivery events.

Prevent duplicate ratings for the same delivery and reviewing user.

Use respectful and helpful performance wording.

## Remaining Mock Data

Audit remaining Rider mock data.

Replace production mock data only when real integration works.

Requirements:

- Do not silently fall back to false production data.
- Preserve development fixtures separately.
- Preserve empty states.
- Remove unused imports and obsolete mock providers.
- Document any mock feature that must temporarily remain.

## Final Complete Rider Test

Test the full successful journey:

1. Rider goes Online.
2. Eligible nearby request appears.
3. Request details display.
4. Estimated earning displays.
5. Rider accepts safely.
6. Rider navigates to pickup.
7. Rider confirms arrival.
8. Rider waits when needed.
9. Rider checks product.
10. Rider completes pickup proof.
11. Rider navigates to Buyer.
12. Rider shares live progress.
13. Rider confirms destination arrival.
14. Rider completes delivery proof.
15. COD is handled when required.
16. Delivery completes.
17. Location sharing stops.
18. Active route clears.
19. Active delivery clears.
20. History updates.
21. Earnings update.
22. Performance updates.
23. Rider returns to Available.

Test exception journeys:

- Request accepted by another Rider
- Request expiration
- Repeated Accept taps
- Internet loss before acceptance
- Internet loss during pickup
- Internet loss during delivery
- App restart
- GPS disabled
- Permission revoked
- Poor GPS
- Route deviation
- Incorrect pickup code
- Incorrect delivery code
- Proof upload failure
- Product not ready
- Product damaged
- Farmer unavailable
- Buyer unavailable
- Waiting timeout
- Cancellation
- Failed delivery
- Product return
- Reassignment
- Product transfer
- Offline messages
- Offline locations
- COD failure
- Duplicate notification
- Server failure

## Quality Checks

Run:

- Formatting
- Linting
- Type checking
- Unit tests
- Integration tests
- Widget or UI tests
- Backend tests
- Concurrency tests
- Offline tests

Fix Rider-related failures introduced by this implementation.

Do not make unrelated large refactors.

## Completion Conditions

- Fee details are accurate.
- Earnings link to deliveries.
- COD requirements are enforced.
- Ratings and performance update correctly.
- Production mock data is removed safely.
- Full Rider journey works.
- Important exception journeys work.
- Automated tests pass.
- No existing Rider profile, vehicle, verification, registration, or Admin features were duplicated.

## Required Final Report

Report:

1. Fee and earnings implementation
2. COD implementation
3. Ratings and performance implementation
4. Mock data removed
5. Mock data still remaining and reason
6. Files created
7. Files modified
8. Backend or database changes
9. Tests added
10. All test results
11. Full manual test result
12. Known limitations
13. Recommended future improvements

Stop after Phase 12.

---

# OPTIONAL PHASE 13 — MULTIPLE AND BATCH DELIVERIES

## Copy and Paste This Prompt

Act as a senior logistics-routing mobile and backend developer.

Implement multiple and batch Rider deliveries.

Read and strictly follow `agent.md`.

Implement this phase only after the entire single-delivery Rider workflow is stable and tested.

Inspect vehicle capacity, delivery deadlines, route optimization, active-delivery state, proof handling, offline synchronization, earnings, and exception workflows before making changes.

## Scope

Allow a Rider to carry multiple compatible deliveries.

Do not change Rider registration, vehicle registration, verification, profile, or Admin design.

## Batch Eligibility

Only allow multiple deliveries when:

- Rider is eligible.
- Active-delivery limit allows it.
- Vehicle capacity is sufficient.
- Combined weight is valid.
- Products can safely travel together.
- Pickup routes are compatible.
- Delivery destinations are compatible.
- All pickup deadlines can be met.
- All delivery deadlines can be met.
- Product-handling rules are compatible.

## Prevent Incompatible Grouping

Prevent grouping when:

- Combined weight exceeds capacity.
- Product conditions conflict.
- Temperature requirements conflict.
- Fragile products cannot be protected.
- Deadlines are impossible.
- Routes create unreasonable delays.
- One delivery requires exclusive transport.
- Rider status does not allow another assignment.

## Batch Display

Show:

- All active deliveries
- Optimized pickup sequence
- Optimized delivery sequence
- Total distance
- Combined estimated time
- Individual deadlines
- Individual earnings
- Combined earnings
- Remaining vehicle capacity
- Product-handling warnings

## Status Handling

Each delivery must retain its own:

- Status
- Timeline
- Proof
- Confirmation code
- Messages
- Payment
- Earnings
- Problems
- History

Do not apply one delivery’s proof or status to another delivery.

## Route Optimization

Create or use a route optimizer that considers:

- Current Rider location
- Pickup order
- Destination order
- Time windows
- Deadlines
- Product requirements
- Vehicle capacity
- Route distance
- Estimated traffic when available

Allow safe recalculation when one delivery changes.

## Cancellation and Failure

Handle:

- One request cancelled before pickup
- One delivery fails
- One Buyer unavailable
- One product requires return
- Remaining deliveries continue
- Route is recalculated
- Capacity is updated
- Earnings are updated separately

## Offline Support

Queue actions separately by delivery.

Preserve ordering dependencies.

Prevent one delivery’s offline conflict from corrupting another delivery.

## Tests

Add tests for:

- Two compatible deliveries
- Incompatible products
- Capacity exceeded
- Pickup sequence
- Delivery sequence
- Deadline conflict
- One cancellation
- One failed delivery
- One return
- Separate proof
- Separate COD payment
- Separate earnings
- Offline synchronization
- App restart with batch delivery
- Route recalculation

## Completion Conditions

- Multiple deliveries remain separate.
- Capacity rules are enforced.
- Route order is valid.
- Individual proof is protected.
- Individual payments and earnings are accurate.
- Failure of one delivery does not corrupt others.
- Offline synchronization remains safe.

## Required Final Report

Report:

1. Batch-delivery architecture
2. Compatibility rules
3. Route-optimization method
4. Files created
5. Files modified
6. Backend changes
7. Tests added
8. Test results
9. Known limitations
10. Manual batch-delivery test steps

Stop after Phase 13.

| Phase                                 | Recommended capability |
| ------------------------------------- | ---------------------- |
| Phase 0 — Codebase audit              | **Extra High**         |
| Phase 1 — Statuses and architecture   | **Extra High**         |
| Phase 2 — Availability and dashboard  | **High**               |
| Phase 3 — Requests and matching       | **High**               |
| Phase 4 — Safe acceptance             | **Extra High**         |
| Phase 5 — Delivery workflow           | **Extra High**         |
| Phase 6 — Pickup confirmation         | **High**               |
| Phase 7 — Map, GPS, and routing       | **Extra High**         |
| Phase 8 — Delivery completion         | **High**               |
| Phase 9 — Offline synchronization     | **Extra High**         |
| Phase 10 — Cancellation and returns   | **Extra High**         |
| Phase 11 — Messages and notifications | **High**               |
| Phase 12 — Earnings and final testing | **Extra High**         |
| Phase 13 — Batch delivery, optional   | **Extra High**         |
