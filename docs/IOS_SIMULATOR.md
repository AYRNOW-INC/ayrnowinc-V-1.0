# AYRNOW — iOS Simulator Guide

## Prerequisites
- Xcode installed (Mac App Store)
- Xcode CLI tools: `xcode-select --install`
- Flutter SDK installed
- CocoaPods installed

## List Available Simulators
```bash
xcrun simctl list devices available | grep -i iphone
```

## Boot a Simulator
```bash
# Boot by device ID (find from list above)
xcrun simctl boot <DEVICE_ID>
open -a Simulator
```

## Build and Run AYRNOW
```bash
cd frontend

# Get dependencies
flutter pub get

# List connected devices
flutter devices

# Run on simulator
flutter run -d <DEVICE_ID>

# Or build and install manually
flutter build ios --simulator --no-tree-shake-icons
xcrun simctl install <DEVICE_ID> build/ios/iphonesimulator/Runner.app
xcrun simctl launch <DEVICE_ID> com.ayrnow.ayrnow
```

## Current Test Device
- **iPhone 16e** — Device ID: `2620A3BC-3BE4-458B-9914-5DCCF40DD747`
- iOS 26

## Bundle ID
- `com.ayrnow.ayrnow`

## Troubleshooting

**"No supported devices connected"**
```bash
open -a Simulator  # Make sure simulator app is running
flutter devices     # Should list the simulator
```

**CocoaPods issues**
```bash
cd frontend/ios
pod install --repo-update
```

**Build failures after dependency changes**
```bash
cd frontend
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

## Notes
- The backend must be running on `localhost:8080` for API calls to work from the simulator
- iOS simulator can access `localhost` directly (no special network config needed)
- Release signing is not yet configured — development/simulator only for now
