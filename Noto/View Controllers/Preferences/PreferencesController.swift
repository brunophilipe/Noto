//
//  PreferencesController.swift
//  Noto
//
//  Created by Bruno Philipe on 28/02/2017.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa
import CCNPreferencesWindowController

protocol PreferencesController: CCNPreferencesWindowControllerProtocol
{
	static func make(preferencesWindow: NSWindow) -> PreferencesController?
}
