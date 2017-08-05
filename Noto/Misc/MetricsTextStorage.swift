//
//  MetricsTextStorage.swift
//  Noto
//
//  Created by Bruno Philipe on 5/8/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

class MetricsTextStorage: ConcreteTextStorage
{
	private var textMetrics = StringMetrics()

	var observer: TextStorageObserver? = nil

	var metrics: StringMetrics
	{
		return textMetrics
	}

	open override func replaceCharacters(in range: NSRange, with str: String)
	{
		let stringLength = (string as NSString).length
		let delta = (str as NSString).length - range.length
		let testRange = range.expanding(byEncapsulating: 1, maxLength: stringLength)

		let metricsBeforeChange = attributedSubstring(from: testRange).string.metrics
		super.replaceCharacters(in: range, with: str)
		let metricsAfterChange = (stringLength + delta) > 0 ? attributedSubstring(from: testRange.expanding(byLength: delta).meaningfulRange).string.metrics
			: StringMetrics()

		textMetrics = textMetrics - metricsBeforeChange + metricsAfterChange

		if let observer = self.observer
		{
			DispatchQueue.main.async
				{
					observer.textStorage(self, didUpdateMetrics: self.metrics)
			}
		}
	}
}

extension NSRange
{
	/// Returns a range with the same location as the receiver and with length equal to the receiver's length if it is > 0, or 1 otherwise.
	var meaningfulRange: NSRange
	{
		return NSMakeRange(location, max(length, 1))
	}

	func expanding(byLength delta: Int) -> NSRange
	{
		return NSMakeRange(location, max(length + delta, 0))
	}

	func expanding(byEncapsulating delta: Int, maxLength: Int) -> NSRange
	{
		return NSMakeRange(max(0, location - delta), min(length + delta, maxLength))
	}
}

protocol TextStorageObserver
{
	func textStorage(_ textStorage: MetricsTextStorage, didUpdateMetrics: StringMetrics)
}
