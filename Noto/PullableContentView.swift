//
// Created by Bruno Philipe on 14/3/17.
// Copyright (c) 2017 Bruno Philipe. All rights reserved.
//

import AppKit

class PullableContentView: NSView
{
	var pullsContent: Bool = false

	override func setFrameSize(_ newSize: NSSize)
	{
		// hehehehe 😈
		super.setFrameSize(NSSize(width: newSize.width, height: newSize.height + (pullsContent ? 22 : 0)))
	}

	override var wantsDefaultClipping: Bool
	{
		return false
	}
}

class NoClippingScrollView: NSScrollView
{
	override var wantsDefaultClipping: Bool
	{
		return false
	}
}
