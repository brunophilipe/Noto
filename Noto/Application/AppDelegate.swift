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

let kNotoErrorDomain = "com.brunophilipe.Noto"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
	let preferencesController = CCNPreferencesWindowController()

	@IBOutlet weak var disabledInfoBarMenuItem: NSMenuItem!
	@IBOutlet weak var hudInfoBarMenuItem: NSMenuItem!
	@IBOutlet weak var statusBarInfoBarMenuItem: NSMenuItem!

	// Cocoa Bindings

	var keyDocumentCanReopen: NSNumber
	{
		return NSNumber.init(value: NSDocumentController.shared().currentDocument?.fileURL != nil)
	}

	// App Delegate
	
	func applicationDidFinishLaunching(_ aNotification: Notification)
	{
		// Insert code here to initialize your application
		makePreferencesController()

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

	// Private Methods

	private func updateInfoBarModeMenuItems()
	{
		let mode = Preferences.instance.infoBarMode

		disabledInfoBarMenuItem.state	= (mode == .none ? 1 : 0)
		hudInfoBarMenuItem.state		= (mode == .hud ? 1 : 0)
		statusBarInfoBarMenuItem.state	= (mode == .status ? 1 : 0)
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
}
