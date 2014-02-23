//
//  BPTextView.m
//  TipTyper
//
//  Created by Bruno Philipe on 2/23/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPTextView.h"

@interface BPTextView ()

@end

@implementation BPTextView
{
	BOOL skip;
}

- (NSUInteger)locationOfPreviousNewLineFromLocation:(NSUInteger)location;
{
	location--;

	NSUInteger index = location;
	NSString *string = self.string;
	unichar chr = '\0';
	BOOL found = NO;

	while (!found && (NSInteger)index >= 0) {
		if (index < string.length)
		{
			chr = [string characterAtIndex:index];
			if (chr == '\n' || chr == '\r') {
				found = YES;
			} else {
				index--;
			}
		}
	}

	return index;
}

- (NSUInteger)countTabCharsFromLocation:(NSUInteger)location
{
	NSUInteger count = 0;
	NSString *string = self.string;
	unichar chr = '\0';
	BOOL finished = NO;

	location++;

	while (!finished && location < string.length) {
		chr = [string characterAtIndex:location];
		if (chr == '\t') {
			count++;
			location++;
		} else {
			finished = YES;
		}
	}

	return count;
}

- (NSString*)buildStringWithTabsCount:(NSUInteger)count
{
	NSMutableString *str = [NSMutableString stringWithCapacity:count];
	for (NSUInteger i=0; i<count; i++) {
		[str appendString:@"\t"];
	}
	return str;
}

- (void)keyDown:(NSEvent *)theEvent
{
	[super keyDown:theEvent];

	if (self.shouldInsertTabsOnLineBreak && theEvent.keyCode == 36) {
		NSRange range = [self rangeForUserTextChange];
		NSString *string = self.string;
		NSUInteger location, count;
		unichar chr;

		if (range.location-1 < string.length) {
			chr = [string characterAtIndex:range.location-1];
			if (chr == '\n') {
				location = [self locationOfPreviousNewLineFromLocation:range.location-1];
				count = [self countTabCharsFromLocation:location];
				skip = YES;
				[self insertText:[self buildStringWithTabsCount:count]];
			}
		}
	}
}

@end
