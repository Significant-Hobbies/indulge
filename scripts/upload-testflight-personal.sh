#!/bin/zsh

set -euo pipefail

project_root="${0:A:h:h}"
personal_team="8F7LXHTJZR"
archive_path="${INDULGE_ARCHIVE_PATH:-$project_root/build/Indulge-Personal.xcarchive}"
export_options="$project_root/scripts/TestFlightExportOptions.plist"
archive_info="$archive_path/Info.plist"

if [[ ! -f "$archive_info" ]]; then
  print -u2 "Signed archive not found at $archive_path."
  exit 2
fi

archive_team="$(plutil -extract ApplicationProperties.Team raw "$archive_info")"
export_team="$(plutil -extract teamID raw "$export_options")"

if [[ "$archive_team" != "$personal_team" || "$export_team" != "$personal_team" ]]; then
  print -u2 "Refusing to upload: archive and export settings must both use personal team $personal_team."
  exit 3
fi

xcodebuild -exportArchive \
  -archivePath "$archive_path" \
  -exportPath "$project_root/build/TestFlightUpload" \
  -exportOptionsPlist "$export_options" \
  -allowProvisioningUpdates
