//
//  NSLayoutConstraint+Additions.swift
//  TipTyper
//
//  Created by Bruno Philipe on 14/3/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import AppKit

extension Collection where Iterator.Element == NSLayoutConstraint
{
	func findConstraint(relating firstAttribute: NSLayoutAttribute,
	                    to secondAttribute: NSLayoutAttribute,
	                    constant: CGFloat) -> NSLayoutConstraint?
	{
		for constraint in self
		{
			if (constraint.constant == constant
				&& constraint.firstAttribute == firstAttribute
				&& constraint.secondAttribute == secondAttribute)
			{
				return constraint
			}
		}

		return nil
	}
}
