//
//  HUDInfoBarController.swift
//  TipTyper
//
//  Created by Bruno Philipe on 5/3/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

class HUDInfoBarController: NSViewController, InfoBar
{
	@IBOutlet private var labelCharacters: NSTextField!
	@IBOutlet private var labelWords: NSTextField!
	@IBOutlet private var labelLines: NSTextField!
	@IBOutlet private var labelEncoding: NSTextField!

	override func viewDidLoad()
	{
		super.viewDidLoad()

		self.view.layer?.cornerRadius = 10
	}

	func setLinesCount(_: String)
	{

	}

	func setWordsCount(_: String)
	{

	}

	func setCharactersCount(_: String)
	{

	}

	func setEncoding(_: String)
	{

	}

	static func make() -> HUDInfoBarController
	{
		return HUDInfoBarController(nibName: "HUDInfoBarController", bundle: Bundle.main)!
	}
}
