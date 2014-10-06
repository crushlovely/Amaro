#!/usr/bin/env python2.7

# This script increments the build number (CFBundleVersion in the Info.plist)
# on Ad-Hoc or Distribution builds that target real devices.
# In the context of Amaro, that means an archive build of any scheme, or any
# non-simulator build of the AppStore scheme.

# This script should be run as a build phase before the "Copy Bundle Resources"
# phase. It has no input or output files.

from __future__ import print_function, unicode_literals
import AmaroLib as lib
from sys import exit

# Bail unless we're a build for something that's going to be released
if not lib.isDistributionOrAdHocBuildForDevice:
    print('Not incrementing build number; this is an internal build')
    exit(0)

buildNumber = lib.buildNumber
try:
    buildNumber = int(buildNumber)
except ValueError, e:
    lib.warn('Unable to parse your build number ("{}") as an integer. Not incrementing it!'.format(buildNumber))
    exit(0)

newBuildNumber = str(buildNumber + 1)
lib.infoPlist['CFBundleVersion'] = newBuildNumber
print('Incrementing build number to {}'.format(newBuildNumber))

lib.writePlist(lib.infoPlistFilename, lib.infoPlist, lib.infoPlistFormat)