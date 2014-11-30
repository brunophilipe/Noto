//
//  NSColor+Luminance.m
//  TipTyper
//
//  Created by Bruno Philipe on 11/30/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "NSColor+Luminance.h"

@implementation NSColor (Luminance)

- (BOOL)isDarkColor
{
	NSColor *rgbSelf = [self colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
	CGFloat luminance = 0.2126*rgbSelf.redComponent + 0.7152*rgbSelf.greenComponent + 0.0722*rgbSelf.blueComponent;
	return luminance<0.5;
}

@end
