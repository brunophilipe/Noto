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
	func increaseIndentForSelectedRanges(_ ranges: [NSRange]) -> [NSRange]
	func decreaseIndentForSelectedRanges(_ ranges: [NSRange]) -> [NSRange]
}

extension NSTextStorage: ModifiableIndentation
{
	func increaseIndentForSelectedRanges(_ ranges: [NSRange]) -> [NSRange]
	{
		let string = self.string as NSString
		var updatedRanges = [NSRange]()
		var insertedCharacters = 0

		for range in ranges
		{
			let enclosingRange = string.lineRange(for: NSMakeRange(range.location, range.length))
			self.replaceCharacters(in: NSMakeRange(enclosingRange.location + insertedCharacters, 0), with: "\t")

			insertedCharacters += 1

			// The new range is always guaranteed to be valid, as long as `range` was valid already.
			updatedRanges.append(NSMakeRange(range.location + insertedCharacters, range.length))
		}

		return updatedRanges
	}

	func decreaseIndentForSelectedRanges(_ ranges: [NSRange]) -> [NSRange]
	{
		let string = self.string as NSString
		var updatedRanges = [NSRange]()
		var removedChracters = 0

		for range in ranges
		{
			let enclosingRange = string.lineRange(for: range)
			var offset = 0

			if string.character(at: enclosingRange.location).isTab()
			{
				self.replaceCharacters(in: NSMakeRange(enclosingRange.location - removedChracters, 1), with: "")

				removedChracters += 1

				if enclosingRange.location >= range.location
				{
					// If the removed character comes *AFTER* the caret, then we need to add one to the offset to cancel the default left 
					// shift applied to the selection range after the indentation decrease
					offset = 1
				}
			}

			updatedRanges.append(NSMakeRange(max(max(range.location, enclosingRange.location) - removedChracters + offset, 0),
			                                 range.length))
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
