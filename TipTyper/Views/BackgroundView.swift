//
//  BackgroundView.swift
//  TipTyper
//
//  Created by Bruno Philipe on 21/2/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

@IBDesignable
class BackgroundView: NSView
{
	@IBInspectable var backgroundColor: NSColor = NSColor.clear

    override func draw(_ dirtyRect: NSRect)
	{
        backgroundColor.setFill()
		NSRectFill(dirtyRect)
    }
    
}
