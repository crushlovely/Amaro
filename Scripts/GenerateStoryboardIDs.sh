#!/bin/bash

# This script walks the storyboards in your project and creates StoryboardIdentifiers.{h,m}
# with constants for all the identifiers in the storyboards.
# See GenerateStoryboardIDs.py for more details.

PROJ_FILE="$SRCROOT/${PROJECT_NAME}.xcodeproj/project.pbxproj"

if [ ! -r "$PROJ_FILE" ]; then
  echo "warning: The project file for storyboard codegen ($PROJ_FILE) was not found or is not readable.\nPlease report this at https://github.com/crushlovely/Amaro/issues." 1&>2
  exit 0
fi

# Grab the ID of the root object (the project itself)
ROOT_OBJ_ID=$(/usr/libexec/PlistBuddy -c 'Print :rootObject' "$PROJ_FILE" 2>/dev/null)

# And fetch the class prefix from that object
CLASS_PREFIX=$(/usr/libexec/PlistBuddy -c "Print :objects:${ROOT_OBJ_ID}:attributes:CLASSPREFIX" "$PROJ_FILE" 2>/dev/null)

DEST="${SRCROOT}/${PROJECT_NAME}/Other-Sources"

# We're naively feeding all storyboards under the project folder into the script.
# In a perfect world we would only do this for storyboards that are actually used as resources
# in the project, but this should cover 99.99% of cases.
find "${SRCROOT}/${PROJECT_NAME}" -type f -name '*.storyboard' -print0 | xargs -0 "${SRCROOT}/Scripts/GenerateStoryboardIDs.py" "$CLASS_PREFIX" "$DEST"
