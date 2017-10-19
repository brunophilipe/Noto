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

	private static let PreferenceLineNumbersFontName = "PreferenceLineNumbersFontName"
	private static let PreferenceLineNumbersFontSize = "PreferenceLineNumbersFontSize"

	private static let PreferenceEditorThemeName = "PreferenceEditorThemeName"
	private static let PreferenceEditorInfoBarMode = "PreferenceEditorInfoBarMode"
	private static let PreferenceEditorShowLineNumbers = "PreferenceEditorShowLineNumbers"
	
	private static let PreferenceEditorSmartSubstitutions	= "PreferenceEditorSmartSubstitutions"
	private static let PreferenceEditorSpellingChecker		= "PreferenceEditorSpellingChecker"
	private static let PreferenceEditorUseSpacesForTabs		= "PreferenceEditorUseSpacesForTabs"
	private static let PreferenceEditorTabSize				= "PreferenceEditorTabSize"
	private static let PreferenceEditorDisableLigatures		= "PreferenceEditorDisableLigatures"
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

	private static let allPreferences = [
		PreferenceGeneralDoubleEscToLeaveFullScreen, PreferenceEditorFontName, PreferenceEditorFontSize, PreferenceLineNumbersFontName,
		PreferenceLineNumbersFontSize, PreferenceEditorThemeName, PreferenceEditorInfoBarMode, PreferenceEditorShowLineNumbers,
		PreferenceEditorSmartSubstitutions, PreferenceEditorSpellingChecker, PreferenceEditorUseSpacesForTabs, PreferenceEditorTabSize,
		PreferenceEditorDisableLigatures, PreferenceEditorCountsWhitespaces, PreferenceEditorShowsInvisibles,
		PreferenceEditorKeepIndentOnNewLines, PreferencePrintWrapContents, PreferencePrintShowDate, PreferencePrintShowFileName,
		PreferencePrintShowPageNumber, PreferencePrintHideLineNumbers, PreferencePrintUseCustomTheme, PreferencePrintThemeName
	]

	private static let allDynamicProperties = [
		"editorFont", "lineNumbersFont", "editorThemeName", "smartSubstitutionsOn", "spellingCheckerOn", "useSpacesForTabs", "tabSize",
		"infoBarMode", "countWhitespacesInTotalCharacters", "showsInvisibles", "keepIndentationOnNewLines", "autoshowLineNumbers",
		"doubleEscToLeaveFullScreen", "printWrapContents", "disableLigatures", "printShowDate", "printShowFileName", "printShowPageNumber",
		"printHideLineNumbers", "printUseCustomTheme", "printThemeName"
	]

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

		init(intValue: Int?)
		{
			self = InfoBarMode(rawValue: intValue ?? 1)!
		}
	}

	func resetToDefault()
	{
		Preferences.allDynamicProperties.forEach({ willChangeValue(forKey: $0) })

		(_editorTheme as? ConcreteEditorTheme)?.willDeallocate = true
		_editorTheme = nil

		Preferences.allPreferences.forEach({ removeObject(forKey: $0) })

		Preferences.allDynamicProperties.forEach({ didChangeValue(forKey: $0) })
	}

	// Editor Settings

	let defaultFontSize: CGFloat = 14.0

	func increaseFontSize()
	{
		let font = self.editorFont

		if let largerFont = NSFont(descriptor: font.fontDescriptor, size: (font.pointSize + 1))
		{
			self.editorFont = largerFont
		}
	}

	func decreaseFontSize()
	{
		let font = self.editorFont

		if font.pointSize > 1, let smallerFont = NSFont(descriptor: font.fontDescriptor, size: (font.pointSize - 1))
		{
			self.editorFont = smallerFont
		}
	}

	func resetFontSize()
	{
		let font = self.editorFont

		if let defaultSizeFont = NSFont(descriptor: font.fontDescriptor, size: defaultFontSize)
		{
			self.editorFont = defaultSizeFont
		}
	}

	@objc dynamic var editorFont: NSFont
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
					if let font = NSFont(name: fontName, size: defaultFontSize)
					{
						return font
					}
				}

				// NO FONTS FOUND??
				NSLog("error: could not find any default fonts!")
				return NSFont.monospacedDigitSystemFont(ofSize: defaultFontSize, weight: .light)
			}
		}

		set
		{
			set(newValue.pointSize, forKey: Preferences.PreferenceEditorFontSize)
			set(newValue.fontName, forKey: Preferences.PreferenceEditorFontName)
		}
	}

	@objc dynamic var lineNumbersFont: NSFont
	{
		get
		{
			let fontSize = double(forKey: Preferences.PreferenceLineNumbersFontSize)

			if	let fontName = string(forKey: Preferences.PreferenceLineNumbersFontName), fontSize > 0,
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
			set(newValue.pointSize, forKey: Preferences.PreferenceLineNumbersFontSize)
			set(newValue.fontName, forKey: Preferences.PreferenceLineNumbersFontName)
		}
	}

	@objc dynamic var editorThemeName: String
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
	
	@objc dynamic var smartSubstitutionsOn: Bool
	{
		get { return bool(forKey: Preferences.PreferenceEditorSmartSubstitutions) }
		set { set(newValue, forKey: Preferences.PreferenceEditorSmartSubstitutions) }
	}
	
	@objc dynamic var spellingCheckerOn: Bool
	{
		get { return bool(forKey: Preferences.PreferenceEditorSpellingChecker) }
		set { set(newValue, forKey: Preferences.PreferenceEditorSpellingChecker) }
	}
	
	@objc dynamic var useSpacesForTabs: Bool
	{
		get { return bool(forKey: Preferences.PreferenceEditorUseSpacesForTabs) }
		set { set(newValue, forKey: Preferences.PreferenceEditorUseSpacesForTabs) }
	}

	@objc dynamic var disableLigatures: Bool
	{
		get { return bool(forKey: Preferences.PreferenceEditorDisableLigatures) }
		set { set(newValue, forKey: Preferences.PreferenceEditorDisableLigatures) }
	}
	
	@objc dynamic var tabSize: UInt
	{
		get { return (value(forKey: Preferences.PreferenceEditorTabSize) as? UInt) ?? 4 }
		set { set(newValue, forKey: Preferences.PreferenceEditorTabSize) }
	}

	@objc dynamic var infoBarMode: InfoBarMode
	{
		get { return InfoBarMode(intValue: value(forKey: Preferences.PreferenceEditorInfoBarMode) as? Int) }
		set { set(newValue.rawValue, forKey: Preferences.PreferenceEditorInfoBarMode) }
	}

	@objc dynamic var countWhitespacesInTotalCharacters: Bool
	{
		get { return bool(forKey: Preferences.PreferenceEditorCountsWhitespaces) }
		set { set(newValue, forKey: Preferences.PreferenceEditorCountsWhitespaces) }
	}

	@objc dynamic var showsInvisibles: Bool
	{
		get { return bool(forKey: Preferences.PreferenceEditorShowsInvisibles) }
		set { set(newValue, forKey: Preferences.PreferenceEditorShowsInvisibles) }
	}

	@objc dynamic var keepIndentationOnNewLines: Bool
	{
		get { return bool(forKey: Preferences.PreferenceEditorKeepIndentOnNewLines) }
		set { set(newValue, forKey: Preferences.PreferenceEditorKeepIndentOnNewLines) }
	}

	@objc dynamic var autoshowLineNumbers: Bool
	{
		get { return bool(forKey: Preferences.PreferenceEditorShowLineNumbers) }
		set { set(newValue, forKey: Preferences.PreferenceEditorShowLineNumbers) }
	}

	// General Settings

	@objc dynamic var doubleEscToLeaveFullScreen: Bool
	{
		get { return bool(forKey: Preferences.PreferenceGeneralDoubleEscToLeaveFullScreen) }
		set { set(newValue, forKey: Preferences.PreferenceGeneralDoubleEscToLeaveFullScreen) }
	}

	// Printing Options

	@objc dynamic var printWrapContents: Bool
	{
		get { return !bool(forKey: Preferences.PreferencePrintWrapContents) }
		set { set(!newValue, forKey: Preferences.PreferencePrintWrapContents) }
	}

	@objc dynamic var printShowDate: Bool
	{
		get { return bool(forKey: Preferences.PreferencePrintShowDate) }
		set { set(newValue, forKey: Preferences.PreferencePrintShowDate) }
	}

	@objc dynamic var printShowFileName: Bool
	{
		get { return bool(forKey: Preferences.PreferencePrintShowFileName) }
		set { set(newValue, forKey: Preferences.PreferencePrintShowFileName) }
	}

	@objc dynamic var printShowPageNumber: Bool
	{
		get { return bool(forKey: Preferences.PreferencePrintShowPageNumber) }
		set { set(newValue, forKey: Preferences.PreferencePrintShowPageNumber) }
	}

	@objc dynamic var printHideLineNumbers: Bool
	{
		get { return bool(forKey: Preferences.PreferencePrintHideLineNumbers) }
		set { set(newValue, forKey: Preferences.PreferencePrintHideLineNumbers) }
	}

	@objc dynamic var printUseCustomTheme: Bool
	{
		get { return bool(forKey: Preferences.PreferencePrintUseCustomTheme) }
		set { set(newValue, forKey: Preferences.PreferencePrintUseCustomTheme) }
	}

	@objc dynamic var printThemeName: String
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
