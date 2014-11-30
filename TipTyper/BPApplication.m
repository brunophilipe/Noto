//
//  BPApplication.m
//  TipTyper
//
//  Created by Bruno Philipe on 10/14/13.
//  Copyright (c) 2013 Bruno Philipe. All rights reserved.
//

#import "BPApplication.h"
#import "BPDocumentWindow.h"
#import "DCOAboutWindowController.h"
#import "BPPreferencesWindowController.h"

NSString *const kBPDefaultFont = @"BP_DEFAULT_FONT";
NSString *const kBPDefaultTextColor = @"BP_DEFAULT_TXTCOLOR";
NSString *const kBPDefaultBGCOLOR = @"BP_DEFAULT_BGCOLOR";
NSString *const kBPDefaultShowLines = @"BP_DEFAULT_SHOWLINES";
NSString *const kBPDefaultShowStatus = @"BP_DEFAULT_SHOWSTATUS";
NSString *const kBPDefaultInsertTabs = @"BP_DEFAULT_INSERTTABS";
NSString *const kBPDefaultInsertSpaces = @"BP_DEFAULT_INSERTSPACES";
NSString *const kBPDefaultCountSpaces = @"BP_DEFAULT_COUNTSPACES";
NSString *const kBPDefaultTabSize = @"BP_DEFAULT_TABSIZE";
NSString *const kBPDefaultEditorWidth = @"BP_DEFAULT_EDITOR_WIDTH";

NSString *const kBPShouldReloadStyleNotification = @"BP_SHOULD_RELOAD_STYLE";

NSString *const kBPTipTyperWebsite = @"http://www.brunophilipe.com/software/tiptyper";

@implementation BPApplication
{
	BPPreferencesWindowController *prefWindowController;
	DCOAboutWindowController *aboutWindowController;

	NSWindow *prefWindow;
}

- (IBAction)openWebsite:(id)sender
{
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	[ws openURL:[NSURL URLWithString:kBPTipTyperWebsite]];
}

- (IBAction)showPreferences:(id)sender
{
	if (!prefWindow)
	{
		prefWindowController = [[BPPreferencesWindowController alloc] initWithWindowNibName:@"Preferences"];
		prefWindow = prefWindowController.window;

		[prefWindow setAnimationBehavior:NSWindowAnimationBehaviorDocumentWindow];
	}

	[prefWindowController performSelector:@selector(showWindow:) withObject:self afterDelay:0.2];
}

#pragma mark - IBActions

- (IBAction)showAboutPanel:(id)sender {
	if (!aboutWindowController) {
		aboutWindowController = [[DCOAboutWindowController alloc] init];

		[aboutWindowController setAppCopyright:@"Copyright Bruno Philipe 2014 – All Rights Reserved"];
		[aboutWindowController setAppWebsiteURL:[NSURL URLWithString:kBPTipTyperWebsite]];
	}

	[aboutWindowController showWindow:sender];
}

@end
