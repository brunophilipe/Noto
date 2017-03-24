//
//  GeneralPreferencesController.swift
//  TipTyper
//
//  Created by Bruno Philipe on 24/3/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa
import CCNPreferencesWindowController

class GeneralPreferencesController: NSViewController
{
	fileprivate var preferencesWindow: NSWindow? = nil

	var doubleEscToLeaveFullScreen: NSNumber
	{
		get { return NSNumber(booleanLiteral: Preferences.instance.doubleEscToLeaveFullScreen) }
		set { Preferences.instance.doubleEscToLeaveFullScreen = newValue.boolValue }
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

extension GeneralPreferencesController: PreferencesController, CCNPreferencesWindowControllerProtocol
{
	public func preferenceIdentifier() -> String!
	{
		return "general"
	}

	func preferenceTitle() -> String!
	{
		return "General"
	}

	func preferenceIcon() -> NSImage!
	{
		return NSImage(named: NSImageNamePreferencesGeneral)
	}

	static func make(preferencesWindow window: NSWindow) -> PreferencesController?
	{
		let controller = GeneralPreferencesController(nibName: "GeneralPreferencesController", bundle: Bundle.main)
		controller?.preferencesWindow = window
		return controller
	}
}
