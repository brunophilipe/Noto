//
//  MetricsTextStorage.swift
//  Noto
//
//  Created by Bruno Philipe on 23/7/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa
import Highlightr

class MetricsTextStorage: CodeAttributedString
{
	private static let rangeChunkSize = 512
	
	private var metricsByRange = [Int: StringMetrics]()
	
	var observer: TextStorageObserver? = nil
	
	var metrics: StringMetrics
	{
		return metricsByRange.reduce(StringMetrics())
		{
			(metricsSum, metric) -> StringMetrics in
		
			return metricsSum + metric.value
		}
	}
	
	override func edited(_ editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int)
	{
		super.edited(editedMask, range: editedRange, changeInLength: delta)
		
		if editedMask == .editedCharacters
		{
			updateMetrics(with: editedRange)
		}
	}
	
	private func updateMetrics(with editedRange: NSRange)
	{
		let totalLength = characters.count
		let chunkSize = MetricsTextStorage.rangeChunkSize
		
		var metricsByRange: [Int: StringMetrics] = [:]
		var processedLength = 0
		
		let monitoredRange = NSMakeRange(editedRange.location - 1, editedRange.length + 2)
		
		for rangeIndex in 0 ..< Int(ceil(Double(totalLength)/Double(chunkSize)))
		{
			let range = NSMakeRange(rangeIndex*chunkSize, min(totalLength - processedLength, chunkSize))
			
			if self.metricsByRange[rangeIndex] == nil || NSIntersectionRange(range, monitoredRange).length != 0
			{
				metricsByRange[rangeIndex] = attributedSubstring(from: range).string.metrics
			}
			else
			{
				metricsByRange[rangeIndex] = self.metricsByRange[rangeIndex]
			}
			
			processedLength += range.length
		}
		
		self.metricsByRange = metricsByRange
		
		observer?.textStorage(self, didUpdateMetrics: self.metrics)
	}
}

protocol TextStorageObserver
{
	func textStorage(_ textStorage: MetricsTextStorage, didUpdateMetrics: StringMetrics)
}
