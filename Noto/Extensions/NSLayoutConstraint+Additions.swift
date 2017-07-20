//
//  NSLayoutConstraint+Additions.swift
//  Noto
//
//  Created by Bruno Philipe on 14/3/17.
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

extension NSLayoutConstraint
{
	static func constraintsForFullSizeEmbeddedView(_ view: NSView) -> [NSLayoutConstraint]
	{
		let constraints: [NSLayoutConstraint] =
			NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": view]) +
			NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": view])

		return constraints
	}
}
