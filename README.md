# CChat iOS

A secure, private messaging app for the overseas Chinese community. CChat provides end-to-end encrypted messaging with minimal data retention—a privacy-focused alternative for private communication.

## Features

- **Private messaging**: 1:1 text chats with encrypted local storage
- **Phone registration**: Sign up with phone number and display name
- **Contact discovery**: Add contacts by phone number
- **Bilingual support**: English and Simplified Chinese (中文)
- **Encrypted storage**: All data encrypted at rest using AES-256-GCM
- **No tracking**: No analytics, no ads, no telemetry

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.0+

## Building

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd CChat-iOS
   ```

2. Open the project in Xcode:
   ```bash
   open CChat.xcodeproj
   ```

3. Select your development team in the Signing & Capabilities tab for the CChat target.

4. Build and run (⌘R) on a simulator or device.

## Project Structure

```
CChat-iOS/
├── CChat/
│   ├── App/           # AppDelegate, SceneDelegate
│   ├── Models/        # User, Contact, Conversation, Message
│   ├── Service/       # Cryptography, Storage, Account, Message services
│   ├── Registration/  # Registration flow
│   ├── Conversations/ # Conversation list, chat thread, contact picker
│   ├── Settings/      # Profile, logout
│   └── Resources/     # Assets, localization (en, zh-Hans)
├── docs/
│   └── MVP_DESIGN.md  # MVP design document
└── README.md
```

## Architecture

The app follows a layered architecture inspired by modern secure messaging apps:

- **Models**: Core data structures (User, Contact, Conversation, Message)
- **Service**: Business logic and persistence
  - `CryptographyService`: AES-256-GCM encryption, Keychain key storage
  - `StorageService`: Encrypted JSON persistence
  - `AccountService`: Registration, profile, logout
  - `MessageService`: Send/receive messages, conversations, contacts
- **UI**: Registration, conversation list, chat thread, settings

## MVP Scope

- [x] Phone registration (mock OTP for demo)
- [x] Profile setup (display name)
- [x] 1:1 text messaging
- [x] Contact discovery and add
- [x] Conversation list and chat thread
- [x] Encrypted local storage
- [x] Bilingual UI (en, zh-Hans)

## Localization

The app supports:
- **English** (default)
- **简体中文** (Simplified Chinese)

Switch your device/simulator language to test localization.

## Security

- **Local encryption**: All stored data is encrypted with AES-256-GCM
- **Key storage**: Encryption keys stored in iOS Keychain
- **MVP note**: This MVP uses local-only storage. A production version would add server sync with end-to-end encryption.

## License

Proprietary. All rights reserved.
