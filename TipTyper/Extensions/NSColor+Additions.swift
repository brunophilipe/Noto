//
//  NSColor+Additions.swift
//  TipTyper
//
//  Created by Bruno Philipe on 21/2/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Cocoa

extension NSColor
{
	convenience init(rgb: UInt)
	{
		self.init(rgba: (rgb << 8) | 0x000000FF)
	}

	convenience init(rgba: UInt)
	{
		let red		= CGFloat((rgba >> 24) & 0x000000FF) / CGFloat(255.0)
		let green	= CGFloat((rgba >> 16) & 0x000000FF) / CGFloat(255.0)
		let blue	= CGFloat((rgba >>  8) & 0x000000FF) / CGFloat(255.0)
		let alpha	= CGFloat((rgba >>  0) & 0x000000FF) / CGFloat(255.0)

		self.init(red: red, green: green, blue: blue, alpha: alpha)
	}
	
	var rgb: UInt
	{
		if colorSpace.colorSpaceModel == .RGB
		{
			var rgbInt = UInt(0)
			
			rgbInt |= UInt(redComponent   * 255) << 16
			rgbInt |= UInt(greenComponent * 255) << 8
			rgbInt |= UInt(blueComponent  * 255) << 0
			
			return rgbInt
		}
		
		return self.usingColorSpace(NSColorSpace.deviceRGB)?.rgb ?? 0
	}

	var rgba: UInt
	{
		return (rgb << 8) | (UInt(alphaComponent * 255) & 0x000000FF)
	}
	
	var luminance: CGFloat
	{
		if let rgb = self.usingColorSpace(NSColorSpace.deviceRGB)
		{
			return 0.2126*rgb.redComponent + 0.7152*rgb.greenComponent + 0.0722*rgb.blueComponent
		}
		
		return 0
	}

	var isDarkColor: Bool
	{
		return luminance < 0.5
	}
}
