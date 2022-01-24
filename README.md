# Provenance Wallet

A mobile wallet.

## Getting Started
### Requisites
1. A Mac machine
2. A physical iOS device

### Software
1. Install the [latest Xcode](https://developer.apple.com/download/all/)
1. Install the [latest Flutter SDK](https://docs.flutter.dev/get-started/install)
1. Install the [latest Android Studio](https://developer.android.com/studio)
1. Install [Homebrew](https://brew.sh/)
    1. In Terminal run `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` 
3. Install Cocoapods
    1.  In Terminal run `brew install cocoapods`
4. *Recommended:* Install the [latest Visual Studio Code](https://code.visualstudio.com/download)

### Zsh Configuration
1. Open or create `~/.zshrc`
1. Add `export PATH="$PATH:<Flutter SDK path>/bin"` (enables `flutter` commands)
1. Add `export JAVA_HOME="/Applications/Android Studio.app/Contents/jre/Contents/Home"` (enables `./gradlew` commands)
2. Run `source ~/.zshrc` or restart Terminal

### Xcode Configuration

> Before continuing, be sure your Apple ID is added to the Figure 
> Technologies Inc. (FDT7XCU6W7) Apple development team.  The following
> steps assume you have selected the Figure Technologies Inc. team when
> using developer.apple.com

Create a development certificate
1. Go to the [Apple certificates list](https://developer.apple.com/account/resources/certificates/list)
2. Click the "+" icon
3. Select Apple Development and click Continue

Find your iOS device UUID
1. Connect your device to your Mac
2. In Terminal, run `flutter devices`

Register your iOS device
1. Go to the [Apple devices list](https://developer.apple.com/account/resources/devices/list)
1. Click the "+" icon
1. Add a descriptive Device Name with your name in it, such as "Roy's iPhone 13"
1. Add your device UUID

Add your device to the development provisioning profile
1. Go to the [Apple profiles list](https://developer.apple.com/account/resources/profiles/list)
2. Select Figure Tech Wallet Dev, and click Edit
3. Under Certificates, select the certificate that you created
4. Under Devices, select the device that you added
5. Click Save
6. In the profile list, hover the Figure Tech Wallet Dev profile and click Download
7. Once downloaded, double click to install

Verify your signing configuration
1. Use an existing XCode workspace or create a sample Flutter app using `flutter create myapp`
2. Open the workspace (i.e. `ios/Runner.xcworkspace` created by `flutter create `myapp`)
3. In the Project Navigator window, select the top level Runner directory
4. Select the Signing & Capabilites tab
5. Under Signing(Debug and Profile), you should not see any issues
6. If Xcode was open during any previous steps, it may need to be closed and re-opened

### Android Studio Configuration
Download SDKs
1. Open Android Studio
2. Open Preferences (Android Studio -> Preferences)
3. Open SDK Manager (Appearance & Behavior -> System Settings -> Android SDK)
    1. If the `Android SDK Location` is empty, click `Edit` to 
       install the Android SDK.
4. On the SDK Platforms tab, select 
    1. Android 12.0
    2. Android 10.0
    3. Android 9.0
5. At the lower right-hand corner of the window, check Show Package Details
6. For each Android version with which you would like to create an emulator, select the Google Play image that matches your system architecture
7. On the SDK Tools tab, select
    1. Android SDK Build-Tools
    2. Android SDK Command-line Tools
    3. Android Emulator
    4. Android SDK Platform-Tools 
8. Click OK to download and install

### Visual Studio Code Configuration
Install the Flutter extension
1. Open the Extensions window (Code -> Preferences -> Extensions)
2. Search for "Flutter" and click Install

Enable Format On Save
1. Open Settings (Code -> Preferences -> Settings)
2. On the User tab, go to Text Editor -> Formatting
3. Check the box for Format On Save

### Verify Your Configuration
1. In Terminal, run `flutter doctor`
2. Fix any issues

### IntelliJ Ultimate Configuration
Open IntelliJ
1. Navigate to Preferences | Plugins | Marketplace
2. Search for the Flutter plugin and install
3. Restart the IDE

Running `flutter doctor` after installing the IntelliJ Flutter plugin could
result in an error like:
```text
[☠] IntelliJ IDEA Ultimate Edition (the doctor check crashed)
    ✗ Due to an error, the doctor check did not complete. If the error message below is not helpful, please let us know about this issue at https://github.com/flutter/flutter/issues.
    ✗ FormatException: Unexpected extension byte (at offset 5)
```

To resolve this issue, patch the `archive` package version used by your local
Flutter installation as the problem seems to be partially fixed 
with `archive:3.1.8`:
1. Edit `FLUTTER_HOME/packages/flutter_tools/pubspec.yaml` changing `archive` 
   version to `archive:3.1.8`
2. Execute `flutter update-packages --force-upgrade` as instructed in that pubspec.yaml

See https://github.com/flutter/flutter/issues/94060#issuecomment-1008040192

### Run on an iOS Device in Xcode
1. In Terminal open the root project directory
2. Run `flutter pub get`
3. Open the `ios` dir
4. Run `pod repo update`
5. Run `pod install`
6. If the project has not previously been run, you might need to run `flutter build ios --config-only` to create `ios/Flutter/Generated.xcconfig`
7. Connect your device
8. Open the workspace `ios/Runner.xcworkspace` in Xcode
9. Click the Run button

### Run on an iOS Device in Visual Studio Code
1. In Terminal open the `ios` dir
2. Run `pod repo update`
3. Run `pod install`
4. Connect your device
5. Select your device at the bottom right-hand corner of the window
6. Open a Dart file such as (main.dart)
7. Run the app (Run -> Start Debugging)

> NOTE when running on an iOS device you may get the error: 
>   "iproxy" cannot be opened because the developer cannot be verified
> 
> To resolve this issue un-quarantive the `iproxy` binary like via Terminal:
```
sudo xattr -d com.apple.quarantine $FLUTTER_HOME/bin/cache/artifacts/usbmuxd/iproxy
```

### Run on iOS or Android in Android Studio
1. Open the root project dir in Android Studio
2. Click run

### Run the Android project in Android Studio
This can help provide more insight into the Gradle build
1. Open the Android project in Android Studio (the `android` dir that contains `settings.gradle`)
2. Click run
