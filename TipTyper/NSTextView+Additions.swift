//
// Created by Bruno Philipe on 12/3/17.
// Copyright (c) 2017 Bruno Philipe. All rights reserved.
//

import AppKit

extension NSTextView
{
	func forceLayoutToCharacterIndex(_ index: Int)
	{
		var loc = index

		if loc > 0, let len = self.textStorage?.length, len > 0
		{
			if loc >= len
			{
				loc = len - 1
			}

			/* Find out which glyph index the desired character index corresponds to */
			if let glyphRange = layoutManager?.glyphRange(forCharacterRange: NSMakeRange(loc, 1), actualCharacterRange: nil),
			   glyphRange.location > 0
			{
				/* Now cause layout by asking a question which has to determine where the glyph is */
				_ = layoutManager?.textContainer(forGlyphAt: glyphRange.location - 1, effectiveRange: nil)
			}
		}
	}
}