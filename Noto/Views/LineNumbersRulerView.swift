//
//  LineNumbersRulerView.swift
//  Noto
//
//  Created by Bruno Philipe on 21/2/17.
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

import Cocoa

let kRulerMargin: CGFloat = 10.0

class LineNumbersRulerView: NSRulerView
{
	// Index of newline characters locations
	private var lineIndexes: [UInt : UInt] = [:]

	// MARK: - Initializers and Deinitializer

	override init(scrollView: NSScrollView?, orientation: NSRulerOrientation)
	{
		super.init(scrollView: scrollView, orientation: orientation)

		setupStateObservers()
	}

	required init(coder: NSCoder)
	{
		super.init(coder: coder)

		setupStateObservers()
	}

	deinit
	{
		clientView = nil
		NotificationCenter.default.removeObserver(self)
		Preferences.instance.removeObserver(self, forKeyPath: "lineNumbersFont")
		Preferences.instance.removeObserver(self, forKeyPath: "editorFont")
	}

	var font = Preferences.instance.lineNumbersFont
	{
		didSet
		{
			invalidateHashMarks()
		}
	}

	var backgroundColor = NSColor(rgb: 0xF5F5F5)
	{
		didSet
		{
			invalidateHashMarks()
			needsDisplay = true
		}
	}

	var textColor = NSColor(rgb: 999999)
	{
		didSet
		{
			invalidateHashMarks()
			needsDisplay = true
		}
	}

	// MARK: - Notifications

	override func observeValue(forKeyPath keyPath: String?,
	                           of object: Any?,
	                           change: [NSKeyValueChangeKey : Any]?,
	                           context: UnsafeMutableRawPointer?)
	{
		if let keyPath = keyPath, ["lineNumbersFont", "editorFont"].contains(keyPath) && object is Preferences
		{
			let pref = Preferences.instance
			var font = pref.lineNumbersFont
			
			if font.pointSize > pref.editorFont.pointSize,
				let smallerFont = NSFont(descriptor: font.fontDescriptor, size: pref.editorFont.pointSize)
			{
				font = smallerFont
			}
			
			self.font = font
		}
	}

	func textDidChange(notification: Notification)
	{
		updateLineInfos()
		needsDisplay = true
		needsLayout = true
	}

	func scrollViewDidScroll(notification: Notification)
	{
		needsDisplay = true
	}

	func reindexLinesForPrinting()
	{
		updateLineInfos()
	}

	// MARK: - Override Methods

	override var clientView: NSView?
	{
		didSet
		{
			NotificationCenter.default.removeObserver(self)

			if clientView == nil
			{
				return
			}

			if let textView = self.textView
			{
				NotificationCenter.default.addObserver(self,
				                                       selector: #selector(LineNumbersRulerView.textDidChange(notification:)),
				                                       name: .NSTextStorageDidProcessEditing,
				                                       object: textView.textStorage)
			}

			if let contentView = scrollView?.contentView
			{
				NotificationCenter.default.addObserver(self,
				                                       selector: #selector(LineNumbersRulerView.scrollViewDidScroll(notification:)),
				                                       name: .NSViewBoundsDidChange,
				                                       object: contentView)
			}

			updateLineInfos()
		}
	}

	override func drawHashMarksAndLabels(in rect: NSRect)
	{
		guard let layoutManager		= textView?.layoutManager,
			  let textContainer		= textView?.textContainer,
			  let heightInset		= textView?.textContainerInset.height,
			  let visibleRect		= scrollView?.contentView.bounds
		else
		{
			return
		}

		let nullRange = NSMakeRange(NSNotFound, 0)

		backgroundColor.setFill()
		NSRectFill(rect)

		textColor.setStroke()

		let visibleRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
		var startLine = findLineForNearestIndex(index: visibleRange.location)
		let endLine = findLineForNearestIndex(index: NSMaxRange(visibleRange))

		let maxText = "\(endLine + 1)" as NSString
		let maxTextSize = maxText.size(withAttributes: numberTextAttributes)

		if startLine > 1
		{
			startLine -= 2
		}
		else if startLine > 0
		{
			startLine -= 1
		}

		for lineNumber in startLine ... endLine
		{
			if let index = lineIndexes[lineNumber]
			{
				let charRange = NSMakeRange(Int(index), 0)

				layoutManager.enumerateEnclosingRects(forGlyphRange: charRange, withinSelectedGlyphRange: nullRange, in: textContainer, using:
					{
						(rect, stop) in

						let ypos = heightInset + NSMinY(rect) - NSMinY(visibleRect)
						let rect = NSRect(x: kRulerMargin,
						                  y: ypos + (rect.height - maxTextSize.height) / 2.0,
						                  width: NSWidth(self.bounds) - kRulerMargin * 2.0,
						                  height: rect.height)

						"\(lineNumber + 1)".draw(in: rect, withAttributes: self.numberTextAttributes)

						stop.pointee = true
				})
			}
		}
	}

	override var requiredThickness: CGFloat
	{
		let defaultThickness = CGFloat(20.0)
		let digits = Int(log10(Double(max(lineIndexes.count, 1))) + 1)
		let sampleString = String(repeating: "8", count: digits) as NSString
		let requiredThickness = sampleString.size(withAttributes: numberTextAttributes).width

		return ceil(max(defaultThickness, 8.0 + requiredThickness + kRulerMargin * 2.0))
	}

	// MARK: - Private Methods

	private func setupStateObservers()
	{
		Preferences.instance.addObserver(self, forKeyPath: "lineNumbersFont", options: .new, context: nil)
		Preferences.instance.addObserver(self, forKeyPath: "editorFont", options: .new, context: nil)
	}

	private func findLineForNearestIndex(index: Int) -> UInt
	{
		let keys = lineIndexes.keys.sorted()

		// First some optimizations
		if index == 0, let key = lineIndexes[0]
		{
			return key
		}

		var left = 0
		var right = lineIndexes.count
		var mid = 0

		// Then do a binary search
		while (right - left) > 1
		{
			mid = (right + left) / 2

			if let foundIndex = lineIndexes[keys[mid]]
			{
				let distance = index - Int(foundIndex)

				if distance < 0
				{
					right = mid
				}
				else if distance > 0
				{
					left = mid
				}
				else
				{
					return keys[mid]
				}
			}
		}

		return keys[mid]
	}

	private var textView: NSTextView?
	{
		return clientView as? NSTextView
	}

	private var usesRTL: Bool
	{
		return NSApplication.shared().userInterfaceLayoutDirection == .rightToLeft
	}

	private var numberParagraphStyle: NSParagraphStyle
	{
		let style = NSParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle

		style.alignment = usesRTL ? .left : .right

		return style
	}

	private var numberTextAttributes: [String : Any]
	{
		return [
			NSFontAttributeName: font,
			NSForegroundColorAttributeName: textColor,
			NSParagraphStyleAttributeName: numberParagraphStyle
		]
	}

	private func updateLineInfos()
	{
		let oldDigitsCount = Int(log10(Double(max(lineIndexes.count, 1))) + 1)

		lineIndexes.removeAll()

		if let textView = self.textView, let text: NSString = textView.string as NSString?
		{
			if text.length == 0
			{
				self.lineIndexes[0] = 0
			}
			else
			{
				var lineNumber = UInt(0)

				text.enumerateSubstrings(in: NSMakeRange(0, text.length), options: [.byLines, .substringNotRequired])
				{ (_, lineRange, enclosingRange, _) in
					self.lineIndexes[lineNumber] = UInt(enclosingRange.location)
					lineNumber += 1
				}

				if text.character(at: text.length - 1) == unichar(0xA) // newline
				{
					self.lineIndexes[lineNumber] = UInt(text.length)
				}
			}
		}

		let newDigitsCount = Int(log10(Double(max(lineIndexes.count, 1))) + 1)

		if newDigitsCount != oldDigitsCount
		{
			DispatchQueue.main.async
			{
				self.ruleThickness = self.requiredThickness
				self.needsLayout = true
			}
		}
	}
}
