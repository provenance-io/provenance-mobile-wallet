#!/usr/bin/env bash
# fail if any commands fails
set -e
# debug log
# set -x

json=$(<../integration_test_data.json)

data=TEST_DATA_JSON="$json"
defines=$(echo -n $data | base64)

pushd android
flutter build apk --flavor dev
./gradlew app:assembleAndroidTest
./gradlew app:assembleDevDebug -Ptarget=integration_test/recover_account_test.dart -Pdart-defines=$defines
popd
