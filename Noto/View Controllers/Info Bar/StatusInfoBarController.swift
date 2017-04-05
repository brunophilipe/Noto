//
//  StatusInfoBarController.swift
//  Noto
//
//  Created by Bruno Philipe on 10/3/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
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
