//
// Created by Bruno Philipe on 2/3/17.
// Copyright (c) 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

class EncodingTool
{
	private static let supportedEncodings: [(encoding: String.Encoding, name: String)] = [
			(encoding: .utf8, name: "UTF-8"),
			(encoding: .ascii, name: "ASCII"),
			(encoding: .isoLatin1, name: "ISO Latin-1"),
			(encoding: .isoLatin2, name: "ISO Latin-2"),
			(encoding: .macOSRoman, name: "Mac OS Roman"),
			(encoding: .windowsCP1251, name: "Windows-1251"),
			(encoding: .windowsCP1252, name: "Windows-1252"),
			(encoding: .windowsCP1253, name: "Windows-1253"),
			(encoding: .windowsCP1254, name: "Windows-1254"),
			(encoding: .windowsCP1250, name: "Windows-1250"),
			(encoding: .utf16, name: "UTF-16"),
			(encoding: .utf16BigEndian, name: "UTF-16 BE"),
			(encoding: .utf16LittleEndian, name: "UTF-16 LE"),
			(encoding: .utf32, name: "UTF-32"),
			(encoding: .utf32BigEndian, name: "UTF-32 BE"),
			(encoding: .utf32LittleEndian, name: "UTF-32 LE"),
			(encoding: .nextstep, name: "NeXT"),
			(encoding: .symbol, name: "Symbol"),
			(encoding: .iso2022JP, name: "ISO-2022 JP"),
			(encoding: .japaneseEUC, name: "Japanese EUC"),
			(encoding: .nonLossyASCII, name: "Lossy ASCII"),
			(encoding: .shiftJIS, name: "Shift JIS")
	]

	static func loadStringFromURL(_ url: URL) -> (String, String.Encoding)?
	{
		if url.isFileURL && FileManager.default.fileExists(atPath: url.path)
		{
			// We try Apple's automatic encoding detector
			var encoding = String.Encoding.utf8
			if let attempt = try? String(contentsOf: url, usedEncoding: &encoding)
			{
				return (attempt, encoding)
			}

			// We attempt utf8 first, since it is very common (and supports ascii), and then isoLatin2.
			// If both fail, we ask the user for the encoding

			var loadedString: String? = nil
			let autoAttempt: [String.Encoding] = [.utf8, .isoLatin2]

			for encoding in autoAttempt
			{
				if let attempt: String = try? String(contentsOf: url, encoding: encoding)
				{
					return (attempt, encoding)
				}
			}

			repeat
			{
				if let encoding = showEncodingPicker()
				{
					if let attempt: String = try? String(contentsOf: url, encoding: encoding)
					{
						return (attempt, encoding)
					}
					// else try again until user hits cancel
				}
				else
				{
					return nil
				}
			}
			while true
		}

		return ("", .utf8)
	}

	static func loadStringFromData(_ data: Data) -> (String, String.Encoding)?
	{
		if data.count > 0
		{
			// We attempt utf8 first, since it is very common (and supports ascii),
			// and if it fails we ask the user for the encoding

			let autoAttempt: [String.Encoding] = [.utf8]

			for encoding in autoAttempt
			{
				if let attempt: String = String(data: data, encoding: encoding)
				{
					return (attempt, encoding)
				}
			}

			repeat
			{
				if let encoding = showEncodingPicker()
				{
					if let attempt: String = String(data: data, encoding: encoding)
					{
						return (attempt, encoding)
					}
					// else try again until user hits cancel
				}
				else
				{
					return nil
				}
			}
			while true
		}

	    return ("", .utf8)
	}

	private static func showEncodingPicker() -> String.Encoding?
	{
		let alert = NSAlert()
		alert.messageText = "Please select an encoding for the file:"
		alert.addButton(withTitle: "OK")
		alert.addButton(withTitle: "Cancel")
		alert.window.title = "Could not detect encoding automatically"

		let encodingPopUpButton = NSPopUpButton(frame: NSRect(x: 0, y: 0, width: 160, height: 40), pullsDown: true)
		let menu = NSMenu()
		supportedEncodings.forEach()
		{
			encodingTuple in

			let menuItem = NSMenuItem(title: encodingTuple.name, action: nil, keyEquivalent: "")
			menuItem.representedObject = encodingTuple.encoding

			menu.addItem(menuItem)
		}

		encodingPopUpButton.menu = menu
		encodingPopUpButton.target = self
		encodingPopUpButton.action = #selector(EncodingTool.didChangeEncodingPopUpButton(_:))
		encodingPopUpButton.title = supportedEncodings.first!.name
		encodingPopUpButton.selectItem(at: 0)

		alert.accessoryView = encodingPopUpButton

		if alert.runModal() == 1000
		{
			return encodingPopUpButton.selectedItem?.representedObject as? String.Encoding
		}

		return nil
	}

	@objc static func didChangeEncodingPopUpButton(_ popUpButton: NSPopUpButton)
	{
		popUpButton.title =? popUpButton.selectedItem?.title
	}
}

