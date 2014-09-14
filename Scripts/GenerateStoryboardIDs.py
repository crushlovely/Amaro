#!/usr/bin/env python2.7

# This script walks the storyboards in your project and spits out one .h/.m pair with
# constants for all the identifiers in the storyboards.
# The constants are namespaced by storyboard name and then category, and look like this:
#   [class prefix][storyboard name]StoryboardIDs.[identifier type].[identifier name]
# For instance, a segue identifier named "M5MainStoryboardProfileSegueID" in
# MainStoryboard.storyboard in a project with class prefix 'M5' would result in a structure
# with this constant:
#   M5MainStoryboardIDs.segues.profile
# Note that the code tries to parse any structure already present in your identifiers,
# to avoid duplicating strings unnecessarily when naming.
# Thus, in the above example, it did not naively generate something like
#  'M5MainStoryboardStoryboardIDs.segues.M5MainStoryboardProfileSegueID'

# The script also tries to make valid identifiers out of your storyboard filenames and
# identifiers. If it can't do so for your use case, please submit a bug at 
# https://github.com/crushlovely/Amaro/issues.

# Inspired by https://github.com/square/objc-codegenutils,
# and using some slugification code from http://flask.pocoo.org/snippets/5/ and
# namespacing idea from https://www.mikeash.com/pyblog/friday-qa-2011-08-19-namespaced-constants-and-functions.html

from __future__ import print_function, unicode_literals
import AmaroLib as lib
from xml.etree import ElementTree
import os

class IDList(object):
    SEGUE = 0
    VIEW_CONTROLLER = 1
    REUSE = 2
    RESTORATION = 3

    def __init__(self, storyboardName, classPrefix):
        self.name = storyboardName
        self.classPrefix = classPrefix
        self.segues = {}
        self.viewControllers = {}
        self.reusables = {}
        self.restorables = {}

        self._defaultPrefixes = [ classPrefix, storyboardName, 'Storyboard' ]
        if storyboardName.endswith('Storyboard'):
            self._defaultPrefixes.append(storyboardName[:-10])

        self.className = lib.variableNameForString(storyboardName, [ classPrefix ], [ 'Storyboard' ], lower = False)
        self._defaultPrefixes.append(self.className)

        if classPrefix:
            self.className = classPrefix + self.className
            self._defaultPrefixes.append(self.className)

        self.className += 'StoryboardIDs'

    def _addId(self, id_, type_):
        targetDict = None
        suffixes = [ 'ID', 'Id', 'Identifier' ]

        if type_ == self.SEGUE:
            targetDict = self.segues
            suffixes.append('Segue')
        elif type_ == self.VIEW_CONTROLLER:
            targetDict = self.viewControllers
            suffixes.extend(['ViewController', 'Controller', 'VC'])
        elif type_ == self.REUSE:
            targetDict = self.reusables
            suffixes.append('Reuse')
        elif type_ == self.RESTORATION:
            targetDict = self.restorables
            suffixes.append('Restoration')

        variableName = lib.variableNameForString(id_, self._defaultPrefixes, suffixes)
        targetDict[variableName] = id_

    def _addIds(self, ids, type_):
        for id_ in ids:
            self._addId(id_, type_)

    @classmethod
    def fromFile(cls, filename, classPrefix, includeRestorationIDs = False):
        res = cls(lib.bareFilename(filename), classPrefix)

        root = ElementTree.parse(fn)

        segueIds = getAttrsForAllNodesWithAttr(root, 'identifier', 'segue')
        res._addIds(segueIds, cls.SEGUE)

        # This seems to be limited to view controllers, but we can't specify a tag, as different
        # UIViewController subclasses have different tags (e.g. nav controllers).
        viewControllerIds = getAttrsForAllNodesWithAttr(root, 'storyboardIdentifier')
        res._addIds(viewControllerIds, cls.VIEW_CONTROLLER)

        reuseIds = getAttrsForAllNodesWithAttr(root, 'reuseIdentifier')
        res._addIds(reuseIds, cls.REUSE)

        if includeRestorationIDs:
            restorationIds = getAttrsForAllNodesWithAttr(root, 'restorationIdentifier')
            restorationIds.extend(getRestorationIDsForVCsUsingStoryboardIDs(root))
            res._addIds(restorationIds, cls.RESTORATION)

        return res

    def headerAndImpContents(self):
        hLines = []
        mLines = []
        indent = '    '

        allTypes = [ 'segues', 'viewControllers', 'reusables', 'restorables' ]
        for typename in allTypes:
            typeDict = getattr(self, typename)
            if not typeDict:
                continue

            hLines.append(indent + 'struct {')
            mLines.append(indent + '.' + typename + ' = {')
            for name, value in typeDict.iteritems():
                hLines.append(indent * 2 + '__unsafe_unretained NSString *' + name + ';')
                mLines.append(indent * 2 + '.{} = @"{}",'.format(name, value))
            hLines.append(indent + '} ' + typename + ';\n')
            mLines.append(indent + '},\n')

        if hLines:
            hLines.insert(0, 'extern const struct ' + self.className + ' {')
            hLines.append('} ' + self.className + ';')

            mLines.insert(0, 'const struct ' + self.className + ' ' + self.className + ' = {')
            mLines.append('};')

        return ('\n'.join(hLines), '\n'.join(mLines))

def getAttrsForAllNodesWithAttr(root, attr, tag = "*"):
    # Get the given attribute from all children of the root tag that have it.
    # Optionally specify the exact child tag you're interested in.
    # Results are all unicodified for consistency
    return [unicode(e.get(attr)) for e in root.findall('.//' + tag + '[@' + attr + ']')]

def getRestorationIDsForVCsUsingStoryboardIDs(root):
    # Returns a list of restoration IDs for view controllers that have their
    # "Use Storyboard ID" box checked in Interface Builder.
    # In this case, the element has useStoryboardIdentifierAsRestorationIdentifier set,
    # but we're only interested in ones that also have a storyboardIdentifier
    elements = root.findall('.//*[@useStoryboardIdentifierAsRestorationIdentifier][@storyboardIdentifier]')
    return [unicode(e.get('storyboardIdentifier')) for e in elements]

def assembleAndOutput(lines, outputDir, outputBasename):
    warning = '// This file is automatically generated at build time from your storyboards.\n'
    warning += '// Any edits you make will be overwritten.\n\n'

    header = warning
    header += '#import <Foundation/Foundation.h>\n\n'
    header += '\n\n'.join(lines[0])

    imp = warning
    imp += '#import "' + outputBasename + '.h"\n\n'
    imp += '\n\n'.join(lines[1])

    headerFn = os.path.join(outputDir, outputBasename + '.h')
    impFn = os.path.join(outputDir, outputBasename + '.m')

    with open(headerFn, 'w') as f:
        f.write(header.encode('utf-8'))

    with open(impFn, 'w') as f:
        f.write(imp.encode('utf-8'))


if __name__ == '__main__':
    outBasename = 'StoryboardIdentifiers'
    prefix = lib.classPrefix
    needRestorationIDs = 'NEED_RESTORATION_IDS' in os.environ

    projectDir = os.path.join(lib.getEnv('SRCROOT'), lib.getEnv('PROJECT_NAME'))

    inputFiles = list(lib.recursiveGlob(projectDir, '*.storyboard'))

    lines = ([], [])
    for fn in inputFiles:
        idList = IDList.fromFile(fn, prefix, needRestorationIDs)
        hString, mString = idList.headerAndImpContents()
        if hString:
            lines[0].append('#pragma mark ' + idList.name)
            lines[0].append(hString)

            lines[1].append('#pragma mark ' + idList.name)
            lines[1].append(mString)

    outDir = os.path.join(projectDir, 'Other-Sources', 'Generated')
    assembleAndOutput(lines, outDir, outBasename)

    print('Generated {}.h and .m files from identifiers in the following storyboard(s): {}'.format(outBasename, ', '.join([os.path.basename(fn) for fn in inputFiles])))
