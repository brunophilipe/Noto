//
//  ModifiableIndentationTest.swift
//  TipTyper
//
//  Created by Bruno Philipe on 26/3/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
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
		textStorage.increaseIndentForSelectedRanges([NSMakeRange(0, 0)])
		XCTAssertEqual("\tThe test string", textStorage.string)

		// Try simple unindent
		textStorage.decreaseIndentForSelectedRanges([NSMakeRange(0, 0)])
		XCTAssertEqual("The test string", textStorage.string)

		// Try two consecutive simple indents
		textStorage.increaseIndentForSelectedRanges([NSMakeRange(0, 0)])
		textStorage.increaseIndentForSelectedRanges([NSMakeRange(0, 0)])
		XCTAssertEqual("\t\tThe test string", textStorage.string)

		// Try two consecutive simple unindents
		textStorage.decreaseIndentForSelectedRanges([NSMakeRange(0, 0)])
		textStorage.decreaseIndentForSelectedRanges([NSMakeRange(0, 0)])
		XCTAssertEqual("The test string", textStorage.string)

		// Add a new line of text
		var lineLength = textStorage.length
		textStorage.append(NSAttributedString.init(string: "\nAnother test string"))
		XCTAssertEqual("The test string\nAnother test string", textStorage.string)

		// Try indenting second line only
		textStorage.increaseIndentForSelectedRanges([NSMakeRange(lineLength + 1, 0)])
		XCTAssertEqual("The test string\n\tAnother test string", textStorage.string)

		// Try unindenting second line only
		textStorage.decreaseIndentForSelectedRanges([NSMakeRange(lineLength + 1, 0)])
		XCTAssertEqual("The test string\nAnother test string", textStorage.string)

		// Try indenting second line only by placing caret in middle of the line
		textStorage.increaseIndentForSelectedRanges([NSMakeRange(lineLength + 6, 0)])
		XCTAssertEqual("The test string\n\tAnother test string", textStorage.string)

		// Try unindenting second line only by placing caret in middle of the line
		textStorage.decreaseIndentForSelectedRanges([NSMakeRange(lineLength + 7, 0)])
		XCTAssertEqual("The test string\nAnother test string", textStorage.string)

		// Try indenting second line only by placing caret in middle of the line
		textStorage.increaseIndentForSelectedRanges([NSMakeRange(lineLength + 6, 0)])
		textStorage.increaseIndentForSelectedRanges([NSMakeRange(lineLength + 7, 0)])
		XCTAssertEqual("The test string\n\t\tAnother test string", textStorage.string)

		// Try unindenting second line only by placing caret in middle of the line
		textStorage.decreaseIndentForSelectedRanges([NSMakeRange(lineLength + 8, 0)])
		textStorage.decreaseIndentForSelectedRanges([NSMakeRange(lineLength + 7, 0)])
		XCTAssertEqual("The test string\nAnother test string", textStorage.string)

		// Try simple indent by placing caret in end of the line
		lineLength = textStorage.length
		textStorage.increaseIndentForSelectedRanges([NSMakeRange(lineLength, 0)])
		XCTAssertEqual("The test string\n\tAnother test string", textStorage.string)

		// Try simple unindent by placing caret in end of the line
		lineLength = textStorage.length
		textStorage.decreaseIndentForSelectedRanges([NSMakeRange(lineLength, 0)])
		XCTAssertEqual("The test string\nAnother test string", textStorage.string)
	}
}
