//
//  EditorView.swift
//  Noto
//
//  Created by Bruno Philipe on 21/2/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//  
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Cocoa
import Carbon

class EditorView: NSTextView
{
	private var tabSize: UInt = 4

	private var metricsTextStorage: MetricsTextStorage?
	{
		return self.textStorage as? MetricsTextStorage
	}

	var textMetrics: StringMetrics?
	{
		return metricsTextStorage?.metrics
	}

	var lineNumbersView: LineNumbersRulerView?
	{
		return enclosingScrollView?.verticalRulerView as? LineNumbersRulerView
	}

	var usesSpacesForTabs: Bool = false
	var keepsIndentationOnNewLines: Bool = false

	var escToLeaveFullScreenMode: WaitStatus = .none

	var invisiblesLayoutManager: InvisiblesLayoutManager?
	{
		return layoutManager as? InvisiblesLayoutManager
	}

	override var textContainerInset: NSSize
	{
		didSet
		{
			invisiblesLayoutManager?.textInset = textContainerInset
			
			// Re-set selected range so that the insertion point is drawn at the right location
			self.selectedRanges = self.selectedRanges
		}
	}

	override var font: NSFont?
	{
		didSet
		{
			invisiblesLayoutManager?.updateFontInformation()
		}
	}

	var textStorageObserver: TextStorageObserver?
	{
		get
		{
			return metricsTextStorage?.observer
		}

		set
		{
			metricsTextStorage?.observer = newValue
		}
	}

	var showsInvisibleCharacters: Bool
	{
		get { return invisiblesLayoutManager?.showsInvisibleCharacters ?? false }
		set
		{
			invisiblesLayoutManager?.showsInvisibleCharacters = newValue
			needsDisplay = true
		}
	}

	var lineNumbersVisible: Bool
	{
		get
		{
			return enclosingScrollView?.rulersVisible ?? false
		}

		set
		{
			enclosingScrollView?.rulersVisible = newValue
		}
	}

	override func awakeFromNib()
	{
		super.awakeFromNib()

		textContainerInset = NSSize(width: 10.0, height: 10.0)

		let text = string

		self.textContainer?.replaceLayoutManager(InvisiblesLayoutManager())
		layoutManager?.replaceTextStorage(MetricsTextStorage())

		if let scrollView = self.enclosingScrollView
		{
			let lineNumbersView = LineNumbersRulerView(scrollView: scrollView, orientation: .verticalRuler)
			lineNumbersView.clientView = self

			scrollView.horizontalRulerView = nil
			scrollView.verticalRulerView = lineNumbersView

			scrollView.hasHorizontalRuler = false
			scrollView.hasVerticalRuler = true
		}

		string = text
		setSelectedRange(NSMakeRange(0, 0))
	}

	deinit
	{
		// Break cyclic reference before the text view deallocs
		lineNumbersView?.clientView = nil

		if let scrollView = self.enclosingScrollView
		{
			scrollView.rulersVisible = false
			scrollView.hasVerticalRuler = false
			scrollView.verticalRulerView = nil
		}
	}

	override func viewWillStartLiveResize()
	{
		super.viewWillStartLiveResize()

		invisiblesLayoutManager?.isResizing = true
	}

	override func viewDidEndLiveResize()
	{
		super.viewDidEndLiveResize()

		invisiblesLayoutManager?.isResizing = false
		needsDisplay = true
	}

	override func insertTab(_ sender: Any?)
	{
		if usesSpacesForTabs
		{
			insertText(String.init(repeating: " ", count: Int(tabSize)), replacementRange: NSRange(location: NSNotFound, length: 0))
		}
		else
		{
			super.insertTab(sender)
		}
	}

	func jumpToLine(lineNumber: Int) -> Bool
	{
		var success = false

		if let string = self.string as NSString?
		{
			var iteratedLines = 1

			string.enumerateSubstrings(in: string.fullStringRange, options: .byLines)
			{
				(substring, range, enclosingRange, stop: UnsafeMutablePointer<ObjCBool>) in

				if lineNumber == iteratedLines
				{
					self.setSelectedRange(range)
					self.scrollRangeToVisible(range)
					stop.pointee = ObjCBool(true)
					success = true
				}

				iteratedLines += 1
			}
		}

		return success
	}

	override func keyDown(with event: NSEvent)
	{
		if event.keyCode == UInt16(kVK_Escape) && Preferences.instance.doubleEscToLeaveFullScreen
		{
			switch escToLeaveFullScreenMode
			{
			case .none:
				escToLeaveFullScreenMode = .waiting(timeout: Date().addingTimeInterval(1).timeIntervalSince1970)

			case .waiting(let timeout):
				if Date().timeIntervalSince1970 < timeout
				{
					super.keyDown(with: event)
				}

				escToLeaveFullScreenMode = .none
			}
		}
		else
		{
			super.keyDown(with: event)
		}

		if keepsIndentationOnNewLines && (event.keyCode == UInt16(kVK_Return) || event.keyCode == UInt16(kVK_ANSI_KeypadEnter))
		{
			var newRanges = [NSValue]()
			var insertedChacacters = 0

			for range in selectedRanges.map({ return $0.rangeValue })
			{
				insertedChacacters += insertIndentationMatchingPreviousLineFromLocation(range.location + insertedChacacters)

				newRanges.append(NSValue(range: NSMakeRange(range.location + insertedChacacters, range.length)))
			}

			selectedRanges = newRanges
		}
	}

	func increaseIndentation()
	{
		if let ranges = textStorage?.increaseIndentForSelectedRanges(selectedRanges.map { return $0.rangeValue },
		                                                             usingUndoManager: self.undoManager)
		{
			selectedRanges = ranges.map { return NSValue(range: $0) }
		}
	}

	func decreaseIndentation()
	{
		if let ranges = textStorage?.decreaseIndentForSelectedRanges(selectedRanges.map { return $0.rangeValue },
		                                                             usingUndoManager: self.undoManager)
		{
			selectedRanges = ranges.map { return NSValue(range: $0) }
		}
	}

	private func insertIndentationMatchingPreviousLineFromLocation(_ location: Int) -> Int
	{
		if let textStorage = self.textStorage
		{
			let string: NSString = textStorage.string as NSString
			let currentLineRange = string.lineRange(for: NSMakeRange(location, 0))

			if currentLineRange.location > 0
			{
				let previousLineRange = string.lineRange(for: NSMakeRange(currentLineRange.location - 1, 0))

				var charCount = 0

				for i in previousLineRange.location ..< NSMaxRange(previousLineRange)
				{
					if string.character(at: i).isSpace() || string.character(at: i).isTab()
					{
						charCount += 1
					}
					else
					{
						break
					}
				}

				let indentationString = string.substring(with: NSMakeRange(previousLineRange.location, charCount))

				textStorage.replaceCharacters(in: NSMakeRange(currentLineRange.location, 0), with: indentationString)

				return charCount
			}
		}

		return 0
	}

	// Has to be updated when font size changes
	func setTabWidth(_ width: UInt)
	{
		// Update paragraph style
		let paragraphStyle = (defaultParagraphStyle ?? NSParagraphStyle.default).mutableCopy() as! NSMutableParagraphStyle
		let characterWidth = (font ?? NSFont.systemFont(ofSize: 14)).screenFont(with: .antialiasedRenderingMode).advancement(forGlyph: NSGlyph(" "))

		paragraphStyle.defaultTabInterval = CGFloat(width) * characterWidth.width
		paragraphStyle.tabStops = []

		defaultParagraphStyle = paragraphStyle

		// Re-render current text with new typing attributes
		var typingAttributes = self.typingAttributes
		typingAttributes[NSAttributedStringKey.paragraphStyle] = paragraphStyle
		self.typingAttributes = typingAttributes

		let textString = self.string as NSString
		let textRange = NSMakeRange(0, textString.length)
		shouldChangeText(in: textRange, replacementString: nil)
		textStorage?.setAttributes(typingAttributes, range: textRange)
		didChangeText()
	}
}

extension EditorView
{
	enum WaitStatus
	{
		case none
		case waiting(timeout: TimeInterval)
	}
}
