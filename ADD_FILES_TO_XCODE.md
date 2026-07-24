# How to Add Files to Xcode Project

## The Two New Files That Need Adding

These files exist on disk but aren't in the Xcode project yet:

```
Production/govuk_ios/ServiceClients/TestTokenIssuer.swift
Production/govuk_ios/ServiceClients/MailboxSetupHelper.swift
```

## Option 1: Drag & Drop (Easiest - 30 seconds)

1. **Open the project**: Double-click `GovUK.xcodeproj` 
2. **In Finder**: Navigate to `Production/govuk_ios/ServiceClients/`
3. **Drag both files** from Finder into Xcode's Project Navigator under the `ServiceClients` group
4. **In the dialog that appears**:
   - ✅ Check "govuk_ios" target
   - ❌ **UNCHECK** "Copy items if needed" (important!)
   - ✅ Select "Create groups"
5. **Click "Finish"**

Done! Build the project (⌘B) to verify.

## Option 2: Add Files Menu (2 minutes)

1. **Open `GovUK.xcodeproj` in Xcode**

2. **In Project Navigator** (left sidebar), navigate to:
   ```
   GovUK
     └── Production
         └── govuk_ios  
             └── ServiceClients
   ```

3. **Right-click** on `ServiceClients` folder → **"Add Files to GovUK..."**

4. **Navigate to and select**:
   - `TestTokenIssuer.swift`
   - `MailboxSetupHelper.swift`
   
   (Hold ⌘ to multi-select both files)

5. **In the add dialog**:
   - **Destination**: ❌ UNCHECK "Copy items if needed"
   - **Added folders**: ✅ "Create groups" (NOT "Create folder references")
   - **Add to targets**: ✅ CHECK "govuk_ios"

6. **Click "Add"**

7. **Verify**: You should now see both files in the ServiceClients group in Xcode

8. **Build** (⌘B) to verify they compile

## Why This is Necessary

Xcode doesn't auto-discover files like modern tools (npm, cargo, go). Every file must be explicitly added to:
- The `project.pbxproj` file (lists all files)
- A build target (which app/framework to compile into)

**Fun fact**: This is why you can have files in your repo that Xcode ignores - they're just not in the project file!

## Verifying It Worked

After adding the files, check:

1. ✅ Both files appear in Project Navigator under ServiceClients
2. ✅ They have the target membership icon (checkbox) next to them
3. ✅ Building succeeds (⌘B)
4. ✅ No "Cannot find type" errors for `TestTokenIssuer` or `MailboxSetupHelper`

## Next Steps

Once the files are added:

```bash
# Seed test data
cd ../mailbox
ts-node scripts/seed-test-data.ts

# Back to iOS repo
cd ../govuk-mobile-ios-app

# Build and run
# Press ⌘R in Xcode
```

The app will now call the real mailbox API!
