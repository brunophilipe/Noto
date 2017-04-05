//
//  AssignIf.swift
//  Noto
//
//  Created by Bruno Philipe on 26/2/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

/**
 * The "Assign-If" operator only assigns to the left-hand value if the right-hand value is not nil
 */
infix operator =?

func =?<T>(lho: inout T, rho: T?)
{
	if let newValue = rho
	{
		lho = newValue
	}
}
