# AuraBot - Conversational Image Recognition App (Anti-Gravity UI)

AuraBot is a futuristic cross-platform conversational image recognition chatbot app built in Flutter. It is designed using Clean Architecture and the MVVM state pattern, backed by Firebase and the OpenRouter API.

## Features

- **Anti-Gravity Design System**: Levitating glassmorphic cards, custom floating particle canvas background, neon gradient boundaries, and 60 FPS transitions.
- **Visual Intelligence**: Captures photos or selects local gallery files, performs OCR and identifies objects, colors, text, and details utilizing the OpenRouter `google/gemini-2.5-flash:free` model.
- **Persistent Context**: Remembers conversation states using Firestore.
- **Firebase Core integration**: Authentication, metadata cataloging, and media storage.

---

## Folder Architecture

The project files are organized cleanly to decouple UI components, business rules, data pipelines, and external integrations:

```
lib/
├── core/                  # Core configurations (Theme settings, OpenRouter REST client)
├── domain/                # Enterprise Business Rules (Entities, Repository interfaces, Use cases)
├── data/                  # Data mapping & database adapters (Models, Data Sources, Repositories implementations)
└── presentation/          # Application Presentation Layer (Views, ViewModels, Custom Canvas/Glow widgets)
```

---

## Getting Started

### 1. Requirements
Ensure you have the Flutter SDK installed on your system.
- [Flutter Installation Guide](https://docs.flutter.dev/get-started/install)

### 2. Configure Firebase

To synchronize accounts, conversations, and save images, attach your Firebase project configs:
- **Android**: Register `com.aurabot.app` in your Firebase console, download `google-services.json`, and place it in `android/app/`.
- **iOS**: Register the bundle ID, download `GoogleService-Info.plist`, and drag it into the Xcode project group folder.
- **Web**: Initialize Firebase configs in `web/index.html`.

Ensure that you enable **Firebase Authentication** (Email/Password), **Cloud Firestore**, and **Firebase Storage** in your console.

### 3. OpenRouter API Key

Get a free key from OpenRouter to execute chatbot completions.
1. Sign up on [OpenRouter](https://openrouter.ai/).
2. Create a new API Key in keys dashboard.
3. Open `lib/core/network/openrouter_client.dart` and paste your key in the `_openRouterApiKey` placeholder string (or configure your CI/CD to inject it).

---

## Build and Run

To launch the app on your connected device/emulator or web browser, execute the following commands in the `/aura_bot_flutter` folder:

```bash
# Fetch pub dependencies
flutter pub get

# Launch the app in debug mode
flutter run
```
