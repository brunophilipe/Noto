//
//  HUDInfoBarController.swift
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

class HUDInfoBarController: NSViewController, InfoBar
{
	@IBOutlet private var labelCharacters: NSTextField!
	@IBOutlet private var labelWords: NSTextField!
	@IBOutlet private var labelLines: NSTextField!
	@IBOutlet private var labelEncoding: NSTextField!

	var animatedViews: [NSView]
	{
		return [labelCharacters, labelWords, labelLines]
	}

	override func viewDidLoad()
	{
		super.viewDidLoad()

		self.view.layer?.cornerRadius = 10

		labelCharacters.menu = makeCopyContextMenuForView(labelCharacters)
		labelWords.menu = makeCopyContextMenuForView(labelWords)
		labelLines.menu = makeCopyContextMenuForView(labelLines)
	}

	func setDarkMode(_ isDark: Bool)
	{
		let textColor = isDark ? NSColor.white : NSColor.black

		labelCharacters.textColor = textColor
		labelWords.textColor = textColor
		labelLines.textColor = textColor
		labelEncoding.textColor = textColor

		let backgroundColor = isDark ? NSColor.darkGray : NSColor.white

		self.view.layer?.backgroundColor = backgroundColor.withAlphaComponent(0.45).cgColor
	}

	func setLinesCount(_ string: String)
	{
		labelLines.stringValue = string
	}

	func setWordsCount(_ string: String)
	{
		labelWords.stringValue = string
	}

	func setCharactersCount(_ string: String)
	{
		labelCharacters.stringValue = string
	}

	func setEncoding(_ string: String)
	{
		labelEncoding.stringValue = string
	}

	static func make() -> HUDInfoBarController
	{
		return HUDInfoBarController(nibName: NSNib.Name(rawValue: "HUDInfoBarController"), bundle: Bundle.main)
	}
}
