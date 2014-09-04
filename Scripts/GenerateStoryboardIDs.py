#!/usr/bin/env python

# This script walks the given storyboards and spits out one .h/.m pair with constants for
# all the identifiers in the storyboards.
# The generated constants are named like this:
#   [class prefix][storyboard name]Storyboard[identifier name][identifier type]ID
# For instance, a segue identifier named "M5ProfileSegueID" in MainStoryboard.storyboard
# in a project with class prefix 'M5' would result in this constant:
#   M5MainStoryboardProfileSegueID
# Note that the code tries to avoid duplicating strings unnecessarily when naming;
# it did not naively generate 'M5MainStoryboardStoryboardM5ProfileSegueIDSegueID'.

# Inspired by https://github.com/square/objc-codegenutils,
# and using some slugification code from http://flask.pocoo.org/snippets/5/

# Arguments to this script are as follows:
#   StoryboardIdentifiers.py classPrefix outputDirectory storyboardFile [storyboardFile [...]]
# Files called StoryboardIdentifiers.{h,m} will be output in the given directory.
# Any existing files with those names will be overwritten.

from xml.etree import ElementTree
import re
from unicodedata import normalize
from os.path import splitext, basename, join as pathjoin
import sys

_punct_re = re.compile(r'[\t !"#$%&\'()*\-/<=>?@\[\\\]^_`{|},.]+')
def sanitizeIdForVariableName(id_):
    # Split everything apart on illegal characters, then recombine,
    # title-casing (but not strictly; other caps inside 'words' can
    # remain) along the way. Also normalize unicode characters into
    # ASCII. This may not be foolproof...

    result = ''

    if isinstance(id_, str): id_ = unicode(id_)

    for word in _punct_re.split(id_):
        word = normalize('NFKD', word).encode('ascii', 'ignore')
        if word:
            result += word[0].upper() + word[1:]

    return result

def headerAndImpLineForId(masterPrefix, storyboardName, id_, suffix):
    constName = sanitizeIdForVariableName(id_)

    # Massage in the prefix...
    if not constName.startswith(masterPrefix):
        # If it doesn't already have the main prefix,

        # add the storyboard name if needed,
        if not constName.startswith(storyboardName):
            constName = storyboardName + constName

        # and also the main prefix.
        constName = masterPrefix + constName
    elif not constName.startswith(masterPrefix + storyboardName):
        # Otherwise, if it has the main prefix but is missing the
        # storyboard name, insert the storyboard name.
        constName = masterPrefix + storyboardName + constName[len(masterPrefix):]

    # Massage in the suffix...
    sansID = None
    strippedID = None
    # Check if it already ends with ID/Id/Identifier
    if constName.endswith('ID') or constName.endswith('Id'):
        sansID = constName[:-2]
        strippedID = constName[-2:]
    elif constName.endswith('Identifier'):
        sansID = constName[:-10]
        strippedID = constName[-10:]

    if strippedID:
        # If it already had ID in some form, but is missing the suffix, insert it.
        if not sansID.endswith(suffix):
            constName = sansID + suffix + strippedID
    elif constName.endswith(suffix):
        # If it didn't have ID but already has the suffix, add ID
        constName += 'ID'
    else:
        # If it didn't have anything, add the suffix and the ID
        constName += suffix + 'ID'

    return ( 'extern NSString * const %s;' % constName, 'NSString * const %s = @"%s";' % (constName, id_) )

def appendHeaderAndImpLines(orig, new, header = None, footer = None):
    if not new[0]: return

    if header:
        orig[0].append(header)
        orig[1].append(header)

    orig[0].extend(new[0])
    orig[1].extend(new[1])

def appendHeaderAndImpLinesForIds(res, header, masterPrefix, storyboardName, ids, suffix):
    lines = ([], [])
    for id_ in ids:
        idLines = headerAndImpLineForId(masterPrefix, storyboardName, id_, suffix)
        if idLines[0]:
            lines[0].append(idLines[0])
            lines[1].append(idLines[1])

    appendHeaderAndImpLines(res, lines, header)

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

def headerAndImpLinesForFile(fn, masterPrefix = ''):
    storyboardName = sanitizeIdForVariableName(splitext(basename(fn))[0])
    if not storyboardName.endswith('Storyboard'): storyboardName += 'Storyboard'

    root = ElementTree.parse(fn)

    segueIds = getAttrsForAllNodesWithAttr(root, 'identifier', 'segue')
    storyboardIds = getAttrsForAllNodesWithAttr(root, 'storyboardIdentifier')
    restorationIds = getAttrsForAllNodesWithAttr(root, 'restorationIdentifier')
    restorationIds.extend(getRestorationIDsForVCsUsingStoryboardIDs(root))
    reuseIds = getAttrsForAllNodesWithAttr(root, 'reuseIdentifier')

    res = ([], [])
    appendHeaderAndImpLinesForIds(res, '\n// Segue Identifiers', masterPrefix, storyboardName, segueIds, 'Segue')
    appendHeaderAndImpLinesForIds(res, '\n// View Controller Identifiers', masterPrefix, storyboardName, storyboardIds, 'Controller')
    appendHeaderAndImpLinesForIds(res, '\n// Restoration Identifiers', masterPrefix, storyboardName, restorationIds, 'Restoration')
    appendHeaderAndImpLinesForIds(res, '\n// Reuse Identifiers', masterPrefix, storyboardName, reuseIds, 'Reuse')

    return res

def assembleAndOutput(lines, outputDir, outputBasename):
    warning = '// This file is automatically generated at build time from your storyboards.\n'
    warning += '// Any edits you make will be overwritten.\n\n'

    header = warning
    header += '#import <Foundation/Foundation.h>\n\n'
    header += '\n'.join(lines[0])

    imp = warning
    imp += '\n'.join(lines[1])

    headerFn = pathjoin(outputDir, outputBasename + '.h')
    impFn = pathjoin(outputDir, outputBasename + '.m')

    with open(headerFn, 'w') as f:
        f.write(header.encode('utf-8'))

    with open(impFn, 'w') as f:
        f.write(imp.encode('utf-8'))


if __name__ == '__main__':
    sys.argv.pop(0)  # Our name

    prefix = sys.argv.pop(0)
    outDir = sys.argv.pop(0)
    outBasename = 'StoryboardIdentifiers'

    lines = ([], [])
    for fn in sys.argv:
        fnLines = headerAndImpLinesForFile(fn, prefix)
        appendHeaderAndImpLines(lines, fnLines, '#pragma mark ' + basename(fn))

        # Add some space after this file's entries, if it had any
        if fnLines[0]:
            lines[0].append('\n')
            lines[1].append('\n')

    assembleAndOutput(lines, outDir, outBasename)
