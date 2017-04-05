//
//  PrintAccessoryViewController.swift
//  Noto
//
//  Created by Bruno Philipe on 12/3/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

class PrintAccessoryViewController: NSViewController
{
	@IBOutlet fileprivate var checkboxRewrapContents: NSButton!
	@IBOutlet fileprivate var checkboxShowFilename: NSButton!
	@IBOutlet fileprivate var checkboxShowDate: NSButton!
	@IBOutlet fileprivate var checkboxShowPageNumber: NSButton!
	@IBOutlet fileprivate var checkboxShowLineNumbers: NSButton!
	@IBOutlet fileprivate var radioButtonNoTheme: NSButton!
	@IBOutlet fileprivate var radioButtonUseTheme: NSButton!
	@IBOutlet fileprivate var popUpButtonThemes: NSPopUpButton!

	dynamic var rewrapContents: NSNumber
	{
		get { return NSNumber(booleanLiteral: Preferences.instance.printWrapContents) }
		set { Preferences.instance.printWrapContents = newValue.boolValue }
	}

	dynamic var showFileName: NSNumber
	{
		get { return NSNumber(booleanLiteral: Preferences.instance.printShowFileName) }
		set { Preferences.instance.printShowFileName = newValue.boolValue }
	}

	dynamic var showDate: NSNumber
	{
		get { return NSNumber(booleanLiteral: Preferences.instance.printShowDate) }
		set { Preferences.instance.printShowDate = newValue.boolValue }
	}

	dynamic var showPageNumber: NSNumber
	{
		get { return NSNumber(booleanLiteral: Preferences.instance.printShowPageNumber) }
		set { Preferences.instance.printShowPageNumber = newValue.boolValue }
	}

	dynamic var showLineNumbers: NSNumber
	{
		get { return NSNumber(booleanLiteral: Preferences.instance.printHideLineNumbers) }
		set { Preferences.instance.printHideLineNumbers = newValue.boolValue }
	}

	fileprivate let observedProperties = [
		"rewrapContents",
		"showFileName",
		"showDate",
		"showPageNumber",
		"showLineNumbers"
	]

	override func awakeFromNib()
	{
		title = "Noto"
	}

    override func viewDidLoad()
	{
        super.viewDidLoad()
        // Do view setup here.

		updateThemesMenu()
    }

	override var representedObject: Any?
	{
		didSet
		{
			for observedProperty in observedProperties
			{
				addObserver(self, forKeyPath: observedProperty, context: nil)
			}
		}
	}

	deinit
	{
		if representedObject != nil
		{
			for observedProperty in observedProperties
			{
				removeObserver(self, forKeyPath: observedProperty)
			}
		}
	}

	override func observeValue(forKeyPath keyPath: String?,
							   of object: Any?,
							   change: [NSKeyValueChangeKey : Any]?,
							   context: UnsafeMutableRawPointer?)
	{

	}

	private func updateThemesMenu()
	{
		let menu = NSMenu()

		let themes = ConcreteEditorTheme.installedThemes()
		var selectedItem: NSMenuItem? = nil

		for theme in themes.native
		{
			menu.addItem(NSMenuItem.itemForEditorTheme(theme,
													   &selectedItem,
													   target: self,
													   #selector(PrintAccessoryViewController.didChangeEditorTheme(_:))))
		}

		if themes.user.count > 0
		{
			menu.addItem(NSMenuItem.separator())

			for theme in themes.user
			{
				menu.addItem(NSMenuItem.itemForEditorTheme(theme,
														   &selectedItem,
														   target: self,
														   #selector(PrintAccessoryViewController.didChangeEditorTheme(_:))))
			}
		}

		if selectedItem == nil
		{
			selectedItem = menu.items.first
		}

		popUpButtonThemes.menu = menu
		popUpButtonThemes.select(selectedItem)
	}
}

extension PrintAccessoryViewController // IBActions
{
	@IBAction func didClickRadioButton(_ sender: NSButton)
	{
		switch sender.tag
		{
		case 1:
			popUpButtonThemes.isEnabled = false

		case 2:
			popUpButtonThemes.isEnabled = true

		default:
			break
		}
	}

	@IBAction func didChangeEditorTheme(_ sender: NSMenuItem?)
	{

	}
}

extension PrintAccessoryViewController // Maker
{
	static func make() -> PrintAccessoryViewController
	{
		return PrintAccessoryViewController(nibName: "PrintAccessoryViewController", bundle: Bundle.main)!
	}
}

extension PrintAccessoryViewController: NSPrintPanelAccessorizing
{
	func localizedSummaryItems() -> [[String : String]]
	{
		return [[String : String]]()
	}

	func keyPathsForValuesAffectingPreview() -> Set<String>
	{
		return Set(observedProperties)
	}
}
