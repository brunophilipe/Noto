//
//  PaddedTextView.swift
//  TipTyper
//
//  Created by Bruno Philipe on 21/2/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

class PaddedTextView: NSTextView
{
	override func awakeFromNib()
	{
		super.awakeFromNib()

		super.textContainerInset = NSSize(width: 15.0, height: 5.0)
	}

	override var textContainerOrigin: NSPoint
	{
		let origin = super.textContainerOrigin
		return NSPoint(x: origin.x + 5.0, y: origin.y)
	}
}
