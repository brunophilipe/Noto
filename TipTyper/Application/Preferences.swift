//
//  Preferences.swift
//  TipTyper
//
//  Created by Bruno Philipe on 21/2/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

class Preferences: UserDefaults
{
	private static let PreferenceEditorFontName = "PreferenceEditorFontName"
	private static let PreferenceEditorFontSize = "PreferenceEditorFontSize"

	private static let PreferenceLineCounterFontName = "PreferenceLineCounterFontName"
	private static let PreferenceLineCounterFontSize = "PreferenceLineCounterFontSize"

	private static let PreferenceEditorThemeName = "PreferenceEditorThemeName"
	private static let PreferenceEditorInfoBarMode = "PreferenceEditorInfoBarMode"
	
	private static let PreferenceEditorSmartSubstitutions	= "PreferenceEditorSmartSubstitutions"
	private static let PreferenceEditorSpellingChecker		= "PreferenceEditorSpellingChecker"
	private static let PreferenceEditorUseSpacesForTabs		= "PreferenceEditorUseSpacesForTabs"
	private static let PreferenceEditorTabSize				= "PreferenceEditorTabSize"
	private static let PreferenceEditorCountsWhitespaces	= "PreferenceEditorCountsWhitespaces"
	private static let PreferenceEditorShowsInvisibles		= "PreferenceEditorShowsInvisibles"

	private static var sharedInstance: Preferences! = nil

	static var instance: Preferences
	{
		if sharedInstance == nil
		{
			sharedInstance = Preferences()
		}

		return sharedInstance
	}

	@objc
	enum InfoBarMode: Int
	{
		case none = 0
		case hud = 1
		case status = 2
	}

	dynamic var editorFont: NSFont
	{
		get
		{
			let fontSize = double(forKey: Preferences.PreferenceEditorFontSize)

			if	let fontName = string(forKey: Preferences.PreferenceEditorFontName), fontSize > 0,
				let font = NSFont(name: fontName, size: CGFloat(fontSize))
			{
				return font
			}
			else
			{
				let fontNames = [
					"SF Mono",
					"Menlo",
					"Monaco",
					"Courier",
					"Andale Mono"
				]

				for fontName in fontNames
				{
					if let font = NSFont(name: fontName, size: 14.0)
					{
						return font
					}
				}

				// NO FONTS FOUND??
				NSLog("error: could not find any default fonts!")
				return NSFont.monospacedDigitSystemFont(ofSize: 14.0, weight: 400)
			}
		}

		set
		{
			set(newValue.pointSize, forKey: Preferences.PreferenceEditorFontSize)
			set(newValue.fontName, forKey: Preferences.PreferenceEditorFontName)
		}
	}

	dynamic var lineCounterFont: NSFont
	{
		get
		{
			let fontSize = double(forKey: Preferences.PreferenceLineCounterFontSize)

			if	let fontName = string(forKey: Preferences.PreferenceLineCounterFontName), fontSize > 0,
				let font = NSFont(name: fontName, size: CGFloat(fontSize))
			{
				return font
			}
			else
			{
				let fontNames = [
					"SF Mono",
					"Menlo",
					"Monaco",
					"Courier",
					"Andale Mono"
				]

				for fontName in fontNames
				{
					if let font = NSFont(name: fontName, size: 10.0)
					{
						return font
					}
				}

				// NO FONTS FOUND??
				NSLog("Fatal error: could not find any default fonts!")
				abort()
			}
		}

		set
		{
			set(newValue.pointSize, forKey: Preferences.PreferenceLineCounterFontSize)
			set(newValue.fontName, forKey: Preferences.PreferenceLineCounterFontName)
		}
	}

	dynamic var editorThemeName: String
	{
		get
		{
			if let themeName = string(forKey: Preferences.PreferenceEditorThemeName)
			{
				return themeName
			}
			else
			{
				return LightEditorTheme().preferenceName!
			}
		}

		set
		{
			set(newValue, forKey: Preferences.PreferenceEditorThemeName)
			synchronize()
		}
	}

	private var _editorTheme: EditorTheme? = nil
	var editorTheme: EditorTheme
	{
		get
		{
			if let theme = _editorTheme
			{
				return theme
			}
			else
			{
				_editorTheme = ConcreteEditorTheme.getWithPreferenceName(self.editorThemeName) ?? LightEditorTheme()
				return _editorTheme!
			}
		}

		set
		{
			_editorTheme = newValue
		}
	}
	
	dynamic var smartSubstitutionsOn: Bool
	{
		get { return bool(forKey: Preferences.PreferenceEditorSmartSubstitutions) }
		set { set(newValue, forKey: Preferences.PreferenceEditorSmartSubstitutions) }
	}
	
	dynamic var spellingCheckerOn: Bool
	{
		get { return bool(forKey: Preferences.PreferenceEditorSpellingChecker) }
		set { set(newValue, forKey: Preferences.PreferenceEditorSpellingChecker) }
	}
	
	dynamic var useSpacesForTabs: Bool
	{
		get { return bool(forKey: Preferences.PreferenceEditorUseSpacesForTabs) }
		set { set(newValue, forKey: Preferences.PreferenceEditorUseSpacesForTabs) }
	}
	
	dynamic var tabSize: UInt
	{
		get { return (value(forKey: Preferences.PreferenceEditorTabSize) as? UInt) ?? 4 }
		set { set(newValue, forKey: Preferences.PreferenceEditorTabSize) }
	}

	dynamic var infoBarMode: InfoBarMode
	{
		get { return InfoBarMode(rawValue: value(forKey: Preferences.PreferenceEditorInfoBarMode) as? Int ?? 1) ?? .hud }
		set { set(newValue.rawValue, forKey: Preferences.PreferenceEditorInfoBarMode) }
	}

	dynamic var countWhitespacesInTotalCharacters: Bool
	{
		get { return bool(forKey: Preferences.PreferenceEditorCountsWhitespaces) }
		set { set(newValue, forKey: Preferences.PreferenceEditorCountsWhitespaces) }
	}

	dynamic var showsInvisibles: Bool
	{
		get { return bool(forKey: Preferences.PreferenceEditorShowsInvisibles) }
		set { set(newValue, forKey: Preferences.PreferenceEditorShowsInvisibles) }
	}
}
