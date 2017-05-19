//
// Created by Bruno Philipe on 12/3/17.
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

extension EditorView
{
	func setColorsFromTheme(theme: EditorTheme)
	{
		backgroundColor = theme.editorBackground
		textColor = theme.editorForeground
		lineNumbersView?.textColor = theme.lineNumbersForeground
		lineNumbersView?.backgroundColor = theme.lineNumbersBackground
	}
}
