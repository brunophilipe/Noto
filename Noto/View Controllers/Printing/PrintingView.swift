//
//  PrintingView.swift
//  Noto
//
//  Created by Bruno Philipe on 12/3/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
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

	private let printInfo: NSPrintInfo?
	private let jobTitle: String
	
	init(printInfo: NSPrintInfo, jobTitle: String)
	{
		self.printInfo = printInfo
		self.jobTitle = jobTitle

		let rect = NSRect(origin: CGPoint(x: 0, y: 0), size: documentSizeForPrintInfo(printInfo: printInfo))

		textView = EditorView(frame: rect)

		super.init(frame: rect)
		
		self.documentView = textView

		let userDefaults = UserDefaults.standard

		if !userDefaults.bool(forKey: NSPrintHeaderAndFooter)
		{
			userDefaults.set(true, forKey: NSPrintHeaderAndFooter)
		}
		
		textView.awakeFromNib()
	}
	
	required init?(coder: NSCoder)
	{
		printInfo = nil
		textView = EditorView()

		jobTitle = (coder.decodeObject(forKey: "PrintingViewJobTitle") as? String) ?? "Untitled"
		
		super.init(coder: coder)
		
		self.documentView = textView
		
		textView.awakeFromNib()
	}

	override var pageHeader: NSAttributedString
	{
		var paperWidth = textView.frame.width

		if let printInfo = self.printInfo
		{
			paperWidth = printInfo.paperSize.width - printInfo.rightMargin
		}

		let headerString = NSMutableAttributedString.init(string: "")

		// Adds filename text aligned to center
		if printPanelAccessoryController?.showFileName == true
		{
			let titleParagraphStyle = NSParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
			titleParagraphStyle.tabStops = [NSTextTab.init(textAlignment: .center, location: paperWidth / 2.0, options: [:])]

			headerString.append(NSAttributedString(string: "\t" + jobTitle,
			                                       attributes: [NSParagraphStyleAttributeName: titleParagraphStyle]))
		}

		// Adds print date text aligned to right
		if printPanelAccessoryController?.showDate == true
		{
			let dateParagraphStyle = NSParagraphStyle.default().mutableCopy() as! NSMutableParagraphStyle
			dateParagraphStyle.tabStops = [NSTextTab.init(textAlignment: .right, location: paperWidth, options: [:])]

			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .short
			dateFormatter.timeStyle = .short

			headerString.append(NSAttributedString(string: "\t" + dateFormatter.string(from: Date()),
			                                       attributes: [NSParagraphStyleAttributeName: dateParagraphStyle]))
		}

		return headerString
	}

	override var pageFooter: NSAttributedString
	{
		if printPanelAccessoryController?.showPageNumber == true
		{
			return super.pageFooter
		}
		else
		{
			return NSAttributedString()
		}
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
