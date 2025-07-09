# 🖼️ Imagen

**Imagen** is an AI-powered image generation Flutter app that leverages the FusionBrain API and Firebase for a seamless, modern experience. Users can generate images from text prompts, manage image history, and use in-app purchases and cloud-based features, all within a visually rich and responsive interface.

---

## 🌟 Features

* 🎨 **AI-Powered Image Generation** – Text-to-image generation using FusionBrain API
* 🔒 **Authentication** – Firebase Auth with Google and Apple Sign-In
* ☁️ **Cloud Integration** – Firestore for image data and history
* 💳 **In-App Purchases** – Integrated with Stripe, Apple Pay, and Google Pay
* 📁 **File Management** – File picker, gallery saving, image sharing
* 🧭 **Intuitive UI** – Bloc, Provider, and GetIt-based architecture
* 🌍 **Localization** – Multilingual support via Flutter localization
* 🔄 **Splash & Theme** – Custom splash screens, dark/light mode, and theming
* 🔔 **App Update Notices** – Smart update prompts with `upgrader`

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK (>= 3.0.3)
* Dart
* Firebase CLI (for setup)
* FusionBrain API key

### Installation

```bash
git clone https://github.com/Modexanderson/imagen.git
cd imagen
flutter pub get
```

### Firebase Setup

* Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to platform folders
* Run `flutterfire configure` or manually update `firebase_options.dart`

### Native Splash (Optional)

```bash
dart run flutter_native_splash:create
```

---

## 📁 Project Structure

```
lib/
├── api/              # API wrappers for FusionBrain
├── bloc/             # Bloc and Cubit files
├── controllers/      # App logic
├── models/           # Data models
├── screens/          # UI Screens
├── services/         # Service layer
├── widgets/          # Reusable UI components
├── utils/            # Helpers and config
├── main.dart         # Entry point
├── app.dart          # Root widget
```

---

## 📷 Screenshots

Place screenshots in `assets/images/` and reference them in the README like:

```markdown
![Splash](assets/images/imagen_black.png)
![UI](assets/images/imagen_graph.png)
```

Ensure `pubspec.yaml` includes:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/
```

📌 **Note**: For private repos, images won’t render unless externally hosted.

---

## 🛠️ Tech Stack

* Flutter 3+
* Firebase (Auth, Firestore)
* FusionBrain API
* Bloc + Provider + GetIt
* Stripe, Apple Pay, Google Pay
* Hive for local storage
* Lottie animations

---

## 📌 TODO

*

---

## ✉️ Contact

Made with ❤️ by [Modexanderson](https://github.com/Modexanderson)

For issues or ideas, feel free to reach out or open a pull request!
