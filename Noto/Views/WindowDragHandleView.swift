//
//  WindowDragHandleView.swift
//  Noto
//
//  Created by Bruno Philipe on 11/7/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

// Inheriting from a concrete NSControl was the only hack I found to get mouse events that wouldn't be overriden by NSTextView.
class WindowDragHandleView: NSTextField
{
	private var trackingArea: NSTrackingArea? = nil

	override func viewDidMoveToWindow()
	{
		super.viewDidMoveToWindow()

		translatesAutoresizingMaskIntoConstraints = false
		isEnabled = false
		isBordered = false
		drawsBackground = true
		alphaValue = 0.0
	}

	override var isOpaque: Bool
	{
		return false
	}

	override var mouseDownCanMoveWindow: Bool
	{
		return true
	}

	override func updateTrackingAreas()
	{
		if let trackingArea = self.trackingArea
		{
			removeTrackingArea(trackingArea)
		}

		let trackingArea = NSTrackingArea(rect: bounds,
		                                  options: [.activeAlways, .enabledDuringMouseDrag, .mouseEnteredAndExited],
		                                  owner: self,
		                                  userInfo: nil)

		addTrackingArea(trackingArea)

		self.trackingArea = trackingArea

		super.updateTrackingAreas()
	}

	override func resetCursorRects()
	{
		addCursorRect(bounds, cursor: .crosshair())
	}

	override func mouseEntered(with event: NSEvent)
	{
		backgroundColor = Preferences.instance.editorTheme.lineNumbersBackground

		super.mouseEntered(with: event)

		animator().alphaValue = 1.0
	}

	override func mouseExited(with event: NSEvent)
	{
		super.mouseExited(with: event)

		animator().alphaValue = 0.0
	}
}
