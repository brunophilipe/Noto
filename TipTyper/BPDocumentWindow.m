//
//  BPDocumentWindow.m
//  TipTyper
//
//  Created by Bruno Philipe on 2/9/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPDocumentWindow.h"
#import "Libraries/LineCounter/MarkerLineNumberView.h"
#import "Classes/NSString+WordsCount.h"

typedef enum {
	kBP_EDITORSPACING_WIDE = 1,
	kBP_EDITORSPACING_MARGIN = 2
} kBP_EDITORSPACING;

@interface BPDocumentWindow ()

@property (strong) NoodleLineNumberView *lineNumberView;

@end

@implementation BPDocumentWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
	self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
	if (self) {
	}
	return self;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen
{
	self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag screen:screen];
	if (self) {
	}
	return self;
}

- (void)construct
{
	self.lineNumberView = [[MarkerLineNumberView alloc] initWithScrollView:self.scrollView];

	[self.scrollView setVerticalRulerView:self.lineNumberView];
    [self.scrollView setHasHorizontalRuler:NO];
    [self.scrollView setHasVerticalRuler:YES];
    [self.scrollView setRulersVisible:YES];
//	[self.scrollView setPostsBoundsChangedNotifications:YES];

	[self.textView setFont:[NSFont fontWithName:@"Monaco" size:12]];
	[self.textView setDelegate:self];
	[self textDidChange:nil];

	[self.contentView setNeedsDisplay:YES];
	[self.lineNumberView setNeedsDisplay:YES];
}

- (void)setLinesCounterVisible:(BOOL)flag
{
	[self.scrollView setRulersVisible:flag];
	[self.tb_toggle_displayOptions setSelected:flag forSegment:0];
}

- (void)setInfoViewVisible:(BOOL)flag
{
	CGRect frame = self.wrapView.frame;
	CGFloat height = self.infoView.frame.size.height;

	if (flag) {
		frame.size.height += height;
		frame.origin.y -= height;

		[self.infoView setHidden:YES];
		[self.wrapView setFrame:frame];
	} else {
		frame.size.height -= height;
		frame.origin.y += height;

		[self.infoView setHidden:NO];
		[self.wrapView setFrame:frame];
	}

	[self.tb_toggle_displayOptions setSelected:!flag forSegment:1];
}

- (void)toggleLinesCounter
{
	[self setLinesCounterVisible:!self.scrollView.rulersVisible];
}

- (void)toggleInfoView
{
	[self setInfoViewVisible:![self.infoView isHidden]];
}

- (void)textDidChange:(NSNotification *)notification {
	[[self.infoView viewWithTag:1] setStringValue:[NSString stringWithFormat:NSLocalizedString(@"BP_LABEL_WORDS", nil),[self.textView.string wordsCount]]];
	[[self.infoView viewWithTag:2] setStringValue:[NSString stringWithFormat:NSLocalizedString(@"BP_LABEL_CHARS", nil),[self.textView.string length]]];
	[[self.infoView viewWithTag:3] setStringValue:[NSString stringWithFormat:NSLocalizedString(@"BP_LABEL_LINES", nil),[[self.lineNumberView lineIndices] count]]];
}

- (void)updateTextViewContents
{
	[self.textView setString:[[NSString alloc] initWithData:self.document.fileData encoding:NSUTF8StringEncoding]];
	[self textDidChange:nil];
}

#pragma mark - IBActions

- (IBAction)action_switch_textAlignment:(id)sender {
	NSSegmentedControl *toggle = sender;
	switch (toggle.selectedSegment) {
		case 0: //Align left
			[self.textView alignLeft:sender];
			break;

		case 1: //Align center
			[self.textView alignCenter:sender];
			break;

		case 2: //Align right
			[self.textView alignRight:sender];
			break;

		default:
			break;
	}
}

- (IBAction)action_switch_editorSpacing:(id)sender {
	NSRect frame = self.scrollView.frame;
	NSSegmentedControl *toggle = sender;
	switch (toggle.selectedSegment) {
		case 0: //Should become wide
			frame.origin.x -= 50;
			frame.size.width += 100;
			break;

		case 1: //Should become narrow
			frame.origin.x += 50;
			frame.size.width -= 100;
			[self setLinesCounterVisible:NO];
			break;
	}
	[self.scrollView setFrame:frame];
}

- (IBAction)action_toggle_displayOptions:(id)sender {
	NSSegmentedControl *toggler = sender;

	switch (toggler.selectedSegment) {
		case 0: //Toggle lines counter
			[self toggleLinesCounter];
			break;

		case 1: //Toggle info display
			[self toggleInfoView];
			break;

		default:
			break;
	}
}

- (IBAction)action_bt_editToolbar:(id)sender {
	[self runToolbarCustomizationPalette:sender];
//	[self.toolbar]
}
@end
