//
//  EditorView.swift
//  TipTyper
//
//  Created by Bruno Philipe on 21/2/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

class EditorView: PaddedTextView
{
	var lineCounterView: LineCounterRulerView? = nil

	override func awakeFromNib()
	{
		super.awakeFromNib()

		if let scrollView = self.enclosingScrollView
		{
			let lineCounterView = LineCounterRulerView(scrollView: scrollView, orientation: .verticalRuler)
			lineCounterView.clientView = self

			scrollView.horizontalRulerView = nil
			scrollView.verticalRulerView = lineCounterView

			scrollView.hasHorizontalRuler = false
			scrollView.hasVerticalRuler = true
			scrollView.rulersVisible = true

			self.lineCounterView = lineCounterView
		}
	}

	deinit
	{
		// Break cyclic reference before the text view deallocs
		lineCounterView?.clientView = nil

		if let scrollView = self.enclosingScrollView
		{
			scrollView.rulersVisible = false
			scrollView.hasVerticalRuler = false
			scrollView.verticalRulerView = nil
		}
	}
    
}
