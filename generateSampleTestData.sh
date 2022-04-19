#!/usr/bin/env bash
# fail if any commands fails
set -e
# debug log
set -x

dart run bin/generate_sample_test_data_json.dart 
