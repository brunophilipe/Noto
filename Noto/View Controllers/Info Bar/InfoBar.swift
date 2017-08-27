//
//  InfoBar.swift
//  Noto
//
//  Created by Bruno Philipe on 5/3/17.
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

protocol InfoBar: class
{
	func setLinesCount(_: String)
	func setWordsCount(_: String)
	func setCharactersCount(_: String)
	func setEncoding(_: String)

	var animatedViews: [NSView] { get }
}

internal extension InfoBar
{
	func makeCopyContextMenuForView(_ view: NSView) -> NSMenu
	{
		let menuItem = NSMenuItem(title: "Copy", action: #selector(DocumentWindow.copyDocumentStatToPasteboard(_:)), keyEquivalent: "")
		menuItem.target = (view.window as? DocumentWindow)
		menuItem.tag = view.tag

		let menu = NSMenu()
		menu.addItem(menuItem)

		return menu
	}

	func setIntermitentState(_ state: Bool)
	{
		let alpha: CGFloat = state ? 0.25 : 1.0

		for view in animatedViews
		{
			view.animator().alphaValue = alpha
		}
	}
}
