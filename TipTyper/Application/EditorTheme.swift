//
//  EditorTheme.swift
//  TipTyper
//
//  Created by Bruno Philipe on 23/02/2017.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

protocol EditorTheme
{
	var name: String { get }
	
	var windowBackground: NSColor { get }
	
	var editorForeground: NSColor { get }
	var editorBackground: NSColor { get }
	
	var lineCounterForeground: NSColor { get }
	var lineCounterBackground: NSColor { get }
}

private let kThemeNameKey					= "name"
private let kThemeWindowBackgroundKey		= "window_background"
private let kThemeEditorBackgroundKey		= "editor_background"
private let kThemeLineCounterBackgroundKey	= "lines_background"
private let kThemeEditorForegroundKey		= "editor_foreground"
private let kThemeLineCounterForegroundKey	= "lines_foreground"

extension EditorTheme
{
	var serialized: [String: AnyObject]
	{
		return [
			kThemeNameKey:					name as NSString,
			kThemeWindowBackgroundKey:		windowBackground,
			kThemeEditorBackgroundKey:		editorBackground,
			kThemeLineCounterBackgroundKey:	lineCounterBackground,
			kThemeEditorForegroundKey:		editorForeground,
			kThemeLineCounterForegroundKey:	lineCounterForeground
		]
	}
	
	func make(fromSerialized dict: [String: AnyObject]) -> EditorTheme
	{
		return ConcreteThemeEditor(fromSerialized: dict)
	}
}

fileprivate class ConcreteThemeEditor: EditorTheme
{
	private var serializedDictionary: [String: AnyObject]
	
	fileprivate init(fromSerialized dict: [String: AnyObject])
	{
		serializedDictionary = dict
	}
	
	var name: String
	{
		return (serializedDictionary[kThemeNameKey] as? String) ?? "(Unamed)"
	}
	
	var windowBackground: NSColor
	{
		return serializedColor(withKey: kThemeWindowBackgroundKey) ?? NSColor(rgb: 0xFDFDFD)
	}
	
	var editorForeground: NSColor
	{
		return serializedColor(withKey: kThemeEditorForegroundKey) ?? NSColor.black
	}
	
	var editorBackground: NSColor
	{
		return serializedColor(withKey: kThemeEditorBackgroundKey) ?? NSColor.clear
	}
	
	var lineCounterForeground: NSColor
	{
		return serializedColor(withKey: kThemeLineCounterForegroundKey) ?? NSColor(rgb: 999999)
	}
	
	var lineCounterBackground: NSColor
	{
		return serializedColor(withKey: kThemeLineCounterBackgroundKey) ?? NSColor(rgb: 0xF5F5F5)
	}
	
	private func serializedColor(withKey key: String) -> NSColor?
	{
		if let colorRGB = serializedDictionary[key] as? UInt
		{
			return NSColor(rgb: colorRGB)
		}
		
		return nil
	}
}

struct LightEditorTheme: EditorTheme
{
	var name: String
	{
		return "Light"
	}
	
	var windowBackground: NSColor
	{
		return NSColor(rgb: 0xFDFDFD)
	}
	
	var editorForeground: NSColor
	{
		return NSColor.black
	}
	
	var editorBackground: NSColor
	{
		return NSColor.clear
	}
	
	var lineCounterForeground: NSColor
	{
		return NSColor(rgb: 999999)
	}
	
	var lineCounterBackground: NSColor
	{
		return NSColor(rgb: 0xF5F5F5)
	}
}
