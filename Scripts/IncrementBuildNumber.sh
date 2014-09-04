#!/bin/bash

# This script increments the build number (CFBundleVersion in the Info.plist)
# on Ad-Hoc or Distribution builds that target real devices.
# In the context of Amaro, that means an archive build of any scheme, or any
# non-simulator build of the AppStore scheme.

# This script should be run as a build phase before the "Copy Bundle Resources"
# phase. It has no input or output files.

set -ue
set -o pipefail

# Bail unless we're a build for distribution
[ \( "$CONFIGURATION" != "Distribution" -a "${CONFIGURATION:0:5}" != "AdHoc" \) -o "$PLATFORM_NAME" = "iphonesimulator" ] && exit 0

if [ ! -w "$INFOPLIST_FILE" ]; then
  echo "error: Info plist ($INFOPLIST_FILE) could not be found or is not writable" 1>&2
  exit 1
fi

buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFOPLIST_FILE")
buildNumber=$(($buildNumber + 1))
echo "Incrementing build number to $buildNumber"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$INFOPLIST_FILE"
