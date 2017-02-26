//
//  EditorPreferencesController.swift
//  TipTyper
//
//  Created by Bruno Philipe on 23/02/2017.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa
import CCNPreferencesWindowController

class EditorPreferencesController: NSViewController
{
	fileprivate var preferencesWindow: NSWindow? = nil

	@IBOutlet var chooseFontButton: NSButton!
	@IBOutlet var fontNameLabel: NSTextField!
	@IBOutlet var editorThemePopUpButton: NSPopUpButton!
	@IBOutlet var editorPreviewTextView: EditorView!

	@IBOutlet var editorTextColorWell: NSColorWell!
	@IBOutlet var editorBackgroundColorWell: NSColorWell!
	@IBOutlet var lineCounterTextColorWell: NSColorWell!
	@IBOutlet var lineCounterBackgroundColorWell: NSColorWell!

    override func viewDidLoad()
	{
        super.viewDidLoad()
        // Do view setup here.

		createObservers()
		updateFontPreview()
		updateThemeColors()
		updateThemesMenu()

		NSColorPanel.shared().showsAlpha = true
    }

	deinit
	{
		removeObservers()
	}

	private func createObservers()
	{
		let pref = Preferences.instance

		pref.addObserver(self, forKeyPath: "editorFont", options: .new, context: nil)
	}

	private func removeObservers()
	{
		let pref = Preferences.instance

		pref.removeObserver(self, forKeyPath: "editorFont")
	}

	override func observeValue(forKeyPath keyPath: String?,
	                           of object: Any?,
	                           change: [NSKeyValueChangeKey : Any]?,
	                           context: UnsafeMutableRawPointer?)
	{
		if object is Preferences
		{
			switch keyPath
			{
			case .some("editorFont"):
				updateFontPreview()

			default:
				break
			}
		}
	}

	// Editor Font

	@IBAction func didClickChooseFont(_ sender: Any)
	{
		if let window = preferencesWindow
		{
			let fontPanel = NSFontPanel.shared()
			fontPanel.setPanelFont(Preferences.instance.editorFont, isMultiple: false)

			fontPanel.makeKeyAndOrderFront(sender)

			window.makeFirstResponder(self)
		}
	}

	override var acceptsFirstResponder: Bool
	{
		return true
	}

	override func changeFont(_ sender: Any?)
	{
		if let fontManager = sender as? NSFontManager
		{
			let pref = Preferences.instance
			pref.editorFont = fontManager.convert(pref.editorFont)
		}
	}

	private func updateFontPreview()
	{
		let pref = Preferences.instance
		let editorFont = pref.editorFont

		editorPreviewTextView.font = editorFont
		fontNameLabel.stringValue = "\(editorFont.displayName ?? editorFont.fontName) \(Int(editorFont.pointSize))pt"
	}

	// Editor Theme

	private func updateThemeColors()
	{
		let theme = Preferences.instance.editorTheme

		editorTextColorWell.color = theme.editorForeground
		editorBackgroundColorWell.color = theme.editorBackground
		lineCounterTextColorWell.color = theme.lineCounterForeground
		lineCounterBackgroundColorWell.color = theme.lineCounterBackground
	}

	private func updateThemesMenu()
	{
		let menu = NSMenu()

		let themes = ConcreteEditorTheme.installedThemes()
		var selectedItem: NSMenuItem? = nil

		for theme in themes.native
		{
			menu.addItem(makeMenuItemForTheme(theme, &selectedItem))
		}

		if themes.user.count > 0
		{
			menu.addItem(NSMenuItem.separator())

			for theme in themes.user
			{
				menu.addItem(makeMenuItemForTheme(theme, &selectedItem))
			}
		}

		if selectedItem == nil
		{
			selectedItem = menu.items.first
		}

		editorThemePopUpButton.menu = menu
		editorThemePopUpButton.select(selectedItem)

		updateThemeColors()
	}

	private func makeMenuItemForTheme(_ theme: EditorTheme, _ selectedItem: inout NSMenuItem?) -> NSMenuItem
	{
		let pref = Preferences.instance
		let menuItem = NSMenuItem(title: theme.name,
		                          action: #selector(EditorPreferencesController.didChangeEditorTheme(_:)),
		                          keyEquivalent: "")

		menuItem.target = self
		menuItem.representedObject = theme

		if selectedItem == nil && theme.preferenceName == pref.editorThemeName
		{
			selectedItem = menuItem
		}

		return menuItem
	}

	@objc func didChangeEditorTheme(_ sender: NSMenuItem)
	{
		if let theme = sender.representedObject as? EditorTheme
		{
			(Preferences.instance.editorTheme as? ConcreteEditorTheme)?.willDeallocate = true
			Preferences.instance.editorTheme = theme
			Preferences.instance.editorThemeName =? theme.preferenceName
		}

		updateThemeColors()
	}

	@IBAction func didChangeColor(_ sender: NSColorWell)
	{
		var theme = Preferences.instance.editorTheme

		if theme is NativeEditorTheme || (theme is UserEditorTheme && !(theme as! UserEditorTheme).isCustomization)
		{
			theme = UserEditorTheme(customizingTheme: theme)
			(Preferences.instance.editorTheme as? ConcreteEditorTheme)?.willDeallocate = true
			Preferences.instance.editorTheme = theme
			Preferences.instance.editorThemeName =? theme.preferenceName

			updateThemesMenu()
		}

		let userTheme = theme as! UserEditorTheme

		switch sender.tag
		{
		case 1: // Editor text color
			userTheme.editorForeground = sender.color

		case 2: // Editor background color
			userTheme.editorBackground = sender.color

		case 3: // Line counter text color
			userTheme.lineCounterForeground = sender.color

		case 4: // Line counter background color
			userTheme.lineCounterBackground = sender.color

		default:
			break
		}
	}
}

protocol PreferencesController: CCNPreferencesWindowControllerProtocol
{
	static func make(preferencesWindow: NSWindow) -> PreferencesController?
}

extension EditorPreferencesController: PreferencesController, CCNPreferencesWindowControllerProtocol
{
	public func preferenceIdentifier() -> String!
	{
		return "editor"
	}
	
	func preferenceTitle() -> String!
	{
		return "Editor"
	}

	func preferenceIcon() -> NSImage!
	{
		return NSImage(named: NSImageNameFontPanel)
	}

	static func make(preferencesWindow window: NSWindow) -> PreferencesController?
	{
		let controller = EditorPreferencesController(nibName: "EditorPreferencesController", bundle: Bundle.main)
		controller?.preferencesWindow = window
		return controller
	}
}
