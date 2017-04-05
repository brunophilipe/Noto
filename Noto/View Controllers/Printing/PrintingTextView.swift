//
// Created by Bruno Philipe on 12/3/17.
// Copyright (c) 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

class PrintingView: NSScrollView
{
	public var printPanelAccessoryController: PrintAccessoryViewController? = nil
	public var originalSize: NSSize = NSMakeSize(0, 0)
	public var textView: EditorView

	private var previousValueOfDocumentWidthInPage: CGFloat = 0
	private var previousValueOfRewrapContents: Bool = false
	private var previousValueOfRulersVisible: Bool = false
	
	init(printInfo: NSPrintInfo)
	{
		let rect = NSRect(origin: CGPoint(x: 0, y: 0), size: documentSizeForPrintInfo(printInfo: printInfo))

		textView = EditorView(frame: rect)

		super.init(frame: rect)
		
		self.documentView = textView
		
		textView.awakeFromNib()
	}
	
	required init?(coder: NSCoder)
	{
		textView = EditorView()
		
		super.init(coder: coder)
		
		self.documentView = textView
		
		textView.awakeFromNib()
	}

	override func knowsPageRange(_ range: NSRangePointer) -> Bool
	{
		if let printInfo = printPanelAccessoryController?.representedObject as? NSPrintInfo,
		   let rewrapContents = printPanelAccessoryController?.rewrapContents.boolValue,
		   let rulersVisible = printPanelAccessoryController?.showLineNumbers.boolValue
		{
			let documentWidthInPage = documentSizeForPrintInfo(printInfo: printInfo).width

			if previousValueOfDocumentWidthInPage != documentWidthInPage
					   || previousValueOfRewrapContents != rewrapContents
					   || previousValueOfRulersVisible != rulersVisible
			{
				previousValueOfDocumentWidthInPage = documentWidthInPage
				previousValueOfRewrapContents = rewrapContents
				previousValueOfRulersVisible = rulersVisible

				self.rulersVisible = rulersVisible

				let width = rewrapContents ? documentWidthInPage : originalSize.width
				let height = rewrapContents ? textView.frame.height : originalSize.height
				var size = NSSize(width: width, height: height)

				if rulersVisible, let lineCounterView = textView.lineCounterView
				{
					lineCounterView.reindexLinesForPrinting()
				}

				setFrameSize(size)

				if rulersVisible, let lineCounterView = textView.lineCounterView
				{
					textView.setFrameSize(NSSize(width: size.width - lineCounterView.requiredThickness, height: 20))
				}
				else
				{
					textView.setFrameSize(NSSize(width: size.width, height: 20))
				}

				/* After setting the size of the parent, we need to layout the text to make sure all is visible */
				textView.sizeToFit()

				/* Now we update the scroll view size, to make sure the entire text view is visible */
				size.height = textView.frame.height
				setFrameSize(size)

				needsDisplay = true

				printInfo.scalingFactor = rewrapContents ? 1.0 : roundPercentage(documentWidthInPage / originalSize.width)

				textView.textContainer?.layoutManager?.defaultAttachmentScaling = rewrapContents ? .scaleProportionallyUpOrDown
																								 : .scaleNone
				textView.forceLayoutToCharacterIndex(Int.max)
			}
		}

		return super.knowsPageRange(range)
	}
}

private func documentSizeForPrintInfo(printInfo: NSPrintInfo) -> NSSize
{
	var paperSize = printInfo.paperSize
	paperSize.width -= (printInfo.leftMargin + printInfo.rightMargin) - defaultTextPadding * 2.0
	paperSize.height -= (printInfo.topMargin + printInfo.bottomMargin)
	return paperSize
}

private var defaultTextPadding: CGFloat =
{
	let container = NSTextContainer()
	return container.lineFragmentPadding
}()

private func roundPercentage(_ input: CGFloat) -> CGFloat
{
	return (floor(input * 100.0) * 0.01)
}