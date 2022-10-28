#!/usr/bin/env bash
# fail if any commands fails
set -e
# debug log
# set -x

json=$(<../integration_test_data.json)

# -Pdart-defines
#    1. Create a key=value pair
#    2. Base 64 encode
#    3. If multiple, comma separate them
data=TEST_DATA_JSON="$json"
defines=$(echo -n $data | base64)

pushd android
flutter build apk --flavor dev  --dart-define CIPHER_SERVICE=memory --dart-define ACCOUNT_STORAGE=memory --dart-define ENABLE_FIREBASE=false
./gradlew app:assembleAndroidTest
./gradlew app:assembleDevDebug -Ptarget=integration_test/main_test.dart -Pdart-defines=$defines
popd
