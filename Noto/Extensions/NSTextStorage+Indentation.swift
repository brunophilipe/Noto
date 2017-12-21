//
//  NSTextStorage+Indentation.swift
//  Noto
//
//  Created by Bruno Philipe on 26/3/17.
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

import AppKit

protocol ModifiableIndentation
{
	func increaseIndentForSelectedRanges(_ ranges: [NSRange], usingUndoManager: UndoManager?, mode: IndentMode) -> [NSRange]
	func decreaseIndentForSelectedRanges(_ ranges: [NSRange], usingUndoManager: UndoManager?, tabWidth: Int) -> [NSRange]
}

protocol CamelCaseNavigation
{
	func findNextWordInCamelCase(_ range: NSRange) -> NSRange
	func findPreviousWordInCamelCase(_ range: NSRange) -> NSRange

	func expandSelectionForwardsInCamelCase(_ range: NSRange) -> NSRange
	func expandSelectionBackwardsInCamelCase(_ range: NSRange) -> NSRange
}

enum IndentMode
{
	case tab
	case space(Int)
}

extension NSTextStorage: ModifiableIndentation
{
	func increaseIndentForSelectedRanges(_ ranges: [NSRange], usingUndoManager undoManager: UndoManager?, mode: IndentMode = .tab) -> [NSRange]
	{
		let string = self.string as NSString
		var updatedRanges = [NSRange]()
		var insertedCharacters = 0

		undoManager?.beginUndoGrouping()
		beginEditing()

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

		endEditing()
		undoManager?.endUndoGrouping()

		return updatedRanges
	}

	func decreaseIndentForSelectedRanges(_ ranges: [NSRange], usingUndoManager undoManager: UndoManager?, tabWidth: Int = 4) -> [NSRange]
	{
		let string = self.string as NSString
		var updatedRanges = [NSRange]()
		var removedCharacters = 0

		var hasBegunUndoGrouping = false
		beginEditing()

		for range in ranges
		{
			let lineRange = string.lineRange(for: range)
			var removedCharactersForRange = 0

			string.enumerateSubstrings(in: lineRange, options: .byLines)
			{
				(_, _, enclosingRange, _) in

				var previousContents: String? = nil
				var undoRange: NSRange? = nil
				
				// Look for tabs
				if string.character(at: enclosingRange.location).isTab()
				{
					let replacementRange = NSMakeRange(enclosingRange.location - removedCharacters - removedCharactersForRange, 1)
					previousContents = self.attributedSubstring(from: replacementRange).string
					undoRange = NSMakeRange(replacementRange.location, 0)

					self.replaceCharacters(in: replacementRange, with: "")

					removedCharactersForRange += 1
				}
				// Look for spaces
				if string.character(at: enclosingRange.location).isSpace()
				{
					var charsToRemove = 1
					
					for i in 1..<tabWidth
					{
						if string.character(at: enclosingRange.location + i).isSpace()
						{
							charsToRemove += 1
						}
						else if string.character(at: enclosingRange.location + i).isTab()
						{
							// In this case we want to remove the tab, otherwise it will just grow to fill the void from the removed spaces.
							charsToRemove += 1
							break
						}
						else
						{
							break
						}
					}
					
					let replacementRange = NSMakeRange(enclosingRange.location - removedCharacters - removedCharactersForRange, charsToRemove)
					previousContents = self.attributedSubstring(from: replacementRange).string
					undoRange = NSMakeRange(replacementRange.location, 0)

					// TODO: NEEDS UNDO
					self.replaceCharacters(in: replacementRange, with: "")
					
					removedCharactersForRange += charsToRemove
				}
				
				if let undoRange = undoRange, let previousContents = previousContents
				{
					// We only begin grouping undos if we are actually going to register one or more undo events, otherwise
					// Cocoa will register an "empty" undo operation for each non-productive key stroke (nothing to unindent),
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
		
		endEditing()

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

	func isSpace() -> Bool
	{
		return self == 0x20
	}
}
