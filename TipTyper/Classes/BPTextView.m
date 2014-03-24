//
//  BPTextView.m
//  TipTyper
//
//  Created by Bruno Philipe on 2/23/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPTextView.h"

#define kBP_KEYCODE_RETURN 36

@interface BPTextView ()

@end

@implementation BPTextView

- (NSUInteger)locationOfPreviousNewLineFromLocation:(NSUInteger)location;
{
	/* The location can be a new line, so we go back one index to avoid that. */
	location--;

	NSUInteger index = location;
	NSString *string = self.string;
	unichar chr = '\0';
	BOOL found = NO;

	/* The indexes are only equal to or greater than zero. */
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

- (NSUInteger)locationOfNextNewLineFromLocation:(NSUInteger)location;
{
	NSUInteger index = location;
	NSString *string = self.string;
	unichar chr = '\0';
	BOOL found = NO;

	/* Lets ignore the current character and search only from then on. */
	index++;

	while (!found && index < string.length) {
		chr = [string characterAtIndex:index];
		if (chr == '\n' || chr == '\r') {
			found = YES;
		} else {
			index++;
		}
	}

	return index;
}

- (NSUInteger)countTabCharsFromLocation:(NSUInteger)location spareSpaces:(NSUInteger *)spareSpaces
{
	NSUInteger count = 0, spaces = 0;
	NSString *string = self.string;
	unichar chr = '\0';
	BOOL finished = NO;

	/* The current character might be a tab or a space, so we conider it in the count. */

	while (!finished && location < string.length) {
		chr = [string characterAtIndex:location];
		if (chr == '\t') {
			count++;
			location++;
		} else if (chr == ' ') {
			spaces++;
			location++;
		} else {
			/* Found a character different fom space or tab, we can exit the loop now. */
			finished = YES;
		}
	}

	/* If the caller sent a pointer to return the spare spaces count, set the value there. */
	if (spareSpaces != NULL) {
		*spareSpaces = spaces%self.tabSize;
	}

	/* There can be a mixture of tabs and spaces in a single line. We should take everything into account. */
	return count + spaces/self.tabSize;
}

- (NSString*)buildStringWithTabsCount:(NSUInteger)count
{
	NSMutableString *str = [NSMutableString stringWithCapacity:count];
	for (NSUInteger i=0; i<count; i++) {
		[str appendString:@"\t"];
	}
	return [str copy];
}

- (NSString*)buildStringWithSpacesCount:(NSUInteger)count
{
	NSMutableString *str = [NSMutableString stringWithCapacity:count];
	for (NSUInteger i=0; i<count; i++) {
		[str appendString:@" "];
	}
	return [str copy];
}

- (void)keyDown:(NSEvent *)theEvent
{
	[super keyDown:theEvent];

	/* Automatic tab insertion. */
	if (self.shouldInsertTabsOnLineBreak && theEvent.keyCode == kBP_KEYCODE_RETURN) {
		NSRange range = [self rangeForUserTextChange];
		NSString *string = self.string;
		NSUInteger location = 0, count = 0;
		unichar chr = '\0';

		if (range.location-1 < string.length) {
			chr = [string characterAtIndex:range.location-1];
			if (chr == '\n') {
				location = [self locationOfPreviousNewLineFromLocation:range.location];
				count = [self countTabCharsFromLocation:location+1 spareSpaces:NULL];

				if (self.shouldInsertSpacesInsteadOfTabs) {
					[self insertText:[self buildStringWithSpacesCount:count * self.tabSize]];
				} else {
					[self insertText:[self buildStringWithTabsCount:count]];
				}
			}
		}
	}
}

- (void)insertTab:(id)sender
{
	if (self.shouldInsertSpacesInsteadOfTabs) {
		[self insertText:[self buildStringWithSpacesCount:self.tabSize]];
	} else {
		[super insertTab:sender];
	}
}

- (void)iterateThroughLinesUsingBlock:(void(^)(NSUInteger location, NSInteger *difference))block
{
	NSUInteger location = 0;
	NSRange range = {0, 0};
	NSInteger count = 0, previousCount = 0, difference = 0, diffRange = 0;
	NSMutableArray *ranges = [NSMutableArray array];
	BOOL isFirstLine = YES, didChange = NO, didChangeFirstLine = NO, didChangeLastLine = NO;

	for (NSValue *rangeVal in [self selectedRanges]) {
		previousCount += count;
		count = 0;

		range = [rangeVal rangeValue];
		range.location += previousCount;
		location = [self locationOfPreviousNewLineFromLocation:range.location] + 1;

		do {
			difference = 0;

			block(location, &difference);

			didChange = (difference != 0);

			if (didChange && isFirstLine) {
				didChangeFirstLine = YES;
			}

			location = [self locationOfNextNewLineFromLocation:location] + 1;
			count += difference;

			isFirstLine = NO;
		} while (location < range.location + range.length + ABS(count) + 1);

		didChangeLastLine = didChange;

		diffRange = (count == 0 ? 0 : (count < 0 ? 1 : -1)) * (self.shouldInsertSpacesInsteadOfTabs ? self.tabSize : 1);
		range = NSMakeRange((((int)range.location - (int)diffRange < 0) && !didChangeFirstLine ? 0 : range.location - diffRange), range.length + count + diffRange);

		[ranges addObject:[NSValue valueWithRange:range]];
	}

	[self setSelectedRanges:ranges];
}

- (void)increaseIndentation
{
	[self iterateThroughLinesUsingBlock:^(NSUInteger location, NSInteger *difference) {
		[self increaseIndentationAtLocation:location];
		*difference = (self.shouldInsertSpacesInsteadOfTabs ? self.tabSize : 1);
	}];
}

- (void)increaseIndentationAtLocation:(NSUInteger)location
{
	if (self.shouldInsertSpacesInsteadOfTabs) {
		[self insertText:[self buildStringWithSpacesCount:self.tabSize] replacementRange:NSMakeRange(location, 0)];
	} else {
		[self insertText:[self buildStringWithTabsCount:1] replacementRange:NSMakeRange(location, 0)];
	}
}

- (void)decreaseIndentation
{
	[self iterateThroughLinesUsingBlock:^(NSUInteger location, NSInteger *difference) {
		NSUInteger spareSpaces = 0;
		if ([self decreaseIndentationAtLocation:location spareSpaces:&spareSpaces]) { //Returns yes if did decrement
			if (spareSpaces > 0) {
				*difference = -spareSpaces;
			} else {
				*difference = -1;
			}
		} else {
			*difference = 0;
		}
	}];
}

- (BOOL)decreaseIndentationAtLocation:(NSUInteger)location spareSpaces:(NSUInteger *)spareSpaces
{
	NSUInteger spaces;
	NSUInteger count = [self countTabCharsFromLocation:location spareSpaces:&spaces];

	if (count > 0) {
		if (self.shouldInsertSpacesInsteadOfTabs) {
			[self insertText:@"" replacementRange:NSMakeRange(location, self.tabSize)];
		} else {
			[self insertText:@"" replacementRange:NSMakeRange(location, 1)];
		}

		return YES;
	} else if (spaces > 0) {
		[self insertText:@"" replacementRange:NSMakeRange(location, spaces)];

		if (spareSpaces != NULL) {
			*spareSpaces = spaces;
		}
		return YES;
	}

	return NO;
}

@end
