//
//  ModifiableIndentationTest.swift
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

import XCTest

class ModifiableIndentationTest: XCTestCase
{
	override func setUp()
	{
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDown()
	{
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}

	func testNewLineFinder()
	{
		//										 0123 4567891 123
		var textStorage = NSTextStorage(string: "car\nbanana\nsky")

		for index in 0 ... 3
		{
			XCTAssertEqual(0, textStorage.findLineStartFromLocation(index))
		}

		for index in 4 ... 10
		{
			XCTAssertEqual(4, textStorage.findLineStartFromLocation(index))
		}

		for index in 11 ... 13
		{
			XCTAssertEqual(11, textStorage.findLineStartFromLocation(index))
		}

		//									 0 1 2345 6789112 3456 78 9
		textStorage = NSTextStorage(string: "\n\ncar\nbanana\nsky\na\n\n")

		XCTAssertEqual(0, textStorage.findLineStartFromLocation(0))
		XCTAssertEqual(1, textStorage.findLineStartFromLocation(1))

		for index in 2 ... 5
		{
			XCTAssertEqual(2, textStorage.findLineStartFromLocation(index))
		}

		for index in 6 ... 12
		{
			XCTAssertEqual(6, textStorage.findLineStartFromLocation(index))
		}

		for index in 13 ... 16
		{
			XCTAssertEqual(13, textStorage.findLineStartFromLocation(index))
		}

		for index in 17 ... 18
		{
			XCTAssertEqual(17, textStorage.findLineStartFromLocation(index))
		}

		XCTAssertEqual(19, textStorage.findLineStartFromLocation(19))
		XCTAssertEqual(19, textStorage.findLineStartFromLocation(20))
		XCTAssertEqual(19, textStorage.findLineStartFromLocation(21))


		XCTAssertEqual(0, textStorage.findLineStartFromLocation(-1))
	}

	func testNewLineFinderOnlyNewLines()
	{
		let textStorage = NSTextStorage(string: "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")

		for index in 0 ... 14
		{
			XCTAssertEqual(index, textStorage.findLineStartFromLocation(index))
		}

		XCTAssertEqual(0, textStorage.findLineStartFromLocation(-1))
		XCTAssertEqual(14, textStorage.findLineStartFromLocation(15))
	}

	func testSingleRangeZeroLength()
	{
		let textStorage = NSTextStorage(string: "The test string")

		// Try simple indent
		XCTAssert(rangeArraysEqual([NSMakeRange(1, 0)], textStorage.increaseIndentForSelectedRanges([NSMakeRange(0, 0)])))
		XCTAssertEqual("\tThe test string", textStorage.string)

		// Try simple unindent
		XCTAssert(rangeArraysEqual([NSMakeRange(0, 0)], textStorage.decreaseIndentForSelectedRanges([NSMakeRange(0, 0)])))
		XCTAssertEqual("The test string", textStorage.string)

		// Try two consecutive simple indents
		XCTAssert(rangeArraysEqual([NSMakeRange(1, 0)], textStorage.increaseIndentForSelectedRanges([NSMakeRange(0, 0)])))
		XCTAssert(rangeArraysEqual([NSMakeRange(1, 0)], textStorage.increaseIndentForSelectedRanges([NSMakeRange(0, 0)])))
		XCTAssertEqual("\t\tThe test string", textStorage.string)

		// Try two consecutive simple unindents
		XCTAssert(rangeArraysEqual([NSMakeRange(0, 0)], textStorage.decreaseIndentForSelectedRanges([NSMakeRange(0, 0)])))
		XCTAssert(rangeArraysEqual([NSMakeRange(0, 0)], textStorage.decreaseIndentForSelectedRanges([NSMakeRange(0, 0)])))
		XCTAssertEqual("The test string", textStorage.string)

		// Add a new line of text
		var lineLength = textStorage.length
		textStorage.append(NSAttributedString.init(string: "\nAnother test string"))
		XCTAssertEqual("The test string\nAnother test string", textStorage.string)

		// Try indenting second line only
		XCTAssert(rangeArraysEqual([NSMakeRange(lineLength + 2, 0)],
		                           textStorage.increaseIndentForSelectedRanges([NSMakeRange(lineLength + 1, 0)])))
		XCTAssertEqual("The test string\n\tAnother test string", textStorage.string)

		// Try unindenting second line only
		XCTAssert(rangeArraysEqual([NSMakeRange(lineLength + 1, 0)],
		                           textStorage.decreaseIndentForSelectedRanges([NSMakeRange(lineLength + 1, 0)])))
		XCTAssertEqual("The test string\nAnother test string", textStorage.string)

		// Try indenting second line only by placing caret in middle of the line
		XCTAssert(rangeArraysEqual([NSMakeRange(lineLength + 7, 0)],
		                           textStorage.increaseIndentForSelectedRanges([NSMakeRange(lineLength + 6, 0)])))
		XCTAssertEqual("The test string\n\tAnother test string", textStorage.string)

		// Try unindenting second line only by placing caret in middle of the line
		XCTAssert(rangeArraysEqual([NSMakeRange(lineLength + 6, 0)],
		                           textStorage.decreaseIndentForSelectedRanges([NSMakeRange(lineLength + 7, 0)])))
		XCTAssertEqual("The test string\nAnother test string", textStorage.string)

		// Try indenting second line only by placing caret in middle of the line
		XCTAssert(rangeArraysEqual([NSMakeRange(lineLength + 7, 0)],
		                           textStorage.increaseIndentForSelectedRanges([NSMakeRange(lineLength + 6, 0)])))
		XCTAssert(rangeArraysEqual([NSMakeRange(lineLength + 8, 0)],
		                           textStorage.increaseIndentForSelectedRanges([NSMakeRange(lineLength + 7, 0)])))
		XCTAssertEqual("The test string\n\t\tAnother test string", textStorage.string)

		// Try unindenting second line only by placing caret in middle of the line
		XCTAssert(rangeArraysEqual([NSMakeRange(lineLength + 7, 0)],
		                           textStorage.decreaseIndentForSelectedRanges([NSMakeRange(lineLength + 8, 0)])))
		XCTAssert(rangeArraysEqual([NSMakeRange(lineLength + 6, 0)],
		                           textStorage.decreaseIndentForSelectedRanges([NSMakeRange(lineLength + 7, 0)])))
		XCTAssertEqual("The test string\nAnother test string", textStorage.string)

		// Try simple indent by placing caret in end of the line
		lineLength = textStorage.length
		XCTAssert(rangeArraysEqual([NSMakeRange(lineLength + 1, 0)],
		                           textStorage.increaseIndentForSelectedRanges([NSMakeRange(lineLength, 0)])))
		XCTAssertEqual("The test string\n\tAnother test string", textStorage.string)

		// Try simple unindent by placing caret in end of the line
		lineLength = textStorage.length
		XCTAssert(rangeArraysEqual([NSMakeRange(lineLength - 1, 0)],
		                           textStorage.decreaseIndentForSelectedRanges([NSMakeRange(lineLength, 0)])))
		XCTAssertEqual("The test string\nAnother test string", textStorage.string)
	}

	func testSingleRangeNonZeroLength()
	{
		var textStorage = NSTextStorage(string: "The test string")

		// Try simple indent
		XCTAssert(rangeArraysEqual([NSMakeRange(1, 5)], textStorage.increaseIndentForSelectedRanges([NSMakeRange(0, 5)])))
		XCTAssertEqual("\tThe test string", textStorage.string)

		// Try simple unindent
		XCTAssert(rangeArraysEqual([NSMakeRange(0, 5)], textStorage.decreaseIndentForSelectedRanges([NSMakeRange(1, 5)])))
		XCTAssertEqual("The test string", textStorage.string)

		// Try two consecutive simple indents
		XCTAssert(rangeArraysEqual([NSMakeRange(1, 7)], textStorage.increaseIndentForSelectedRanges([NSMakeRange(0, 7)])))
		XCTAssert(rangeArraysEqual([NSMakeRange(2, 7)], textStorage.increaseIndentForSelectedRanges([NSMakeRange(1, 7)])))
		XCTAssertEqual("\t\tThe test string", textStorage.string)

		// Try two consecutive simple unindents
		XCTAssert(rangeArraysEqual([NSMakeRange(1, 7)], textStorage.decreaseIndentForSelectedRanges([NSMakeRange(2, 7)])))
		XCTAssert(rangeArraysEqual([NSMakeRange(0, 7)], textStorage.decreaseIndentForSelectedRanges([NSMakeRange(1, 7)])))
		XCTAssertEqual("The test string", textStorage.string)

		textStorage.append(NSAttributedString.init(string: "\nHold it\nWait a minute...\nI can't read my writing, my own writing!"))
		XCTAssertEqual("The test string\nHold it\nWait a minute...\nI can't read my writing, my own writing!", textStorage.string)

		// Test indent all lines in entire text
		let length = textStorage.length
		XCTAssert(rangeArraysEqual([NSMakeRange(1, length + 3)], textStorage.increaseIndentForSelectedRanges([NSMakeRange(0, length)])))

		// Test unindent all lines in entire text
		XCTAssert(rangeArraysEqual([NSMakeRange(0, length)], textStorage.decreaseIndentForSelectedRanges([NSMakeRange(1, length + 3)])))

		textStorage = NSTextStorage(string: "extension EditorView\n{\n\tenum WaitStatus\n\t{\n\t\tcase none\n\t\tcase waiting(timeout: TimeInterval)\n\t}\n}\n\n\n\n\n")
		XCTAssert(rangeArraysEqual([NSMakeRange(0, 92)], textStorage.decreaseIndentForSelectedRanges([NSMakeRange(0, 97)])))
		XCTAssert(rangeArraysEqual([NSMakeRange(0, 90)], textStorage.decreaseIndentForSelectedRanges([NSMakeRange(0, 92)])))
	}

	func testIndentEdgeCases()
	{
		let textStorage = NSTextStorage(string: "Hold it\nWait a minute...\nI can't read my writing, my own writing!")

		// Atempt to un-indent non-indented line
		XCTAssert(rangeArraysEqual([NSMakeRange(8, 0)], textStorage.decreaseIndentForSelectedRanges([NSMakeRange(8, 0)])))
		XCTAssertEqual("Hold it\nWait a minute...\nI can't read my writing, my own writing!", textStorage.string)

		// Attempt un-indent by placing caret in the EOF
		let length = textStorage.length
		XCTAssert(rangeArraysEqual([NSMakeRange(length, 0)], textStorage.decreaseIndentForSelectedRanges([NSMakeRange(length, 0)])))
		XCTAssertEqual("Hold it\nWait a minute...\nI can't read my writing, my own writing!", textStorage.string)
	}

	func testMultipleRangesZeroLength()
	{
		// Even though the text editor doesn't currently support multiple zero-length ranges, we will test the algorithm anyway
		let textStorage = NSTextStorage(string: "Hold it\nWait a minute...\nI can't read my writing, my own writing!")

		XCTAssert(rangeArraysEqual([NSMakeRange(1, 0), NSMakeRange(10, 0)],
		                           textStorage.increaseIndentForSelectedRanges([NSMakeRange(0, 0), NSMakeRange(8, 0)])))
		XCTAssertEqual("\tHold it\n\tWait a minute...\nI can't read my writing, my own writing!", textStorage.string)

		XCTAssert(rangeArraysEqual([NSMakeRange(0, 0), NSMakeRange(8, 0)],
		                           textStorage.decreaseIndentForSelectedRanges([NSMakeRange(1, 0), NSMakeRange(10, 0)])))
		XCTAssertEqual("Hold it\nWait a minute...\nI can't read my writing, my own writing!", textStorage.string)

		XCTAssert(rangeArraysEqual([NSMakeRange(19, 0), NSMakeRange(54, 0)],
		                           textStorage.increaseIndentForSelectedRanges([NSMakeRange(18, 0), NSMakeRange(52, 0)])))
		XCTAssertEqual("Hold it\n\tWait a minute...\n\tI can't read my writing, my own writing!", textStorage.string)

		XCTAssert(rangeArraysEqual([NSMakeRange(18, 0), NSMakeRange(52, 0)],
		                           textStorage.decreaseIndentForSelectedRanges([NSMakeRange(19, 0), NSMakeRange(54, 0)])))
		XCTAssertEqual("Hold it\nWait a minute...\nI can't read my writing, my own writing!", textStorage.string)
	}
}

func rangeArraysEqual(_ first: [NSRange], _ second: [NSRange]) -> Bool
{
	return first.elementsEqual(second) { return NSEqualRanges($0, $1) }
}
