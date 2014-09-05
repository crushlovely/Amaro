#!/bin/bash

# This removes localization files for regions which you haven't explicitly localized.
# This is mainly to work around a three-factor problem:
# 1) iTunes Connect reads .lproj folders to detect supported languages in an app.
# 2) FormatterKit (and other pods) provides translations for a ton of languages.
# 3) CocoaPods copies all translations from all pods into our app.
# So, iTunes Connect ends up thinking our app supports a lot of languages it doesn't.
# By reading the "knownRegions" property of the pbxproj, we can get the list of
# regions you've actually created a localization for in the project settings.
# See this GitHub issue for details and other workarounds:
# https://github.com/mattt/FormatterKit/issues/88

# This script should be run as a build phase after both the "Copy Bundle Resources"
# and "Copy Pods Resources" phases. It has no input or output files.

# Don't run in continuous integration
[ "$CI" = "true" ] && exit 0

set -ue
set -o pipefail

# Also, no use in running if we're not a Distribution or AdHoc build
[ \( "$CONFIGURATION" != "Distribution" -a "${CONFIGURATION:0:5}" != "AdHoc" \) -o "$PLATFORM_NAME" = "iphonesimulator" ] && exit 0

PROJ_FILE="$SRCROOT/${PROJECT_NAME}.xcodeproj/project.pbxproj"

if [ ! -r "$PROJ_FILE" ]; then
  echo "warning: The project file for localization parsing ($PROJ_FILE) was not found or is not readable. Please report this at https://github.com/crushlovely/Amaro/issues." 1&>2
  exit 0
fi

# Grab the ID of the root object (the project itself)
ROOT_OBJ_ID=$(/usr/libexec/PlistBuddy -c 'Print :rootObject' "$PROJ_FILE" 2>/dev/null)

# That object has a knownRegions property that is an array of locale strings (e.g. "Base", "en").
# Grab that, spit it out in JSON, and massage it into a string fit for a find query.
# For instance, the above example will become '-name Base.lproj -o -name en.lproj'
# The <> stuff in the seds is jank to get the -o only between intermediate terms
REGIONS_PRED=$(plutil -extract "objects.${ROOT_OBJ_ID}.knownRegions" json -o - "$PROJ_FILE" 2>/dev/null | \
    python -c 'import sys, json; print "\n".join(json.load(sys.stdin))' | \
    sed 's/$/.lproj>/;s/^/<-name /' |  \
    paste -sd' ' - | \
    sed 's/> </ -o /g;s/[<>]//g' )

echo "Keeping localizations for regions: $(echo $REGIONS_PRED | sed 's/-name //g;s/ -o/,/g;s/\.lproj//g')"

find "$CODESIGNING_FOLDER_PATH" -maxdepth 1 -type d -name '*.lproj' -not \( $REGIONS_PRED \) -exec rm -rf {} +
