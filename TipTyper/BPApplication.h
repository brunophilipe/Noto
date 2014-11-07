//
//  BPApplication.h
//  TipTyper
//
//  Created by Bruno Philipe on 10/14/13.
//  Copyright (c) 2013 Bruno Philipe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BPDocument.h"

extern NSString *const kBPDefaultFont;
extern NSString *const kBPDefaultTextColor;
extern NSString *const kBPDefaultBGCOLOR;
extern NSString *const kBPDefaultShowLines;
extern NSString *const kBPDefaultShowStatus;
extern NSString *const kBPDefaultInsertTabs;
extern NSString *const kBPDefaultInsertSpaces;
extern NSString *const kBPDefaultCountSpaces;
extern NSString *const kBPDefaultTabSize;
extern NSString *const kBPDefaultEditorWidth;

extern NSString *const kBPShouldReloadStyleNotification;

extern NSString *const kBPTipTyperWebsite;

@class BPDocument;

@interface BPApplication : NSApplication

@property BOOL keyDocument_isLinkedToFile;
@property BOOL hasKeyDocument;

/**
 * Sends a message to the shared application manager to open the app's website using the default browser.
 */
- (IBAction)openWebsite:(id)sender;

/**
 *  Opens (and creates if necessary) the preferences window.
 */
- (IBAction)showPreferences:(id)sender;

/**
 *  Opens the About panel.
 */
- (IBAction)showAboutPanel:(id)sender;

@end
