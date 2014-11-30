//
//  BPLayoutManager.m
//  TipTyper
//
//  Created by Bruno Philipe on 11/30/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPLayoutManager.h"
#import "NSColor+Luminance.h"

typedef enum {
	BPHiddenGlypthNewLine,
	BPHiddenGlypthSpace,
	BPHiddenGlypthTab
} BPHiddenGlypth;

@implementation BPLayoutManager

+ (NSString*)stringForHiddenGlypth:(BPHiddenGlypth)glypth
{
	NSString __block *CRLF, *SPACE, *TAB;

	@synchronized(self)
	{
		if (!CRLF)
		{
			CRLF	= @"⤦";
			SPACE	= @"⎵";
			TAB		= @"→";
		}

		switch (glypth) {
			case BPHiddenGlypthNewLine:
				return CRLF;

			case BPHiddenGlypthSpace:
				return SPACE;

			case BPHiddenGlypthTab:
				return TAB;

			default:
				return nil;
		}
	}
}

+ (NSFont*)cachedInvisibleGlyphFontWithSize:(CGFloat)size
{
	NSFont *font;
	CGFloat lastSize;
	@synchronized(self)
	{
		if (!font || lastSize != size) {
			font = [NSFont fontWithName:@"Helvetica" size:size];
			lastSize = size;
		}
	}
	return font;
}

- (void)drawGlyphsForGlyphRange:(NSRange)glyphRange atPoint:(NSPoint)origin
{
	//init glyphs
	NSString *docContents = [self.textStorage string];
	CGFloat userFontSize = [self.textStorage font].pointSize;
	NSString *glyph = nil;
	NSPoint glyphPoint;
	NSRect glyphRect;
	NSDictionary *attr = @{NSForegroundColorAttributeName: [self.textViewForBeginningOfSelection.backgroundColor isDarkColor] ? [NSColor grayColor] : [NSColor lightGrayColor], NSFontAttributeName: [BPLayoutManager cachedInvisibleGlyphFontWithSize:userFontSize]};

	//loop thru current range, drawing glyphs
	for (NSUInteger i = glyphRange.location; i < NSMaxRange(glyphRange); i++)
	{
		//look for special chars
		switch ([docContents characterAtIndex:i])
		{
				//space
			case ' ':
				glyph = [BPLayoutManager stringForHiddenGlypth:BPHiddenGlypthSpace];
				break;

				//tab
			case '\t':
				glyph = [BPLayoutManager stringForHiddenGlypth:BPHiddenGlypthTab];
				break;

				//eol
			case 0x2028:
			case 0x2029:
			case '\n':
			case '\r':
				glyph = [BPLayoutManager stringForHiddenGlypth:BPHiddenGlypthNewLine];
				break;

				//do nothing
			default:
				glyph = nil;
				break;
		}

		//should we draw?
		if (glyph)
		{
			glyphPoint = [self locationForGlyphAtIndex:i];
			glyphRect = [self lineFragmentRectForGlyphAtIndex:i effectiveRange:NULL];
			glyphPoint.x += glyphRect.origin.x;
			glyphPoint.y = glyphRect.origin.y;
			[glyph drawAtPoint:glyphPoint withAttributes:attr];
		}
	}

	[super drawGlyphsForGlyphRange:glyphRange atPoint:origin];
}

@end
