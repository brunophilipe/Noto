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

	private static let sharedInstance = Preferences()

	static var instance: Preferences
	{
		return sharedInstance
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
				NSLog("Fatal error: could not find any default fonts!")
				abort()
			}
		}

		set
		{
			set(newValue.pointSize, forKey: Preferences.PreferenceEditorFontSize)
			set(newValue.fontName, forKey: Preferences.PreferenceEditorFontName)
		}
	}
}
