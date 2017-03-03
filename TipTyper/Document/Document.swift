//
//  Document.swift
//  TipTyper
//
//  Created by Bruno Philipe on 14/1/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

class Document: NSDocument
{
	private var loadedString: String? = nil
	private var usedEncoding: String.Encoding = .utf8

	private var savePanelMessage: String? = nil

	override init()
	{
	    super.init()

		// Add your subclass-specific initialization here.
	}

	override func makeWindowControllers()
	{
		super.makeWindowControllers()

		window?.setup()
		sendDataToWindow()
	}

	var window: DocumentWindow?
	{
		get
		{
			return windowControllers.first?.window as? DocumentWindow
		}
	}

	override class func autosavesInPlace() -> Bool
	{
		return true
	}

	override var windowNibName: String?
	{
		// Returns the nib file name of the document
		// If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this property and override -makeWindowControllers instead.
		return "Document"
	}

	override var shouldRunSavePanelWithAccessoryView: Bool
	{
		return false
	}

	override func prepareSavePanel(_ savePanel: NSSavePanel) -> Bool
	{
		if let message = self.savePanelMessage
		{
			let label = NSTextField(string: message)
			label.allowsEditingTextAttributes = false
			label.isSelectable = false
			label.isBordered = false
			label.drawsBackground = false

			savePanel.accessoryView = label
		}

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
			throw NSError(domain: kTipTyperErrorDomain, code: 1020, userInfo: [NSLocalizedDescriptionKey: "Could not restore file"])
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
			throw NSError(domain: kTipTyperErrorDomain, code: 1010, userInfo: [NSLocalizedDescriptionKey: "Could not load file"])
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
				if let newEncoding = EncodingTool.showEncodingPicker(),
				   let newString = try? String(contentsOf: fileURL, encoding: newEncoding)
				{
					self.loadedString = newString
					self.usedEncoding = newEncoding

					sendDataToWindow()
					updateChangeCount(.changeCleared)
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
			self.usedEncoding = newEncoding
			self.savePanelMessage = "Saving file with new encoding: \(newEncoding.description)"

			saveAs(sender)

			self.savePanelMessage = nil
		}
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
}
