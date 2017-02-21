//
//  DocumentWindow.swift
//  TipTyper
//
//  Created by Bruno Philipe on 21/2/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

@IBDesignable
class DocumentWindow: NSWindow
{
	@IBOutlet var textView: NSTextView!

	var text: String
	{
		get
		{
			return textView.string ?? ""
		}

		set
		{
			textView.string = newValue
		}
	}

	func setupUI()
	{
		Preferences.instance.addObserver(self, forKeyPath: "editorFont", options: NSKeyValueObservingOptions.new, context: nil)

		setupWindowStyle()

		updateEditorSettings()
	}

	deinit
	{
		Preferences.instance.removeObserver(self, forKeyPath: "editorFont")
	}

	private func setupWindowStyle()
	{
		backgroundColor = NSColor.white
		titlebarAppearsTransparent = true
	}

	override func observeValue(forKeyPath keyPath: String?,
	                           of object: Any?,
	                           change: [NSKeyValueChangeKey : Any]?,
	                           context: UnsafeMutableRawPointer?)
	{
		if object is Preferences && keyPath == "editorFont"
		{
			textView.font = Preferences.instance.editorFont
		}
	}

	private func updateEditorSettings()
	{
		textView.font = Preferences.instance.editorFont
	}
}
