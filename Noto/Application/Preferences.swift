//
//  Preferences.swift
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

class Preferences: UserDefaults
{
	private static let PreferenceGeneralDoubleEscToLeaveFullScreen = "PreferenceGeneralDoubleEscToLeaveFullScreen"

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
	private static let PreferenceEditorKeepIndentOnNewLines	= "PreferenceEditorKeepIndentOnNewLines"

	private static let PreferencePrintWrapContents		= "PreferencePrintWrapContents"
	private static let PreferencePrintShowDate			= "PreferencePrintShowDate"
	private static let PreferencePrintShowFileName		= "PreferencePrintShowFileName"
	private static let PreferencePrintShowPageNumber	= "PreferencePrintShowPageNumber"
	private static let PreferencePrintHideLineNumbers	= "PreferencePrintHideLineNumbers"
	private static let PreferencePrintUseCustomTheme	= "PreferencePrintUseCustomTheme"
	private static let PreferencePrintThemeName			= "PreferencePrintThemeName"

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

	// Editor Settings

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

	dynamic var keepIndentationOnNewLines: Bool
	{
		get { return bool(forKey: Preferences.PreferenceEditorKeepIndentOnNewLines) }
		set { set(newValue, forKey: Preferences.PreferenceEditorKeepIndentOnNewLines) }
	}

	// General Settings

	dynamic var doubleEscToLeaveFullScreen: Bool
	{
		get { return bool(forKey: Preferences.PreferenceGeneralDoubleEscToLeaveFullScreen) }
		set { set(newValue, forKey: Preferences.PreferenceGeneralDoubleEscToLeaveFullScreen) }
	}

	// Printing Options

	dynamic var printWrapContents: Bool
	{
		get { return !bool(forKey: Preferences.PreferencePrintWrapContents) }
		set { set(!newValue, forKey: Preferences.PreferencePrintWrapContents) }
	}

	dynamic var printShowDate: Bool
	{
		get { return bool(forKey: Preferences.PreferencePrintShowDate) }
		set { set(newValue, forKey: Preferences.PreferencePrintShowDate) }
	}

	dynamic var printShowFileName: Bool
	{
		get { return bool(forKey: Preferences.PreferencePrintShowFileName) }
		set { set(newValue, forKey: Preferences.PreferencePrintShowFileName) }
	}

	dynamic var printShowPageNumber: Bool
	{
		get { return bool(forKey: Preferences.PreferencePrintShowPageNumber) }
		set { set(newValue, forKey: Preferences.PreferencePrintShowPageNumber) }
	}

	dynamic var printHideLineNumbers: Bool
	{
		get { return bool(forKey: Preferences.PreferencePrintHideLineNumbers) }
		set { set(newValue, forKey: Preferences.PreferencePrintHideLineNumbers) }
	}

	dynamic var printUseCustomTheme: Bool
	{
		get { return bool(forKey: Preferences.PreferencePrintUseCustomTheme) }
		set { set(newValue, forKey: Preferences.PreferencePrintUseCustomTheme) }
	}

	dynamic var printThemeName: String
	{
		get
		{
			if let themeName = string(forKey: Preferences.PreferencePrintThemeName)
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
			set(newValue, forKey: Preferences.PreferencePrintThemeName)
			synchronize()
		}
	}
}
