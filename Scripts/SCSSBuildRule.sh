#!/bin/bash

# This build rule converts .scss files in your project to .css files.
# In Xcode, the output files should be set to "$(DERIVED_FILE_DIR)/$(INPUT_FILE_BASE).css".

set -e

# Try to use an RVM install, or otherwise just hope sass is in the PATH
[ -r ~/.rvm/environments/default ] && source ~/.rvm/environments/default
if [ -n "$GEM_HOME" ]; then
    SASS="${GEM_HOME}/bin/sass"
else
    SASS="`which sass`"
fi

if [ -z "$SASS" -o ! -x "$SASS" ]; then
    echo "error: To use .scss files, you must install sass and have it in your PATH. See http://sass-lang.com/install for instructions." 1>&2
    exit 1
fi

# Xcode doesn't like to copy resources from build rules out to the product folder,
# so we're doing it ourselves, and adding the derived files output to placate
# its dependency stuff.
OUTPUT="${DERIVED_FILE_DIR}/${INPUT_FILE_BASE}.css"
"$SASS" "$INPUT_FILE_PATH" "$OUTPUT"
cp "$OUTPUT" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${INPUT_FILE_BASE}.css"
