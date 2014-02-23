//
//  BPDocumentWindow.h
//  TipTyper
//
//  Created by Bruno Philipe on 2/9/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BPDocument.h"
#import "Classes/BPBackgroundView.h"

@class BPDocument;

@interface BPDocumentWindow : NSWindow <NSTextViewDelegate>

@property (weak) BPDocument *document;

- (void)construct;
- (void)updateTextViewContents;

- (void)toggleLinesCounter;
- (void)toggleInfoView;

- (BOOL)isDisplayingLines;
- (BOOL)isDisplayingInfo;

#pragma mark - IBOutlets

@property (strong) IBOutlet BPBackgroundView *wrapView;
@property (strong) IBOutlet NSScrollView *scrollView;
@property (strong) IBOutlet NSTextView *textView;
@property (strong) IBOutlet NSView *infoView;
@property (strong) IBOutlet NSSegmentedControl *tb_switch_textAlignment;
@property (strong) IBOutlet NSSegmentedControl *tb_switch_editorSpacing;
@property (strong) IBOutlet NSSegmentedControl *tb_toggle_displayOptions;
@property (strong) IBOutlet NSToolbarItem *tb_bt_editToolbar;

#pragma mark - IBActions

- (IBAction)action_switch_textAlignment:(id)sender;
- (IBAction)action_switch_editorSpacing:(id)sender;
- (IBAction)action_toggle_displayOptions:(id)sender;
- (IBAction)action_bt_editToolbar:(id)sender;
- (IBAction)action_showJumpToLineDialog:(id)sender;
- (IBAction)action_switch_changeFontSize:(id)sender;

@end
