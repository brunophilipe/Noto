//
// Created by Bruno Philipe on 12/3/17.
// Copyright (c) 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

extension NSMenuItem
{
	static func itemForEditorTheme(_ theme: EditorTheme,
								   _ selectedItem: inout NSMenuItem?,
								   target: AnyObject,
								   _ selector: Selector) -> NSMenuItem
	{
		let pref = Preferences.instance
		let menuItem = NSMenuItem(title: theme.name,
								  action: selector,
								  keyEquivalent: "")

		menuItem.target = target
		menuItem.representedObject = theme

		if selectedItem == nil && theme.preferenceName == pref.editorThemeName
		{
			selectedItem = menuItem
		}

		return menuItem
	}
}