//
//  TRexAboutWindowController.swift
//  T-Rex
//
//  Created by David Ehlen on 24.07.15.
//  Copyright © 2015 David Ehlen. All rights reserved.
//

import Cocoa

public enum WindowState {
    case Collapsed
    case Expanded
}

@objc(TRexAboutWindowController)
open class TRexAboutWindowController : NSWindowController {
        
    @objc open var appName = ""
    open var appVersion = ""
    open var appCopyright = NSAttributedString()
    open var appCredits = NSAttributedString()
    open var appEULA = NSAttributedString()
    open var appURL : URL?
    open var textShown = NSAttributedString()
    open var windowState: WindowState = .Collapsed
    open var windowShouldHaveShadow = true
    
    @IBOutlet var infoView: NSView!
    @IBOutlet var textField: NSTextView!
    @IBOutlet var visitWebsiteButton: NSButton!
    @IBOutlet var EULAButton: NSButton!
    @IBOutlet var creditsButton: NSButton!
    @IBOutlet var versionLabel: NSTextField!
    
    override open func windowDidLoad() {
        super.windowDidLoad()
        self.setup()
    }
    
    private func setup() {
        self.infoView.wantsLayer = true
        self.infoView.layer?.cornerRadius = 10.0
        self.infoView.layer?.backgroundColor = NSColor.white.cgColor
        self.window?.backgroundColor = NSColor.white
        self.window?.hasShadow = self.windowShouldHaveShadow
        
        if self.appName.isEmpty {
            self.appName = valueFromInfoDict("CFBundleName") ?? ""
        }
        
        if self.appVersion.isEmpty {
            let version = valueFromInfoDict("CFBundleVersion") ?? ""
            let shortVersion = valueFromInfoDict("CFBundleShortVersionString") ?? ""
            self.appVersion = "Version \(shortVersion) (Build \(version))"
            versionLabel.stringValue = self.appVersion
        }
        
        if self.appCopyright.string.isEmpty {
            let font = NSFont(name: "HelveticaNeue", size: 11.0) ?? NSFont.systemFont(ofSize: 11.0)
            let color = floor(NSAppKitVersion.current.rawValue) <= Double((NSAppKitVersion.macOS10_9).rawValue) ? NSColor.lightGray : NSColor.tertiaryLabelColor
            let attribs:[ NSAttributedString.Key : Any] = [.foregroundColor : color,
                                                          .font : font]
            self.appCopyright = NSAttributedString(string: valueFromInfoDict("NSHumanReadableCopyright") ?? "", attributes:attribs)
        }
        
        if self.appCredits.string.isEmpty {
            guard let creditsRTF = Bundle.main.path(forResource: "Credits", ofType: "rtf") else {
                self.creditsButton.isHidden = true
                print("Credits not found in bundle. Hiding Credits Button.")
                return
            }
            guard let attributedAppCredits = NSAttributedString(path: creditsRTF, documentAttributes: nil) else {
                self.creditsButton.isHidden = true
                print("Could not create attributed string from credits. Hiding Credits Button.")
                return
            }
            self.appCredits = attributedAppCredits
        }
        
        if self.appEULA.string.isEmpty {
            guard let eulaRTF = Bundle.main.path(forResource: "EULA", ofType: "rtf") else {
                self.EULAButton.isHidden = true
                print("EULA not found in bundle. Hiding EULA Button.")
                return
            }
            guard let attributedEula = NSAttributedString(path: eulaRTF, documentAttributes: nil) else {
                self.EULAButton.isHidden = true
                print("Could not create attributed string from eula. Hiding EULA Button.")
                return
            }
            self.appEULA = attributedEula
        }
        
        self.textField.textStorage?.setAttributedString(self.appCopyright)
        self.creditsButton.title = "Credits"
        self.EULAButton.title = "EULA"
    }
    
    private func valueFromInfoDict(_ string:String) -> String? {
        guard let dictionary = Bundle.main.infoDictionary else {
            return nil
        }
        
        let result = dictionary[string] as? String
        return result
    }
    
    
    //Window Management
    private func changeWindowState(windowState: WindowState) {
        let amountToIncreaseHeight: CGFloat = windowState == .Collapsed ? 100 : -100
        var oldFrame:NSRect = self.window!.frame
        oldFrame.size.height += amountToIncreaseHeight
        oldFrame.origin.y -= amountToIncreaseHeight
        self.window!.setFrame(oldFrame,display:true, animate:true)
        self.windowState = windowState == .Collapsed ? .Expanded : .Collapsed
    }
    
//    @objc open func windowShouldClose(_ sender: AnyObject) -> Bool {
//        self.showCopyright(sender)
//        return true
//    }
    
//    override open func showWindow(_ sender: Any?) {
//        self.showWindow(sender)
//    }
    
    //Button Actions
    @IBAction func visitWebsite(_ sender: AnyObject) {
        guard let url = self.appURL else { return }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func showCredits(_ sender: AnyObject) {
        if(self.windowState == .Collapsed) {
            self.changeWindowState(windowState: .Collapsed)
        }
        self.textField.textStorage?.setAttributedString(self.appCredits)
    }
    
    @IBAction func showEULA(_ sender: AnyObject) {
        if(self.windowState == .Collapsed) {
            self.changeWindowState(windowState: .Collapsed)
        }
        self.textField.textStorage!.setAttributedString(self.appEULA)
    }
    
    @IBAction func showCopyright(_ sender: AnyObject) {
        if(self.windowState == .Expanded) {
            self.changeWindowState(windowState: .Expanded)
        }
        
        self.textField.textStorage?.setAttributedString(self.appCopyright)
    }
}
