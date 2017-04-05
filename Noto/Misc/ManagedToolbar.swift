//
// Created by Bruno Philipe on 22/3/17.
// Copyright (c) 2017 Bruno Philipe. All rights reserved.
//

import AppKit

class ManagedToolbar: NSToolbar
{
	dynamic var dynamicIsVisible: Bool = true

	override var isVisible: Bool
	{
		didSet
		{
			dynamicIsVisible = isVisible
		}
	}

}
