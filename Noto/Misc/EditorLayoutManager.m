//
//  EditorLayoutManager.m
//  Noto
//
//  Created by Bruno Resende on 25/05/2017.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

#import "EditorLayoutManager.h"

@interface EditorLayoutManager ()

@property (nonatomic) NSUInteger lastParaLocation;
@property (nonatomic) NSUInteger lastParaNumber;

@end

@implementation EditorLayoutManager
{
	BOOL _drawsInvisibleCharacters;
	BOOL _isDrawingPaused;
}

@synthesize editorLayoutManagerDelegate;

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		_textInset = NSMakeSize(10, 10);
	}
	return self;
}

-(void)setIsDrawingPaused:(BOOL)isDrawingPaused
{
	_isDrawingPaused = isDrawingPaused;
	
	if (!isDrawingPaused)
	{
		[[self textContainers] enumerateObjectsUsingBlock:
		 ^(NSTextContainer * _Nonnull textContainer, NSUInteger idx, BOOL * _Nonnull stop)
		 {
			 [self textContainerChangedGeometry:textContainer];
		 }];
	}
}

- (BOOL)isDrawingPaused
{
	return _isDrawingPaused;
}

- (void)setDrawsInvisibleCharacters:(BOOL)drawsInvisibleCharacters
{
	_drawsInvisibleCharacters = drawsInvisibleCharacters;
	[self invalidateDisplayForGlyphRange:NSMakeRange(0, [[self textStorage] length])];
}

- (BOOL)drawsInvisibleCharacters
{
	return _drawsInvisibleCharacters;
}

- (NSUInteger)lineNumberForRange:(NSRange)charRange
{
	//  NSString does not provide a means of efficiently determining the paragraph number of a range of text.  This code
	//  attempts to optimize what would normally be a series linear searches by keeping track of the last paragraph number
	//  found and uses that as the starting point for next paragraph number search.  This works (mostly) because we
	//  are generally asked for continguous increasing sequences of paragraph numbers.  Also, this code is called in the
	//  course of drawing a pagefull of text, and so even when moving back, the number of paragraphs to search for is
	//  relativly low, even in really long bodies of text.
	//
	//  This all falls down when the user edits the text, and can potentially invalidate the cached paragraph number which
	//  causes a (potentially lengthy) search from the beginning of the string.
	
	if (charRange.location == self.lastParaLocation)
	{
		return self.lastParaNumber;
	}
	else if (charRange.location < self.lastParaLocation)
	{
		//  We need to look backwards from the last known paragraph for the new paragraph range.  This generally happens
		//  when the text in the UITextView scrolls downward, revaling paragraphs before/above the ones previously drawn.
		
		NSString* s = self.textStorage.string;
		__block NSUInteger paraNumber = self.lastParaNumber;
		
		[s enumerateSubstringsInRange:NSMakeRange(charRange.location, self.lastParaLocation - charRange.location)
							  options:NSStringEnumerationByParagraphs|NSStringEnumerationSubstringNotRequired|NSStringEnumerationReverse
						   usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
							   if (enclosingRange.location <= charRange.location) {
								   *stop = YES;
							   }
							   --paraNumber;
						   }];
		
		self.lastParaLocation = charRange.location;
		self.lastParaNumber = paraNumber;
		return paraNumber;
	}
	else
	{
		//  We need to look forward from the last known paragraph for the new paragraph range.  This generally happens
		//  when the text in the UITextView scrolls upwards, revealing paragraphs that follow the ones previously drawn.
		
		NSString* s = self.textStorage.string;
		__block NSUInteger paraNumber = self.lastParaNumber;
		
		[s enumerateSubstringsInRange:NSMakeRange(self.lastParaLocation, charRange.location - self.lastParaLocation)
							  options:NSStringEnumerationByParagraphs|NSStringEnumerationSubstringNotRequired
						   usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
							   if (enclosingRange.location >= charRange.location) {
								   *stop = YES;
							   }
							   ++paraNumber;
						   }];
		
		self.lastParaLocation = charRange.location;
		self.lastParaNumber = paraNumber;
		return paraNumber;
	}
}

- (void)processEditingForTextStorage:(NSTextStorage *)textStorage
							  edited:(NSTextStorageEditActions)editMask
							   range:(NSRange)newCharRange
					  changeInLength:(NSInteger)delta
					invalidatedRange:(NSRange)invalidatedCharRange
{
	[super processEditingForTextStorage:textStorage
								 edited:editMask
								  range:newCharRange
						 changeInLength:delta
					   invalidatedRange:invalidatedCharRange];
	
	if ((editMask & NSTextStorageEditedCharacters) > 0 && invalidatedCharRange.location < self.lastParaLocation)
	{
		//  When the backing store is edited ahead the cached paragraph location, invalidate the cache and force a complete
		//  recalculation.  We cannot be much smarter than this because we don't know how many paragraphs have been deleted
		//  since the text has already been removed from the backing store.
		
		self.lastParaLocation = 0;
		self.lastParaNumber = 0;
	}

	[[self editorLayoutManagerDelegate] layoutManagerDidProcessEdit:self];
}

- (void)textContainerChangedGeometry:(NSTextContainer *)container
{
	if (![self isDrawingPaused])
	{
		[super textContainerChangedGeometry:container];
	}
}

- (BOOL)drawsOutsideLineFragmentForGlyphAtIndex:(NSUInteger)glyphIndex
{
	return YES;
}

#pragma mark - Invisibles

typedef enum
{
	HiddenGlypthNewLine,
	HiddenGlypthSpace,
	HiddenGlypthTab
} HiddenGlypth;

- (nullable NSFont *)invisiblesFont
{
	static CGFloat cachedSize = 0.0;
	static NSFont *cachedFont = nil;

	if (!_editorLayoutManagerDataSource)
	{
		return nil;
	}

	CGFloat size = [_editorLayoutManagerDataSource invisiblesPointSize];

	if (size != cachedSize || cachedFont == nil)
	{
		cachedSize = size;
		cachedFont = [NSFont fontWithName:@"Menlo" size:size];
	}

	return cachedFont;
}

+ (nullable NSString *)stringForHiddenGlypth:(HiddenGlypth)glypth
{
	switch (glypth)
	{
		case HiddenGlypthNewLine:	return @"↵";
		case HiddenGlypthSpace:		return @"•";
		case HiddenGlypthTab:		return @"⇥";
	}

	return nil;
}

- (CGRect)adjustedGlyphBoundsForGlyphRange:(NSRange)glyphRange inContainer:(NSTextContainer *)textContainer
{
	CGRect glyphBounds = [self boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];

	// Readjust vertical position of the glyph
	glyphBounds.origin.y -= glyphBounds.size.height * 0.1;
	glyphBounds.origin.y += _textInset.height;
	glyphBounds.origin.x += _textInset.width;

	if (glyphBounds.size.width == 0.0)
	{
		// Any positive value big enough for the character will do. The height is always a good value in this case.
		// This is zero when measuring the newline character, as the alternative is getting the y position from the next line.
		glyphBounds.size.width = glyphBounds.size.height;
	}

	return glyphBounds;
}

BOOL rangesContainIndex(NSArray<NSValue *> *ranges, NSInteger index)
{
//	if ([ranges count] <= 1 && [[ranges firstObject] rangeValue].length == 0)
//	{
//		return NO;
//	}
	for (NSValue *value in ranges)
	{
		NSRange range = [value rangeValue];
		
		if (index >= range.location && index < NSMaxRange(range))
		{
			return YES;
		}
	}
	
	return NO;
}

- (void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin
{
	if (!_drawsInvisibleCharacters || !_editorLayoutManagerDataSource)
	{
		[super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
		return;
	}

	NSArray<NSValue *> *selectedRanges = [[self firstTextView] selectedRanges];
	NSTextContainer *textContainer = [[self textContainers] firstObject];
	NSString *string = [[self textStorage] string];
	NSColor *replacementColor = [_editorLayoutManagerDataSource invisiblesColor];

	for (NSUInteger glyphIndex = glyphsToShow.location; glyphIndex < glyphsToShow.location + glyphsToShow.length; glyphIndex++)
	{
		NSUInteger characterIndex = [self characterIndexForGlyphAtIndex: glyphIndex];
		NSString *glyphReplacement = nil;
		NSBezierPath *replacementPath = nil;
		NSColor *actualColor = rangesContainIndex(selectedRanges, glyphIndex) ? [NSColor blackColor] : replacementColor;

		switch ([string characterAtIndex:characterIndex])
		{
			case ' ':
				glyphReplacement = [EditorLayoutManager stringForHiddenGlypth:HiddenGlypthSpace];
				[glyphReplacement drawInRect:[self adjustedGlyphBoundsForGlyphRange:NSMakeRange(glyphIndex, 1) inContainer:textContainer]
							  withAttributes:@{NSFontAttributeName: [self invisiblesFont],
											   NSForegroundColorAttributeName: actualColor}];
				break;

			case '\n':
				glyphReplacement = [EditorLayoutManager stringForHiddenGlypth:HiddenGlypthNewLine];
				[glyphReplacement drawInRect:[self adjustedGlyphBoundsForGlyphRange:NSMakeRange(glyphIndex, 0) inContainer:textContainer]
							  withAttributes:@{NSFontAttributeName: [self invisiblesFont],
											   NSForegroundColorAttributeName: actualColor}];
				break;

			case '\t':
			{
				// Tabs are replaced with a rectangle whose width is made to fit the "visual" width of the tab in the text.
				CGRect glyphBounds = [self adjustedGlyphBoundsForGlyphRange:NSMakeRange(glyphIndex, 1) inContainer:textContainer];
				CGFloat rectHeight = glyphBounds.size.height * 0.18;

				CGRect bezierRect = CGRectMake(glyphBounds.origin.x + 1.0,
											   floor(glyphBounds.origin.y + (glyphBounds.size.height - rectHeight) * 0.65),
											   glyphBounds.size.width - 2.0,
											   ceil(rectHeight));

				replacementPath = [NSBezierPath bezierPathWithRoundedRect:bezierRect xRadius:rectHeight/2.0 yRadius:rectHeight/2.0];
			}
			break;
		}

		if (replacementPath)
		{
			[actualColor setFill];
			[replacementPath fill];
		}
	}

	[super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
}

@end
