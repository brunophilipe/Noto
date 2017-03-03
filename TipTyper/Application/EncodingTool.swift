//
// Created by Bruno Philipe on 2/3/17.
// Copyright (c) 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

class EncodingTool
{
	private static let supportedEncodings: [String.Encoding] =
	{
		var encodings: [String.Encoding] = [
			.ascii,
			.utf8,
			.isoLatin1,
			.isoLatin2,
			.macOSRoman,
			.windowsCP1251,
			.windowsCP1252,
			.windowsCP1253,
			.windowsCP1254,
			.windowsCP1250,
			.utf16,
			.utf16BigEndian,
			.utf16LittleEndian,
			.utf32,
			.utf32BigEndian,
			.utf32LittleEndian,
			.nextstep,
			.symbol,
			.iso2022JP,
			.japaneseEUC,
			.nonLossyASCII,
			.shiftJIS,
		]

		encodings.sort()
		{
			(left, right) -> Bool in

			return left.description.compare(right.description) == .orderedAscending
		}

		return encodings
	}()

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

			let autoAttempt: [String.Encoding] = [.utf8, .utf16]

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
					// user has hit cancel
					return nil
				}
			}
			while true
		}

		return ("", .utf8)
	}

	static func showEncodingPicker() -> String.Encoding?
	{
		let alert = NSAlert()
		alert.messageText = "Please select an encoding for the file:"
		alert.addButton(withTitle: "OK")
		alert.addButton(withTitle: "Cancel")
		alert.window.title = "Could not detect encoding automatically"

		let encodingPopUpButton = NSPopUpButton(frame: NSRect(x: 0, y: 0, width: 190, height: 40), pullsDown: false)
		let menu = NSMenu()

		for encoding in EncodingTool.supportedEncodings
		{
			let menuItem = NSMenuItem(title: encoding.description, action: nil, keyEquivalent: "")
			menuItem.representedObject = encoding

			menu.addItem(menuItem)
		}

		encodingPopUpButton.menu = menu
		encodingPopUpButton.target = self
		encodingPopUpButton.action = #selector(EncodingTool.didChangeEncodingPopUpButton(_:))

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

