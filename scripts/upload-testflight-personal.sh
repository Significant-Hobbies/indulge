#!/bin/zsh

set -euo pipefail

project_root="${0:A:h:h}"
personal_team="8F7LXHTJZR"
archive_path="${INDULGE_ARCHIVE_PATH:-$project_root/build/Indulge.xcarchive}"
export_options="$project_root/scripts/TestFlightExportOptions.plist"
archive_info="$archive_path/Info.plist"
expected_bundle_id="$(awk '/PRODUCT_BUNDLE_IDENTIFIER:/ { print $2; exit }' "$project_root/project.yml")"
expected_version="$(awk '/MARKETING_VERSION:/ { print $2; exit }' "$project_root/project.yml")"
expected_build="$(awk '/CURRENT_PROJECT_VERSION:/ { print $2; exit }' "$project_root/project.yml")"

if [[ ! -f "$archive_info" ]]; then
  print -u2 "Signed archive not found at $archive_path."
  exit 2
fi

archive_team="$(plutil -extract ApplicationProperties.Team raw "$archive_info")"
archive_bundle_id="$(plutil -extract ApplicationProperties.CFBundleIdentifier raw "$archive_info")"
archive_version="$(plutil -extract ApplicationProperties.CFBundleShortVersionString raw "$archive_info")"
archive_build="$(plutil -extract ApplicationProperties.CFBundleVersion raw "$archive_info")"
export_team="$(plutil -extract teamID raw "$export_options")"

if [[ "$archive_team" != "$personal_team" || "$export_team" != "$personal_team" ]]; then
  print -u2 "Refusing to upload: archive and export settings must both use personal team $personal_team."
  exit 3
fi

if [[ "$archive_bundle_id" != "$expected_bundle_id" \
  || "$archive_version" != "$expected_version" \
  || "$archive_build" != "$expected_build" ]]; then
  print -u2 "Refusing to upload: archive identity does not match project.yml."
  print -u2 "Expected $expected_bundle_id $expected_version ($expected_build); found $archive_bundle_id $archive_version ($archive_build)."
  exit 4
fi

xcodebuild -exportArchive \
  -archivePath "$archive_path" \
  -exportPath "$project_root/build/TestFlightUpload" \
  -exportOptionsPlist "$export_options" \
  -allowProvisioningUpdates
