# It's CrushBootstrap!
*(better name forthcoming)*

## What's this then?
We want to hit the ground running. Xcode and the iOS ecosystem don't make that easy. Enter CrushBootstrap. After running one simple command, you get a ready-to-build universal iOS application, [full of delights](#whats-included-).


## Gimme gimme
Change to your projects directory, run this line in your terminal, and follow the prompts:

```sh
(read -p 'GitHub username: ' GH_USER; read -sp 'Password: ' GH_PASS; bash -i <(curl -sSLu "$GH_USER:$GH_PASS" https://raw.github.com/crushlovely/CrushBootstrap/master/tiramisu.sh))
```

Of course, if you're wary of running random shell scripts (legit!), please read [tiramisu.sh](blob/master/tiramisu.sh). At a high level, the script creates a local git repository with CrushBootstrap as a remote named "bootstrap", tweaks filenames and contents as per your input, and grabs third-party code.

(Tiramisu is Italian for "pick me up". Bootstrap... pick me up... get it?!? 💃)


## Details and Requirements
The bootstrap assumes:

* You are using Xcode 5.
* You have the [CocoaPods gem](http://cocoapods.org/#install) installed.
* You are targetting iOS 7.0, at minimum (and thus will be compiling against at least the iOS 7.0 SDK).
    * If the client takes issue with this, point them [here](https://developer.apple.com/support/appstore/). As of March 2014, iOS 7 has an 85% adoption rate.

And, optionally:

* Sass/`.scss` support requires the [Sass command line tool](http://sass-lang.com/install) to be installed.


## What's Included?
CrushBootstrap aims to set you up with all you need to write a beautiful, maintainable, well-tested app.

### Foundation
* A well-chosen class prefix is enforced.
* A local git repository for the application is created (and committed to a few times through the initialization process).
* Sane `.gitignore` and `.gitattributes` files are included.
* A `Certificates` directory is included with a readme file about what to include so that other developers can test and release the app.
* Sensible defaults for build options, warnings, and the like.
    * Build configurations are split into xcconfig files for modularity and consistency. We're using [jspahrsummers/xcconfigs](https://github.com/jspahrsummers/xcconfigs) as our base.
* Automatic ways to easily distinguish between builds of the app:
    * Ad-hoc and development builds have their bundle id suffixed with ".adhoc" or ".dev" so that they can co-exist on devices with other builds.
    * Ad-hoc and development builds have their names suffixed with a beta or alpha symbol (and are badged with the same on the home screen) to easily distinguish them in places where it may otherwise be difficult.
* The build number of the app is incremented on every non-simulator, non-debug build. This ensures that external services (e.g. TestFlight) can reliably distinguish builds, even if the version number doesn't change.
* [CocoaPods](http://cocoapods.org) are integrated from the get-go.
* A barebones settings bundle is included with an "Acknowledgements" section that includes licenses for all your pods. It's automatically updated after each `pod install`.

### Logging, Error Reporting, Testing
* [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack) is configured for logging. A custom formatter is used by default to include the class and method name in log messages.
* The [Crashlytics framework](http://crashlytics.com) is included, and tied into CocoaLumberjack so that high-importance log messages are sent to Crashlytics.
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
* [Crush's homegrown library](https://github.com/crushlovely/CRLLib) with commonly needed functionality, such as creating UIColors from hex, playing short sound effects, and performing blocks on the main thread.

### More...
Additionally, the Podfile notes a few optional libraries that you may find useful:

* [OMPromises](https://github.com/b52/OMPromises), a promises/futures library modelled after [Promises/A+](http://promises-aplus.github.io/promises-spec/).
* [Mantle](https://github.com/MantleFramework/Mantle), a project from the GitHub folks to make simpler, safer model classes.
* [SSKeychain](https://github.com/soffes/sskeychain), a friendly wrapper around the Keychain API.
* [DateTools](https://github.com/MatthewYork/DateTools), if you find yourself needing to do a lot of datetime math.
* [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs), to stub out responses from web services for testing or early in development.


## Maintaining the Spirit
CrushBootstrap will get you started on the right foot, but it's up to you not to mess it up! Here are some tips to stay in line with the spirit of the project.

Read up on the included and optional libraries. Most of them are very good at solving common problems, and you should become familiar with them. Ideally you should spend your time solving problems, not [solving problems around solving problems](http://www.chris-granger.com/2014/03/27/toward-a-better-programming/).

Here are some specific tips:

* Making a change to a build setting? Make it once in your project's `.xcconfig` file, so that it will propagate to all configurations.
* Adding an external library? If there's a podspec for it, bring it in via Cocoapods. If there's not, consider writing one and submitting it upstream. Use git submodules as a last resort; version and dependency management with them is a pain in the ass.
    * There should almost never be a reason to check in third-party projects wholesale. If you need to modify someone else's code, fork the repo and include the fork in your Podfile with a direct [`:git` reference](http://guides.cocoapods.org/syntax/podfile.html#pod).
* Use CocoaLumberjack's `DDLog` variants instead of `NSLog`. It's faster, provides more information, is more configurable, and understands log levels. All of that with the same familiar syntax. Retrain your fingers.
* Make friends with Pixate Freestyle. We've yet to have much experience with it in the real world, but it seems pretty damn amazing. Check out the [samples](https://github.com/Pixate/pixate-freestyle-ios/tree/master/samples) to see what I mean.

And finally, **check out our [Programming Conventions](https://github.com/crushlovely/programming-conventions/wiki)**.


## License Rundown

As mentioned above, the bootstrap [automatically generates a settings section](https://github.com/CocoaPods/CocoaPods/wiki/Acknowledgements) containing license information for all your Cocoapods. If that's unacceptable for your purposes, here's the license information on the included and optional components:

* Pixate Freestyle: [Apache 2](https://github.com/Pixate/pixate-freestyle-ios/blob/master/LICENSE) -- **requires a copy of the license somewhere in the distribution**
* Crashlytics Framework: [Terms and Conditions](http://try.crashlytics.com/terms)
* CrashlyticsLumberjack: [BSD 3-Clause](http://www.opensource.org/licenses/BSD-3-Clause) -- see [this StackOverflow discussion](http://stackoverflow.com/a/670982) about the implications of this for iOS applications (short version: consensus seems to be "do what you will", but the official word is unclear).
* CocoaLumberjack: [standard BSD](https://github.com/CocoaLumberjack/CocoaLumberjack/blob/master/LICENSE.txt)
* AFNetworking: [MIT](https://github.com/AFNetworking/AFNetworking/blob/master/LICENSE)
* extobjc: [MIT](https://github.com/jspahrsummers/libextobjc/blob/master/LICENSE.md)
* FormatterKit: [MIT](https://github.com/mattt/FormatterKit/blob/master/LICENSE)
* Asterism: [MIT](https://github.com/mattt/FormatterKit/blob/master/LICENSE)
* OMPromises: [MIT](https://github.com/b52/OMPromises/blob/master/LICENSE)
* Mantle: [MIT](https://github.com/MantleFramework/Mantle)
* SSKeyChain: [MIT](https://github.com/soffes/sskeychain/blob/master/LICENSE)
* DateTools: [MIT](https://github.com/MatthewYork/DateTools/blob/master/LICENSE)