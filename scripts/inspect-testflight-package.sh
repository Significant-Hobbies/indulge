#!/bin/zsh

set -euo pipefail

project_root="${0:A:h:h}"
package_path="${INDULGE_PACKAGE_PATH:-$project_root/build/TestFlightPackage/Indulge.ipa}"
expected_team="8F7LXHTJZR"
expected_bundle_id="$(awk '/PRODUCT_BUNDLE_IDENTIFIER:/ { print $2; exit }' "$project_root/project.yml")"
expected_version="$(awk '/MARKETING_VERSION:/ { print $2; exit }' "$project_root/project.yml")"
expected_build="$(awk '/CURRENT_PROJECT_VERSION:/ { print $2; exit }' "$project_root/project.yml")"

if [[ ! -f "$package_path" ]]; then
  print -u2 "TestFlight package is missing at $package_path."
  exit 2
fi

temporary_directory="$(mktemp -d)"
trap 'rm -rf "$temporary_directory"' EXIT
unzip -q "$package_path" -d "$temporary_directory"

app_path="$(find "$temporary_directory/Payload" -maxdepth 1 -type d -name '*.app' -print -quit)"
if [[ -z "$app_path" ]]; then
  print -u2 "The package does not contain an application bundle."
  exit 3
fi

entitlements="$temporary_directory/entitlements.plist"
profile="$temporary_directory/profile.plist"
codesign -d --entitlements :- "$app_path" > "$entitlements" 2>/dev/null
security cms -D -i "$app_path/embedded.mobileprovision" > "$profile"

read_entitlement() {
  local key_path="${1//./\\.}"
  plutil -extract "$key_path" raw "$entitlements" 2>/dev/null || print missing
}

bundle_id="$(plutil -extract CFBundleIdentifier raw "$app_path/Info.plist")"
version="$(plutil -extract CFBundleShortVersionString raw "$app_path/Info.plist")"
build="$(plutil -extract CFBundleVersion raw "$app_path/Info.plist")"
team="$(plutil -extract TeamIdentifier.0 raw "$profile")"
get_task_allow="$(read_entitlement get-task-allow)"
push_environment="$(read_entitlement aps-environment)"
icloud_environment="$(read_entitlement com.apple.developer.icloud-container-environment)"
authority="$(codesign -dv --verbose=4 "$app_path" 2>&1 | awk -F= '/^Authority=/ && !seen { print $2; seen=1 }')"
framework_count="$(find "$app_path" -maxdepth 2 -type d -name '*.framework' | wc -l | tr -d ' ')"

print "Package: $package_path"
print "Identity: $bundle_id $version ($build)"
print "Team: $team"
print "Signing authority: $authority"
print "get-task-allow: $get_task_allow"
print "Push environment: $push_environment"
print "iCloud environment: $icloud_environment"
print "Embedded frameworks: $framework_count"

if [[ "$team" != "$expected_team" \
  || "$bundle_id" != "$expected_bundle_id" \
  || "$version" != "$expected_version" \
  || "$build" != "$expected_build" ]]; then
  print -u2 "Package identity does not match the intended Indulge release."
  exit 4
fi

if [[ "$authority" != Apple\ Distribution:* \
  || "$get_task_allow" == "true" \
  || "$push_environment" != "production" \
  || "$icloud_environment" != "Production" ]]; then
  print -u2 "Package is not signed with App Store/TestFlight distribution entitlements."
  exit 5
fi

if [[ "$framework_count" != "0" ]]; then
  print -u2 "Package unexpectedly embeds third-party frameworks."
  exit 6
fi

plutil -lint "$app_path/PrivacyInfo.xcprivacy"
print "Classification: testflight-package-ready"
