//
//  DocumentWindow.swift
//  Noto
//
//  Created by Bruno Philipe on 21/2/17.
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

@IBDesignable
class DocumentWindow: NSWindow
{
	fileprivate var infoBarController: InfoBar? = nil

	private var infoBarConstraints: [NSLayoutConstraint]? = nil
	private var defaultTopThemeConstraint: NSLayoutConstraint? = nil
	private var customTopThemeConstraint: NSLayoutConstraint? = nil
	private var titleDragHandleView: WindowDragHandleView!

	@IBOutlet var textView: EditorView!
	@IBOutlet var textEditorBottomConstraint: NSLayoutConstraint!
	@IBOutlet var titleBarSeparatorView: BackgroundView!
	@IBOutlet var textEditorTopConstraint: NSLayoutConstraint!

	fileprivate var characterCount: Int = 0
	{
		didSet
		{
			infoBarController?.setCharactersCount("\(characterCount) Character\(characterCount == 1 ? "" : "s")")
		}
	}

	fileprivate var wordsCount: Int = 0
	{
		didSet
		{
			infoBarController?.setWordsCount("\(wordsCount) Word\(wordsCount == 1 ? "" : "s")")
		}
	}

	fileprivate var linesCount: Int = 1
	{
		didSet
		{
			infoBarController?.setLinesCount("\(linesCount) Line\(linesCount == 1 ? "" : "s")")
		}
	}

	private let observedPreferences = [
			"editorFont", "editorThemeName", "smartSubstitutionsOn", "spellingCheckerOn", "tabSize", "useSpacesForTabs",
			"infoBarMode", "countWhitespacesInTotalCharacters", "showsInvisibles", "keepIndentationOnNewLines"
	]

	private let observedThemeSettings = [
			"editorBackground", "editorForeground", "lineNumbersBackground", "lineNumbersForeground", "willDeallocate"
	]

	var text: String
	{
		get
		{
			return textView.string ?? ""
		}

		set
		{
			textView.string = newValue
		}
	}

	override var toolbar: NSToolbar?
	{
		willSet
		{
			if let toolbar = self.toolbar
			{
				toolbar.removeObserver(self, forKeyPath: "dynamicIsVisible")
			}
		}

		didSet
		{
			if let toolbar = self.toolbar
			{
				toolbar.addObserver(self, forKeyPath: "dynamicIsVisible", options: .new, context: nil)
			}
		}
	}

	internal func setup(_ document: Document)
	{
		for observedPreference in observedPreferences
		{
			Preferences.instance.addObserver(self, forKeyPath: observedPreference, options: .new, context: nil)
		}

		setupWindowStyle()

		self.setupInfoBar()

		updateEditorFont()
		updateEditorColors()
		updateEditorSubstitutions()
		updateEditorSpellingCheck()
		updateEditorInvisibles()
		updateEditorTabSize()
		updateEditorSpacesForTabsOption()
		updateEditorKeepIndentsSetting()
		setupThemeObserver()

		textView.lineNumbersVisible = Preferences.instance.autoshowLineNumbers
		textView.undoManager?.removeAllActions()
		textView.textStorageObserver = self
		textView.delegate = self

		let dragHandle = WindowDragHandleView(frame: NSMakeRect(0, 0, 100, 80))
		dragHandle.backgroundColor = Preferences.instance.editorTheme.editorBackground.withAlphaComponent(0.5)
		dragHandle.isHidden = toolbar?.isVisible ?? true
		self.contentView?.addSubview(dragHandle)

		let constraints: [NSLayoutConstraint] =
			NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": dragHandle]) +
			NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view(22)]", options: [], metrics: nil, views: ["view": dragHandle])

		NSLayoutConstraint.activate(constraints)

		titleDragHandleView = dragHandle
	}

	deinit
	{
		if let toolbar = self.toolbar
		{
			toolbar.removeObserver(self, forKeyPath: "dynamicIsVisible")
		}

		for observedPreference in observedPreferences
		{
			Preferences.instance.removeObserver(self, forKeyPath: observedPreference)
		}

		removeThemeObserver()
	}

	override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool
	{
		if menuItem.action == #selector(DocumentWindow.toggleLineNumbers(_:))
		{
			menuItem.title = textView.lineNumbersVisible ? "Hide Line Numbers" : "Show Line Numbers"
		}
		else if menuItem.action == #selector(DocumentWindow.toggleShowInvisibles(_:))
		{
			menuItem.title = textView.showsInvisibleCharacters ? "Hide Invisible Characters" : "Show Invisible Characters"
		}

		return super.validateMenuItem(menuItem)
	}

	override func mouseDragged(with event: NSEvent)
	{
		super.mouseDragged(with: event)
	}

	@IBAction func jumpToALine(_ sender: Any?)
	{
		let alert = NSAlert()
		alert.alertStyle = .informational
		alert.messageText = "Go to line:"
		alert.addButton(withTitle: "Go")
		alert.addButton(withTitle: "Cancel")

		let textField = NSTextField()
		textField.frame = NSMakeRect(0, 0, 90, 22)
		alert.accessoryView = textField

		alert.beginSheetModal(for: self)
		{
			response in

			if response == NSAlertFirstButtonReturn
			{
				if !self.textView.jumpToLine(lineNumber: textField.integerValue)
				{
					let warning = NSAlert()
					warning.alertStyle = .warning
					warning.messageText = "No such line “\(textField.stringValue)”."
					warning.addButton(withTitle: "OK")

					warning.beginSheetModal(for: self)
				}
			}
		}

		alert.window.makeFirstResponder(textField)
	}

	@IBAction func toggleShowInvisibles(_ sender: Any?)
	{
		Preferences.instance.showsInvisibles.flip()
	}

	@IBAction func toggleLineNumbers(_ sender: Any?)
	{
		textView.lineNumbersVisible.flip()

		Preferences.instance.autoshowLineNumbers = textView.lineNumbersVisible
	}

	@IBAction func copyDocumentStatToPasteboard(_ sender: Any?)
	{
		let pasteboard = NSPasteboard.general()

		switch (sender as? NSMenuItem)?.tag
		{
		case .some(1):
			pasteboard.clearContents()
			pasteboard.writeObjects([NSString(string: "\(characterCount)")])

		case .some(2):
			pasteboard.clearContents()
			pasteboard.writeObjects([NSString(string: "\(wordsCount)")])

		case .some(3):
			pasteboard.clearContents()
			pasteboard.writeObjects([NSString(string: "\(linesCount)")])

		default:
			break
		}
	}

	private func setupThemeObserver()
	{
		let theme = Preferences.instance.editorTheme

		if let themeObject = theme as? ConcreteEditorTheme
		{
			for themeSetting in observedThemeSettings
			{
				themeObject.addObserver(self, forKeyPath: themeSetting, options: .new, context: nil)
			}
		}
	}

	private func removeThemeObserver()
	{
		let theme = Preferences.instance.editorTheme

		if let themeObject = theme as? ConcreteEditorTheme
		{
			for themeSetting in observedThemeSettings
			{
				themeObject.removeObserver(self, forKeyPath: themeSetting)
			}
		}
	}

	private func setupWindowStyle()
	{
		titlebarAppearsTransparent = true

		updateWindowToolbarStyle()

		minSize = NSSize(width: 300, height: 200)
	}

	private func setupInfoBar()
	{
		if let infoBarConstraints = self.infoBarConstraints
		{
			NSLayoutConstraint.deactivate(infoBarConstraints)
			self.infoBarConstraints = nil
		}

		if let viewController = infoBarController as? NSViewController
		{
			viewController.view.removeFromSuperview()
			self.infoBarController = nil
		}

		switch Preferences.instance.infoBarMode
		{
		case .hud:
			let infoBarController = HUDInfoBarController.make()
			let infoBar = infoBarController.view

			if let contentView = self.contentView
			{
				infoBar.translatesAutoresizingMaskIntoConstraints = false
				contentView.addSubview(infoBar)

				var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[infoBar]-16-|",
																 metrics: nil,
																 views: ["infoBar": infoBar])

				constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=30)-[infoBar]-(>=20)-|",
																			  metrics: nil,
																			  views: ["infoBar": infoBar]))

				constraints.append(NSLayoutConstraint(item: contentView,
													  attribute: .centerX,
													  relatedBy: .equal,
													  toItem: infoBar,
													  attribute: .centerX,
													  multiplier: 1.0,
													  constant: 0.0))

				infoBarConstraints = constraints

				NSLayoutConstraint.activate(constraints)

				self.infoBarController = infoBarController

				textEditorBottomConstraint.constant = 0
			}

		case .status:
			let infoBarController = StatusInfoBarController.make()
			let infoBar = infoBarController.view

			if let contentView = self.contentView
			{
				infoBar.translatesAutoresizingMaskIntoConstraints = false
				contentView.addSubview(infoBar)

				var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[infoBar]-0-|",
																 metrics: nil,
																 views: ["infoBar": infoBar])

				constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[infoBar]-0-|",
																			  metrics: nil,
																			  views: ["infoBar": infoBar]))

				infoBarConstraints = constraints

				NSLayoutConstraint.activate(constraints)

				self.infoBarController = infoBarController

				textEditorBottomConstraint.constant = infoBar.bounds.height
			}

		default:
			textEditorBottomConstraint.constant = 0
			break
		}

		updateEditorColors()
		updateDocumentMetrics()

		infoBarController?.setEncoding((delegate as? Document)?.encoding.description ?? "<error>")
	}

	fileprivate func updateDocumentMetrics()
	{
		if let string = textView.string
		{
			let metrics = string.metrics

			self.wordsCount = metrics.words
			self.characterCount = Preferences.instance.countWhitespacesInTotalCharacters ? metrics.allCharacters : metrics.chars
			self.linesCount = metrics.lines
		}
	}

	override func observeValue(forKeyPath keyPath: String?,
							   of object: Any?,
							   change: [NSKeyValueChangeKey: Any]?,
							   context: UnsafeMutableRawPointer?)
	{
		textView.undoManager?.disableUndoRegistration()

		if object is Preferences
		{
			switch keyPath
			{
			case .some("editorFont"):
				updateEditorFont()

			case .some("editorThemeName"):
				updateEditorColors()
				setupThemeObserver()

			case .some("smartSubstitutionsOn"):
				updateEditorSubstitutions()

			case .some("spellingCheckerOn"):
				updateEditorSpellingCheck()

			case .some("tabSize"):
				updateEditorTabSize()

			case .some("useSpacesForTabs"):
				updateEditorSpacesForTabsOption()

			case .some("infoBarMode"):
				setupInfoBar()

			case .some("countWhitespacesInTotalCharacters"):
				updateDocumentMetrics()

			case .some("showsInvisibles"):
				updateEditorInvisibles()

			case .some("keepIndentationOnNewLines"):
				updateEditorKeepIndentsSetting()

			default:
				break
			}
		}
		else if object is EditorTheme
		{
			switch keyPath
			{
			case .some("willDeallocate"):
				removeThemeObserver()

			case .some(_):
				updateEditorColors()

			default:
				break
			}
		}
		else if object is NSToolbar
		{
			switch keyPath
			{
			case .some("dynamicIsVisible"):
				updateWindowToolbarStyle()

			default:
				break
			}
		}

		textView.undoManager?.enableUndoRegistration()
	}

	private func updateWindowToolbarStyle()
	{
		let visible = (toolbar?.isVisible ?? false)

		if let contentView = self.contentView as? PullableContentView
		{
			contentView.pullsContent = !visible
		}

		textView.textContainerInset = NSSize(width: textView.textContainerInset.width, height: visible ? 10 : 32)

		titleBarSeparatorView.isHidden = !visible
		titleDragHandleView?.isHidden = visible

		if let contentView = self.contentView
		{
			contentView.setFrameSize(NSSize(width: contentView.frame.size.width,
											height: contentView.frame.size.height - (visible ? 22.0 : 0.0)))
		}
	}

	private func updateEditorFont()
	{
		textView.font = Preferences.instance.editorFont

		updateEditorTabSize()
	}

	private func updateEditorColors()
	{
		let theme = Preferences.instance.editorTheme
		let isDark = theme.editorBackground.isDarkColor

		let appearance = isDark ? NSAppearance(named:NSAppearanceNameVibrantDark)
								: NSAppearance(named:NSAppearanceNameVibrantLight)

		self.appearance = appearance

		if let hudController = infoBarController as? HUDInfoBarController
		{
			hudController.setDarkMode(!isDark)
		}
		else if let statusController = infoBarController as? StatusInfoBarController
		{
			statusController.setTextColor(theme.lineNumbersForeground)
			statusController.setBackgroundColor(theme.lineNumbersBackground)
		}

		backgroundColor = theme.editorBackground
		titleDragHandleView?.backgroundColor = theme.editorBackground.withAlphaComponent(0.5)
		textView.setColorsFromTheme(theme: theme)
	}
	
	private func updateEditorSubstitutions()
	{
		let enabled = Preferences.instance.smartSubstitutionsOn
		
		textView.isAutomaticDashSubstitutionEnabled = enabled
		textView.isAutomaticQuoteSubstitutionEnabled = enabled
		textView.smartInsertDeleteEnabled = enabled
	}
	
	private func updateEditorSpellingCheck()
	{
		let enabled = Preferences.instance.spellingCheckerOn
		
		textView.isContinuousSpellCheckingEnabled = enabled
		textView.isAutomaticSpellingCorrectionEnabled = enabled
	}

	private func updateEditorInvisibles()
	{
		let enabled = Preferences.instance.showsInvisibles

		textView.showsInvisibleCharacters = enabled
	}

	private func updateEditorTabSize()
	{
		textView.setTabWidth(Preferences.instance.tabSize)
	}

	private func updateEditorSpacesForTabsOption()
	{
		textView.usesSpacesForTabs = Preferences.instance.useSpacesForTabs
	}

	private func updateEditorKeepIndentsSetting()
	{
		textView.keepsIndentationOnNewLines = Preferences.instance.keepIndentationOnNewLines
	}
}

extension DocumentWindow: NSTextViewDelegate
{
	func textViewDidChangeSelection(_ notification: Notification)
	{
		textView.lineNumbersView?.needsDisplay = true
	}
}

extension DocumentWindow: TextStorageObserver
{
	func textStorageWillUpdateMetrics(_ textStorage: MetricsTextStorage)
	{
		DispatchQueue.main.asyncAfter(deadline: .now()+0.25)
		{
			if textStorage.isUpdatingMetrics
			{
				self.infoBarController?.setIntermitentState(true)
			}
		}
	}

	func textStorage(_ textStorage: MetricsTextStorage, didUpdateMetrics metrics: StringMetrics)
	{
		let countsWhitespaces = Preferences.instance.countWhitespacesInTotalCharacters

		infoBarController?.setIntermitentState(false)

		characterCount = countsWhitespaces ? metrics.allCharacters : metrics.chars
		linesCount = metrics.lines
		wordsCount = metrics.words
	}
}

extension DocumentWindow
{
	func encodingDidChange(document: Document, newEncoding: String.Encoding)
	{
		infoBarController?.setEncoding(document.encoding.description)
	}
}
