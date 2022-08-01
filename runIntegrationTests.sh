#!/usr/bin/env bash
# fail if any commands fails
set -e
# debug log
set -x

# Load json from file
TEST_DATA_JSON=$(<../integration_test_data.json)

# Remove newlines
TEST_DATA_JSON=${TEST_DATA_JSON//$'\n'/}

# Replace multiple spaces with single space
TEST_DATA_JSON=$TEST_DATA_JSON | tr -s ' '

flutter test integration_test/recover_account_test.dart --flavor dev --dart-define TEST_DATA_JSON="$TEST_DATA_JSON" --dart-define CIPHER_SERVICE=memory
