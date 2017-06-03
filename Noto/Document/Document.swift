//
//  Document.swift
//  Noto
//
//  Created by Bruno Philipe on 14/1/17.
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

class Document: NSDocument
{
	private var loadedString: String? = nil
	private var usedEncoding: String.Encoding = .utf8

	private var pendingOperations = [PendingOperation]()

	override init()
	{
	    super.init()

		// Add your subclass-specific initialization here.
	}

	override func makeWindowControllers()
	{
		super.makeWindowControllers()

		window?.setup(self)
		sendDataToWindow()
	}

	var window: DocumentWindow?
	{
		get
		{
			return windowControllers.first?.window as? DocumentWindow
		}
	}

	var encoding: String.Encoding
	{
		return usedEncoding
	}

	override class func autosavesInPlace() -> Bool
	{
		return true
	}

	override var windowNibName: String?
	{
		return "Document"
	}

	override var shouldRunSavePanelWithAccessoryView: Bool
	{
		return false
	}

	override func prepareSavePanel(_ savePanel: NSSavePanel) -> Bool
	{
		if let operation = popFirstPendingOperationOf(type: SavePanelMessageOperation.self)
		{
			let label = NSTextField(string: operation.message)
			label.allowsEditingTextAttributes = false
			label.isSelectable = false
			label.isBordered = false
			label.drawsBackground = false

			savePanel.accessoryView = label
		}

		savePanel.isExtensionHidden = false
		savePanel.allowsOtherFileTypes = true

		return super.prepareSavePanel(savePanel)
	}

	override func data(ofType typeName: String) throws -> Data
	{
		if let data = window?.text.data(using: usedEncoding)
		{
			return data
		}

		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}

	override func write(to url: URL, ofType typeName: String) throws
	{
		let oldEncoding = self.usedEncoding

		do
		{
			if let operation = popFirstPendingOperationOf(type: ChangeEncodingNotificationOperation.self)
			{
				self.usedEncoding = operation.encoding

				try data(ofType: typeName).write(to: url)

				self.window?.encodingDidChange(document: self, newEncoding: usedEncoding)
			}
			else
			{
				try data(ofType: typeName).write(to: url)
			}
		}
		catch let error
		{
			self.usedEncoding = oldEncoding
			throw error
		}
	}

	override func revert(toContentsOf url: URL, ofType typeName: String) throws
	{
		if url.isFileURL
		{
			try read(from: url, ofType: typeName)
			sendDataToWindow()
			updateChangeCount(.changeCleared)
		}
		else
		{
			throw NSError(domain: kNotoErrorDomain, code: 1020, userInfo: [NSLocalizedDescriptionKey: "Could not restore file"])
		}
	}

	override func read(from url: URL, ofType typeName: String) throws
	{
		if let (loadedString, usedEncoding) = EncodingTool.loadStringFromURL(url)
		{
			self.loadedString = loadedString
			self.usedEncoding = usedEncoding
		}
		else
		{
			throw NSError(domain: kNotoErrorDomain, code: 1010, userInfo: [NSLocalizedDescriptionKey: "Could not load file"])
		}
	}

	override func fileNameExtension(forType typeName: String, saveOperation: NSSaveOperationType) -> String?
	{
		return fileURL?.pathExtension ?? "txt"
	}

	override func printOperation(withSettings printSettings: [String: Any]) throws -> NSPrintOperation
	{
		if let window = self.window
		{
			let jobTitle = fileURL?.lastPathComponent ?? window.textView.printJobTitle
			let printInfo = self.printInfo.copy() as! NSPrintInfo
			printInfo.isVerticallyCentered = false
			printInfo.dictionary().addEntries(from: printSettings)

			let printView = PrintingView(printInfo: printInfo, jobTitle: jobTitle)
			if let storage = window.textView.textStorage?.string
			{
				let textStorage = NSTextStorage(string: storage)
				printView.textView.layoutManager?.replaceTextStorage(textStorage)
			}

			printView.textView.textColor = NSColor.black
			printView.textView.font = Preferences.instance.editorFont
			printView.textView.lineNumbersView?.font = Preferences.instance.lineNumbersFont
			printView.textView.setLayoutOrientation(window.textView.layoutOrientation)
			
			if let lineNumbersView = printView.textView.lineNumbersView
			{
				lineNumbersView.backgroundColor = NSColor.white
				lineNumbersView.textColor = NSColor.black
			}

			let accessoryContoller = PrintAccessoryViewController.make()
			let printOperation = NSPrintOperation(view: printView, printInfo: printInfo)
			printOperation.showsPrintPanel = true
			printOperation.showsProgressPanel = true
			printOperation.jobTitle = jobTitle

			var originalSize = window.textView.frame.size

			if window.textView.lineNumbersVisible, let lineNumbersView = window.textView.lineNumbersView
			{
				originalSize.width += lineNumbersView.frame.width
			}

			printView.originalSize = originalSize
			printView.printPanelAccessoryController = accessoryContoller

			let printPanel = printOperation.printPanel
			printPanel.options = [
				printPanel.options,
				.showsPaperSize,
				.showsOrientation,
				.showsScaling
			]

			printPanel.addAccessoryController(accessoryContoller)

			return printOperation
		}
		else
		{
			throw NSError(domain: kNotoErrorDomain,
						  code: 2001,
						  userInfo: [NSLocalizedDescriptionKey: "Could not retrieve data to print"])
		}
	}

	private func sendDataToWindow()
	{
		undoManager?.disableUndoRegistration()

		if let string = loadedString
		{
			window?.text = string
			loadedString = nil
		}

		undoManager?.enableUndoRegistration()
	}

	fileprivate func reopenFileAskingForEncoding()
	{
		if let fileURL = self.fileURL
		{
			repeat
			{
				if let newEncoding = EncodingTool.showEncodingPicker()
				{
					if let newString = try? String(contentsOf: fileURL, encoding: newEncoding)
					{
						self.loadedString = newString
						self.usedEncoding = newEncoding

						// Sends the re-encoded text
						sendDataToWindow()

						// Tells the window that the encoding changed
						window?.encodingDidChange(document: self, newEncoding: usedEncoding)

						// Resets the change status
						updateChangeCount(.changeCleared)
						return
					}
				}
				else
				{
					// User clicked cancel
					return
				}
			}
			while true
		}
	}

	fileprivate func saveFileAskingForEncoding(_ sender: Any?)
	{
		if let newEncoding = EncodingTool.showEncodingPicker()
		{
			self.pendingOperations.append(SavePanelMessageOperation(message: "Saving file with new encoding: \(newEncoding.description)"))
			self.pendingOperations.append(ChangeEncodingNotificationOperation(encoding: newEncoding))

			saveAs(sender)
		}
	}

	private func popFirstPendingOperationOf<T: PendingOperation>(type: T.Type) -> T?
	{
		if let index = pendingOperations.index(where: { stored in stored is T })
		{
			let operation = pendingOperations[index]
			pendingOperations.remove(at: index)
			return operation as? T
		}

		return nil
	}
}

extension Document
{
	@IBAction func reopenWithEncoding(_ sender: Any?)
	{
		reopenFileAskingForEncoding()
	}

	@IBAction func saveAsWithEncoding(_ sender: Any?)
	{
		saveFileAskingForEncoding(sender)
	}

	@IBAction func increaseIndentation(_ sender: Any?)
	{
		window?.textView.increaseIndentation()
	}

	@IBAction func decreaseIndentation(_ sender: Any?)
	{
		window?.textView.decreaseIndentation()
	}

	@IBAction func changeIndentationWithSegmentedControl(_ sender: NSSegmentedControl?)
	{
		switch sender?.selectedSegment
		{
		case .some(0):
			window?.textView.decreaseIndentation()

		case .some(1):
			window?.textView.increaseIndentation()

		default:
			break
		}
	}
}

private protocol PendingOperation {}

private struct SavePanelMessageOperation: PendingOperation
{
	var message: String
}

private struct ChangeEncodingNotificationOperation: PendingOperation
{
	var encoding: String.Encoding
}
