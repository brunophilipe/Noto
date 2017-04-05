//
//  PaddedTextView.swift
//  Noto
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

		textContainerInset = NSSize(width: 10.0, height: 10.0)
	}
}
