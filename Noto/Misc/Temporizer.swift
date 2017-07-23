//
//  Temporizer.swift
//  Noto
//
//  Created by Bruno Philipe on 23/7/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

class Temporizer
{
	let delay: TimeInterval
	let temporizedBlock: () -> Void

	private var timer: Timer? = nil

	init(withFiringDelay delay: TimeInterval, andUsingBlock block: @escaping () -> Void)
	{
		self.delay = delay
		self.temporizedBlock = block
	}

	func trigger()
	{
		if let timer = self.timer
		{
			// Re-schedule the existing timer
			timer.fireDate = Date(timeIntervalSinceNow: delay)
		}
		else
		{
			// Create new timer
			timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false)
			{
				timer in

				self.temporizedBlock()

				// Cleans the timer if appropriate
				if self.timer === timer
				{
					self.timer = nil
				}
			}
		}
	}
}
