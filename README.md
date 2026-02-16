# Virtual Try-On App Based on flutter 

A Flutter application for Virtual Try-On using Hugging Face Inference API.

## Features
- **Platform Support**: Web, Android, iOS.
- **Try-On**: Upload a person image and a cloth image.
- **Categories**: Upper Body, Lower Body, Dresses (Overall), Shoes.
- **API**: Integration with Hugging Face Inference API (e.g., yisol/IDM-VTON).

## Setup
1. Open `lib/utils/constants.dart`.
2. Replace `YOUR_HUGGING_FACE_API_TOKEN` with your actual Hugging Face API Token (Read permission).
3. If using a custom Space or Endpoint, update `modelApiUrl`.

## Running the App

### Web
```bash
flutter run -d chrome
```

### Android
```bash
flutter run -d android
```

### iOS
```bash
flutter run -d ios

```


## Note on API
The app uses a generic request structure for VTON models. If using a specific HF Space (via Gradio), the payload structure in `lib/api/api_service.dart` might need adjustment (e.g., matching the `fn_index` or specific JSON keys of the model).


## UpcomingUI

![App Screenshot](https://cdn.dribbble.com/userupload/43858842/file/original-05121a7b32d4e4f52ed2248bd82f1bf0.png?resize=1600x1200&vertical=center)
