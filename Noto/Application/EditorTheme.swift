//
//  EditorTheme.swift
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

protocol EditorTheme: class
{
	var name: String { get }
	
	var editorForeground: NSColor { get }
	var editorBackground: NSColor { get }
	
	var lineNumbersForeground: NSColor { get }
	var lineNumbersBackground: NSColor { get }

	var preferenceName: String? { get }
}

private let kThemeNameKey					= "name"
private let kThemeEditorBackgroundKey		= "editor_background"
private let kThemeLineNumbersBackgroundKey	= "lines_background"
private let kThemeEditorForegroundKey		= "editor_foreground"
private let kThemeLineNumbersForegroundKey	= "lines_foreground"

private let kThemeNativeNamePrefix = "native:"
private let kThemeUserNamePrefix = "user:"

extension EditorTheme
{
	fileprivate static var userThemeKeys: [String]
	{
		return [
			kThemeEditorBackgroundKey,
			kThemeLineNumbersBackgroundKey,
			kThemeEditorForegroundKey,
			kThemeLineNumbersForegroundKey]
	}

	fileprivate var serialized: [String: AnyObject]
	{
		return [
			kThemeNameKey:					name as NSString,
			kThemeEditorBackgroundKey:		editorBackground,
			kThemeLineNumbersBackgroundKey:	lineNumbersBackground,
			kThemeEditorForegroundKey:		editorForeground,
			kThemeLineNumbersForegroundKey:	lineNumbersForeground
		]
	}
	
	func make(fromSerialized dict: [String: AnyObject]) -> EditorTheme
	{
		return ConcreteEditorTheme(fromSerialized: dict)
	}

	static func installedThemes() -> (native: [EditorTheme], user: [EditorTheme])
	{
		let nativeThemes: [EditorTheme] = [
			LightEditorTheme(),
			DarkEditorTheme()
		]

		var userThemes: [EditorTheme] = []

		if let themesDirectoryURL = URLForUserThemesDirectory()
		{
			if let fileURLs = try? FileManager.default.contentsOfDirectory(at: themesDirectoryURL,
			                                                               includingPropertiesForKeys: nil,
			                                                               options: [.skipsHiddenFiles])
			{
				for fileURL in fileURLs
				{
					if fileURL.pathExtension == "plist", let theme = UserEditorTheme(fromFile: fileURL)
					{
						userThemes.append(theme)
					}
				}
			}
		}

		return (nativeThemes, userThemes)
	}

	static func URLForUserThemesDirectory() -> URL?
	{
		if let appSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
		{
			let themeDirectory = appSupportDirectory.appendingPathComponent("Noto/Themes/")

			do
			{
				try FileManager.default.createDirectory(at: themeDirectory, withIntermediateDirectories: true, attributes: nil)
			}
			catch let error
			{
				NSLog("Could not create Themes directory: \(themeDirectory). Please check permissions. Error: \(error)")
			}

			return themeDirectory
		}

		return nil
	}

	public static func getWithPreferenceName(_ name: String) -> EditorTheme?
	{
		if name.hasPrefix(kThemeNativeNamePrefix)
		{
			let themeName = name.substring(from: name.index(name.startIndex, offsetBy: kThemeNativeNamePrefix.characters.count))

			switch themeName
			{
			case "Light":
				return LightEditorTheme()

			case "Dark":
				return DarkEditorTheme()

			default:
				return nil
			}
		}
		else if name.hasPrefix(kThemeUserNamePrefix)
		{
			let themeFilePath = name.substring(from: name.index(name.startIndex, offsetBy: kThemeUserNamePrefix.characters.count))

			if FileManager.default.fileExists(atPath: themeFilePath)
			{
				return UserEditorTheme(fromFile: URL(fileURLWithPath: themeFilePath))
			}
			else
			{
				return nil
			}
		}
		else
		{
			return nil
		}
	}
}

class ConcreteEditorTheme: NSObject, EditorTheme
{
	fileprivate init(fromSerialized dict: [String: AnyObject])
	{
		_name = (dict[kThemeNameKey] as? String) ?? "(Unamed)"
		editorForeground		= (dict[kThemeEditorForegroundKey] as? NSColor) ?? NSColor.black
		editorBackground		= (dict[kThemeEditorBackgroundKey] as? NSColor) ?? NSColor(rgb: 0xFDFDFD)
		lineNumbersForeground	= (dict[kThemeLineNumbersForegroundKey] as? NSColor) ?? NSColor(rgb: 0x999999)
		lineNumbersBackground	= (dict[kThemeLineNumbersBackgroundKey] as? NSColor) ?? NSColor(rgb: 0xF5F5F5)
	}
	
	fileprivate var _name: String

	var name: String
	{
		return _name
	}

	dynamic var editorForeground: NSColor
	dynamic var editorBackground: NSColor
	dynamic var lineNumbersForeground: NSColor
	dynamic var lineNumbersBackground: NSColor

	dynamic var willDeallocate: Bool = false

	var preferenceName: String?
	{
		return "\(kThemeNativeNamePrefix)\(name)"
	}

	func makeCustom() -> EditorTheme?
	{
		return UserEditorTheme(customizingTheme: self)
	}
}

class UserEditorTheme : ConcreteEditorTheme
{
	fileprivate var fileWriterOldURL: URL? = nil
	fileprivate var fileWriterTimer: Timer? = nil

	fileprivate var fileURL: URL?
	{
		if let themesDirectory = UserEditorTheme.URLForUserThemesDirectory()
		{
			return themesDirectory.appendingPathComponent(name).appendingPathExtension("plist")
		}
		else
		{
			return nil
		}
	}

	init(customizingTheme originalTheme: EditorTheme)
	{
		let newName = originalTheme.name.appending(" (Custom)")

		super.init(fromSerialized: originalTheme.serialized)

		_name = newName

		writeToFile(immediatelly: true)
	}

	init?(fromFile fileURL: URL)
	{
		if fileURL.isFileURL, var themeDictionary = NSDictionary(contentsOf: fileURL) as? [String : AnyObject]
		{
			for itemKey in UserEditorTheme.userThemeKeys
			{
				if themeDictionary[itemKey] == nil
				{
					return nil
				}

				if let intValue = themeDictionary[itemKey] as? UInt
				{
					themeDictionary[itemKey] = NSColor(rgb: intValue)
				}
			}

			super.init(fromSerialized: themeDictionary)

			_name = fileURL.deletingPathExtension().lastPathComponent
		}
		else
		{
			return nil
		}
	}

	var isCustomization: Bool
	{
		return name.hasSuffix("(Custom)")
	}

	override var preferenceName: String?
	{
		if let fileURL = self.fileURL
		{
			return "\(kThemeUserNamePrefix)\(fileURL.path)"
		}

		return nil
	}

	override func didChangeValue(forKey key: String)
	{
		super.didChangeValue(forKey: key)

		if !["name", "willDeallocate"].contains(key)
		{
			writeToFile(immediatelly: false)
		}
	}

	func renameTheme(newName: String) -> Bool
	{
		if let oldUrl = fileURL
		{
			fileWriterOldURL = oldUrl

			_name = newName

			return moveThemeFile()
		}

		return false
	}

	func deleteTheme() -> Bool
	{
		return deleteThemeFile()
	}
}

extension UserEditorTheme
{
	func writeToFile(immediatelly: Bool)
	{
		if immediatelly
		{
			writeToFileNow()
			fileWriterTimer?.invalidate()
			fileWriterTimer = nil
		}
		else
		{
			if let timer = self.fileWriterTimer
			{
				timer.fireDate = Date().addingTimeInterval(3)
			}
			else
			{
				fileWriterTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false)
				{
					(timer) in

					self.writeToFileNow()
					self.fileWriterTimer = nil
				}
			}
		}
	}

	func exportThemeTo(url targetUrl: URL)
	{
		writeToFileNow(url: targetUrl)
	}

	private func writeToFileNow(url targetUrl: URL? = nil)
	{
		if let url = targetUrl ?? self.fileURL
		{
			let serialized = self.serialized
			let dict = (serialized as NSDictionary).mutableCopy() as! NSMutableDictionary

			for settingKey in serialized.keys
			{
				if let color = dict[settingKey] as? NSColor
				{
					dict.setValue(color.rgb, forKey: settingKey)
				}
			}

			dict.write(to: url, atomically: true)
		}
	}

	fileprivate func moveThemeFile() -> Bool
	{
		if let oldURL = fileWriterOldURL, let newURL = fileURL
		{
			do
			{
				try FileManager.default.moveItem(at: oldURL, to: newURL)

				fileWriterOldURL = nil

				return true
			}
			catch let error
			{
				NSLog("Error! Could not rename theme file! \(error)")

				return false
			}
		}

		return false
	}

	fileprivate func deleteThemeFile() -> Bool
	{
		if let url = fileURL
		{
			do
			{
				try FileManager.default.removeItem(at: url)

				return true
			}
			catch let error
			{
				NSLog("Error! Could not delete theme file! \(error)")
			}
		}

		return false
	}
}

protocol NativeEditorTheme: EditorTheme
{}

extension NativeEditorTheme
{
	var preferenceName: String?
	{
		return "\(kThemeNativeNamePrefix)\(name)"
	}
}

class LightEditorTheme: NativeEditorTheme
{
	var name: String
	{
		return "Light"
	}
	
	var editorForeground: NSColor
	{
		return NSColor.black
	}
	
	var editorBackground: NSColor
	{
		return NSColor(rgb: 0xFDFDFD)
	}
	
	var lineNumbersForeground: NSColor
	{
		return NSColor(rgb: 0x999999)
	}
	
	var lineNumbersBackground: NSColor
	{
		return NSColor(rgb: 0xF5F5F5)
	}
}

class DarkEditorTheme: NativeEditorTheme
{
	var name: String
	{
		return "Dark"
	}

	var editorForeground: NSColor
	{
		return NSColor(rgba: 3688619007)
	}

	var editorBackground: NSColor
	{
		return NSColor(rgba: 926365695)
	}

	var lineNumbersForeground: NSColor
	{
		return NSColor(rgba: 1953789183)
	}

	var lineNumbersBackground: NSColor
	{
		return NSColor(rgba: 707406591)
	}
}
