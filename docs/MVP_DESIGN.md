# CChat iOS — MVP Design Document

## Product Overview

**CChat** is a secure, private messaging app designed for overseas Chinese community users. It serves as a privacy-focused alternative for private communication, emphasizing end-to-end encryption and minimal data retention.

### Target Users
- Overseas Chinese community members
- Users seeking private, encrypted communication
- People who value data privacy and control over their conversations

### Value Proposition
- **Privacy-first**: End-to-end encrypted messaging; we cannot read your conversations
- **Minimal data**: No analytics, no tracking, no ads
- **Bilingual support**: English and Simplified Chinese (中文)

---

## Architecture Overview

Inspired by modern secure messaging architectures, CChat follows a layered modular structure:

```
┌─────────────────────────────────────────────────────────────┐
│                      CChat (App Target)                      │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────────┐ │
│  │ Registration │  │ Conversation │  │ Settings / Profile  │ │
│  │     Flow     │  │  List & Chat │  │                     │ │
│  └─────────────┘  └──────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   CChatServiceKit (Framework)                │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────────────────┐ │
│  │ Account  │ │ Messages │ │ Contacts │ │ Cryptography    │ │
│  └──────────┘ └──────────┘ └──────────┘ └─────────────────┘ │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────────────────┐ │
│  │ Storage  │ │ Network  │ │ Threads / Conversations      │ │
│  └──────────┘ └──────────┘ └──────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Platform / Dependencies                    │
│  SQLCipher | CryptoKit | URLSession | libPhoneNumber        │
└─────────────────────────────────────────────────────────────┘
```

---

## MVP Scope

### In Scope (MVP v1)
| Feature | Description |
|---------|-------------|
| **Phone registration** | Sign up / sign in with phone number + OTP (or mock for demo) |
| **Profile setup** | Display name, optional avatar |
| **1:1 messaging** | Send and receive text messages |
| **Contact discovery** | Add contacts by phone number |
| **Conversation list** | List of chats sorted by recent activity |
| **Chat thread** | Message thread UI with bubbles, timestamps |
| **Local encryption** | Encrypted local database (SQLCipher or CryptoKit-based) |
| **E2E encryption** | Basic E2E for messages (AES-256-GCM with key exchange) |
| **Bilingual UI** | English + 简体中文 |

### Out of Scope (Post-MVP)
- Voice/video calls
- Group chats
- Media attachments (images, files)
- Push notifications (requires backend)
- Username-based discovery
- Disappearing messages
- Backups

---

## Module Design

### 1. CChat (App Target)
- **AppDelegate / SceneDelegate**: App lifecycle, dependency injection
- **Registration**: Phone input, OTP verification, profile creation
- **ConversationListViewController**: List of conversations
- **ConversationViewController**: Individual chat thread
- **SettingsViewController**: Profile, logout
- **Resources**: Assets, Localization (en, zh-Hans)

### 2. CChatServiceKit
- **Account**: Current user, registration state
- **Storage**: Encrypted database (conversations, messages, contacts)
- **Contacts**: Contact model, add by phone
- **Messages**: Send/receive, persistence
- **Threads**: Conversation threading
- **Cryptography**: Key generation, E2E encrypt/decrypt
- **Network**: API client (mock or real backend)
- **Util**: Logging, extensions

### 3. Data Models
```
User
  - id: String
  - phoneNumber: String
  - displayName: String?
  - avatarURL: String? (MVP: nil)

Contact
  - id: String
  - phoneNumber: String
  - displayName: String?
  - userId: String? (when registered)

Conversation (Thread)
  - id: String
  - participantIds: [String]
  - lastMessageAt: Date
  - lastMessagePreview: String?

Message
  - id: String
  - conversationId: String
  - senderId: String
  - body: String
  - createdAt: Date
  - isOutgoing: Bool
  - status: sent | delivered | read (MVP: sent only)
```

---

## Security Design

### Local Storage
- **Encryption**: SQLCipher or CryptoKit-wrapped SQLite
- **Key derivation**: Device-specific key from Keychain
- **Sensitive data**: Passphrase, keys stored in Keychain only

### End-to-End Encryption (MVP)
- **Algorithm**: AES-256-GCM
- **Key exchange**: Simplified Diffie-Hellman or pre-shared keys (MVP)
- **Forward secrecy**: Not in MVP; planned for v2

### Backend Assumptions
- MVP can use a mock in-memory backend
- Real backend: REST API, minimal metadata, encrypted payloads
- Server stores only: user id, phone hash, encrypted message blobs (no plaintext)

---

## UI/UX Flow

```
[Splash] → [Registration: Phone] → [OTP] → [Profile: Name] → [Conversation List]
                                                                      │
                                                    [New Chat] ←───────┘
                                                    [Select Contact]
                                                    [Conversation View]
                                                    [Settings]
```

### Screens
1. **Splash**: Logo, app name "CChat"
2. **Phone Entry**: Country code + phone number, "Continue"
3. **OTP Entry**: 6-digit code, "Verify" (MVP: accept any code for demo)
4. **Profile Setup**: Display name, "Start Messaging"
5. **Conversation List**: Tab bar (Chats, Contacts, Settings)
6. **New Chat**: Contact picker
7. **Conversation View**: Message bubbles, input bar
8. **Settings**: Profile, language, privacy, logout

---

## Technical Stack

| Layer | Technology |
|-------|------------|
| Language | Swift 5.x |
| Min iOS | 15.0 |
| UI | UIKit + Auto Layout |
| Storage | SQLite + SQLCipher (or GRDB) |
| Crypto | CryptoKit |
| Network | URLSession |
| Phone parsing | libPhoneNumber-iOS |
| Package manager | Swift Package Manager (preferred) or CocoaPods |

---

## Localization

| Key | English | 简体中文 |
|-----|---------|----------|
| app_name | CChat | CChat |
| welcome_title | Private Messaging | 私密通讯 |
| phone_prompt | Enter your phone number | 输入您的手机号 |
| verify_code | Enter verification code | 输入验证码 |
| display_name | Display name | 显示名称 |
| new_chat | New Chat | 新聊天 |
| conversations | Chats | 聊天 |
| settings | Settings | 设置 |
| send | Send | 发送 |
| ... | ... | ... |

---

## Project Structure

```
CChat-iOS/
├── CChat/
│   ├── App/
│   │   ├── AppDelegate.swift
│   │   └── SceneDelegate.swift
│   ├── Registration/
│   ├── Conversations/
│   ├── Settings/
│   ├── Resources/
│   │   ├── Assets.xcassets
│   │   ├── Localizable.strings (en, zh-Hans)
│   │   └── Info.plist
│   └── Info.plist
├── CChatServiceKit/
│   ├── Account/
│   ├── Storage/
│   ├── Contacts/
│   ├── Messages/
│   ├── Threads/
│   ├── Cryptography/
│   ├── Network/
│   └── Util/
├── docs/
│   └── MVP_DESIGN.md
├── CChat.xcodeproj
└── README.md
```

---

## Implementation Phases

### Phase 1: Foundation
- [ ] Xcode project setup
- [ ] CChatServiceKit framework / module
- [ ] Data models (User, Contact, Conversation, Message)
- [ ] Storage layer (SQLite + encryption)

### Phase 2: Core Logic
- [ ] Account management
- [ ] Mock registration / auth
- [ ] Message send/receive pipeline
- [ ] Basic E2E encryption

### Phase 3: UI
- [ ] Registration flow
- [ ] Conversation list
- [ ] Chat thread
- [ ] Settings
- [ ] Localization

### Phase 4: Integration
- [ ] End-to-end flow
- [ ] Error handling
- [ ] README and build instructions

---

## Success Criteria for MVP

1. User can "register" with phone and display name
2. User can add a contact by phone number
3. User can send and receive text messages in 1:1 chat
4. Messages are encrypted at rest
5. UI supports English and Simplified Chinese
6. App builds and runs on iOS 15+
