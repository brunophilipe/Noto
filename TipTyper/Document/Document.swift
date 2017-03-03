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
			updateChangeCount(.changeCleared)
			sendDataToWindow()
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
}

