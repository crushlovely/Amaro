# ![icon](CrushBootstrap/Resources/Images.xcassets/AppIcon.appiconset/Icon-76.png) Amaro [![Build Status](https://travis-ci.org/crushlovely/Amaro.svg?branch=master)](https://travis-ci.org/crushlovely/Amaro)

Crush & Lovely's iOS boilerplate.


## Say what now?
We want to hit the ground running. Xcode and the iOS ecosystem don't make that easy. Enter Amaro. After running one simple command, you get a ready-to-build universal iOS application, [full of delights](#whats-included).


## Gimme gimme
Change to your projects directory, run this line in your terminal, and follow the prompts:

```sh
ruby -e "$(curl -fsSL https://raw.github.com/crushlovely/Amaro/master/tiramisu)
```

Of course, if you're wary of running random scripts (legit!), please read [tiramisu](tiramisu). At a high level, the script creates a local git repository with Amaro as a remote named "bootstrap", tweaks filenames and contents as per your input, and grabs third-party code from Cocoapods.

(Tiramisu is Italian for "pick me up". Bootstrap... pick me up... get it?!? :dancer:)


## Details and Requirements
The bootstrap assumes:

* You are using Xcode 5.
* You have the [CocoaPods gem](http://cocoapods.org/#install) installed.
* You are on OS 10.9 or later
* You are targetting iOS 7.0, at minimum (and thus will be compiling against at least the iOS 7.0 SDK).
    * As of [July 2014](https://developer.apple.com/support/appstore/), iOS 7 has an 90% adoption rate.

And, optionally:

* Sass/`.scss` support requires the [Sass command line tool](http://sass-lang.com/install) to be installed.


## What's Included?
Amaro aims to set you up with all you need to write a beautiful, maintainable, well-tested app. All the default pods are optional; feel free to pick and choose as needed for your project (though you will probably want most of them).

### Foundation
* A well-chosen class prefix is enforced (or may be omitted entirely... [the times, they are a-changin'](http://inessential.com/2014/07/24/prefixes_considered_passe))
* A local git repository for the application is created (and committed to a few times through the initialization process).
* Sane `.gitignore` and `.gitattributes` files are included.
* A `Certificates` directory is included with a readme file about what to include so that other developers can test and release the app.
* Sensible defaults for build options, warnings, and the like.
    * Build configurations are split into xcconfig files for modularity and consistency. We're using [jspahrsummers/xcconfigs](https://github.com/jspahrsummers/xcconfigs) as our base.
    * There are separate staging, production, and distribution schemes by default. No more fiddling with variables here and there to switch your target environment.
* Automatic ways to easily distinguish between builds of the app:
    * Ad-hoc and development builds have their bundle id suffixed with ".adhoc" or ".dev" so that they can co-exist on devices with other builds.
    * Ad-hoc and development builds' icons are badged an 🅢 for staging environments and a 🅟 for production environments. The bundle names (but not the display names) are also changed to easily distinguish them in places where it may otherwise be difficult.
* The build number of the app is incremented on every ad-hoc and distribution build. This ensures that external distribution services can reliably distinguish builds, even if the version number itself doesn't change.
* [CocoaPods](http://cocoapods.org) are integrated from the get-go.
* A barebones settings bundle is included with an "Acknowledgements" section that includes licenses for all your pods. It's automatically updated after each `pod install`.

### Logging, Error Reporting, Testing
* [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack) is configured for logging. A [custom formatter](https://github.com/crushlovely/Sidecar/blob/master/Sidecar/CRLMethodLogFormatter.h) is used by default to include the class and method name in log messages.
* The [Crashlytics framework](http://crashlytics.com) is included, and tied into CocoaLumberjack via [CrashlyticsLumberjack](https://github.com/TechSmith/CrashlyticsLumberjack) so that high-importance log messages are sent to Crashlytics.
* [Aperitif](https://github.com/crushlovely/Aperitif), to check for updates of the app in [Installr](https://installrapp.com) and prompt the user to install them (in ad hoc builds only, obviously).
* [Specta](https://github.com/specta/specta), [Expecta](https://github.com/specta/expecta), and [OCMokito](https://github.com/jonreid/OCMockito) are included to allow for the creation of [Rspec](http://rspec.info)-like tests. Xcode integration for testing is fully configured; add your tests to the Specs target and hit Cmd+U.
* The test target automatically generates code coverage data that can be viewed with [Cover Story](https://code.google.com/p/coverstory/) or [gcov](http://gcc.gnu.org/onlinedocs/gcc/Gcov-Intro.html).

### Visuals
* [Pixate Freestyle](https://github.com/Pixate/pixate-freestyle-ios), for easy, centralized app styling via CSS.
    * SCSS files included in the project are automatically compiled at build-time, and only the resulting CSS is included in your app. This functionality requires that [Sass](http://sass-lang.com/install) be installed and available in your path (or in your default RVM configuration's path).

### Utility Belt
* [AFNetworking](https://github.com/AFNetworking/AFNetworking)
* [libextobjc](https://github.com/jspahrsummers/libextobjc)'s [scope](https://github.com/jspahrsummers/libextobjc/blob/master/extobjc/EXTScope.h) and [keypath checking](https://github.com/jspahrsummers/libextobjc/blob/master/extobjc/EXTKeyPathCoding.h) modules.
* [FormatterKit](https://github.com/mattt/FormatterKit), for all your string-formatting needs.
* [Asterism](https://github.com/robb/Asterism), a fast, simple and flexible library for manipulating collections.
* [Sidecar](https://github.com/crushlovely/Sidecar), Crush's homegrown library. Features commonly needed functionality, such as creating UIColors from hex, playing short sound effects, and performing blocks on the main thread.

### More...
Additionally, the Podfile notes a few optional libraries that you may find useful:

* [PromiseKit](https://github.com/mxcl/PromiseKit/blob/master/LICENSE), a promises/futures library similar to [Promises/A+](http://promises-aplus.github.io/promises-spec/), and related wrappers for core libraries.
* [Mantle](https://github.com/MantleFramework/Mantle), a project from the GitHub folks to make simpler, safer model classes.
* [SSKeychain](https://github.com/soffes/sskeychain), a friendly wrapper around the Keychain API.
* [DateTools](https://github.com/MatthewYork/DateTools), if you find yourself needing to do a lot of datetime math.
* [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs), to stub out responses from web services for testing or early in development.


## Maintaining the Spirit
Amaro will get you started on the right foot, but it's up to you not to mess it up! Here are some tips to stay in line with the spirit of the project.

Read up on the included and optional libraries. Most of them are very good at solving common problems, and you should become familiar with them. Ideally you should spend your time solving problems, not [solving problems around solving problems](http://www.chris-granger.com/2014/03/27/toward-a-better-programming/).

Here are some specific tips:

* Making a change to a build setting? Make it once in your project's `.xcconfig` file, so that it will propagate to all configurations.
* Adding an external library? If there's a podspec for it, bring it in via Cocoapods. If there's not, consider writing one and submitting it upstream. Use git submodules as a last resort; version and dependency management with them is a pain in the ass.
    * There should almost never be a reason to check in third-party projects wholesale. If you need to modify someone else's code, fork the repo and include the fork in your Podfile with a direct [`:git` reference](http://guides.cocoapods.org/syntax/podfile.html#pod).
* Use CocoaLumberjack's `DDLog` variants instead of `NSLog`. It's faster, provides more information, is more configurable, and understands log levels. All of that with the same familiar syntax. Retrain your fingers.
* Need to define different settings in staging and production? Check out the [ProjectName-Environment.h](CrushBootstrap/Other-Sources/CrushBootstrap-Environment.h) file in Other Sources. It defines macros to test the type of build that is currently taking place.
* Make friends with Pixate Freestyle. We've yet to have much experience with it in the real world, but it seems pretty damn amazing. Check out the [samples](https://github.com/Pixate/pixate-freestyle-ios/tree/master/samples) to see what I mean.


## License
The real content and value of Amaro is as a template; once you've created a new project with the initialization script, Amaro leaves barely a trace. So, in most cases, the only licenses you need to worry about are [those of the third-party software](#third-party-license-rundown) you've included. But anyway, should you want to deal with Amaro itself, it's MIT licensed:

Copyright (c) 2014 Crush & Lovely, LLC

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


## Third-Party License Rundown

As mentioned above, the bootstrap [automatically generates a settings section](https://github.com/CocoaPods/CocoaPods/wiki/Acknowledgements) containing license information for all your Cocoapods. If that's unacceptable for your purposes, here's the license information on the included and optional components:

* Pixate Freestyle: [Apache 2](https://github.com/Pixate/pixate-freestyle-ios/blob/master/LICENSE) -- **requires a copy of the license somewhere in the distribution**
* Crashlytics Framework: [Terms and Conditions](http://try.crashlytics.com/terms)
* CrashlyticsLumberjack: [BSD 3-Clause](https://github.com/TechSmith/CrashlyticsLumberjack/blob/master/LICENSE) -- see [this StackOverflow discussion](http://stackoverflow.com/a/670982) about the implications of this for iOS applications (short version: consensus seems to be "do what you will", but the official word is unclear).
* CocoaLumberjack: [standard BSD](https://github.com/CocoaLumberjack/CocoaLumberjack/blob/master/LICENSE.txt)
* AFNetworking: [MIT](https://github.com/AFNetworking/AFNetworking/blob/master/LICENSE)
* extobjc: [MIT](https://github.com/jspahrsummers/libextobjc/blob/master/LICENSE.md)
* FormatterKit: [MIT](https://github.com/mattt/FormatterKit/blob/master/LICENSE)
* Asterism: [MIT](https://github.com/mattt/FormatterKit/blob/master/LICENSE)
* PromiseKit: [MIT](https://github.com/mxcl/PromiseKit/blob/master/LICENSE)
* Mantle: [MIT](https://github.com/MantleFramework/Mantle)
* SSKeyChain: [MIT](https://github.com/soffes/sskeychain/blob/master/LICENSE)
* DateTools: [MIT](https://github.com/MatthewYork/DateTools/blob/master/LICENSE)
* Sidecar: [MIT](https://github.com/crushlovely/Sidecar/blob/master/LICENSE)
* Aperitif: [MIT](https://github.com/crushlovely/Aperitif/blob/master/LICENSE)


## Acknowledgements

The lovely [default icon](http://thenounproject.com/term/scotch/9025/) was created by Scott Lewis for The Noun Project. It is licensed under the [Creative Commons Attribution 3.0 license](http://creativecommons.org/licenses/by/3.0/us/).
