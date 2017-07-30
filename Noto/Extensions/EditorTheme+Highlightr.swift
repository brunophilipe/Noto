//
//  EditorTheme+Highlightr.swift
//  Noto
//
//  Created by Bruno Philipe on 30/7/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation
import Highlightr

extension EditorTheme
{
	func makeHighlightrTheme(withFont font: NSFont) -> Theme
	{
		let themeString = ".hljs{display:block;overflow-x:auto;padding:0.5em;color:#000000;background:#fdfdfd}.hljs-comment,.hljs-quote{color:#a0a1a7;font-style:italic}.hljs-formula{color:#a626a4}.hljs-doctag,.hljs-keyword{color:#a626a4;font-weight:bold;}.hljs-section,.hljs-name,.hljs-selector-tag,.hljs-deletion,.hljs-subst{color:#e45649}.hljs-literal{color:#0184bb;font-weight:bold}.hljs-string,.hljs-regexp,.hljs-addition,.hljs-attribute,.hljs-meta-string{color:#50a14f}.hljs-built_in,.hljs-class,.hljs-type{color:#a626a4;font-weight:bold;}.hljs-attr,.hljs-variable,.hljs-template-variable,.hljs-selector-class,.hljs-selector-attr,.hljs-selector-pseudo,.hljs-number{color:#e5b800}.hljs-symbol,.hljs-bullet,.hljs-link,.hljs-meta,.hljs-selector-id{color:#4078f2}.hljs-emphasis{font-style:italic}.hljs-strong{font-weight:bold}.hljs-link{text-decoration:underline}.hljs-title{}"

		return Theme(themeString: themeString, font: font)
	}
}
