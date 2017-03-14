//
// Created by Bruno Philipe on 14/3/17.
// Copyright (c) 2017 Bruno Philipe. All rights reserved.
//

import AppKit

class PullableContentView: NSView
{
	var pullsContent: Bool = true

	override func alignmentRect(forFrame frame: NSRect) -> NSRect
	{
		return NSRect(x: frame.origin.x,
		              y: frame.origin.y,
		              width: frame.size.width,
		              height: frame.size.height + (pullsContent ? 22 : 0))
	}

	override func frame(forAlignmentRect alignmentRect: NSRect) -> NSRect
	{
		return NSRect(x: alignmentRect.origin.x,
		              y: alignmentRect.origin.y,
		              width: alignmentRect.size.width,
		              height: alignmentRect.size.height)
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
