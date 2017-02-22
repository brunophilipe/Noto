//
//  LineCounterRulerView.swift
//  TipTyper
//
//  Created by Bruno Philipe on 21/2/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

let kRulerMargin: CGFloat = 10.0

class LineCounterRulerView: NSRulerView
{
	// Index of newline characters locations
	private var lineIndexes: [UInt : String.CharacterView.Index] = [:]

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
		Preferences.instance.removeObserver(self, forKeyPath: "lineCounterFont")
	}

	var font = Preferences.instance.lineCounterFont
	{
		didSet
		{
			needsDisplay = true
		}
	}

	var backgroundColor = NSColor(rgb: 0xF5F5F5)
	{
		didSet
		{
			needsDisplay = true
		}
	}

	var textColor = NSColor(rgb: 999999)
	{
		didSet
		{
			needsDisplay = true
		}
	}

	// MARK: - Notifications

	override func observeValue(forKeyPath keyPath: String?,
	                           of object: Any?,
	                           change: [NSKeyValueChangeKey : Any]?,
	                           context: UnsafeMutableRawPointer?)
	{
		if keyPath == "lineCounterFont" && object is Preferences
		{
			font = Preferences.instance.lineCounterFont
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
				                                       selector: #selector(LineCounterRulerView.textDidChange(notification:)),
				                                       name: .NSTextStorageDidProcessEditing,
				                                       object: textView.textStorage)
			}

			if let contentView = scrollView?.contentView
			{
				NotificationCenter.default.addObserver(self,
				                                       selector: #selector(LineCounterRulerView.scrollViewDidScroll(notification:)),
				                                       name: .NSViewBoundsDidChange,
				                                       object: contentView)
			}

			updateLineInfos()
		}
	}

	override func drawHashMarksAndLabels(in rect: NSRect)
	{
		guard let layoutManager	= textView?.layoutManager,
			  let textContainer	= textView?.textContainer,
			  let heightInset	= textView?.textContainerInset.height,
			  let visibleRect	= scrollView?.contentView.bounds,
			  let text			= textView?.string
		else
		{
			return
		}

		let nullRange = NSMakeRange(NSNotFound, 0)

		backgroundColor.setFill()
		NSRectFill(rect)

		textColor.setStroke()

		for (lineNumber, index) in lineIndexes
		{
			let charRange = NSMakeRange(Int(text.distance(from: text.startIndex, to: index)), 0)
			var rectCount: Int = 0
			if let rectArray = layoutManager.rectArray(forCharacterRange: charRange,
			                                           withinSelectedCharacterRange: nullRange,
			                                           in: textContainer,
			                                           rectCount: &rectCount),
				rectCount > 0
			{
				let ypos = heightInset + NSMinY(rectArray[0]) - NSMinY(visibleRect);
				let lineText = "\(lineNumber + 1)" as NSString
				let textSize = lineText.size(withAttributes: numberTextAttributes)

				let rect = NSRect(x: kRulerMargin,
				                  y: ypos + (rectArray[0].height - textSize.height) / 2.0,
				                  width: NSWidth(bounds) - kRulerMargin * 2.0,
				                  height: rectArray[0].height)

				lineText.draw(in: rect, withAttributes: numberTextAttributes)
			}
		}
	}

	override var requiredThickness: CGFloat
	{
		let defaultThickness = CGFloat(20.0)
		let digits = Int(log10(Double(max(lineIndexes.count, 1))) + 1)
		let sampleString = String(repeating: "8", count: digits) as NSString
		let requiredThickness = sampleString.size(withAttributes: numberTextAttributes).width

		return ceil(max(defaultThickness, requiredThickness + kRulerMargin * 2.0))
	}

	// MARK: - Private Methods

	private func setupStateObservers()
	{
		Preferences.instance.addObserver(self, forKeyPath: "lineCounterFont", options: .new, context: nil)
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
		if let textView = self.textView
		{
			lineIndexes.removeAll()

			let text = textView.string ?? ""
			let chars = text.characters
			var lineNumber = UInt(0)

			text.enumerateSubstrings(in: chars.startIndex ..< chars.endIndex, options: .byLines)
			{ (_, lineRange, enclosingRange, _) in
				self.lineIndexes[lineNumber] = enclosingRange.lowerBound
				lineNumber += 1
			}

			if text == "" || chars[text.index(before: text.endIndex)] == "\n"
			{
				self.lineIndexes[lineNumber] = text.endIndex
			}
		}
	}
}

infix operator ?=

func ?=<T>(lho: inout T, rho: T?)
{
	if let newValue = rho
	{
		lho = newValue
	}
}
