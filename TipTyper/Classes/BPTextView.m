//
//  BPTextView.m
//  TipTyper
//
//  Created by Bruno Philipe on 2/23/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPTextView.h"

#define kBP_KEYCODE_RETURN 36

#define BP_IS_FIRST_CHAR (int)range.location - (int)diffRange

@interface BPTextView ()

@end

@implementation BPTextView

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

		range.location--;

		if (range.location < string.length) {
			chr = [string characterAtIndex:range.location];
			if (chr == '\n') {
				[string getLineStart:&location end:nil contentsEnd:nil forRange:NSMakeRange(range.location, 1)];
				count = [self countTabCharsFromLocation:location spareSpaces:NULL];

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

- (void)increaseIndentation
{
	NSMutableArray *ranges = [[self selectedRanges] mutableCopy];
	NSUInteger totalCharactersAdded = 0;

	for (NSUInteger rangeIndex = 0; rangeIndex < ranges.count; rangeIndex++) {
		NSRange currentRange = [[ranges objectAtIndex:rangeIndex] rangeValue];
		NSUInteger charactersAdded = 0;
		BOOL singleCharRange = currentRange.length == 0;

		currentRange.location += totalCharactersAdded;
		currentRange.length += singleCharRange ? 1 : 0;

		NSString *text = self.string;
		NSString *substring = [text substringWithRange:currentRange];
		NSMutableArray *lineStarts = [NSMutableArray new];

		[substring enumerateSubstringsInRange:NSMakeRange(0, substring.length) options:NSStringEnumerationByLines usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
			NSUInteger lineStart = 0;
			[text getLineStart:&lineStart end:nil contentsEnd:nil forRange:NSMakeRange(currentRange.location + substringRange.location, substringRange.length)];
			[lineStarts addObject:@(lineStart)];
		}];

		for (NSUInteger line=0; line<lineStarts.count; line++) {
			charactersAdded = [self increaseIndentationAtLocation:[[lineStarts objectAtIndex:line] integerValue] + charactersAdded * line];
		}

		[ranges replaceObjectAtIndex:rangeIndex withObject:[NSValue valueWithRange:NSMakeRange(currentRange.location + charactersAdded, currentRange.length - (singleCharRange ? 1 : 0) + charactersAdded * (lineStarts.count - 1))]];

		totalCharactersAdded += charactersAdded * lineStarts.count;
	}

	[self setSelectedRanges:ranges];
}

- (void)decreaseIndentation
{
	NSMutableArray *ranges = [[self selectedRanges] mutableCopy];
	NSUInteger totalCharactersRemoved = 0;

	for (NSUInteger rangeIndex = 0; rangeIndex < ranges.count; rangeIndex++) {
		NSRange currentRange = [[ranges objectAtIndex:rangeIndex] rangeValue];
		NSUInteger charactersRemoved = 0, charactersRemovedFirstLine = 0;
		BOOL singleCharRange = currentRange.length == 0;

		currentRange.location -= totalCharactersRemoved;
		currentRange.length += singleCharRange ? 1 : 0;

		NSString *text = self.string;
		NSString *substring = [text substringWithRange:currentRange];
		NSMutableArray *lineStarts = [NSMutableArray new];

		[substring enumerateSubstringsInRange:NSMakeRange(0, substring.length) options:NSStringEnumerationByLines usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
			NSUInteger lineStart = 0;
			[text getLineStart:&lineStart end:nil contentsEnd:nil forRange:NSMakeRange(currentRange.location + substringRange.location, substringRange.length)];
			[lineStarts addObject:@(lineStart)];
		}];

		for (NSUInteger line=0; line<lineStarts.count; line++) {
			charactersRemoved += [self decreaseIndentationAtLocation:[[lineStarts objectAtIndex:line] integerValue] - charactersRemoved];
			if (line == 0)
				charactersRemovedFirstLine = charactersRemoved;
		}

		[ranges replaceObjectAtIndex:rangeIndex withObject:[NSValue valueWithRange:NSMakeRange(currentRange.location - charactersRemovedFirstLine, currentRange.length - (singleCharRange ? 1 : 0) - (charactersRemoved - charactersRemovedFirstLine))]];

		totalCharactersRemoved += charactersRemoved;
	}

	[self setSelectedRanges:ranges];
}

- (NSUInteger)increaseIndentationAtLocation:(NSUInteger)location
{
	if (self.shouldInsertSpacesInsteadOfTabs) {
		[self insertText:[self buildStringWithSpacesCount:self.tabSize] replacementRange:NSMakeRange(location, 0)];
		return self.tabSize;
	} else {
		[self insertText:[self buildStringWithTabsCount:1] replacementRange:NSMakeRange(location, 0)];
		return 1;
	}
}

- (NSUInteger)decreaseIndentationAtLocation:(NSUInteger)location
{
	NSUInteger spaces;
	NSUInteger count = [self countTabCharsFromLocation:location spareSpaces:&spaces];

	if (count > 0) {
		[self insertText:@"" replacementRange:NSMakeRange(location, 1)];
		return 1;
	} else if (spaces > 0) {
		[self insertText:@"" replacementRange:NSMakeRange(location, spaces)];

//		if (spareSpaces != NULL) {
//			*spareSpaces = spaces;
//		}
		return spaces;
	}

	return 0;
}

@end
