#!/usr/bin/env bash
# fail if any commands fails
set -e
# debug log
set -x

dart run bin/generate_endpoints_json.dart 
