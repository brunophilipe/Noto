//
//  DocumentWindow.swift
//  TipTyper
//
//  Created by Bruno Philipe on 21/2/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

@IBDesignable
class DocumentWindow: NSWindow
{
	private weak var document: Document? = nil
	private var infoBarController: InfoBar? = nil
	private var infoBarConstraints: [NSLayoutConstraint]? = nil

	@IBOutlet var textView: EditorView!

	var text: String
	{
		get
		{
			return textView.string ?? ""
		}

		set
		{
			textView.string = newValue
			updateInfoBar()
		}
	}

	func setup(_ document: Document)
	{
		Preferences.instance.addObserver(self, forKeyPath: "editorFont", options: .new, context: nil)
		Preferences.instance.addObserver(self, forKeyPath: "editorThemeName", options: .new, context: nil)
		Preferences.instance.addObserver(self, forKeyPath: "smartSubstitutionsOn", options: .new, context: nil)
		Preferences.instance.addObserver(self, forKeyPath: "spellingCheckerOn", options: .new, context: nil)
		Preferences.instance.addObserver(self, forKeyPath: "tabSize", options: .new, context: nil)
		Preferences.instance.addObserver(self, forKeyPath: "useSpacesForTabs", options: .new, context: nil)
		Preferences.instance.addObserver(self, forKeyPath: "infoBarMode", options: .new, context: nil)

		self.document = document
		document.delegate = self

		setupWindowStyle()
		setupInfoBar()

		updateEditorFont()
		updateEditorColors()
		updateEditorSubstitutions()
		updateEditorSpellingCheck()
		updateEditorTabSize()
		updateEditorSpacesForTabsOption()
		setupThemeObserver()

		textView.undoManager?.removeAllActions()
	}

	deinit
	{
		document?.delegate = nil

		Preferences.instance.removeObserver(self, forKeyPath: "editorFont")
		Preferences.instance.removeObserver(self, forKeyPath: "editorThemeName")
		Preferences.instance.removeObserver(self, forKeyPath: "smartSubstitutionsOn")
		Preferences.instance.removeObserver(self, forKeyPath: "spellingCheckerOn")
		Preferences.instance.removeObserver(self, forKeyPath: "tabSize")
		Preferences.instance.removeObserver(self, forKeyPath: "useSpacesForTabs")
		Preferences.instance.removeObserver(self, forKeyPath: "infoBarMode")

		removeThemeObserver()
	}

	private func setupThemeObserver()
	{
		let theme = Preferences.instance.editorTheme

		if let themeObject = theme as? ConcreteEditorTheme
		{
			themeObject.addObserver(self, forKeyPath: "editorBackground", options: .new, context: nil)
			themeObject.addObserver(self, forKeyPath: "editorForeground", options: .new, context: nil)
			themeObject.addObserver(self, forKeyPath: "lineCounterBackground", options: .new, context: nil)
			themeObject.addObserver(self, forKeyPath: "lineCounterForeground", options: .new, context: nil)
			themeObject.addObserver(self, forKeyPath: "willDeallocate", options: .new, context: nil)
		}
	}

	private func removeThemeObserver()
	{
		let theme = Preferences.instance.editorTheme

		if let themeObject = theme as? ConcreteEditorTheme
		{
			themeObject.removeObserver(self, forKeyPath: "editorBackground")
			themeObject.removeObserver(self, forKeyPath: "editorForeground")
			themeObject.removeObserver(self, forKeyPath: "lineCounterBackground")
			themeObject.removeObserver(self, forKeyPath: "lineCounterForeground")
			themeObject.removeObserver(self, forKeyPath: "willDeallocate")
		}
	}

	private func setupWindowStyle()
	{
		titlebarAppearsTransparent = true

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

				textView.delegate = self
			}

		default:
			textView.delegate = nil
			break
		}
	}

	func updateInfoBar()
	{
		if let infoBar = self.infoBarController, let string = self.textView.string
		{
			let characterCount = string.characters.count
			var wordsCount = Int(0)
			var linesCount = Int(0)

			string.enumerateSubstrings(in: string.fullStringRange, options: .byWords)
			{
				_ in wordsCount += 1
			}

			string.enumerateSubstrings(in: string.fullStringRange, options: .byLines)
			{
				_ in linesCount += 1
			}

			infoBar.setCharactersCount("c: \(characterCount)")
			infoBar.setWordsCount("t: \(wordsCount)")
			infoBar.setLinesCount("l: \(linesCount)")
			infoBar.setEncoding(document?.encoding.description ?? "<error>")
		}
	}

	override func observeValue(forKeyPath keyPath: String?,
	                           of object: Any?,
	                           change: [NSKeyValueChangeKey : Any]?,
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

		textView.undoManager?.enableUndoRegistration()
	}

	private func updateEditorFont()
	{
		textView.font = Preferences.instance.editorFont
	}

	private func updateEditorColors()
	{
		let theme = Preferences.instance.editorTheme

		appearance = theme.editorBackground.isDarkColor ? NSAppearance(named:NSAppearanceNameVibrantDark)
														: NSAppearance(named:NSAppearanceNameVibrantLight)

		backgroundColor = theme.editorBackground
		textView.backgroundColor = theme.editorBackground
		textView.textColor = theme.editorForeground
		textView.lineCounterView?.textColor = theme.lineCounterForeground
		textView.lineCounterView?.backgroundColor = theme.lineCounterBackground
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

	private func updateEditorTabSize()
	{
		textView.setTabWidth(Preferences.instance.tabSize)
	}

	private func updateEditorSpacesForTabsOption()
	{
		textView.usesSpacesForTabs = Preferences.instance.useSpacesForTabs
	}
}

extension DocumentWindow: NSTextViewDelegate
{
	func textDidChange(_ notification: Notification)
	{
		self.updateInfoBar()
	}
}

extension DocumentWindow: DocumentDelegate
{
	func encodingDidChange(document: Document, newEncoding: String.Encoding)
	{
		self.updateInfoBar()
	}

}
