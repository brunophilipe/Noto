//
//  NSTextStorage+Indentation.swift
//  TipTyper
//
//  Created by Bruno Philipe on 26/3/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import AppKit

protocol ModifiableIndentation
{
	func increaseIndentForSelectedRanges(_ ranges: [NSRange])
	func decreaseIndentForSelectedRanges(_ ranges: [NSRange])
}

extension NSTextStorage: ModifiableIndentation
{
	func increaseIndentForSelectedRanges(_ ranges: [NSRange])
	{
		insert(NSAttributedString.init(string: "\t"), at: findLineStartFromLocation(ranges[0].location))
	}

	func decreaseIndentForSelectedRanges(_ ranges: [NSRange])
	{
		replaceCharacters(in: NSMakeRange(findLineStartFromLocation(ranges[0].location), 1), with: "")
	}

	func findLineStartFromLocation(_ location: Int) -> NSInteger
	{
		if location <= 0
		{
			return 0
		}
		else
		{
			let string = self.string as NSString
			let totalLength = string.length
			var current = min(location, totalLength) - 1

			repeat
			{
				if string.character(at: current).isNewLine()
				{
					return min(current + 1, totalLength - 1)
				}

				current = max(0, current - 1)
			}
			while (current > 0)

			return current
		}
	}
}

private extension unichar
{
	func isNewLine() -> Bool
	{
		return [0xA, 0xD].contains(self)
	}
}
