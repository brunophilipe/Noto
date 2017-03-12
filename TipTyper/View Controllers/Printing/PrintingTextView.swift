//
// Created by Bruno Philipe on 12/3/17.
// Copyright (c) 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

class PrintingTextView: NSTextView
{
	var printPanelAccessoryController: PrintAccessoryViewController? = nil
	var originalSize: NSSize = NSMakeSize(0, 0)

	private var previousValueOfDocumentSizeInPage: NSSize = NSMakeSize(0, 0)
	private var previousValueOfRewrapContents: Bool = false

	override func knowsPageRange(_ range: NSRangePointer) -> Bool
	{
		if let printInfo = printPanelAccessoryController?.representedObject as? NSPrintInfo,
		   let rewrapContents = printPanelAccessoryController?.rewrapContents.boolValue
		{
			let documentSizeInPage = documentSizeForPrintInfo(printInfo: printInfo)

			if !NSEqualSizes(previousValueOfDocumentSizeInPage, documentSizeInPage) || previousValueOfRewrapContents != rewrapContents
			{
				previousValueOfDocumentSizeInPage = documentSizeInPage
				previousValueOfRewrapContents = rewrapContents

				let size = rewrapContents ? documentSizeInPage : originalSize
				self.frame = NSMakeRect(0, 0, size.width, size.height)

				printInfo.scalingFactor = rewrapContents ? 1.0 : documentSizeInPage.width / originalSize.width

				self.textContainer?.layoutManager?.defaultAttachmentScaling = rewrapContents ? .scaleProportionallyUpOrDown : .scaleNone
				self.forceLayoutToCharacterIndex(Int.max)
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