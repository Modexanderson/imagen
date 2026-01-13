# Imagen

> AI-powered image generation at your fingertips

A Flutter app that turns your text prompts into stunning images using the FusionBrain API. Create, manage, and share AI-generated artwork with a modern, intuitive interface backed by Firebase and secure payment integration.

---

## Screenshots

### Mobile

<p align="center">
  <img src="https://raw.githubusercontent.com/Modexanderson/imagen/master/assets/images/screenshots/1.png" width="250" />
  <img src="https://raw.githubusercontent.com/Modexanderson/imagen/master/assets/images/screenshots/2.png" width="250" />
  <img src="https://raw.githubusercontent.com/Modexanderson/imagen/master/assets/images/screenshots/3.png" width="250" />
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/Modexanderson/imagen/master/assets/images/screenshots/4.png" width="250" />
  <img src="https://raw.githubusercontent.com/Modexanderson/imagen/master/assets/images/screenshots/5.png" width="250" />
</p>

### iPad

<p align="center">
  <img src="https://raw.githubusercontent.com/Modexanderson/imagen/master/assets/images/screenshots/iPad/1.png" width="400" />
  <img src="https://raw.githubusercontent.com/Modexanderson/imagen/master/assets/images/screenshots/iPad/2.png" width="400" />
</p>

---

## Features

- **AI Image Generation** - Turn text prompts into images using FusionBrain API
- **User Authentication** - Firebase Auth with Google and Apple Sign-In
- **Image History** - Cloud storage of generated images via Firestore
- **In-App Purchases** - Credits system with Stripe, Apple Pay, and Google Pay
- **Gallery Integration** - Save images to device gallery and share with others
- **File Management** - Advanced file picker and image handling
- **Modern Architecture** - Clean code with Bloc, Provider, and GetIt
- **Multi-language Support** - Built-in localization for multiple languages
- **Theme Support** - Light and dark mode with smooth transitions
- **Smart Updates** - Automatic update prompts for new versions
- **Offline Storage** - Local caching with Hive database
- **Smooth Animations** - Lottie animations for enhanced UX

---

## Tech Stack

**Frontend**
- Flutter 3+
- Dart 3+

**State Management**
- Flutter Bloc
- Provider
- GetIt (Dependency Injection)

**Backend & Services**
- Firebase Authentication
- Cloud Firestore
- FusionBrain AI API

**Payment**
- Stripe
- Apple Pay
- Google Pay

**Storage**
- Hive (Local)
- Firebase Storage (Cloud)

**UI/UX**
- Lottie Animations
- Custom Themes
- Material Design 3

---

## Getting Started

### Prerequisites

- Flutter SDK (3.0.3 or higher)
- Dart SDK (3.0 or higher)
- Firebase CLI
- FusionBrain API key
- Stripe account (for payments)

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/Modexanderson/imagen.git
cd imagen
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Configure Firebase**

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

Alternatively, manually add:
- `google-services.json` to `android/app/`
- `GoogleService-Info.plist` to `ios/Runner/`

4. **Setup FusionBrain API**

Create a file `lib/config/api_keys.dart`:

```dart
class ApiKeys {
  static const String fusionBrainApiKey = 'YOUR_API_KEY_HERE';
  static const String fusionBrainSecretKey = 'YOUR_SECRET_KEY_HERE';
}
```

5. **Setup Stripe**

Add your Stripe keys to the appropriate config files.

6. **Generate splash screen** (optional)

```bash
dart run flutter_native_splash:create
```

7. **Run the app**

```bash
flutter run
```

---

## Project Structure

```
lib/
├── api/                      # API integration
│   ├── fusionbrain_api.dart # FusionBrain API wrapper
│   └── endpoints.dart       # API endpoints
├── bloc/                    # State management
│   ├── auth/               # Authentication bloc
│   ├── image/              # Image generation bloc
│   └── payment/            # Payment bloc
├── controllers/            # Business logic
│   ├── image_controller.dart
│   └── auth_controller.dart
├── models/                 # Data models
│   ├── user_model.dart
│   ├── image_model.dart
│   └── payment_model.dart
├── screens/               # UI screens
│   ├── home/
│   ├── auth/
│   ├── generation/
│   └── history/
├── services/             # Service layer
│   ├── firebase_service.dart
│   ├── storage_service.dart
│   └── payment_service.dart
├── widgets/              # Reusable components
│   ├── image_card.dart
│   ├── prompt_input.dart
│   └── loading_indicator.dart
├── utils/               # Utilities
│   ├── constants.dart
│   ├── helpers.dart
│   └── validators.dart
├── l10n/               # Localization files
├── main.dart          # App entry point
└── app.dart          # Root widget
```

---

## Configuration

### Assets

Ensure your `pubspec.yaml` includes:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/
  fonts:
    - family: CustomFont
      fonts:
        - asset: fonts/CustomFont-Regular.ttf
```

### Environment Variables

Create a `.env` file (not tracked in git):

```env
FUSIONBRAIN_API_KEY=your_api_key
FUSIONBRAIN_SECRET=your_secret
STRIPE_PUBLISHABLE_KEY=your_stripe_key
```

### Firebase Configuration

Update `firebase_options.dart` with your Firebase project settings.

---

## Building for Release

### Android

1. **Create keystore**

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. **Create `android/key.properties`**

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

3. **Build**

```bash
# APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS

1. **Open in Xcode**

```bash
open ios/Runner.xcworkspace
```

2. **Configure signing and capabilities**

3. **Build**

```bash
flutter build ios --release
```

---

## API Integration

### FusionBrain API

The app uses FusionBrain's text-to-image API. Key features:

- Text prompt to image conversion
- Style selection
- Resolution options
- Generation history

Example usage:

```dart
final result = await FusionBrainAPI.generateImage(
  prompt: 'A beautiful sunset over mountains',
  style: GenerationStyle.realistic,
);
```

### Firebase Services

- **Authentication** - Email, Google, Apple Sign-In
- **Firestore** - Image metadata and user data
- **Storage** - Cloud image storage
- **Analytics** - Usage tracking

---

## Payment Integration

The app supports multiple payment methods:

- Credit/Debit Cards (via Stripe)
- Apple Pay
- Google Pay

Credits system:
- Generate images using credits
- Purchase credit packages
- Track usage history

---

## Localization

Supported languages:
- English
- Spanish
- French
- German
- Add more in `lib/l10n/`

To add a new language:

1. Create `app_<locale>.arb` in `lib/l10n/`
2. Update `l10n.yaml`
3. Run `flutter gen-l10n`

---

## Development Roadmap

- [ ] Video generation support
- [ ] Image editing features
- [ ] Social sharing improvements
- [ ] Image collections/albums
- [ ] Advanced AI parameters
- [ ] Community gallery
- [ ] Batch generation
- [ ] API rate limiting UI
- [ ] Generation templates
- [ ] User profiles

---

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -m 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Open a Pull Request

### Code Style

- Follow Flutter style guide
- Use meaningful variable names
- Add comments for complex logic
- Write unit tests for new features

---

## Testing

Run tests:

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widgets/
```

---

## Troubleshooting

### Common Issues

**Firebase not connecting:**
- Verify `google-services.json` and `GoogleService-Info.plist` are in correct locations
- Check Firebase project configuration

**API errors:**
- Verify API keys are correct
- Check API rate limits
- Ensure network connectivity

**Build failures:**
- Run `flutter clean`
- Delete `pubspec.lock` and run `flutter pub get`
- Check Flutter version compatibility

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Privacy & Security

- User data encrypted in transit and at rest
- Secure payment processing via Stripe
- No personal data sold to third parties
- See [Privacy Policy](PRIVACY.md) for details

---

## Acknowledgments

- FusionBrain for their amazing AI API
- Flutter team for the framework
- Firebase for backend infrastructure
- Open source community for packages used

---

## Contact

**Anderson Modex**

- GitHub: [@Modexanderson](https://github.com/Modexanderson)
- Project: [https://github.com/Modexanderson/imagen](https://github.com/Modexanderson/imagen)

For issues, feature requests, or questions, please open an issue on GitHub.

---

Made with Flutter