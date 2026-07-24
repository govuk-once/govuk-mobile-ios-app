# Mailbox API Integration Guide

**Version**: 1.0 (PoC)  
**Last Updated**: 2026-07-23  
**Backend Repository**: `gds/once/mailbox`

## Overview

This guide helps the iOS team integrate with the Mailbox Client Access API. The API allows citizens to:
- List their government mail
- View individual messages
- Mark messages as read/unread
- Delete and archive messages
- Grant consent for departments to send them mail

## Quick Start

### 1. API Base URL

```swift
// Development environment (to be deployed)
let baseURL = "https://client-access.mailbox-dev.once.service.gov.uk"

// Note: Actual URL will be provided once deployed
// Check with backend team for current deployment status
```

### 2. Authentication

All API requests require a Bearer token in the Authorization header:

```swift
let token = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9..." // From test issuer
let headers = [
    "Authorization": "Bearer \(token)",
    "Content-Type": "application/json"
]
```

**PoC Authentication Flow**:
1. For the PoC, tokens are issued by a **test issuer** (not real OneLogin)
2. The test issuer JWKS endpoint will be provided by the backend team
3. Tokens contain an `auth_system_sub` claim that resolves to a `mailboxId`
4. The API's Lambda authorizer validates the token signature and resolves the citizen's identity

**Getting Test Tokens**:

The test issuer provides an endpoint to generate tokens on-demand:

```bash
# Generate a token for a specific test citizen
curl -X POST https://test-issuer.mailbox-dev.once.service.gov.uk/v1/token \
  -H "Content-Type: application/json" \
  -d '{"authSystemSub": "test-citizen-001"}'

# Response:
{
  "token": "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**OR** use the VS Code REST Client with `mailbox-api.http`:
1. Open `../mailbox/mailbox-api.http`
2. Run section "0.1 Generate Token from Test Issuer"
3. Copy the token from the response

Each test token represents a specific test citizen (identified by `authSystemSub`).
Tokens expire after 24 hours - generate a new one when needed.

### 3. Required Setup Steps

Before a citizen can receive mail, they must:

1. **Create their mailbox** (one-time):
   ```swift
   POST /users
   // No body required - mailboxId is derived from the token's auth_system_sub claim
   ```

2. **Grant department consent** (per department):
   ```swift
   POST /consents
   {
     "departmentId": "dwp",
     "departmentPersonId": "ABC123456"
   }
   ```

**Important**: If a citizen hasn't created their mailbox or granted consent to a department, messages from that department will be rejected at ingestion time (fail-closed by design).

---

## API Endpoints

### Base Headers

All requests must include:
```
Authorization: Bearer {token}
Content-Type: application/json
```

---

### 1. List Messages

**Endpoint**: `GET /messages`

**Description**: Lists all messages for the authenticated citizen, ordered by `receivedAt` (newest first).

**Query Parameters**:
- `limit` (optional, number): Maximum messages to return (default varies by backend config)
- `nextToken` (optional, string): Pagination token from a previous response

**Request Example**:
```http
GET /messages?limit=20 HTTP/1.1
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "messages": [
    {
      "messageId": "3f083b6b-69ad-423e-93a1-7ab2c8e58353",
      "mailboxId": "a7f3c2e1-5d9b-4a1e-8f7d-2c9e4b6a1d3f",
      "receivedAt": "2026-07-21T09:30:00Z",
      "subject": "Action required: Upload your fit note",
      "sender": "Department for Work and Pensions"
    },
    {
      "messageId": "8a2d4f1c-3e7b-4c9a-9f2e-1d5b7a3c8e6f",
      "mailboxId": "a7f3c2e1-5d9b-4a1e-8f7d-2c9e4b6a1d3f",
      "receivedAt": "2026-07-20T14:15:00Z",
      "subject": "Your vehicle tax is due",
      "sender": "Driver and Vehicle Licensing Agency"
    }
  ],
  "nextToken": "eyJtYWlsYm94SWQiOiJhN2YzYzJlMS01ZDliLTRhMWUtOGY3ZC0yYzllNGI2YTFkM2YiLCJyZWNlaXZlZEF0IjoiMjAyNi0wNy0yMFQxNDoxNTowMFoifQ=="
}
```

**Response Fields**:
- `messages`: Array of message list items (see schema below)
- `nextToken`: Present if there are more messages to fetch (pass to next request)

**Error Responses**:
- `401 Unauthorized`: Invalid or expired token
- `500 Internal Server Error`: Authorization context invalid (should never happen in production)

**iOS Implementation Notes**:
- Implement pagination using `nextToken` for "Load More" functionality
- Cache `receivedAt` for the last fetched message to enable pull-to-refresh
- Filter deleted messages on the client side if needed (backend may include soft-deleted items)

---

### 2. Get Message Details

**Endpoint**: `GET /messages/{messageId}`

**Description**: Retrieves full details of a specific message, including the message body.

**Path Parameters**:
- `messageId` (required, string): The UUID of the message

**Request Example**:
```http
GET /messages/3f083b6b-69ad-423e-93a1-7ab2c8e58353 HTTP/1.1
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "messageId": "3f083b6b-69ad-423e-93a1-7ab2c8e58353",
  "mailboxId": "a7f3c2e1-5d9b-4a1e-8f7d-2c9e4b6a1d3f",
  "receivedAt": "2026-07-21T09:30:00Z",
  "subject": "Action required: Upload your fit note",
  "sender": "Department for Work and Pensions",
  "body": "You need to upload a fit note from your GP to continue receiving Universal Credit payments.\n\nIf you don't upload a fit note by 28 July 2026, your payments may be affected."
}
```

**Response Fields**:
- All fields from message list item, plus:
- `body` (string): Full message content (plain text for PoC)

**Error Responses**:
- `400 Bad Request`: Missing messageId parameter
- `401 Unauthorized`: Invalid or expired token
- `404 Not Found`: Message doesn't exist OR belongs to a different citizen
- `500 Internal Server Error`: Authorization context invalid

**Security Note**: 
The API returns `404` for both "message doesn't exist" and "message belongs to another citizen" to prevent information leakage. Never assume a 404 means the messageId is invalid.

---

### 3. Mark Message as Read

**Endpoint**: `PATCH /messages/{messageId}`

**Description**: Marks a message as read by setting a `readAt` timestamp.

**Path Parameters**:
- `messageId` (required, string): The UUID of the message

**Request Body**:
```json
{
  "readAt": "2026-07-23T10:15:30Z"
}
```

**Request Example**:
```http
PATCH /messages/3f083b6b-69ad-423e-93a1-7ab2c8e58353 HTTP/1.1
Authorization: Bearer {token}
Content-Type: application/json

{
  "readAt": "2026-07-23T10:15:30Z"
}
```

**Response** (200 OK):
```json
{
  "success": true
}
```

**Error Responses**:
- `400 Bad Request`: Missing messageId or invalid readAt format
- `401 Unauthorized`: Invalid or expired token
- `404 Not Found`: Message doesn't exist or belongs to another citizen
- `500 Internal Server Error`: Update failed

**iOS Implementation Notes**:
- Use ISO 8601 format for `readAt` timestamp: `Date().ISO8601Format()`
- Mark as read when the user views the message detail screen
- Optimistically update UI and handle failures gracefully
- Consider debouncing if rapidly marking multiple messages

---

### 4. Mark Message as Unread

**Endpoint**: `PATCH /messages/{messageId}`

**Description**: Marks a message as unread by removing the `readAt` timestamp.

**Path Parameters**:
- `messageId` (required, string): The UUID of the message

**Request Body**:
```json
{
  "readAt": null
}
```

**Request Example**:
```http
PATCH /messages/3f083b6b-69ad-423e-93a1-7ab2c8e58353 HTTP/1.1
Authorization: Bearer {token}
Content-Type: application/json

{
  "readAt": null
}
```

**Response** (200 OK):
```json
{
  "success": true
}
```

**Error Responses**: Same as "Mark as Read"

**iOS Implementation Notes**:
- Use `null` (not omit the field) to clear the `readAt` timestamp
- Consider swipe actions for quick mark as unread from list view

---

### 5. Delete Message

**Endpoint**: `DELETE /messages/{messageId}`

**Description**: Soft-deletes a message. The message is flagged as deleted but not removed from storage.

**Path Parameters**:
- `messageId` (required, string): The UUID of the message

**Request Example**:
```http
DELETE /messages/3f083b6b-69ad-423e-93a1-7ab2c8e58353 HTTP/1.1
Authorization: Bearer {token}
```

**Response** (204 No Content):
```
(Empty body)
```

**Error Responses**:
- `400 Bad Request`: Missing messageId
- `401 Unauthorized`: Invalid or expired token
- `404 Not Found`: Message doesn't exist or already deleted
- `500 Internal Server Error`: Delete operation failed

**iOS Implementation Notes**:
- Soft-delete means the backend flags the message as deleted
- Remove from local UI immediately on success
- Show "Undo" option if implementing a trash/recently deleted feature
- Deleted messages may still appear in API responses - filter by a `deleted` flag if present

---

### 6. Archive Message

**Endpoint**: `PATCH /messages/{messageId}`

**Description**: Archives a message by setting an `archived` flag.

**Path Parameters**:
- `messageId` (required, string): The UUID of the message

**Request Body**:
```json
{
  "archived": true
}
```

**Request Example**:
```http
PATCH /messages/3f083b6b-69ad-423e-93a1-7ab2c8e58353 HTTP/1.1
Authorization: Bearer {token}
Content-Type: application/json

{
  "archived": true
}
```

**Response** (200 OK):
```json
{
  "success": true
}
```

**To Unarchive**:
```json
{
  "archived": false
}
```

**Error Responses**: Same as other PATCH operations

**iOS Implementation Notes**:
- Use separate views/filters for archived vs active messages
- Archive is distinct from delete - archived messages are still accessible
- Consider swipe actions for quick archiving from list view

---

### 7. Grant Department Consent

**Endpoint**: `POST /consents`

**Description**: Links a department's identifier for the citizen to their mailbox, enabling that department to send them mail.

**Request Body**:
```json
{
  "departmentId": "dwp",
  "departmentPersonId": "ABC123456"
}
```

**Request Example**:
```http
POST /consents HTTP/1.1
Authorization: Bearer {token}
Content-Type: application/json

{
  "departmentId": "dwp",
  "departmentPersonId": "NI123456C"
}
```

**Response** (201 Created):
```json
{
  "mailboxId": "a7f3c2e1-5d9b-4a1e-8f7d-2c9e4b6a1d3f",
  "departmentId": "dwp",
  "departmentPersonId": "NI123456C",
  "consentedAt": "2026-07-23T10:30:00Z"
}
```

**Error Responses**:
- `400 Bad Request`: Missing or invalid departmentId/departmentPersonId
- `401 Unauthorized`: Invalid or expired token
- `409 Conflict`: Consent already exists for this department/person pair
- `500 Internal Server Error`: Consent creation failed

**iOS Implementation Notes**:
- This is typically called during onboarding when linking government accounts
- Each department has its own identifier scheme for `departmentPersonId` (NI number, reference number, etc.)
- Consent is required before a department can successfully send messages to the citizen
- Consider a consent management screen showing all linked departments

---

### 8. Create Mailbox (One-time Setup)

**Endpoint**: `POST /users`

**Description**: Creates a mailbox for the authenticated citizen. Idempotent - safe to call multiple times with the same token.

**Request Body**: None (identity derived from token)

**Request Example**:
```http
POST /users HTTP/1.1
Authorization: Bearer {token}
```

**Response** (201 Created or 200 OK if already exists):
```json
{
  "mailboxId": "a7f3c2e1-5d9b-4a1e-8f7d-2c9e4b6a1d3f",
  "authSystemSub": "sub_a1b2c3d4e5f6",
  "createdAt": "2026-07-23T10:00:00Z"
}
```

**Error Responses**:
- `401 Unauthorized`: Invalid or expired token
- `500 Internal Server Error`: Mailbox creation failed

**iOS Implementation Notes**:
- Call this once during first-time user onboarding
- Store the `mailboxId` locally if needed for debugging
- This is required before any other operations will work
- Safe to call on every app launch - it's idempotent

---

## Data Models

### MessageListItem

```swift
struct MessageListItem: Codable {
    let messageId: String           // UUID
    let mailboxId: String           // UUID
    let receivedAt: String          // ISO 8601 timestamp
    let subject: String             // Human-readable subject
    let sender: String              // Department display name
}
```

### MessageDetail

```swift
struct MessageDetail: Codable {
    let messageId: String
    let mailboxId: String
    let receivedAt: String
    let subject: String
    let sender: String
    let body: String                // Plain text for PoC
    // Future fields (not yet implemented):
    // let serviceName: String?
    // let messageType: String?
    // let primaryAction: Action?
    // let deadline: String?
    // let secondaryAction: Action?
}
```

### Pagination

```swift
struct ListMessagesResponse: Codable {
    let messages: [MessageListItem]
    let nextToken: String?          // Present if more results available
}
```

---

## Error Handling

### Standard HTTP Status Codes

| Status | Meaning | Action |
|--------|---------|--------|
| 200 OK | Success | Process response |
| 201 Created | Resource created | Process response |
| 204 No Content | Success, no body | Update UI state |
| 400 Bad Request | Invalid input | Show error to user |
| 401 Unauthorized | Auth failed | Refresh token or re-authenticate |
| 404 Not Found | Resource not found | Show appropriate message |
| 409 Conflict | Resource already exists | May be safe to proceed |
| 500 Internal Server Error | Backend error | Retry with exponential backoff |
| 502 Bad Gateway | Upstream service error | Retry or show error |

### Error Response Format

```json
{
  "error": "Human-readable error message"
}
```

### Retry Strategy

**Recommended approach**:
1. **5xx errors**: Retry with exponential backoff (max 3 attempts)
2. **401 errors**: Refresh token once, then fail
3. **4xx errors (except 401)**: Don't retry, show error to user
4. **Network errors**: Retry with exponential backoff

**Example exponential backoff**:
```swift
let delays = [1.0, 2.0, 4.0] // seconds
for (attempt, delay) in delays.enumerated() {
    do {
        return try await makeRequest()
    } catch {
        if attempt < delays.count - 1 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
    }
}
```

---

## Authentication Details

### Token Structure

The test issuer generates JWTs with this structure:

```json
{
  "alg": "ES256",
  "typ": "JWT"
}
{
  "sub": "test-user-123",
  "auth_system_sub": "sub_a1b2c3d4e5f6",
  "iss": "https://test-issuer.mailbox-dev.once.service.gov.uk",
  "aud": "mailbox-client-access",
  "exp": 1721736000,
  "iat": 1721732400
}
```

**Key Claims**:
- `auth_system_sub`: Maps to the citizen's `mailboxId` (replaces OneLogin's real sub claim for PoC)
- `iss`: Must match the expected test issuer URL
- `aud`: Must be "mailbox-client-access"
- `exp`: Token expiration time (Unix timestamp)

### Token Lifecycle

1. **Obtain token**: Call test issuer endpoint (provided by backend team)
2. **Store securely**: Use iOS Keychain for token storage
3. **Refresh**: Test tokens have fixed expiry - generate new ones as needed
4. **Validation**: Backend validates signature, issuer, audience, and expiry

### JWKS Endpoint

The test issuer publishes its public keys at:
```
https://test-issuer.mailbox-dev.once.service.gov.uk/.well-known/jwks.json
```

This is used by the backend Lambda authorizer, not by your iOS app directly.

---

## Testing

### Test Data Setup

**Prerequisites**:
1. Get a test token from the backend team
2. Create mailbox: `POST /users`
3. Grant consent: `POST /consents` with test department credentials

**Test Departments**:
- `departmentId`: `"dwp"`, `"dvla"`, `"hmrc"` (confirm with backend team)
- Each department has specific `departmentPersonId` formats

### Sample Test Scenarios

#### Happy Path - List and Read
```swift
// 1. Create mailbox (if needed)
POST /users

// 2. List messages
GET /messages?limit=10

// 3. View message details
GET /messages/{messageId}

// 4. Mark as read
PATCH /messages/{messageId}
{ "readAt": "2026-07-23T10:15:00Z" }
```

#### Error Scenarios to Test
```swift
// 1. Invalid token
Authorization: Bearer invalid_token
// Expected: 401 Unauthorized

// 2. Missing messageId
GET /messages/
// Expected: 400 Bad Request

// 3. Non-existent message
GET /messages/00000000-0000-0000-0000-000000000000
// Expected: 404 Not Found

// 4. Expired token
Authorization: Bearer {expired_token}
// Expected: 401 Unauthorized
```

### Backend E2E Test Status

The backend has comprehensive E2E tests but currently requires AWS SSO authentication to run. Contact the backend team for:
- Deployed API endpoint URLs
- Test issuer token generation scripts
- Access to test environments

---

## Known Limitations (PoC)

1. **Authentication**: Test issuer only, not real OneLogin integration
2. **Message Format**: Plain text only - no HTML, styling, or attachments
3. **Deduplication**: Not enforced - duplicate `referenceId` values may create duplicate messages
4. **Read Status Tracking**: No device-level tracking - `READ` events not yet implemented
5. **Audit Trail**: Lightweight version only - doesn't include full tamper-proof features
6. **Department Auth**: API key stub for ingestion (not relevant to client access)
7. **Fail-Closed Identity**: Citizens must explicitly create mailbox and grant consent before receiving mail

---

## Future Enhancements (Post-PoC)

These features are documented in the backend but not yet built:

- **Rich message format**: HTML body with styling, attachments
- **Action buttons**: `primaryAction` and `secondaryAction` with onward journeys
- **Message types**: Categorization (Update, Action, Confirmation, Legal Notice)
- **Deadlines**: `deadline` field for time-sensitive actions
- **Real OneLogin integration**: Replace test issuer with production identity provider
- **Device tracking**: `READ` events tied to specific devices
- **Push notifications**: Real-time delivery when new messages arrive
- **Management portal**: Web UI for citizens to manage settings

---

## Support and Contact

### Backend Team Contacts
- Repository: `gds/once/mailbox`
- Slack: (Add your team channel)
- Current Sprint: M3 - End-to-end PoC check (target 2026-08-15)

### Getting Help

**Before reaching out**:
1. Check this document for API specifications
2. Review backend `docs/` directory for detailed architectural decisions
3. Check backend `CLAUDE.md` for development guidelines

**Questions to Ask Backend Team**:
- "What is the current deployed API URL?"
- "How do I generate test tokens?"
- "Which test departments and departmentPersonIds should I use?"
- "Is CORS configured for my development domain?"
- "What are the current rate limits?"

### Documentation Sources

- Backend API: `gds/once/mailbox/docs/prd/client-access-api.md`
- Domain model: `gds/once/mailbox/docs/domain.md`
- Message format: `gds/once/mailbox/docs/message-format.md`
- Decisions: `gds/once/mailbox/docs/decisions/`
- PoC roadmap: `gds/once/mailbox/docs/poc-roadmap.md`

---

## Quick Reference

### All Endpoints Summary

| Method | Endpoint | Purpose | Auth |
|--------|----------|---------|------|
| GET | `/messages` | List messages | Bearer |
| GET | `/messages/{id}` | Get message details | Bearer |
| PATCH | `/messages/{id}` | Update message (read/archive) | Bearer |
| DELETE | `/messages/{id}` | Delete message | Bearer |
| POST | `/consents` | Grant department consent | Bearer |
| POST | `/users` | Create mailbox | Bearer |

### Example Swift Networking Layer

```swift
import Foundation

enum MailboxAPIError: Error {
    case invalidURL
    case invalidResponse
    case authenticationFailed
    case notFound
    case serverError(Int)
    case decodingError(Error)
}

class MailboxAPIClient {
    private let baseURL: String
    private let session: URLSession
    
    init(baseURL: String, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    func listMessages(token: String, limit: Int? = nil, nextToken: String? = nil) async throws -> ListMessagesResponse {
        var components = URLComponents(string: "\(baseURL)/messages")!
        var queryItems: [URLQueryItem] = []
        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: "\(limit)"))
        }
        if let nextToken = nextToken {
            queryItems.append(URLQueryItem(name: "nextToken", value: nextToken))
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        guard let url = components.url else {
            throw MailboxAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        
        return try JSONDecoder().decode(ListMessagesResponse.self, from: data)
    }
    
    func getMessage(token: String, messageId: String) async throws -> MessageDetail {
        guard let url = URL(string: "\(baseURL)/messages/\(messageId)") else {
            throw MailboxAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        
        return try JSONDecoder().decode(MessageDetail.self, from: data)
    }
    
    func markAsRead(token: String, messageId: String, readAt: Date) async throws {
        try await updateMessage(token: token, messageId: messageId, body: [
            "readAt": ISO8601DateFormatter().string(from: readAt)
        ])
    }
    
    func markAsUnread(token: String, messageId: String) async throws {
        try await updateMessage(token: token, messageId: messageId, body: [
            "readAt": NSNull()
        ])
    }
    
    func archiveMessage(token: String, messageId: String, archived: Bool) async throws {
        try await updateMessage(token: token, messageId: messageId, body: [
            "archived": archived
        ])
    }
    
    private func updateMessage(token: String, messageId: String, body: [String: Any]) async throws {
        guard let url = URL(string: "\(baseURL)/messages/\(messageId)") else {
            throw MailboxAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await session.data(for: request)
        try validateResponse(response)
    }
    
    func deleteMessage(token: String, messageId: String) async throws {
        guard let url = URL(string: "\(baseURL)/messages/\(messageId)") else {
            throw MailboxAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await session.data(for: request)
        try validateResponse(response)
    }
    
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw MailboxAPIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw MailboxAPIError.authenticationFailed
        case 404:
            throw MailboxAPIError.notFound
        default:
            throw MailboxAPIError.serverError(httpResponse.statusCode)
        }
    }
}
```

---

## Changelog

| Date | Version | Changes |
|------|---------|---------|
| 2026-07-23 | 1.0 | Initial PoC integration guide |

---

**End of Document**
