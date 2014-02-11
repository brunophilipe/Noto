//
//  BPTopBarView.m
//  TipTyper
//
//  Created by Bruno Philipe on 2/10/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPTopBarView.h"

@implementation BPTopBarView
{
	NSBezierPath *path;
	CGFloat scaleFactor;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		[self setBackgroundColor:NSColorFromRGB(0xededed)];
		[self setTopBorderColor:NSColorFromRGB(0x9f9f9f)];
		scaleFactor = [self.window backingScaleFactor];
		path = [NSBezierPath bezierPath];
		[path setLineWidth:scaleFactor];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
	[self.topBorderColor setStroke];

	[path removeAllPoints];
	[path moveToPoint:NSMakePoint(0, self.bounds.size.height-(scaleFactor == 1 ? 1 : 1.5))];
	[path lineToPoint:NSMakePoint(self.bounds.size.width, self.bounds.size.height-(scaleFactor == 1 ? 1 : 1.5))];
	[path stroke];
}

@end
