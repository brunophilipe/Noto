//
//  EditorView.swift
//  TipTyper
//
//  Created by Bruno Philipe on 21/2/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

class EditorView: PaddedTextView
{
	private let invisiblesLayoutManager = InvisiblesLayoutManager()
	private var tabSize: UInt = 4

	var lineCounterView: LineCounterRulerView? = nil
	var usesSpacesForTabs: Bool = false

	override func awakeFromNib()
	{
		super.awakeFromNib()

		self.textContainer?.replaceLayoutManager(invisiblesLayoutManager)

		if let scrollView = self.enclosingScrollView
		{
			let lineCounterView = LineCounterRulerView(scrollView: scrollView, orientation: .verticalRuler)
			lineCounterView.clientView = self

			scrollView.horizontalRulerView = nil
			scrollView.verticalRulerView = lineCounterView

			scrollView.hasHorizontalRuler = false
			scrollView.hasVerticalRuler = true
			scrollView.rulersVisible = true

			self.lineCounterView = lineCounterView
		}
	}

	deinit
	{
		// Break cyclic reference before the text view deallocs
		lineCounterView?.clientView = nil

		if let scrollView = self.enclosingScrollView
		{
			scrollView.rulersVisible = false
			scrollView.hasVerticalRuler = false
			scrollView.verticalRulerView = nil
		}
	}

	override func insertTab(_ sender: Any?)
	{
		if usesSpacesForTabs
		{
			insertText(String.init(repeating: " ", count: Int(tabSize)), replacementRange: NSRange(location: NSNotFound, length: 0))
		}
		else
		{
			super.insertTab(sender)
		}
	}

	// Has to be updated when font size changes
	func setTabWidth(_ width: UInt)
	{
		// Update paragraph style
		let paragraphStyle = (defaultParagraphStyle ?? NSParagraphStyle.default()).mutableCopy() as! NSMutableParagraphStyle
		let characterWidth = (font ?? NSFont.systemFont(ofSize: 14)).screenFont(with: .antialiasedRenderingMode).advancement(forGlyph: NSGlyph(" "))

		paragraphStyle.defaultTabInterval = CGFloat(width) * characterWidth.width
		paragraphStyle.tabStops = []

		defaultParagraphStyle = paragraphStyle

		// Re-render current text with new typing attributes
		var typingAttributes = self.typingAttributes
		typingAttributes[NSParagraphStyleAttributeName] = paragraphStyle
		self.typingAttributes = typingAttributes

		if let textString: NSString = self.string as NSString?
		{
			let textRange = NSMakeRange(0, textString.length)
			shouldChangeText(in: textRange, replacementString: nil)
			textStorage?.setAttributes(typingAttributes, range: textRange)
			didChangeText()
		}
	}
    
}
