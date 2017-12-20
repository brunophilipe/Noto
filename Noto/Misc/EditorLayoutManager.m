//
//  EditorLayoutManager.m
//  Noto
//
//  Created by Bruno Resende on 25/05/2017.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

#import "EditorLayoutManager.h"
#import "Noto-Swift.h"

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

	CGFloat size = [[[Preferences instance] editorFont] pointSize];

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

- (CGRect)adjustedGlyphBoundsForGlyph:(NSUInteger)glyphIndex inContainer:(NSTextContainer *)textContainer
{
	CGRect glyphBounds = [self boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1) inTextContainer:textContainer];

	// Readjust vertical position of the glyph
	glyphBounds.origin.y -= glyphBounds.size.height * 0.1;
	glyphBounds.origin.y += 10.0;
	glyphBounds.origin.x += 10.0;

	return glyphBounds;
}

- (void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin
{
	if (!_drawsInvisibleCharacters)
	{
		[super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
		return;
	}

	NSTextContainer *textContainer = [[self textContainers] firstObject];
	NSString *string = [[self textStorage] string];
	NSColor *replacementColor = [[NSColor lightGrayColor] colorWithAlphaComponent:0.4];

	for (NSUInteger glyphIndex = glyphsToShow.location; glyphIndex < glyphsToShow.location + glyphsToShow.length; glyphIndex++)
	{
		NSUInteger characterIndex = [self characterIndexForGlyphAtIndex: glyphIndex];
		NSString *glyphReplacement = nil;
		NSBezierPath *replacementPath = nil;

		switch ([string characterAtIndex:characterIndex])
		{
			case ' ':
				glyphReplacement = [EditorLayoutManager stringForHiddenGlypth:HiddenGlypthSpace];
				break;

			case '\n':
				glyphReplacement = [EditorLayoutManager stringForHiddenGlypth:HiddenGlypthNewLine];
				break;

			case '\t':
			{
				// Tabs are replaced with a rectangle whose width is made to fit the "visual" width of the tab in the text.
				CGRect glyphBounds = [self adjustedGlyphBoundsForGlyph:glyphIndex inContainer:textContainer];
				CGFloat rectHeight = glyphBounds.size.height * 0.18;

				CGRect bezierRect = CGRectMake(ceil(glyphBounds.origin.x + 2.0),
											   floor(glyphBounds.origin.y + (glyphBounds.size.height - rectHeight) * 0.65),
											   floor(glyphBounds.size.width - 4.0),
											   ceil(rectHeight));

				replacementPath = [NSBezierPath bezierPathWithRoundedRect:bezierRect xRadius:rectHeight/2.0 yRadius:rectHeight/2.0];
			}
			break;
		}

		if (glyphReplacement)
		{
			[glyphReplacement drawInRect:[self adjustedGlyphBoundsForGlyph:glyphIndex inContainer:textContainer]
						  withAttributes:@{NSFontAttributeName: [self invisiblesFont], NSForegroundColorAttributeName: replacementColor}];
		}

		if (replacementPath)
		{
			[replacementColor setFill];
			[replacementPath fill];
		}
	}

	[super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
}

@end
