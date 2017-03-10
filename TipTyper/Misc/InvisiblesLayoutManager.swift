//
//  InvisiblesLayoutManager.swift
//  TipTyper
//
//  Created by Bruno Philipe on 28/2/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

class InvisiblesLayoutManager: NSLayoutManager
{
	var displayInvisibles: Bool = true
	var textInset = NSSize(width: 10, height: 10)

	private let kVisibleGlyphForNewLine: NSString	= "↩︎"
	private let kVisibleGlyphForBlank: NSString		= "⎵"
	private let kVisibleGlyphForTab: NSString		= "⇥"

	private var pointScale: CGFloat = 1
	private var fontPointSize: CGFloat = 14

	private var lastInvisibleFont: NSFont? = nil
	private var lastInvisibleFontSize: CGFloat? = nil

	required init?(coder: NSCoder)
	{
		super.init(coder: coder)

		updateInvalidatables()
	}

	override init()
	{
		super.init()

		updateInvalidatables()
	}

	private func invisiblesFontWithSize(size: CGFloat) -> NSFont
	{
		if lastInvisibleFontSize != size || lastInvisibleFont == nil
		{
			lastInvisibleFontSize = size
			lastInvisibleFont = NSFont(name: "Inconsolata", size: size)
								?? NSFont(name: "Helvetica", size: size)
		}

		return lastInvisibleFont ?? NSFont.systemFont(ofSize: size)
	}

	private func updateInvalidatables()
	{
		pointScale = self.firstTextView?.window?.backingScaleFactor ?? 1.0
		fontPointSize = self.textStorage?.font?.pointSize ?? 14.0
	}

	override func invalidateDisplay(forGlyphRange glyphRange: NSRange)
	{
		updateInvalidatables()

		super.invalidateDisplay(forGlyphRange: glyphRange)
	}

	override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: NSPoint)
	{
		let invisiblesAttributes: [String : Any] = [
			NSForegroundColorAttributeName: (Preferences.instance.editorTheme.editorForeground).withAlphaComponent(0.6),
			NSFontAttributeName: invisiblesFontWithSize(size: fontPointSize * 0.6)
		]

		for glyphIndex in glyphsToShow.location ..< NSMaxRange(glyphsToShow)
		{
			if let storageString: NSString = textStorage?.string as NSString?
			{
				var glyph: NSString? = nil

				switch storageString.character(at: glyphIndex)
				{
				// eol
				case 0x2028, 0x2029, 0x000A, 0x000D:
					glyph = kVisibleGlyphForNewLine

				// space
				case 0x0020:
					glyph = kVisibleGlyphForBlank

				// tab
				case 0x0009:
					glyph = kVisibleGlyphForTab

				// do nothing
				default:
					break
				}

				if let glyph = glyph
				{
					var point = location(forGlyphAt: glyphIndex)
					let rect = lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: nil, withoutAdditionalLayout: true)

					point.x += rect.origin.x + textInset.width
					point.y  = rect.origin.y + rect.height * pow((14.0 / max(fontPointSize, 1)), 0.5)

					glyph.draw(at: point, withAttributes: invisiblesAttributes)
				}
			}
		}

		super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)
	}
}
