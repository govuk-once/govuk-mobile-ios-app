# 🚀 Mailbox Quick Start Guide

**TL;DR**: Everything is wired up and ready to test! Just add the new files to Xcode, seed data, and run.

## Prerequisites ✅

- ✅ Backend deployed
- ✅ API URLs configured
- ✅ Test token issuer integrated
- ✅ Swift files created
- ⚠️ Need to add files to Xcode project

## Quick Start (5 minutes)

### 1. Add New Files to Xcode

Open `GovUK.xcodeproj` and add these two new files to the `govuk_ios` target:

```
Production/govuk_ios/ServiceClients/TestTokenIssuer.swift
Production/govuk_ios/ServiceClients/MailboxSetupHelper.swift
```

**How to add:**
1. In Xcode Project Navigator, right-click `Production/govuk_ios/ServiceClients`
2. Select "Add Files to GovUK..."
3. Navigate to the files above
4. **Uncheck** "Copy items if needed"
5. Select target: `govuk_ios`
6. Click "Add"

### 2. Seed Test Data

Run the seed script from the mailbox repo:

```bash
cd ../mailbox
ts-node scripts/seed-test-data.ts
```

Or use the helper script from iOS repo:

```bash
./scripts/seed-mailbox-data.sh
```

This creates:
- ✅ Mailbox for test-citizen-001
- ✅ Consents to DWP, DVLA, HMRC
- ✅ 7 government messages (UC, tax, vehicle tax, etc.)

### 3. Build & Run

In Xcode: Press ⌘R

Or from terminal:
```bash
xcodebuild -project GovUK.xcodeproj \
  -scheme GovUK \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build
```

### 4. Navigate to Mailbox

Open the Mailbox tab in the app. You should see 7 test messages!

## What Changed

### New Files Created
- `TestTokenIssuer.swift` - Generates test tokens from test issuer
- `MailboxSetupHelper.swift` - Utility to create mailboxes and grant consents

### Files Updated
- `MailboxServiceClient.swift` - Updated with real API URL
- `MailboxService.swift` - Wired to real API (removed mock data)
- `Mailbox.swift` - Added adapters to convert API → UI models

### Configuration
All hardcoded with deployed URLs:
- **Client Access API**: `https://l8yqwba7pd.execute-api.eu-west-2.amazonaws.com/prod`
- **Test Token Issuer**: `https://xd2oxqfeqb.execute-api.eu-west-2.amazonaws.com/v1/`
- **Identity Resolution**: `https://ifu2dhrrpl.execute-api.eu-west-2.amazonaws.com/prod`

## Testing

### Expected Flow
1. **App launches** → Mailbox tab visible
2. **Tap Mailbox** → Loading spinner
3. **Token generation** → TestTokenIssuer fetches token for test-citizen-001
4. **API call** → MailboxServiceClient.listMessages()
5. **Messages render** → 7 government messages appear
6. **Tap message** → Detail view with full body
7. **Mark as read** → PATCH to backend
8. **Delete message** → DELETE to backend

### Manual Testing Checklist
- [ ] Messages load (not empty/error state)
- [ ] Can tap message to see detail
- [ ] Detail shows full message body
- [ ] Messages marked as read (visual indicator)
- [ ] Can mark as unread via context menu
- [ ] Can delete message (swipe or context menu)
- [ ] Filter chips work (All, DVLA, HMRC, DWP, etc.)
- [ ] Sender icons/colors display correctly

### Debugging

**No messages showing?**
1. Check Xcode console for errors
2. Verify seed script ran successfully
3. Try deleting app and reinstalling
4. Check Network tab in Xcode debugger

**API errors?**
1. Verify backend is deployed: `curl https://l8yqwba7pd.execute-api.eu-west-2.amazonaws.com/prod/messages` (should return 401)
2. Check test issuer: `curl -X POST https://xd2oxqfeqb.execute-api.eu-west-2.amazonaws.com/v1/token -H "Content-Type: application/json" -d '{"authSystemSub":"test-citizen-001"}'`

**Build errors?**
1. Make sure both new files are added to Xcode target
2. Clean build folder (⌘⇧K)
3. Check imports are correct

## Architecture Overview

```
┌─────────────────────────────────────┐
│  MailboxListView (SwiftUI)          │
└────────────┬────────────────────────┘
             │
┌────────────▼────────────────────────┐
│  MailboxListViewModel                │
└────────────┬────────────────────────┘
             │
┌────────────▼────────────────────────┐
│  MailboxService                      │
│  - Manages state                     │
│  - Calls API client                  │
│  - Generates tokens                  │
└────────────┬────────────────────────┘
             │
     ┌───────┴───────┐
     ▼               ▼
┌──────────┐  ┌──────────────────┐
│ Test     │  │ Mailbox          │
│ Token    │  │ Service          │
│ Issuer   │  │ Client           │
└────┬─────┘  └────┬─────────────┘
     │             │
     │             │
     └─────┬───────┘
           ▼
    ┌──────────────┐
    │  Real        │
    │  Backend     │
    │  API         │
    └──────────────┘
```

## Test Users

Three test citizens available:

### test-citizen-001 (default)
- Name: Sarah Thompson
- NI: ST123456A
- Driver: THOMS801234ST9IJ
- Tax Ref: 1234567890

### test-citizen-002
- Name: James Wilson
- NI: JW987654B
- Driver: WILSO902156JW1AB
- Tax Ref: 0987654321

### test-citizen-003
- Name: Aisha Patel
- NI: AP456789C
- Driver: PATEL703289AP2CD
- Tax Ref: 5555666777

To switch users, modify `MailboxService.init()` or pass a different `testAuthSystemSub` parameter.

## Next Steps

### Before M4 (2026-09-05)
- [ ] Replace test tokens with real OneLogin tokens
- [ ] Add token caching/refresh logic
- [ ] Implement offline support
- [ ] Add unit tests
- [ ] Add UI tests
- [ ] Improve error handling

### Nice to Have
- [ ] Push notifications for new messages
- [ ] Message search
- [ ] Batch operations
- [ ] Badge count on tab

## Resources

- **Full Status**: See `MAILBOX_STATUS.md`
- **Integration Docs**: See `MAILBOX_INTEGRATION.md`
- **Implementation Guide**: See `MAILBOX_README.md`
- **Backend Repo**: `../mailbox/`
- **Seed Script**: `../mailbox/scripts/seed-test-data.ts`

## Support

**Issues?**
1. Check the Xcode console output
2. Verify backend deployment
3. Check network requests in Xcode debugger
4. Review `MAILBOX_STATUS.md` for troubleshooting

**Questions?**
Ask the backend team or check the integration docs!

---

✅ **Status**: Ready to test!  
🎯 **Next**: Add files to Xcode → Seed data → Run app
