//
//  GeneralPreferencesController.swift
//  Noto
//
//  Created by Bruno Philipe on 24/3/17.
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

class GeneralPreferencesController: NSViewController
{
	@IBOutlet var buttonRequireDoubleEsc: NSButton!

	fileprivate var preferencesWindow: NSWindow? = nil

	var doubleEscToLeaveFullScreen: NSNumber
	{
		get { return NSNumber(booleanLiteral: Preferences.instance.doubleEscToLeaveFullScreen) }
		set { Preferences.instance.doubleEscToLeaveFullScreen = newValue.boolValue }
	}

	@IBAction func didClickResetPreferences(_ sender: Any)
	{
		willChangeValue(forKey: "doubleEscToLeaveFullScreen")

		Preferences.instance.resetToDefault()

		didChangeValue(forKey: "doubleEscToLeaveFullScreen")
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
		return NSImage(named: NSImage.Name.preferencesGeneral)
	}

	static func make(preferencesWindow window: NSWindow) -> PreferencesController?
	{
		let controller = GeneralPreferencesController(nibName: NSNib.Name(rawValue: "GeneralPreferencesController"), bundle: Bundle.main)
		controller.preferencesWindow = window
		return controller
	}
}
