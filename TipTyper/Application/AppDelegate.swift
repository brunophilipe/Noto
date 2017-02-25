//
//  AppDelegate.swift
//  TipTyper
//
//  Created by Bruno Philipe on 14/1/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa
import CCNPreferencesWindowController

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
	let preferencesController = CCNPreferencesWindowController()
	
	func applicationDidFinishLaunching(_ aNotification: Notification)
	{
		// Insert code here to initialize your application
		makePreferencesController()
	}

	func applicationWillTerminate(_ aNotification: Notification)
	{
		// Insert code here to tear down your application
	}
	
	private func makePreferencesController()
	{
		preferencesController.centerToolbarItems = true
		
		var controllers: [NSViewController?] = [
			EditorPreferencesController.make()
		]
		
		controllers = controllers.filter({ return $0 != nil })
		
		preferencesController.setPreferencesViewControllers(controllers)
	}
}

extension AppDelegate
{
	@IBAction func showPreferences(_ sender: AnyObject)
	{
		preferencesController.showPreferencesWindow()
	}
}
