//
//  StatusInfoBarController.swift
//  Noto
//
//  Created by Bruno Philipe on 10/3/17.
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

class StatusInfoBarController: NSViewController, InfoBar
{
	@IBOutlet private var labelCharacters: NSTextField!
	@IBOutlet private var labelWords: NSTextField!
	@IBOutlet private var labelLines: NSTextField!
	@IBOutlet private var labelEncoding: NSTextField!

    override func viewDidLoad()
	{
        super.viewDidLoad()
        // Do view setup here.

		labelCharacters.menu = makeCopyContextMenuForView(labelCharacters)
		labelWords.menu = makeCopyContextMenuForView(labelWords)
		labelLines.menu = makeCopyContextMenuForView(labelLines)
    }

	func setTextColor(_ color: NSColor)
	{
		labelCharacters.textColor = color
		labelWords.textColor = color
		labelLines.textColor = color
		labelEncoding.textColor = color
	}

	func setBackgroundColor(_ color: NSColor)
	{
		self.view.layer?.backgroundColor = color.cgColor
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

	static func make() -> StatusInfoBarController
	{
		return StatusInfoBarController(nibName: "StatusInfoBarController", bundle: Bundle.main)!
	}
}
