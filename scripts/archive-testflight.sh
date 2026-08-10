#!/bin/zsh

set -euo pipefail

project_root="${0:A:h:h}"
personal_team="8F7LXHTJZR"
development_team="${INDULGE_DEVELOPMENT_TEAM:-$personal_team}"
archive_path="${INDULGE_ARCHIVE_PATH:-$project_root/build/Indulge.xcarchive}"
allow_provisioning_updates="${INDULGE_ALLOW_PROVISIONING_UPDATES:-NO}"

if [[ "$development_team" != "$personal_team" ]]; then
  print -u2 "Refusing to archive: Indulge is locked to personal team $personal_team."
  exit 3
fi

cd "$project_root"
xcodegen generate

provisioning_arguments=()
if [[ "$allow_provisioning_updates" == "YES" ]]; then
  provisioning_arguments=(-allowProvisioningUpdates)
fi

xcodebuild archive \
  -project Indulge.xcodeproj \
  -scheme Indulge \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "$archive_path" \
  "${provisioning_arguments[@]}" \
  DEVELOPMENT_TEAM="$development_team"

print "Created signed archive at $archive_path"
