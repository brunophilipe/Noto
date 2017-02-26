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

		setupWindowStyle()

		updateEditorFont()
		updateEditorColors()
		setupThemeObserver()
	}

	deinit
	{
		Preferences.instance.removeObserver(self, forKeyPath: "editorFont")
		Preferences.instance.removeObserver(self, forKeyPath: "editorThemeName")

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
}
