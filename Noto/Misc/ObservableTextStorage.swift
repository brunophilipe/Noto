//
//  ObservableTextStorage.swift
//  Noto
//
//  Created by Bruno Philipe on 23/7/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa
import Highlightr

class ObservableTextStorage: CodeAttributedString
{
	var observer: TextStorageObserver? = nil

	override func edited(_ editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int)
	{
		if editedMask.contains(.editedCharacters)
		{
			print("Changed string(\(delta)): \(attributedSubstring(from: editedRange).string)")
		}

		super.edited(editedMask, range: editedRange, changeInLength: delta)
	}
}

protocol TextStorageObserver
{
	func textStorage(_ textStorage: ObservableTextStorage, didChangeNumberOfCharacters: Int, andWhitespaces: Int)
	func textStorage(_ textStorage: ObservableTextStorage, didChangeNumberOfLines: Int)
	func textStorage(_ textStorage: ObservableTextStorage, didChangeNumberOfWords: Int)
}
