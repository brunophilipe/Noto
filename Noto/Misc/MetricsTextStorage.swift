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

	private var _isUpdatingMetrics = false

	var observer: TextStorageObserver? = nil

	var metrics: StringMetrics
	{
		return textMetrics
	}

	var isUpdatingMetrics: Bool
	{
		return _isUpdatingMetrics
	}

	override func replaceCharacters(in range: NSRange, with str: String)
	{
		let stringLength = (string as NSString).length
		let delta = (str as NSString).length - range.length
		let testRange = range.expanding(byEncapsulating: 1, maxLength: stringLength)

		_isUpdatingMetrics = true

		if let observer = self.observer
		{
			DispatchQueue.main.async
				{
					observer.textStorageWillUpdateMetrics(self)
				}
		}

		let stringBeforeChange = attributedSubstring(from: testRange).string

		super.replaceCharacters(in: range, with: str)

		let stringAfterChange = self.attributedSubstring(from: testRange.expanding(byLength: delta).meaningfulRange).string

		DispatchQueue.global(qos: .utility).async
			{
				let metricsBeforeChange = stringBeforeChange.metrics
				let metricsAfterChange = (stringLength + delta) > 0 ? stringAfterChange.metrics
																	: StringMetrics()

				self.textMetrics = self.textMetrics - metricsBeforeChange + metricsAfterChange

				self._isUpdatingMetrics = false

				if let observer = self.observer
				{
					DispatchQueue.main.async
						{
							observer.textStorage(self, didUpdateMetrics: self.metrics)
						}
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
		let newLocation = max(0, location - delta)
		let newLength = min(length + delta * 2, maxLength - newLocation)
		return NSMakeRange(newLocation, newLength)
	}
}

protocol TextStorageObserver
{
	func textStorageWillUpdateMetrics(_ textStorage: MetricsTextStorage)
	func textStorage(_ textStorage: MetricsTextStorage, didUpdateMetrics: StringMetrics)
}
