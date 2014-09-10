from __future__ import print_function

import os
import sys
from collections import defaultdict
import types
import Foundation
from fnmatch import fnmatch

# Hat tip: http://stackoverflow.com/a/3013910
def lazyprop(fn):
    attr_name = '_lazy_' + fn.__name__
    @property
    def _lazyprop(self):
        if not hasattr(self, attr_name):
            setattr(self, attr_name, fn(self))
        return getattr(self, attr_name)
    return _lazyprop


class AmaroLibModule(types.ModuleType):
    REPORT_URL = 'https://github.com/crushlovely/Amaro/issues'

    def __init__(self):
        super(AmaroLibModule, self).__init__('AmaroLib')

        # These are populated when the corresponding files are loaded
        self.projectPlistFormat = None
        self.infoPlistFormat = None


    #### Build environment predicates

    @lazyprop
    def _configuration(self):
        return self.getEnv('CONFIGURATION')

    @property
    def targetingStaging(self):
        return self._configuration.endswith('Staging')

    @property
    def targetingProduction(self):
        return self._configuration.endswith('Production')

    @property
    def isAdHocConfiguration(self):
        return self._configuration.startswith('AdHoc')

    @property
    def isDebugConfiguration(self):
        return self._configuration.startswith('Debug')

    @property
    def isProfileConfiguration(self):
        return self._configuration.startswith('Profile')

    @property
    def isTestConfiguration(self):
        return self._configuration.startswith('Test')

    @property
    def isDistributionConfiguration(self):
        return self._configuration == 'Distribution'

    isDistributionBuild = isDistributionConfiguration

    @property
    def isDistributionOrAdHocBuildForDevice(self):
        return self.buildingForDevice and (self.isDistributionConfiguration or self.isAdHocConfiguration)

    @property
    def inContinuousIntegration(self):
        return os.environ.get('CI') == 'true'

    @property
    def buildingForSimulator(self):
        return os.environ.get('PLATFORM_NAME') == 'iphonesimulator'

    @property
    def buildingForDevice(self):
        return not self.buildingForSimulator


    #### Project file and related introspection
    @property
    def projectName(self):
        return self.getEnv('PROJECT_NAME')

    @property
    def projectFilename(self):
        return self.envFormat('{SRCROOT}/{PROJECT_NAME}.xcodeproj/project.pbxproj')

    @lazyprop
    def parsedProjectObject(self):
        parsedProject, self.projectPlistFormat = self.loadPlist(self.projectFilename)
        return parsedProject

    def getProjectObject(self, objectId):
        return self.parsedProjectObject.valueForKeyPath_('objects.' + objectId)

    @lazyprop
    def rootProjectObject(self):
        rootObjectId = self.parsedProjectObject['rootObject']
        return self.getProjectObject(rootObjectId)

    def getProjectKeypath(self, keypath):
        return self.rootProjectObject.valueForKeyPath_(keypath)

    @property
    def classPrefix(self):
        return self.getProjectKeypath('attributes.CLASSPREFIX')

    @lazyprop
    def mainTargetObject(self):
        targetsIds = self.getProjectKeypath('targets')
        for targetId in targetsIds:
            targetObj = self.getProjectObject(targetId)
            if targetObj.name == self.projectName:
                return targetObj

    def getBuildPhasesOfType(self, isa, target = None):
        if not target:
            target = self.mainTargetObject

        phaseIds = target['buildPhases']
        phases = []
        for phaseId in phaseIds:
            phase = self.getProjectObject(phaseId)
            if phase.isa == isa:
                phases.append(phase)

        return phases


    #### Info.plist introspection
    @property
    def infoPlistFilename(self):
        return os.path.join(self.getEnv('SRCROOT'), self.getEnv('INFOPLIST_FILE'))

    @lazyprop
    def infoPlist(self):
        plist, self.infoPlistFormat = self.loadPlist(self.infoPlistFilename)
        return plist

    def getInfoPlistKeypath(self, keypath):
        return self.infoPlist.valueForKeyPath_(keypath)

    @property
    def version(self):
        return self.getInfoPlistKeypath('CFBundleShortVersionString')

    @property
    def buildNumber(self):
        return self.getInfoPlistKeypath(Foundation.kCFBundleVersionKey)


    #### Helper functions
    def loadPlist(self, filename, mutableContainers = True, failureIsFatal = True):
        plistData = Foundation.NSData.dataWithContentsOfFile_(filename)
        if not plistData and failureIsFatal:
            self.die('Unable to read plist file {}.\nPlease report this at {}'.format(filename, self.REPORT_URL))
        
        options = 0
        if mutableContainers:
            options = Foundation.NSPropertyListMutableContainers

        plist, plistFormat, error = Foundation.NSPropertyListSerialization.propertyListWithData_options_format_error_(plistData, options, None, None)
        if error and failureIsFatal:
            self.die('Unable to parse plist file {}\nError message: {!s}\n\nPlease report this at {}.'.format(filename, error, self.REPORT_URL))

        return (plist, plistFormat)

    def writePlist(self, filename, plistRoot, outputFormat = Foundation.NSPropertyListXMLFormat_v1_0, failureIsFatal = True):
        plistData, error = Foundation.NSPropertyListSerialization.dataWithPropertyList_format_options_error_(plistRoot, outputFormat, 0, None)
        if error and failureIsFatal:
            self.die('Unable to convert object {!r} to a property list!\nError message: {!s}\n\nPlease report this at {}.'.format(plistRoot, error, self.REPORT_URL))

        success, error = plistData.writeToFile_options_error_(filename, 0, None)
        if not success and failureIsFatal:
            self.die('Unable to write plist file at {}.\nError message: {!s}\n\nPlese report this at: {}.'.format(filename, error, self.REPORT_URL))

    def getEnv(self, varName, default = None, missingIsFatal = True):
        if varName in os.environ:
            return os.environ[varName]
        elif not missingIsFatal:
            return default

        self.dieOverMissingEnvVariable(varName)

    def envFormat(self, s, defaults = None, missingKeyIsFatal = True):
        if defaults:
            d = os.environ.copy().update(defaults)
        else:
            d = os.environ
        
        if not missingKeyIsFatal:
            d = defaultdict(str, d)

        try:
            return s.format(**d)
        except KeyError, e:
            # Since we're using a defaultdict in the !missingKeyIsFatal case, this
            # exception will only happen if this is fatal.
            self.dieOverMissingEnvVariable(e.message)

    def bareFilename(self, fn):
        return os.path.splitext(os.path.basename(fn))[0]

    def recursiveGlob(self, rootDir, pattern):
        for root, _, files in os.walk(rootDir):
            for basename in files:
                if fnmatch(basename, pattern):
                    yield os.path.join(root, basename)

    def die(self, message):
        print('error: ' + message, file = sys.stderr)
        sys.exit(1)

    def dieOverMissingEnvVariable(self, varName):
        self.die('Environmental variable {} is not set!\nAre you running inside an Xcode build phase or rule? If so, please report this at {}'.format(varName, self.REPORT_URL))

    def warn(self, message):
        print('warning: ' + message, file = sys.stderr)


# When we overwrite our entry in sys.modules, we lose the last reference to .. ouselves,
# which results in Bad Things. So we have to stash a temporary reference to stop that from
# happening. See this post for info: http://stackoverflow.com/posts/5365733/revisions
_ref = sys.modules[__name__]
sys.modules[__name__] = AmaroLibModule()
