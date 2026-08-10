#!/bin/zsh

set -euo pipefail

project_root="${0:A:h:h}"
test_destination="${INDULGE_TEST_DESTINATION:-platform=iOS Simulator,name=Indulge iPhone 17 Pro,OS=26.4}"

cd "$project_root"
xcodegen generate
xcodebuild \
  -project Indulge.xcodeproj \
  -scheme Indulge \
  -sdk iphonesimulator \
  -destination "$test_destination" \
  test
