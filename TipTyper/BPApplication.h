//
//  BPApplication.h
//  TipTyper
//
//  Created by Bruno Philipe on 10/14/13.
//  Copyright (c) 2013 Bruno Philipe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BPDocument.h"

@class BPDocument;

@interface BPApplication : NSApplication

@property BOOL keyDocument_showingLines;
@property BOOL keyDocument_showingInfo;
@property BOOL keyDocument_isLinkedToFile;
@property BOOL hasKeyDocument;

/**
 Sets the key document. This method is called from any BPDocument when its window becomes key.
 */
- (void)setKeyDocument:(BPDocument *)keyDocument;

/**
 Sends a message to the shared application manager to open the app's website using the default browser.
 */
- (IBAction)openWebsite:(id)sender;

/**
 Opens (and creates if necessary) the preferences window.
 */
- (IBAction)showPreferences:(id)sender;

#pragma mark - Preferences Window

@property (strong) NSFont *currentFont;
@property (strong) NSColor *color_text;
@property (strong) NSColor *color_bg;

@property (strong) IBOutlet NSTextField *field_currentFont;
@property (strong) IBOutlet NSTextField *textView_example;
@property (strong) IBOutlet NSTextField *field_tabSize;
@property (strong) IBOutlet NSButton *checkbox_insertTabs;
@property (strong) IBOutlet NSButton *checkbox_insertSpaces;
@property (strong) IBOutlet NSButton *checkbox_showLines;
@property (strong) IBOutlet NSButton *checkbox_showStatus;
@property (strong) IBOutlet NSStepper *stepper_tabSize;

- (IBAction)action_changeFont:(id)sender;
- (IBAction)action_revertDefaults:(id)sender;
- (IBAction)action_controlChanged:(id)sender;
- (IBAction)action_applyChanges:(id)sender;

- (IBAction)showAboutPanel:(id)sender;
@end
