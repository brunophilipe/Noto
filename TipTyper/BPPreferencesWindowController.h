//
//  BPPreferencesViewController.h
//  TipTyper
//
//  Created by Bruno Philipe on 11/7/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BPPreferencesWindowController : NSWindowController

@property (strong) NSFont *currentFont;
@property (strong) NSColor *color_text;
@property (strong) NSColor *color_bg;

@property (strong) IBOutlet NSTextField *field_currentFont;
@property (strong) IBOutlet NSTextField *textView_example;
@property (strong) IBOutlet NSTextField *field_tabSize;
@property (strong) IBOutlet NSTextField *field_editorSize;
@property (strong) IBOutlet NSButton    *checkbox_insertTabs;
@property (strong) IBOutlet NSButton    *checkbox_insertSpaces;
@property (strong) IBOutlet NSButton    *checkbox_countSpaces;
@property (strong) IBOutlet NSButton    *checkbox_showLines;
@property (strong) IBOutlet NSButton    *checkbox_showStatus;
@property (strong) IBOutlet NSButton	*checkbox_showInvisibles;
@property (strong) IBOutlet NSStepper   *stepper_tabSize;
@property (strong) IBOutlet NSStepper   *stepper_editorSize;

- (IBAction)action_changeFont:(id)sender;
- (IBAction)action_revertDefaults:(id)sender;
- (IBAction)action_controlChanged:(id)sender;
- (IBAction)action_applyChanges:(id)sender;

@end
