//
//  ThemePreferencesController.swift
//  TipTyper
//
//  Created by Bruno Philipe on 23/02/2017.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa
import CCNPreferencesWindowController

class ThemePreferencesController: NSViewController
{
	fileprivate var preferencesWindow: NSWindow? = nil

	@IBOutlet var renameThemePopover: NSPopover!
	@IBOutlet var renameThemeTextField: NSTextField!

	@IBOutlet var editorThemePopUpButton: NSPopUpButton!
	@IBOutlet var renameThemeButton: NSButton!
	@IBOutlet var deleteThemeButton: NSButton!
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
		updateFontPreviewColors()
		updateThemeColors()

		NSColorPanel.shared().showsAlpha = false
    }

	deinit
	{
		removeObservers()
	}

	override func viewWillAppear()
	{
		super.viewWillAppear()

		updateThemesMenu()
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
	}

	private func updateFontPreviewColors()
	{
		let theme = Preferences.instance.editorTheme

		editorPreviewTextView.textColor = theme.editorForeground
		editorPreviewTextView.backgroundColor = theme.editorBackground
		editorPreviewTextView.lineCounterView?.textColor = theme.lineCounterForeground
		editorPreviewTextView.lineCounterView?.backgroundColor = theme.lineCounterBackground
		editorPreviewTextView.needsDisplay = true
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
			menu.addItem(NSMenuItem.itemForEditorTheme(theme,
													   &selectedItem,
													   target: self,
													   #selector(ThemePreferencesController.didChangeEditorTheme(_:))))
		}

		if themes.user.count > 0
		{
			menu.addItem(NSMenuItem.separator())

			for theme in themes.user
			{
				menu.addItem(NSMenuItem.itemForEditorTheme(theme,
														   &selectedItem,
														   target: self,
														   #selector(ThemePreferencesController.didChangeEditorTheme(_:))))
			}
		}

		if selectedItem == nil
		{
			let theme = Preferences.instance.editorTheme

			if let userTheme = theme as? UserEditorTheme
			{
				menu.addItem(NSMenuItem.itemForEditorTheme(userTheme,
														   &selectedItem,
														   target: self,
														   #selector(ThemePreferencesController.didChangeEditorTheme(_:))))
				userTheme.writeToFile(immediatelly: true)
			}
			else
			{
				selectedItem = menu.items.first
			}
		}

		editorThemePopUpButton.menu = menu
		editorThemePopUpButton.select(selectedItem)

		renameThemeButton.isHidden = !(selectedItem?.representedObject is UserEditorTheme)
		deleteThemeButton.isHidden = !(selectedItem?.representedObject is UserEditorTheme)

		updateThemeColors()
	}

	private func setRenameThemeTextFieldState(error: String?)
	{
		if let errorMessage = error
		{
			renameThemeTextField.backgroundColor = NSColor(rgb: 0xFFEEEE)
			renameThemeTextField.textColor = NSColor(rgb: 0xFF2222)

			showErrorAlert(errorMessage: "Error renaming theme: \(errorMessage)")
			{
				() in
				self.renameThemePopover.close()
			}
		}
		else
		{
			renameThemeTextField.backgroundColor = NSColor.white
			renameThemeTextField.textColor = NSColor.black
		}
	}

	private func showErrorAlert(errorMessage: String, callback: ((Void) -> Void)? = nil)
	{
		let alert = NSAlert()
		alert.messageText = "Error"
		alert.informativeText = errorMessage
		alert.addButton(withTitle: "OK")

		alert.runModal()

		callback?()
	}

	private func setNewPreferenceEditorTheme(theme: EditorTheme)
	{
		let pref = Preferences.instance

		(pref.editorTheme as? ConcreteEditorTheme)?.willDeallocate = true
		pref.editorTheme = theme
		pref.editorThemeName =? theme.preferenceName
	}

	@objc func didChangeEditorTheme(_ sender: NSMenuItem)
	{
		if let theme = sender.representedObject as? EditorTheme
		{
			setNewPreferenceEditorTheme(theme: theme)
		}

		renameThemeButton.isHidden = !(sender.representedObject is UserEditorTheme)
		deleteThemeButton.isHidden = !(sender.representedObject is UserEditorTheme)

		updateThemeColors()
		updateFontPreviewColors()
	}

	@IBAction func didClickRenameTheme(_ sender: NSButton)
	{
		let theme = Preferences.instance.editorTheme

		if theme is UserEditorTheme
		{
			renameThemeTextField.stringValue = theme.name
			renameThemeTextField.selectText(sender)

			renameThemePopover.show(relativeTo: editorThemePopUpButton.bounds, of: editorThemePopUpButton, preferredEdge: .maxX)
		}
	}

	@IBAction func didClickDeleteTheme(_ sender: NSButton)
	{
		let theme = Preferences.instance.editorTheme

		if let userTheme = theme as? UserEditorTheme
		{
			if userTheme.deleteTheme()
			{
				setNewPreferenceEditorTheme(theme: LightEditorTheme())
				updateThemesMenu()
				updateFontPreviewColors()
			}
			else
			{
				showErrorAlert(errorMessage: "Error renaming theme: Could not delete theme file!")
			}
		}
	}

	@IBAction func didClickCommitNewThemeName(_ sender: Any)
	{
		if let theme = Preferences.instance.editorTheme as? UserEditorTheme
		{
			let newName = renameThemeTextField.stringValue

			if newName == ""
			{
				setRenameThemeTextFieldState(error: "Theme name can't be empty!")
			}
			else
			{
				if newName != theme.name
				{
					if !theme.renameTheme(newName: newName)
					{
						setRenameThemeTextFieldState(error: "Could not rename theme file...")
					}
					else
					{
						setRenameThemeTextFieldState(error: nil)
						setNewPreferenceEditorTheme(theme: theme)
						updateThemesMenu()
					}
				}
				else
				{
					setRenameThemeTextFieldState(error: nil)
				}

				renameThemePopover.close()
			}
		}
	}

	@IBAction func didChangeColor(_ sender: NSColorWell)
	{
		var theme = Preferences.instance.editorTheme

		if theme is NativeEditorTheme || (theme is UserEditorTheme && !(theme as! UserEditorTheme).isCustomization)
		{
			theme = UserEditorTheme(customizingTheme: theme)

			setNewPreferenceEditorTheme(theme: theme)
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

		updateFontPreviewColors()
	}
}

extension ThemePreferencesController: PreferencesController, CCNPreferencesWindowControllerProtocol
{
	public func preferenceIdentifier() -> String!
	{
		return "theme"
	}
	
	func preferenceTitle() -> String!
	{
		return "Theme"
	}

	func preferenceIcon() -> NSImage!
	{
		return NSImage(named: NSImageNameColorPanel)
	}

	static func make(preferencesWindow window: NSWindow) -> PreferencesController?
	{
		let controller = ThemePreferencesController(nibName: "ThemePreferencesController", bundle: Bundle.main)
		controller?.preferencesWindow = window
		return controller
	}
}
