//
//  ThemePreferencesController.swift
//  Noto
//
//  Created by Bruno Philipe on 23/02/2017.
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
import CCNPreferencesWindowController

class ThemePreferencesController: NSViewController
{
	fileprivate var preferencesWindow: NSWindow? = nil

	@IBOutlet var renameThemePopover: NSPopover!
	@IBOutlet var renameThemeTextField: NSTextField!

	@IBOutlet var editorThemePopUpButton: NSPopUpButton!
	@IBOutlet var renameThemeButton: NSButton!
	@IBOutlet var deleteThemeButton: NSButton!
	@IBOutlet var shareThemeButton: NSButton!
	@IBOutlet var editorPreviewTextView: EditorView!

	@IBOutlet var editorTextColorWell: NSColorWell!
	@IBOutlet var editorBackgroundColorWell: NSColorWell!
	@IBOutlet var lineNumbersTextColorWell: NSColorWell!
	@IBOutlet var lineNumbersBackgroundColorWell: NSColorWell!

    override func viewDidLoad()
	{
        super.viewDidLoad()
        // Do view setup here.

		createObservers()
		updateFontPreview()
		updateFontPreviewColors()
		updateThemeColors()

		editorPreviewTextView.lineNumbersVisible = true

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
		pref.addObserver(self, forKeyPath: "editorThemeName", options: .new, context: nil)
	}

	private func removeObservers()
	{
		let pref = Preferences.instance

		pref.removeObserver(self, forKeyPath: "editorFont")
		pref.removeObserver(self, forKeyPath: "editorThemeName")
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

			case .some("editorThemeName"):
				updateFontPreviewColors()
				updateThemeColors()

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
		editorPreviewTextView.lineNumbersView?.textColor = theme.lineNumbersForeground
		editorPreviewTextView.lineNumbersView?.backgroundColor = theme.lineNumbersBackground
		editorPreviewTextView.needsDisplay = true
	}

	// Editor Theme

	private func updateThemeColors()
	{
		let theme = Preferences.instance.editorTheme

		editorTextColorWell.color = theme.editorForeground
		editorBackgroundColorWell.color = theme.editorBackground
		lineNumbersTextColorWell.color = theme.lineNumbersForeground
		lineNumbersBackgroundColorWell.color = theme.lineNumbersBackground
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

		menu.addItem(NSMenuItem.separator())

		let importThemeItem = NSMenuItem(title: "Import theme from file…",
		                                 action: #selector(ThemePreferencesController.didClickImportTheme(_:)),
		                                 keyEquivalent: "")
		importThemeItem.target = self
		menu.addItem(importThemeItem)

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

		let hideThemeButtons = !(selectedItem?.representedObject is UserEditorTheme)
		renameThemeButton.isHidden = hideThemeButtons
		deleteThemeButton.isHidden = hideThemeButtons
		shareThemeButton.isHidden = hideThemeButtons

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

		let hideThemeButtons = !(sender.representedObject is UserEditorTheme)
		renameThemeButton.isHidden = hideThemeButtons
		deleteThemeButton.isHidden = hideThemeButtons
		shareThemeButton.isHidden = hideThemeButtons

		updateThemeColors()
		updateFontPreviewColors()
		updateThemesMenu()
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

	@IBAction func didClickImportTheme(_ sender: NSMenuItem)
	{
		if let window = self.preferencesWindow
		{
			let panel = NSOpenPanel()
			panel.canChooseFiles = true
			panel.canChooseDirectories = false
			panel.prompt = "Import Theme"
			panel.message = "Choose a location from where to import the theme file:"
			panel.allowedFileTypes = ["plist"]
			panel.directoryURL = URL(fileURLWithPath: "~/Desktop")

			panel.beginSheetModal(for: window)
			{
				(result) in

				if result == NSFileHandlingPanelOKButton, let fileUrl = panel.url
				{
					if let theme = UserEditorTheme(fromFile: fileUrl)
					{
						theme.writeToFile(immediatelly: true)

						self.setNewPreferenceEditorTheme(theme: theme)
						self.updateThemesMenu()
					}
				}
			}
		}
	}

	@IBAction func didClickShareTheme(_ sender: Any)
	{
		if let window = self.preferencesWindow, let theme = Preferences.instance.editorTheme as? UserEditorTheme
		{
			let panel = NSSavePanel()
			panel.prompt = "Export Theme"
			panel.message = "Choose a location where to export the theme file:"
			panel.directoryURL = URL(fileURLWithPath: "~/Desktop")
			panel.nameFieldStringValue = "\(theme.name).plist"

			panel.beginSheetModal(for: window)
			{
				(result) in

				if result == NSFileHandlingPanelOKButton, let targetUrl = panel.url
				{
					theme.exportThemeTo(url: targetUrl)
				}
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
			userTheme.lineNumbersForeground = sender.color

		case 4: // Line counter background color
			userTheme.lineNumbersBackground = sender.color

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
