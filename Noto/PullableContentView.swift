//
// Created by Bruno Philipe on 14/3/17.
// Copyright (c) 2017 Bruno Philipe. All rights reserved.
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

class PullableContentView: NSView
{
	var pullsContent: Bool = false

	override func setFrameSize(_ newSize: NSSize)
	{
		// This is a hack (hopefully temporary) which forces the container view to extend under the title
		// view. It should ideally be replaced by a non-hack.
		super.setFrameSize(NSSize(width: newSize.width, height: newSize.height + (pullsContent ? 22 : 0)))
	}

	override var wantsDefaultClipping: Bool
	{
		return false
	}
}

class NoClippingScrollView: NSScrollView
{
	override var wantsDefaultClipping: Bool
	{
		return false
	}
}
