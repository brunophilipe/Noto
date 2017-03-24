//
//  EditorPreferencesViewController.swift
//  TipTyper
//
//  Created by Bruno Philipe on 28/02/2017.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa
import CCNPreferencesWindowController

class EditorPreferencesViewController: NSViewController
{
	fileprivate var preferencesWindow: NSWindow? = nil
	
	@IBOutlet var chooseFontButton: NSButton!
	@IBOutlet var fontNameLabel: NSTextField!
	@IBOutlet var infoBarModeSegmentedControl: NSSegmentedControl!
	
	var smartSubstitutionsOn: NSNumber
	{
		get { return NSNumber(booleanLiteral: Preferences.instance.smartSubstitutionsOn) }
		set { Preferences.instance.smartSubstitutionsOn = newValue.boolValue }
	}
	
	var spellingCheckerOn: NSNumber
	{
		get { return NSNumber(booleanLiteral: Preferences.instance.spellingCheckerOn) }
		set { Preferences.instance.spellingCheckerOn = newValue.boolValue }
	}

	var useSpacesForTabs: NSNumber
	{
		get { return NSNumber(booleanLiteral: Preferences.instance.useSpacesForTabs) }
		set { Preferences.instance.useSpacesForTabs = newValue.boolValue }
	}

	var tabSize: NSNumber
	{
		get { return NSNumber(value: Preferences.instance.tabSize) }
		set { Preferences.instance.tabSize = newValue.uintValue }
	}

	var infoBarMode: NSNumber
	{
		get { return  NSNumber(value: Preferences.instance.infoBarMode.rawValue) }
		set { Preferences.instance.infoBarMode = Preferences.InfoBarMode(rawValue: newValue.intValue) ?? .hud }
	}

	var countsWhitespaces: NSNumber
	{
		get { return NSNumber(booleanLiteral: Preferences.instance.countWhitespacesInTotalCharacters) }
		set { Preferences.instance.countWhitespacesInTotalCharacters = newValue.boolValue }
	}
	
	override func viewDidLoad()
	{
        super.viewDidLoad()
		
		createObservers()
		updateFontPreview()
    }
	
	deinit
	{
		removeObservers()
	}
	
	override func viewDidDisappear()
	{
		super.viewDidDisappear()
		
		NSFontPanel.shared().close()
	}
	
	private func createObservers()
	{
		let pref = Preferences.instance
		
		pref.addObserver(self, forKeyPath: "editorFont", options: .new, context: nil)
		pref.addObserver(self, forKeyPath: "infoBarMode", options: .new, context: nil)
	}
	
	private func removeObservers()
	{
		let pref = Preferences.instance
		
		pref.removeObserver(self, forKeyPath: "editorFont")
		pref.removeObserver(self, forKeyPath: "infoBarMode")
	}
	
	override func observeValue(forKeyPath keyPath: String?,
	                           of object: Any?,
	                           change: [NSKeyValueChangeKey : Any]?,
	                           context: UnsafeMutableRawPointer?)
	{
		if object is Preferences
		{
			switch keyPath
			{
			case .some("editorFont"):
				updateFontPreview()

			case .some("infoBarMode"):
				infoBarModeSegmentedControl.selectedSegment = infoBarMode.intValue

			default:
				break
			}
		}
	}
	
	// Editor Font
	
	@IBAction func didClickChooseFont(_ sender: Any)
	{
		if let window = preferencesWindow
		{
			let fontPanel = NSFontPanel.shared()
			fontPanel.setPanelFont(Preferences.instance.editorFont, isMultiple: false)
			fontPanel.makeKeyAndOrderFront(sender)
			
			window.makeFirstResponder(self)
		}
	}
	
	override var acceptsFirstResponder: Bool
	{
		return true
	}
	
	override func changeFont(_ sender: Any?)
	{
		if let fontManager = sender as? NSFontManager
		{
			let pref = Preferences.instance
			pref.editorFont = fontManager.convert(pref.editorFont)
		}
	}
	
	private func updateFontPreview()
	{
		let pref = Preferences.instance
		let editorFont = pref.editorFont
		
		fontNameLabel.stringValue = "\(editorFont.displayName ?? editorFont.fontName) \(Int(editorFont.pointSize))pt"
	}
}

extension EditorPreferencesViewController: PreferencesController, CCNPreferencesWindowControllerProtocol
{
	public func preferenceIdentifier() -> String!
	{
		return "editor"
	}
	
	func preferenceTitle() -> String!
	{
		return "Editor"
	}
	
	func preferenceIcon() -> NSImage!
	{
		return NSImage(named: NSImageNameFontPanel)
	}
	
	static func make(preferencesWindow window: NSWindow) -> PreferencesController?
	{
		let controller = EditorPreferencesViewController(nibName: "EditorPreferencesViewController", bundle: Bundle.main)
		controller?.preferencesWindow = window
		return controller
	}
}
