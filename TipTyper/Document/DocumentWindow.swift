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
		}
	}

	func setupUI()
	{
		Preferences.instance.addObserver(self, forKeyPath: "editorFont", options: NSKeyValueObservingOptions.new, context: nil)
		Preferences.instance.addObserver(self, forKeyPath: "editorThemeName", options: NSKeyValueObservingOptions.new, context: nil)
		Preferences.instance.addObserver(self, forKeyPath: "smartSubstitutionsOn", options: NSKeyValueObservingOptions.new, context: nil)
		Preferences.instance.addObserver(self, forKeyPath: "spellingCheckerOn", options: NSKeyValueObservingOptions.new, context: nil)
		Preferences.instance.addObserver(self, forKeyPath: "tabSize", options: NSKeyValueObservingOptions.new, context: nil)

		setupWindowStyle()

		updateEditorFont()
		updateEditorColors()
		updateEditorSubstitutions()
		updateEditorSpellingCheck()
		updateEditorTabSize()
		setupThemeObserver()
	}

	deinit
	{
		Preferences.instance.removeObserver(self, forKeyPath: "editorFont")
		Preferences.instance.removeObserver(self, forKeyPath: "editorThemeName")
		Preferences.instance.removeObserver(self, forKeyPath: "smartSubstitutionsOn")
		Preferences.instance.removeObserver(self, forKeyPath: "spellingCheckerOn")
		Preferences.instance.removeObserver(self, forKeyPath: "tabSize")

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
}
