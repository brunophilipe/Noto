//
//  EditorPreferencesController.swift
//  TipTyper
//
//  Created by Bruno Philipe on 23/02/2017.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa
import CCNPreferencesWindowController

class EditorPreferencesController: NSViewController
{
    override func viewDidLoad()
	{
        super.viewDidLoad()
        // Do view setup here.
    }
}

protocol PreferencesController: CCNPreferencesWindowControllerProtocol
{
	static func make() -> PreferencesController?
}

extension EditorPreferencesController: PreferencesController
{
	public func preferenceIdentifier() -> String!
	{
		return "editor"
	}
	
	func preferenceTitle() -> String!
	{
		return "Editor"
	}

	func preferenceIcon() -> NSImage!
	{
		return NSImage(named: NSImageNameFontPanel)
	}

	static func make() -> PreferencesController?
	{
		return EditorPreferencesController(nibName: "EditorPreferencesController", bundle: Bundle.main)
	}
}
