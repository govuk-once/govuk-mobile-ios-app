# Mailbox iOS Implementation

This directory contains the iOS implementation for the Government Mailbox feature.

## What's Been Created

### 1. Data Models (`Model/Mailbox.swift`)
- `MessageListItem` - Message summary for list view
- `MessageDetail` - Full message with body and actions
- `GrantConsentRequest/Response` - Department consent models
- `CreateMailboxResponse` - Mailbox creation
- `MailboxError` - Error types

### 2. Service Client (`ServiceClients/MailboxServiceClient.swift`)
- `MailboxServiceClientInterface` - Protocol for dependency injection
- `MailboxServiceClient` - API client implementation
- Endpoints:
  - `createMailbox()` - POST /users
  - `listMessages()` - GET /messages
  - `getMessage()` - GET /messages/{id}
  - `markAsRead()` - PATCH /messages/{id}
  - `markAsUnread()` - PATCH /messages/{id}
  - `archiveMessage()` - PATCH /messages/{id}
  - `deleteMessage()` - DELETE /messages/{id}
  - `grantConsent()` - POST /consents

### 3. View Models (`ViewModels/MailboxViewModel.swift`)
- `MailboxViewModel` - Manages message list state
- `MessageDetailViewModel` - Manages single message state
- Includes loading, error handling, and pagination

### 4. SwiftUI Views
- `MailboxListView.swift` - Message list with swipe actions
- `MessageDetailView.swift` - Full message display with actions
- Includes:
  - Pull-to-refresh
  - Pagination ("Load More")
  - Swipe to delete/archive
  - Message type badges
  - Deadline warnings
  - Action buttons
  - Empty state
  - Error handling

### 5. API Testing (`../../mailbox/mailbox-api.http`)
Located in the mailbox backend repo for seeding test data:
- Setup citizen mailbox
- Grant department consents
- Seed 7 test messages
- Test all CRUD operations

## How to Use in Xcode

### 1. Add Files to Xcode Project

1. Open `GovUK.xcodeproj` in Xcode
2. Right-click on the project navigator
3. Select "Add Files to GovUK..."
4. Navigate to `Production/govuk_ios/` and select:
   - `Model/Mailbox.swift`
   - `ServiceClients/MailboxServiceClient.swift`
   - `ViewModels/MailboxViewModel.swift`
   - `SwiftUIViews/MailboxListView.swift`
   - `SwiftUIViews/MessageDetailView.swift`
5. Ensure "Copy items if needed" is **unchecked** (files are already in correct location)
6. Ensure "Create groups" is selected
7. Add to target: `govuk_ios`

### 2. Configure the Service Client

In your app initialization or dependency injection setup:

```swift
// Example: In your main app or coordinator
let mailboxServiceClient = MailboxServiceClient(
    baseURL: "https://client-access.mailbox-dev.once.service.gov.uk"
)
```

**Important**: Update the `baseURL` when the backend is deployed. Current URL is a placeholder.

### 3. Get a Test Token

**Backend team needs to provide**:
1. Test token generation script
2. Or: Test issuer endpoint URL
3. Example test tokens

For development, you can use a placeholder token:
```swift
let testToken = "YOUR_TEST_TOKEN_HERE"
```

### 4. Display the Mailbox View

Add to your navigation structure:

```swift
// Simple example - add to your tab bar or navigation
MailboxListView(
    viewModel: MailboxViewModel(
        serviceClient: mailboxServiceClient,
        token: currentUserToken
    )
)
```

### 5. Preview in Xcode

The views include SwiftUI previews with mock data:
- Open `MailboxListView.swift` in Xcode
- Click the "Resume" button in the preview canvas
- Or: Cmd+Option+Enter to show previews

## Testing the Backend API

### Prerequisites

1. **Deploy the backend** (from mailbox repo):
   ```bash
   cd ../mailbox
   pnpm run deploy:development
   ```

2. **Get the deployed URL** from CloudFormation outputs

3. **Get a test token** from the backend team

4. **Update the `.http` file**:
   - Open `../mailbox/mailbox-api.http`
   - Replace `@baseUrl` with actual deployed URL
   - Replace `@testToken` with actual test token
   - Replace `@departmentApiKey` with actual API key

### Using VS Code REST Client

1. Install "REST Client" extension in VS Code
2. Open `../mailbox/mailbox-api.http`
3. Click "Send Request" above any request block

### Seed Test Data Flow

**Run these requests in order**:

1. **Create Mailbox**:
   ```
   POST {{baseUrl}}/users
   ```

2. **Grant Consents** (run all 3):
   ```
   POST {{baseUrl}}/consents (DWP)
   POST {{baseUrl}}/consents (DVLA)
   POST {{baseUrl}}/consents (HMRC)
   ```

3. **Seed Messages** (run all 7):
   - Urgent UC message with deadline
   - Vehicle tax due
   - Tax return reminder
   - Passport update
   - State pension
   - Driving licence renewal
   - Simple informational message

4. **Verify in iOS App**:
   - Build and run the iOS app
   - Navigate to mailbox view
   - Messages should appear

## Current Limitations (PoC)

1. **Authentication**: Using test issuer, not real OneLogin
2. **Token Management**: No automatic refresh implemented
3. **Offline Support**: Not implemented
4. **Push Notifications**: Not implemented
5. **Message Body**: Plain text only (no HTML formatting)
6. **Attachments**: Not supported
7. **Search/Filter**: Not implemented
8. **Badge Counts**: Not implemented

## Next Steps

### Immediate (to see it working)

1. ✅ Add Swift files to Xcode project
2. ⏳ Wait for backend deployment
3. ⏳ Get test token from backend team
4. ✅ Configure service client with real URL
5. ✅ Integrate into app navigation
6. ✅ Test with seeded data

### Before M4 Milestone (2026-09-05)

1. **Authentication Integration**
   - Wire up real token from app's existing auth flow
   - Handle token refresh
   - Store token securely in Keychain

2. **Navigation Integration**
   - Add mailbox tab to main tab bar
   - Or: Add to existing account/services section
   - Deep linking support

3. **Testing**
   - Unit tests for ViewModels
   - UI tests for critical flows
   - Error scenario testing

4. **Polish**
   - Loading states
   - Error recovery
   - Empty states
   - Accessibility labels

## File Structure

```
Production/govuk_ios/
├── Model/
│   └── Mailbox.swift                 # Data models and errors
├── ServiceClients/
│   └── MailboxServiceClient.swift    # API client
├── ViewModels/
│   └── MailboxViewModel.swift        # View state management
└── SwiftUIViews/
    ├── MailboxListView.swift         # Message list
    └── MessageDetailView.swift       # Message detail
```

## Architecture

Follows the app's existing patterns:
- **MVVM**: ViewModels manage state, Views are declarative
- **Protocol-oriented**: Service client uses protocol for testing
- **Completion handlers**: Async/await can be added later
- **SwiftUI**: Modern declarative UI

## Troubleshooting

### "Cannot find type 'MailboxServiceClient'"
- Ensure files are added to Xcode project
- Check target membership is set to `govuk_ios`
- Clean build folder (Cmd+Shift+K)

### "401 Unauthorized"
- Token is invalid or expired
- Get fresh token from backend team
- Check token format includes "Bearer" prefix

### "No messages appearing"
- Run seed data requests first (see `.http` file)
- Check backend logs for errors
- Verify consent was granted for departments

### "Network error"
- Check backend is deployed
- Verify base URL is correct
- Check device/simulator has internet access

### Preview not working
- Mock service client is included for previews
- Ensure `#if DEBUG` block is uncommented
- Try Cmd+Option+P to refresh previews

## API Documentation

Full API documentation: `MAILBOX_INTEGRATION.md`

Includes:
- Complete endpoint specifications
- Request/response schemas
- Authentication details
- Error handling guide
- Swift networking examples

## Contact

**Backend Team** (for deployment/tokens):
- Repository: `gds/once/mailbox`
- See: `mailbox/docs/ios-integration-handover.md`

**Questions**:
1. Where is the deployed API URL?
2. How do I get test tokens?
3. What are the test department IDs?
4. Is CORS configured?

## Screenshots

_Add screenshots here once implemented_

## Demo Video

_Add demo video link here once recorded_

---

**Created**: 2026-07-23  
**Status**: Ready for integration (pending backend deployment)  
**Next Review**: After backend M3 milestone
