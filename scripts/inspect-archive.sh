#!/bin/zsh

set -euo pipefail

project_root="${0:A:h:h}"
archive_path="${INDULGE_ARCHIVE_PATH:-$project_root/build/Indulge.xcarchive}"
require_testflight="NO"

if [[ "${1:-}" == "--require-testflight" ]]; then
  require_testflight="YES"
elif [[ -n "${1:-}" ]]; then
  print -u2 "Usage: $0 [--require-testflight]"
  exit 64
fi

archive_info="$archive_path/Info.plist"
app_path="$archive_path/Products/Applications/Indulge.app"

if [[ ! -f "$archive_info" || ! -d "$app_path" ]]; then
  print -u2 "Archive is incomplete or missing at $archive_path."
  exit 2
fi

temporary_directory="$(mktemp -d)"
trap 'rm -rf "$temporary_directory"' EXIT
entitlements="$temporary_directory/entitlements.plist"

codesign -d --entitlements :- "$app_path" > "$entitlements" 2>/dev/null

read_archive_value() {
  plutil -extract "ApplicationProperties.$1" raw "$archive_info"
}

read_entitlement() {
  local key_path="${1//./\\.}"
  plutil -extract "$key_path" raw "$entitlements" 2>/dev/null || print "missing"
}

team="$(read_archive_value Team)"
bundle_id="$(read_archive_value CFBundleIdentifier)"
version="$(read_archive_value CFBundleShortVersionString)"
build="$(read_archive_value CFBundleVersion)"
signing_identity="$(read_archive_value SigningIdentity)"
get_task_allow="$(read_entitlement get-task-allow)"
push_environment="$(read_entitlement aps-environment)"
icloud_environment="$(read_entitlement com.apple.developer.icloud-container-environment)"

classification="development-device"
if [[ "$signing_identity" == Apple\ Distribution:* \
  && "$get_task_allow" != "true" \
  && "$push_environment" == "production" \
  && "$icloud_environment" == "Production" ]]; then
  classification="testflight-ready"
fi

print "Archive: $archive_path"
print "Identity: $bundle_id $version ($build)"
print "Team: $team"
print "Signing identity: $signing_identity"
print "get-task-allow: $get_task_allow"
print "Push environment: $push_environment"
print "iCloud environment: $icloud_environment"
print "Classification: $classification"

if [[ "$require_testflight" == "YES" && "$classification" != "testflight-ready" ]]; then
  print -u2 "Refusing TestFlight export: this archive is for development-device verification, not App Store distribution."
  exit 5
fi
