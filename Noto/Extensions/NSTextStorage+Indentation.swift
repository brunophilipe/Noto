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
			var insertedCharactersForRange = 0
			let lineRange = string.lineRange(for: NSMakeRange(range.location, range.length))

			string.enumerateSubstrings(in: lineRange, options: .byLines)
			{
				(_, lineRange, enclosingRange, _) in

				self.replaceCharacters(in: NSMakeRange(enclosingRange.location + insertedCharacters + insertedCharactersForRange, 0),
				                       with: "\t")

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

		return updatedRanges
	}

	func decreaseIndentForSelectedRanges(_ ranges: [NSRange]) -> [NSRange]
	{
		let string = self.string as NSString
		var updatedRanges = [NSRange]()
		var removedCharacters = 0

		for range in ranges
		{
			let lineRange = string.lineRange(for: range)
			var removedCharactersForRange = 0

			string.enumerateSubstrings(in: lineRange, options: .byLines)
			{
				(_, _, enclosingRange, _) in

				if string.character(at: enclosingRange.location).isTab()
				{
					self.replaceCharacters(in: NSMakeRange(enclosingRange.location - removedCharacters - removedCharactersForRange, 1),
					                       with: "")

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
