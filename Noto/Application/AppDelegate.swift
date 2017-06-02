//
//  AppDelegate.swift
//  Noto
//
//  Created by Bruno Philipe on 14/1/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//  
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Cocoa
import CCNPreferencesWindowController
import TRexAboutWindowController

#if SPARKLE
import Sparkle
#endif

let kNotoErrorDomain = "com.brunophilipe.Noto"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
	fileprivate let preferencesController = CCNPreferencesWindowController()
	fileprivate let aboutWindowController = TRexAboutWindowController(windowNibName: "PFAboutWindow")

	@IBOutlet weak var disabledInfoBarMenuItem: NSMenuItem!
	@IBOutlet weak var hudInfoBarMenuItem: NSMenuItem!
	@IBOutlet weak var statusBarInfoBarMenuItem: NSMenuItem!

	// Cocoa Bindings

	var keyDocumentCanReopen: NSNumber
	{
		return NSNumber.init(value: NSDocumentController.shared().currentDocument?.fileURL != nil)
	}

	var hasUpdaterFeature: NSNumber
	{
		#if SPARKLE
		return true
		#else
		return false
		#endif
	}

	// App Delegate
	
	func applicationDidFinishLaunching(_ aNotification: Notification)
	{
		// Insert code here to initialize your application
		makePreferencesController()
		makeAboutWindow()

		updateInfoBarModeMenuItems()

		Preferences.instance.addObserver(self, forKeyPath: "infoBarMode", options: .new, context: nil)
	}

	func applicationWillTerminate(_ aNotification: Notification)
	{
		// Insert code here to tear down your application
		Preferences.instance.removeObserver(self, forKeyPath: "infoBarMode")
	}

	override func observeValue(forKeyPath keyPath: String?,
							   of object: Any?,
							   change: [NSKeyValueChangeKey: Any]?,
							   context: UnsafeMutableRawPointer?)
	{
		if object is Preferences && keyPath == "infoBarMode"
		{
			updateInfoBarModeMenuItems()
		}
	}

	func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool
	{
		if FileManager.default.ubiquityIdentityToken != nil
		{
			// Show open panel instead of building a new file right away.
			let panel = NSOpenPanel()
			panel.makeKeyAndOrderFront(self)

			return false
		}
		else
		{
			return true
		}
	}

	// Private Methods

	private func updateInfoBarModeMenuItems()
	{
		let mode = Preferences.instance.infoBarMode

		disabledInfoBarMenuItem.state	= (mode == .none ? 1 : 0)
		hudInfoBarMenuItem.state		= (mode == .hud ? 1 : 0)
		statusBarInfoBarMenuItem.state	= (mode == .status ? 1 : 0)
	}

	private func makeAboutWindow()
	{
		let bundle = Bundle.main

		aboutWindowController.appURL = URL(string: "https://www.brunophilipe.com/software/noto")!
		aboutWindowController.appName = (bundle.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? "Noto"

		if let creditsHtmlUrl = bundle.url(forResource: "acknowledgements", withExtension: "html"),
		   let creditsHtmlData: Data = try? Data(contentsOf: creditsHtmlUrl),
		   let creditsHtmlString = NSAttributedString(html: creditsHtmlData, options: [:], documentAttributes: nil)
		{
			aboutWindowController.appCredits = creditsHtmlString
		}

		let font: NSFont = NSFont(name: "HelveticaNeue", size: 11) ?? NSFont.systemFont(ofSize: 11)
		let color: NSColor = NSColor.tertiaryLabelColor
		let copyright = (bundle.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String) ?? "Copyright © 2017 Bruno Philipe. All rights reserved."
		let attribs: [String : AnyObject] = [NSForegroundColorAttributeName: color, NSFontAttributeName:font]

		aboutWindowController.appCopyright = NSAttributedString(string: copyright, attributes: attribs)
		aboutWindowController.windowShouldHaveShadow = true
	}

	private func makePreferencesController()
	{
		preferencesController.centerToolbarItems = true
		
		let types: [PreferencesController.Type] = [
			GeneralPreferencesController.self,
			EditorPreferencesViewController.self,
			ThemePreferencesController.self
		]

		if let window = preferencesController.window
		{
			let controllers: [PreferencesController] = types.reduce([])
			{
				(controllers, controllerType) -> [PreferencesController] in

				if let controller = controllerType.make(preferencesWindow: window)
				{
					return controllers + [controller]
				}
				else
				{
					return controllers
				}
			}

			preferencesController.setPreferencesViewControllers(controllers)
		}
	}
}

extension AppDelegate
{
	@IBAction func showPreferences(_ sender: AnyObject)
	{
		preferencesController.showPreferencesWindow()
	}

	@IBAction func setInfoBarMode(_ sender: AnyObject)
	{
		if let menuItem = sender as? NSMenuItem,
		   let mode = Preferences.InfoBarMode(rawValue: menuItem.tag)
		{
			Preferences.instance.infoBarMode = mode
		}
	}

	@IBAction func showAboutWindow(_ sender: Any)
	{
		aboutWindowController.showWindow(sender)
	}

	@IBAction func checkForUpdates(_ sender: Any)
	{
		#if SPARKLE
		SUUpdater.shared().checkForUpdates(sender)
		#endif
	}
}
