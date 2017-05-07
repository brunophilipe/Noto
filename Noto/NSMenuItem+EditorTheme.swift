//
// Created by Bruno Philipe on 12/3/17.
// Copyright (c) 2017 Bruno Philipe. All rights reserved.
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

extension NSMenuItem
{
	static func itemForEditorTheme(_ theme: EditorTheme,
								   _ selectedItem: inout NSMenuItem?,
								   target: AnyObject,
								   _ selector: Selector,
								   selectedThemeName: String = Preferences.instance.editorThemeName) -> NSMenuItem
	{
		let menuItem = NSMenuItem(title: theme.name,
								  action: selector,
								  keyEquivalent: "")

		menuItem.target = target
		menuItem.representedObject = theme

		if selectedItem == nil && theme.preferenceName == selectedThemeName
		{
			selectedItem = menuItem
		}

		return menuItem
	}
}
