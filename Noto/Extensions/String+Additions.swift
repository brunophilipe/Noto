//
// Created by Bruno Philipe on 8/3/17.
// Copyright (c) 2017 Bruno Philipe. All rights reserved.
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

import Foundation

extension String
{
	var fullStringRange: Range<Index>
	{
		return startIndex..<endIndex
	}
	
	var metrics: StringMetrics
	{
		var wordsCount = 0
		var linesCount = 0
		var characterCount = 0
		var whitespaceCharsCount = 0
		
		let totalCharsCount = characters.count
		
		let whitespaceCharacterSet = NSCharacterSet.whitespacesAndNewlines
		
		characters.forEach
		{
			character in
			
			if String(character).rangeOfCharacter(from: whitespaceCharacterSet) == nil
			{
				characterCount += 1
			}
			else
			{
				whitespaceCharsCount += 1
			}
		}
		
		enumerateSubstrings(in: fullStringRange, options: [.byWords, .substringNotRequired], { _ in wordsCount += 1 })
		enumerateSubstrings(in: fullStringRange, options: [.byLines, .substringNotRequired], { _ in linesCount += 1 })
		
		if totalCharsCount == 0 || substring(with: index(before: endIndex)..<endIndex) == "\n"
		{
			linesCount += 1
		}
		
		return StringMetrics(characterCount, whitespaceCharsCount, wordsCount, linesCount)
	}
}

struct StringMetrics
{
	let chars: Int
	let whitespaceChars: Int
	let words: Int
	let lines: Int
	
	init(_ characterCount: Int, _ whitespaceCharsCount: Int, _ wordsCount: Int, _ linesCount: Int)
	{
		chars = characterCount
		whitespaceChars = whitespaceCharsCount
		words = wordsCount
		lines = linesCount
	}
	
	var allCharacters: Int
	{
		return chars + whitespaceChars
	}
}

func +(lhs: StringMetrics, rhs: StringMetrics) -> StringMetrics
{
	return StringMetrics(lhs.chars + rhs.chars, lhs.whitespaceChars + rhs.whitespaceChars, lhs.words + rhs.words, lhs.lines + rhs.lines)
}

extension NSString
{
	var fullStringRange: NSRange
	{
		return NSMakeRange(0, length)
	}
}
