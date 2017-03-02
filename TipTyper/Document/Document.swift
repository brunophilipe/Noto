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
	private var loadedData: (string: String, encoding: String.Encoding)? = nil

	override init()
	{
	    super.init()

		// Add your subclass-specific initialization here.
	}

	override func makeWindowControllers()
	{
		super.makeWindowControllers()

		window?.setupUI()

		if let string = loadedData?.string
		{
			window?.text = string
			loadedData = nil
		}
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
		if let data = window?.text.data(using: .utf8)
		{
			return data
		}

		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}

//	override func revert(toContentsOf url: URL, ofType typeName: String) throws
//	{
//		try super.revert(toContentsOf: url, ofType: typeName)
//	}

	override func read(from data: Data, ofType typeName: String) throws
	{
		if let loadedData = EncodingTool.loadStringFromData(data)
		{
			self.loadedData = loadedData
		}
		else
		{
			throw NSError(domain: "com.brunophilipe.TipTyper", code: 1010, userInfo: [NSLocalizedDescriptionKey: "Could not load file"])
		}
	}
}

