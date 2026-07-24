# Mailbox Integration - Current Status

**Last Updated**: 2026-07-24

## ✅ **COMPLETE - Ready to Test**

The mailbox integration is **fully wired to the real backend API** and ready for testing!

### What's Been Implemented

1. **✅ API Client** - `MailboxServiceClient.swift`
   - Connected to real deployed API: `https://l8yqwba7pd.execute-api.eu-west-2.amazonaws.com/prod`
   - All 6 endpoints implemented (list, get, read, unread, archive, delete, consent)

2. **✅ Test Token Issuer** - `TestTokenIssuer.swift`
   - Integrated: `https://xd2oxqfeqb.execute-api.eu-west-2.amazonaws.com/v1/`
   - Generates test tokens on-demand for development

3. **✅ Service Layer** - `MailboxService.swift`
   - Updated to call real API (no more mock data!)
   - Token management integrated
   - Uses test-citizen-001 by default

4. **✅ Model Adapters** - `Mailbox.swift`
   - Converts API models (MessageListItem/MessageDetail) to UI models (MailboxMessage)
   - Maps department names to UI sender types

5. **✅ Setup Helper** - `MailboxSetupHelper.swift`
   - Creates mailboxes for test users
   - Grants department consents
   - Streamlined setup for testing

## 📋 **Files Created/Updated**

### New Files
- `Production/govuk_ios/ServiceClients/TestTokenIssuer.swift` - Token generation
- `Production/govuk_ios/ServiceClients/MailboxSetupHelper.swift` - Test setup utilities

### Updated Files
- `Production/govuk_ios/ServiceClients/MailboxServiceClient.swift` - Real API URL
- `Production/govuk_ios/Services/MailboxService.swift` - Wired to real API
- `Production/govuk_ios/Model/Mailbox.swift` - Added model adapters

### Existing Files (Already in Project)
- `Production/govuk_ios/Views/Mailbox/MailboxListView.swift`
- `Production/govuk_ios/Views/Mailbox/MailboxDetailView.swift`
- `Production/govuk_ios/Views/Mailbox/MailboxMessageRow.swift`
- `Production/govuk_ios/ViewModels/Mailbox/MailboxListViewModel.swift`
- `Production/govuk_ios/ViewModels/Mailbox/MailboxDetailViewModel.swift`
- `Production/govuk_ios/Coordinators/Mailbox/MailboxCoordinator.swift`
- `Production/govuk_ios/Model/Mailbox/MailboxMessage.swift`

## 🎯 **Next Steps**

### 1. Add New Files to Xcode Project (5 minutes)

The two new Swift files need to be added to the Xcode project:

1. Open `GovUK.xcodeproj` in Xcode
2. Right-click `Production/govuk_ios/ServiceClients` in Project Navigator
3. Select "Add Files to GovUK..."
4. Add:
   - `TestTokenIssuer.swift`
   - `MailboxSetupHelper.swift`
5. Ensure "Copy items if needed" is **unchecked**
6. Ensure target is `govuk_ios`

### 2. Seed Test Data (from mailbox repo)

```bash
cd ../mailbox
pnpm seed-data
```

This will:
- Create a mailbox for test-citizen-001
- Grant consents to DWP, DVLA, HMRC
- Send 7 test messages

### 3. Build & Run

```bash
xcodebuild -project GovUK.xcodeproj -scheme GovUK -destination 'platform=iOS Simulator,name=iPhone 15' build
```

Or open in Xcode and run (⌘R)

### 4. Navigate to Mailbox Tab

The mailbox tab should already be in the app's tab bar. Tap it to see the messages!

## 🔧 **Configuration**

### Current Test User
- **authSystemSub**: `test-citizen-001`
- **Name**: Sarah Thompson
- **NI Number**: ST123456A
- **Driver Number**: THOMS801234ST9IJ
- **Tax Reference**: 1234567890

To use a different test user, modify `MailboxService.init()`:

```swift
MailboxService(testAuthSystemSub: "test-citizen-002")
```

Available test citizens: `test-citizen-001`, `test-citizen-002`, `test-citizen-003`

### API Endpoints

All configured in the respective service clients:

- **Client Access API**: `https://l8yqwba7pd.execute-api.eu-west-2.amazonaws.com/prod`
- **Identity Resolution API**: `https://ifu2dhrrpl.execute-api.eu-west-2.amazonaws.com/prod`
- **Test Token Issuer**: `https://xd2oxqfeqb.execute-api.eu-west-2.amazonaws.com/v1/`

## 🧪 **Testing**

### Manual Testing Steps

1. **Launch app** - Build and run in simulator
2. **Open Mailbox tab** - Should show loading state
3. **View messages** - List of government messages appears
4. **Tap a message** - Opens detail view with full body
5. **Mark as read** - Opens automatically, can mark unread via context menu
6. **Delete message** - Swipe left or use context menu
7. **Filter by sender** - Use chip filters at top of list

### Expected Behavior

- ✅ Messages load from real API (no mock data)
- ✅ Tokens generated automatically per request
- ✅ Sender names mapped correctly (DWP, DVLA, HMRC, etc.)
- ✅ Read/unread status syncs with backend
- ✅ Delete removes from backend

### Debugging

If messages don't load:

1. **Check backend deployment**: Visit API URL in browser (should return 404 but not timeout)
2. **Check test data**: Run `pnpm seed-data` in mailbox repo
3. **Check Xcode console**: Look for API errors or token generation failures
4. **Verify test user**: Mailbox created for test-citizen-001?

## 📊 **Architecture**

```
MailboxListView (UI)
    ↓
MailboxListViewModel
    ↓
MailboxService (Service Layer)
    ↓
TestTokenIssuer + MailboxServiceClient (API Layer)
    ↓
Real Backend API (AWS Lambda)
```

**Key Design Decisions**:

1. **Token per request** - Simple for PoC, tokens generated on-demand
2. **Adapter pattern** - API models convert to existing UI models
3. **Backwards compatible** - Existing UI code unchanged
4. **Test issuer** - Uses test tokens until OneLogin integration

## 🔮 **Future Work**

### Before Production (M4 - 2026-09-05)

1. **Real authentication** - Switch from test issuer to OneLogin tokens
2. **Token caching** - Cache tokens with refresh logic
3. **Error handling** - Better user-facing error messages
4. **Offline support** - Cache messages locally
5. **Unit tests** - Test service layer with mocked API client
6. **UI tests** - Critical flow tests

### Post-PoC Enhancements

1. **Push notifications** - New message alerts
2. **Rich actions** - In-app actions beyond just links
3. **Message search** - Filter/search messages
4. **Batch operations** - Mark all as read, bulk delete
5. **Badge counts** - Unread count on tab bar

## 📞 **Support**

**Backend Deployed By**: Backend team
**CloudFormation Stack**: MailboxStack
**AWS Region**: eu-west-2

**Test Data Script**: `../mailbox/scripts/seed-test-data.ts`

**Questions?**
- Check `MAILBOX_INTEGRATION.md` for API docs
- Check `MAILBOX_README.md` for implementation details
- Check backend repo: `../mailbox/`

---

**Status**: ✅ **READY TO TEST** 
**Next Action**: Add new files to Xcode + seed test data + run app
