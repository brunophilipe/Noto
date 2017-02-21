//
//  NSColor+Additions.swift
//  TipTyper
//
//  Created by Bruno Philipe on 21/2/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

extension NSColor
{
	convenience init(rgb: UInt)
	{
		self.init(rgba: (rgb << 8) | 0x000000FF)
	}

	convenience init(rgba: UInt)
	{
		let red		= CGFloat((rgba >> 24) & 0x000000FF) / CGFloat(255.0)
		let green	= CGFloat((rgba >> 16) & 0x000000FF) / CGFloat(255.0)
		let blue	= CGFloat((rgba >>  8) & 0x000000FF) / CGFloat(255.0)
		let alpha	= CGFloat((rgba >>  0) & 0x000000FF) / CGFloat(255.0)

		self.init(red: red, green: green, blue: blue, alpha: alpha)
	}
}
