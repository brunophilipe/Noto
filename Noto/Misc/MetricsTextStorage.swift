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

		let oldMetrics = textMetrics

		if let observer = self.observer
		{
			observer.textStorageWillUpdateMetrics(self)
		}

		let stringBeforeChange = attributedSubstring(from: testRange).string

		super.replaceCharacters(in: range, with: str)

		let rangeAfterChange = testRange.expanding(by: delta).meaningfulRange
		let stringAfterChange = (stringLength + delta) > 0 ? attributedSubstring(from: rangeAfterChange).string : ""

		DispatchQueue.global(qos: .utility).async
			{
				let metricsBeforeChange = stringBeforeChange.metrics
				let metricsAfterChange = stringAfterChange.metrics

				self.textMetrics = self.textMetrics - metricsBeforeChange + metricsAfterChange

				self._isUpdatingMetrics = false

				if let observer = self.observer
				{
					DispatchQueue.main.async
						{
							observer.textStorage(self, didUpdateMetrics: self.metrics, fromOldMetrics: oldMetrics)
						}
				}
			}
	}
}

protocol TextStorageObserver
{
	func textStorageWillUpdateMetrics(_ textStorage: MetricsTextStorage)
	func textStorage(_ textStorage: MetricsTextStorage, didUpdateMetrics: StringMetrics, fromOldMetrics: StringMetrics)
}
