# TRexAboutWindowController
Swift clone of PFAboutWindow

### PFAboutWindow
[PFAboutWindow](https://github.com/perfaram/PFAboutWindow) is a Objective-C-Only library which provides a pretty designed About-Window for your application. Is is super easy to show credits, eula and copyright information in a great looking window which is oriented on Xcode6's About-Window design.

### Purpose
Since there was no Swift version of this library I thought I'd convert it by myself. You can find a Swift clone of PFAboutWindow in this repository. Also the .xib file was migrated to use AutoLayout. Everything is supported except for localizing the Buttons. If you need to localize the buttons you have to add it by yourself by creating a Localizable.strings file. Feel free to add it on your own and create a pull request !

### Version
1.5.2

### Screenshots
Before you download/install the application you can get a little sneak peek by looking at this screenshots:

![alt tag](https://raw.github.com/dehlen/TRexAboutWindowController/master/screenshot1.png)

![alt tag](https://raw.github.com/dehlen/TRexAboutWindowController/master/screenshot2.png)

### Installation/Usage

This library can be installed via Cocoapods:

```
pod 'TRexAboutWindowController'
```

Then just add it to your project like so:

```swift
import TRexAboutWindowController

var aboutWindowController:TRexAboutWindowController

override init() {
        self.aboutWindowController = TRexAboutWindowController(windowNibName: "PFAboutWindow")
        super.init()
}

@IBAction func showAboutWindow(sender:AnyObject) {
        self.aboutWindowController.appURL = NSURL(string:"https://github.com/T-Rex-Editor/")!
        self.aboutWindowController.appName = "TRex-Editor"
        let font:NSFont? = NSFont(name: "HelveticaNeue", size: 11.0)
        let color:NSColor? = NSColor.tertiaryLabelColor()
        let attribs:[String:AnyObject] = [NSForegroundColorAttributeName:color!,
            NSFontAttributeName:font!]
        
        self.aboutWindowController.appCopyright = NSAttributedString(string: "Copyright (c) 2015 David Ehlen", attributes: attribs)
        
        self.aboutWindowController.windowShouldHaveShadow = true
        self.aboutWindowController .showWindow(nil)
    }

```

Then connect the IBAction `showAboutWindow` with the About menu entry or some button you want.
You can also have a look at the Demo project to get an idea of how to integrate this library into your project.

[Demo Project](https://github.com/dehlen/TRexAboutWindowControllerDemo)

### Development

Want to contribute? Great!
You might want to check out the open issues or fork this repository to create a pull request. I'd love to see something like that.

### Todo's
- None yet, If you have a Todo please create an issue

### License
----

The MIT License (MIT)

Copyright (c) 2015 David Ehlen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

**Free Software, Hell Yeah!**
