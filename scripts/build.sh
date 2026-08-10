#!/bin/zsh

set -euo pipefail

project_root="${0:A:h:h}"

cd "$project_root"
xcodegen generate
xcodebuild \
  -project Indulge.xcodeproj \
  -scheme Indulge \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
