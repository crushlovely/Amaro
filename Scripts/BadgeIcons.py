#!/usr/bin/env python
# -*- coding: utf-8 -*-

# This script reads the Info.plist in CODESIGNING_FOLDER_PATH, as well as several other
# environmental variables, and (if appropriate) badges the app's icons to indicate
# whether it targets staging or production and its version and build number.

# This is not run under continuous integration or for app store builds.
# Version and build information is hidden on very small icons, like those used
# in Spotlight.


from __future__ import print_function
from os import environ
from sys import exit

# Exit early if we're in CI or making an app store build
if environ.get('CI') == 'true': exit(0)
if environ.get('CONFIGURATION') == 'Distribution': exit(0)


from AppKit import *
from Quartz import *
from CoreText import *
from os.path import splitext, join as pathJoin, exists as fileExists
from math import floor, ceil
from sys import argv, stderr

FONT_NAME = 'Helvetica-Bold'


def getIconAndBaseColor(isStaging):
    if isStaging:
        baseColor = NSColor.colorWithCalibratedRed_green_blue_alpha_(0.168, 0.306, 0.184, 1)
        iconCharacter = u'🅢'
    else:
        baseColor = NSColor.colorWithCalibratedRed_green_blue_alpha_(0.315, 0.108, 0.093, 1)
        iconCharacter = u'🅟'

    return (iconCharacter, baseColor)


def makeAttributedVersionString(versionText, fontSize, color):
    versionParagraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy()
    versionParagraphStyle.setLineBreakMode_(NSLineBreakByClipping)
    versionParagraphStyle.setAlignment_(NSRightTextAlignment)

    versionFont = NSFont.fontWithName_size_(FONT_NAME, fontSize)

    versionAttributes = {
        NSFontAttributeName: versionFont,
        NSForegroundColorAttributeName: color,
        NSParagraphStyleAttributeName: versionParagraphStyle
    }

    return NSAttributedString.alloc().initWithString_attributes_(versionText, versionAttributes)


def makeAttributedIconString(iconGlyph, fontSize, color):
    iconFont = NSFont.fontWithName_size_(FONT_NAME, fontSize)
    iconAttributes = {
        NSFontAttributeName: iconFont,
        NSForegroundColorAttributeName: color
    }

    return NSAttributedString.alloc().initWithString_attributes_(iconGlyph, iconAttributes)


def getBadgeImage(approxIconHeight, staging, versionText):
    iconGlyph, baseColor = getIconAndBaseColor(staging)

    BORDER_THICKNESS = 0.25  # As a percentage of the icon diameter
    MIN_ICON_HEIGHT_FOR_VERSION_TEXT = 15  # below this, the version text will be left out

    # First, calculate the size of the version text
    versionString = makeAttributedVersionString(versionText, approxIconHeight / 2.5, NSColor.whiteColor())
    versionStringBounds = versionString.boundingRectWithSize_options_(NSZeroSize, NSStringDrawingUsesLineFragmentOrigin)
    versionStringWidth = NSWidth(versionStringBounds)
    if approxIconHeight < MIN_ICON_HEIGHT_FOR_VERSION_TEXT:
        versionStringWidth = 0

    # And now the icon...
    iconString = makeAttributedIconString(iconGlyph, approxIconHeight, baseColor)
    iconImage = getImageOfGlyph(iconString, NSColor.colorWithWhite_alpha_(1.0, 0.8))
    iconSize = iconImage.size()

    # Calculate some frames and whatnot
    totalBorderThickness = NSMakeSize(ceil(iconSize.width * BORDER_THICKNESS),
                                      ceil(iconSize.height * BORDER_THICKNESS))

    iconOrigin = NSMakePoint(ceil(totalBorderThickness.width / 2.0),
                             ceil(totalBorderThickness.height / 2.0))

    borderedIconSize = NSMakeSize(iconSize.width + totalBorderThickness.width,
                                  iconSize.height + totalBorderThickness.height)

    badgeSize = NSMakeSize(ceil(borderedIconSize.width + versionStringWidth + totalBorderThickness.width / 2.0),
                           borderedIconSize.height)

    rightBackgroundBoxBounds = NSIntegralRect(NSMakeRect(borderedIconSize.width / 2.0,
                                                         0,
                                                         badgeSize.width - borderedIconSize.width / 2.0,
                                                         badgeSize.height))

    textFrameBounds = NSIntegralRect(NSMakeRect(borderedIconSize.width,
                                                (badgeSize.height - NSHeight(versionStringBounds)) / 2.0,  # vertically centered
                                                versionStringWidth,
                                                badgeSize.height))

    # And now drawing
    badgeImage = NSImage.alloc().initWithSize_(badgeSize)
    badgeImage.lockFocusFlipped_(True)

    # The background rectangle + circle
    boxColor = NSColor.colorWithCalibratedHue_saturation_brightness_alpha_(baseColor.hueComponent(), baseColor.saturationComponent(), 0.6, 0.9)
    boxColor.set()
    NSRectFill(rightBackgroundBoxBounds)

    iconBackgroundCircleRect = (NSZeroPoint, borderedIconSize)
    iconBackgroundCirclePath = NSBezierPath.bezierPathWithOvalInRect_(iconBackgroundCircleRect)
    boxColor.set()
    iconBackgroundCirclePath.fill()

    # The icon
    iconDestRect = (iconOrigin, iconSize)
    iconImage.drawInRect_fromRect_operation_fraction_respectFlipped_hints_(iconDestRect, NSZeroRect, NSCompositeSourceAtop, 1.0, True, None)

    # Text
    if approxIconHeight >= MIN_ICON_HEIGHT_FOR_VERSION_TEXT:
        versionString.drawInRect_(textFrameBounds)

    badgeImage.unlockFocus()

    return badgeImage


def getImageOfGlyph(glyphAttributedString, backingColor):
    line = CTLineCreateWithAttributedString(glyphAttributedString)

    # Get a rough size of our glyph. We'll use this to make the NSImage, and get a more accurate
    # frame once we have a context to call CTLineGetImageBounds.
    typographicWidth, ascent, descent, leading = CTLineGetTypographicBounds(line, None, None, None)

    img = NSImage.alloc().initWithSize_(NSMakeSize(ceil(typographicWidth), ceil(ascent + descent)))

    
    img.lockFocus()

    context = NSGraphicsContext.currentContext().graphicsPort()

    bounds = CTLineGetImageBounds(line, context)

    CGContextTranslateCTM(context, 0, ceil(descent))  # Shift everything up so the descender is inside our image

    if backingColor:
        # Draw a circle behind the glyph with the ratio to the size of the glyph
        bgCircleDiameterRatio = 0.9
        bgCircleOffsetRatio = (1.0 - bgCircleDiameterRatio) / 2.0

        bgCircleRect = NSMakeRect(bounds.origin.x + bounds.size.width * bgCircleOffsetRatio,
                                  bounds.origin.y + bounds.size.height * bgCircleOffsetRatio,
                                  bounds.size.width * bgCircleDiameterRatio,
                                  bounds.size.height * bgCircleDiameterRatio)

        backgroundCirclePath = NSBezierPath.bezierPathWithOvalInRect_(bgCircleRect)
        backingColor.setFill()
        backgroundCirclePath.fill()

    CTLineDraw(line, context)

    bitmapRep = NSBitmapImageRep.alloc().initWithFocusedViewRect_(NSIntegralRect(bounds))

    img.unlockFocus()

    finalImage = NSImage.alloc().initWithSize_(NSIntegralRect(bounds).size)
    finalImage.addRepresentation_(bitmapRep)

    return finalImage


def badgeFile(fn, destinationDir, isStaging, versionString, buildString):
    fullVersionString = ''
    if versionString:
        fullVersionString += 'v' + versionString
    if buildString:
        if versionString: fullVersionString += '\n'
        fullVersionString += 'b' + buildString

    # Not using -[NSImage initWithContentsOfFile:] here, since that treats @2x files
    # specially, which we don't want in this case.
    imgData = NSData.dataWithContentsOfFile_(fn)
    img = NSImage.alloc().initWithData_(imgData)
    size = img.size()

    # Generate the badge image
    iconHeight = size.height * 0.3
    badgeImage = getBadgeImage(iconHeight, isStaging, fullVersionString)
    badgeSize = badgeImage.size()

    # Draw it over top
    img.lockFocus()

    boxShadowColor = NSColor.colorWithWhite_alpha_(0.2, 0.5)
    boxShadow = NSShadow.alloc().init()
    boxShadow.setShadowColor_(boxShadowColor)
    boxShadow.setShadowOffset_(NSZeroSize)
    boxShadow.setShadowBlurRadius_(iconHeight / 3.0)
    boxShadow.set();

    badgeBottomPadding = ceil(0.15 * size.height)
    badgeDestRect = ((size.width - badgeSize.width,
                      badgeBottomPadding),
                     badgeSize)
    badgeImage.drawInRect_fromRect_operation_fraction_respectFlipped_hints_(badgeDestRect, NSZeroRect, NSCompositeSourceAtop, 1.0, True, None)

    bitmapRep = NSBitmapImageRep.alloc().initWithFocusedViewRect_((NSZeroPoint, size))

    img.unlockFocus()

    # And spit the thing out
    pngData = bitmapRep.representationUsingType_properties_(NSPNGFileType, None)

    destFn = NSString.lastPathComponent(fn).stringByDeletingPathExtension() + '.png'
    dest = NSString.pathWithComponents_([ destinationDir, destFn ])

    pngData.writeToFile_atomically_(dest, False)


def getIconFilenamesAndVersionAndBuild(dir):
    plistData = NSData.dataWithContentsOfFile_(pathJoin(dir, 'Info.plist'))
    if not plistData:
        print('error: Unable to read Info plist file in %s.\nPlease report this at https://github.com/crushlovely/Amaro/issues' % dir, file=stderr)
        exit(1)

    plist, format, error = NSPropertyListSerialization.propertyListWithData_options_format_error_(plistData, 0, None, None)

    if error:
        print('error: Unable to deserialize Info plist file in %s\nError message: %s\n\nPlease report this at https://github.com/crushlovely/Amaro/issues' % (dir, error), file=stderr)
        exit(1)

    iPhoneIcons = plist.valueForKeyPath_('CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles') or []
    iPadIcons = plist.valueForKeyPath_('CFBundleIcons~ipad.CFBundlePrimaryIcon.CFBundleIconFiles') or []

    fns = []
    fns.extend([fn + '.png' for fn in iPhoneIcons])
    fns.extend([fn + '@2x.png' for fn in iPhoneIcons])
    fns.extend([fn + '~ipad.png' for fn in iPadIcons])
    fns.extend([fn + '@2x~ipad.png' for fn in iPadIcons])
    fns = [pathJoin(dir, fn) for fn in fns]

    return (filter(fileExists, fns), plist.get('CFBundleShortVersionString'), plist.get('CFBundleVersion'))


if __name__ == '__main__':
    staging = environ.get('CONFIGURATION', '').endswith('Staging')
    sourceDir = environ.get('CODESIGNING_FOLDER_PATH')

    iconFns, version, build = getIconFilenamesAndVersionAndBuild(sourceDir)

    for fn in iconFns:
        badgeFile(fn, sourceDir, staging, version, build)
