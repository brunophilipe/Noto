//
//  BPView.m
//  TipTyper
//
//  Created by Bruno Philipe on 2/10/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPBackgroundView.h"

@implementation BPBackgroundView

- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if (self) {
		[self setBackgroundColor:[NSColor whiteColor]];
		[self setNeedsDisplay:YES];
	}
	return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[self.backgroundColor setFill];
	NSRectFill(self.bounds);
}

@end
