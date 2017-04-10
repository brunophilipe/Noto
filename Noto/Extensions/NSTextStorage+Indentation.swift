//
//  NSTextStorage+Indentation.swift
//  Noto
//
//  Created by Bruno Philipe on 26/3/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import AppKit

protocol ModifiableIndentation
{
	func increaseIndentForSelectedRanges(_ ranges: [NSRange], usingUndoManager: UndoManager?) -> [NSRange]
	func decreaseIndentForSelectedRanges(_ ranges: [NSRange], usingUndoManager: UndoManager?) -> [NSRange]
}

extension NSTextStorage: ModifiableIndentation
{
	func increaseIndentForSelectedRanges(_ ranges: [NSRange], usingUndoManager undoManager: UndoManager?) -> [NSRange]
	{
		let string = self.string as NSString
		var updatedRanges = [NSRange]()
		var insertedCharacters = 0

		undoManager?.beginUndoGrouping()

		for range in ranges
		{
			var insertedCharactersForRange = 0
			let lineRange = string.lineRange(for: NSMakeRange(range.location, range.length))

			string.enumerateSubstrings(in: lineRange, options: .byLines)
			{
				(_, lineRange, enclosingRange, _) in

				let replacementRange = NSMakeRange(enclosingRange.location + insertedCharacters + insertedCharactersForRange, 0)
				let previousContents = self.attributedSubstring(from: replacementRange)
				let undoRange = NSMakeRange(replacementRange.location, 1)

				self.replaceCharacters(in: replacementRange, with: "\t")

				undoManager?.registerUndo(withTarget: self)
				{
					(target) in

					target.replaceCharacters(in: undoRange, with: previousContents)
				}

				insertedCharactersForRange += 1
			}

			if range.length == 0
			{
				updatedRanges.append(NSMakeRange(range.location + insertedCharacters + insertedCharactersForRange, range.length))
			}
			else if insertedCharactersForRange > 0
			{
				updatedRanges.append(NSMakeRange(range.location + insertedCharacters + 1, range.length + (insertedCharactersForRange - 1)))
			}
			else
			{
				updatedRanges.append(NSMakeRange(range.location + insertedCharacters, range.length))
			}

			insertedCharacters += insertedCharactersForRange
		}

		undoManager?.endUndoGrouping()

		return updatedRanges
	}

	func decreaseIndentForSelectedRanges(_ ranges: [NSRange], usingUndoManager undoManager: UndoManager?) -> [NSRange]
	{
		let string = self.string as NSString
		var updatedRanges = [NSRange]()
		var removedCharacters = 0

		var hasBegunUndoGrouping = false

		for range in ranges
		{
			let lineRange = string.lineRange(for: range)
			var removedCharactersForRange = 0

			string.enumerateSubstrings(in: lineRange, options: .byLines)
			{
				(_, _, enclosingRange, _) in

				if string.character(at: enclosingRange.location).isTab()
				{
					let replacementRange = NSMakeRange(enclosingRange.location - removedCharacters - removedCharactersForRange, 1)
					let previousContents = self.attributedSubstring(from: replacementRange)
					let undoRange = NSMakeRange(replacementRange.location, 0)

					self.replaceCharacters(in: replacementRange, with: "")

					// We only begin grouping undos if we are actually going to register one or more undo events, otherwise Cocoa will 
					// register an "empty" undo operation for each non-productive key stroke (nothing to unindent),
					// and that would produce an unintuitive UX where pressing Cmd+Z doesn't seem to do anything.
					if !hasBegunUndoGrouping
					{
						undoManager?.beginUndoGrouping()
						hasBegunUndoGrouping = true
					}

					undoManager?.registerUndo(withTarget: self)
					{
						(target) in

						target.replaceCharacters(in: undoRange, with: previousContents)
					}

					removedCharactersForRange += 1
				}
			}

			let rangeStart = range.location - removedCharacters

			if range.length == 0
			{
				updatedRanges.append(NSMakeRange(max(rangeStart - removedCharactersForRange, lineRange.location - removedCharacters),
				                                 range.length))
			}
			else if removedCharactersForRange > 0
			{
				if rangeStart - 1 < lineRange.location - removedCharacters
				{
					updatedRanges.append(NSMakeRange(lineRange.location - removedCharacters,
					                                 range.length - removedCharactersForRange))
				}
				else
				{
					updatedRanges.append(NSMakeRange(rangeStart - 1,
					                                 range.length - removedCharactersForRange + 1))
				}
			}
			else
			{
				updatedRanges.append(NSMakeRange(max(rangeStart, lineRange.location - removedCharacters),
				                                 range.length))
			}

			removedCharacters += removedCharactersForRange
		}

		if hasBegunUndoGrouping
		{
			undoManager?.endUndoGrouping()
		}

		return updatedRanges
	}

	func findLineStartFromLocation(_ location: Int) -> NSInteger
	{
		if location <= 0
		{
			return 0
		}

		let string = self.string as NSString
		return string.lineRange(for: NSMakeRange(min(location, string.length - 1), 0)).location
	}
}

extension unichar
{
	func isTab() -> Bool
	{
		return self == 0x9
	}
}
