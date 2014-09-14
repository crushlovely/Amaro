#!/usr/bin/env python2.7

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

from __future__ import print_function, unicode_literals
import AmaroLib as lib
from sys import exit
from glob import glob
import os.path
from shutil import rmtree

# Don't run in continuous integration or if we're not a build for release
if lib.inContinuousIntegration or not lib.isDistributionOrAdHocBuildForDevice:
    print('Not removing localizations; this is an internal build')
    exit(0)

# The project object has a knownRegions property that is an array of 
# locale strings (e.g. "Base", "en") that were set up in Xcode.
knownRegions = lib.getProjectKeypath('knownRegions')

if not knownRegions:
    lib.warn('The project is reporting that there are no known localizations in your project.\nPlease report this at {}'.format(lib.REPORT_URL))
    exit(0)

print('Keeping localizations for regions: ' + ', '.join(knownRegions))

regionsAndFoldersToDelete = []
lprojFolders = glob(os.path.join(lib.getEnv('CODESIGNING_FOLDER_PATH'), '*.lproj'))
for lprojFolder in lprojFolders:
    region = lib.bareFilename(lprojFolder)
    if not region in knownRegions:
        regionsAndFoldersToDelete.append((region, lprojFolder))

if regionsAndFoldersToDelete:
    print('Removing extraneous localizations: ' + ', '.join([t[0] for t in regionsAndFoldersToDelete]))
    try:
        for _, folder in regionsAndFoldersToDelete:
            rmtree(folder)
    except Exception, e:
        lib.die('Error deleting localization directories: {!s}\n\nPlease report this at {}'.format(e, lib.REPORT_URL))
