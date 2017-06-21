![CocoaPod version](https://img.shields.io/cocoapods/v/CCNPreferencesWindowController.svg?style=flat)
![Travis CI build status](https://travis-ci.org/phranck/CCNPreferencesWindowController.svg?branch=develop)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

### Overview

`CCNPreferencesWindowController` is an Objective-C subclass of `NSWindowController` that automatically manages your custom view controllers for handling app preferences. 

Here is a shot of the included example application:

![CCNPreferencesWindowController Example Application](https://cocoanaut.com/files/webImages/github/CCNPreferencesWindowController.gif)


### CocoaPods

You can add `CCNPreferencesWindowController` by using CocoaPods. Just add this line to your Podfile:

```
pod 'CCNPreferencesWindowController'
```

### Carthage

Add `CCNPreferencesWindowController` to your Cartfile to have it installed by Carthage.

```
github "phranck/CCNPreferencesWindowController" >= 1.4.3
```

Build it by running the command `carthage update`, then drag `CCNPreferencesWindowController.framework` into your Xcode project.


### Usage

```Objective-C
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // init the preferences window controller
    self.preferences = [CCNPreferencesWindowController new];
    self.preferences.centerToolbarItems = YES;	// or NO

    // setup all preference view controllers
    [self.preferences setPreferencesViewControllers:@[
        [PreferencesGeneralViewController new],
        [PreferencesNetworkViewController new],
        [PreferencesBonjourViewController new]
    ]];
}

- (IBAction)showPreferencesWindow:(id)sender {
    [self.preferences showPreferencesWindow];
}

```

That's all.


### Requirements

`CCNPreferencesWindowController` was written using ARC and "modern" Objective-C 2. At the moment it has only support for OS X 10.10 Yosemite. OS X 10.9 Mavericks should work too, but it's untested yet.


### Contribution

The code is provided as-is, and it is far from being complete or free of bugs. If you like this component feel free to support it. Make changes related to your needs, extend it or just use it in your own project. Pull-Requests and Feedbacks are very welcome. Just contact me at [phranck@cocoanaut.com](mailto:phranck@cocoanaut.com?Subject=CCNPreferencesWindowController) or send me a ping on Twitter [@TheCocoaNaut](http://twitter.com/TheCocoaNaut). 


### Documentation
The complete documentation you will find on [CocoaDocs](http://cocoadocs.org/docsets/CCNPreferencesWindowController/).


### License
This software is published under the [MIT License](http://cocoanaut.mit-license.org).


### Software that uses CCNPreferencesWindowController

* [Review Times](http://reviewtimes.cocoanaut.com) - A small Mac tool that shows you the calculated average of the review times for both the Mac App Store and the iOS App Store
* [WhatRoute](https://www.whatroute.net) - WhatRoute is a network diagnostic utility designed for Apple Macintosh computers. Primarily it provides a Traceroute function, but can also perform Ping, Domain Name Service queries, Whois queries and monitor the traffic to and from your computer.
