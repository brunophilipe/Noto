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

typedef NS_ENUM(NSUInteger, BP_DEFAULT_TYPES) {
	BP_DEFAULTS_FONT =			(1<<1),
	BP_DEFAULTS_TXTCOLOR =		(1<<2),
	BP_DEFAULTS_BGCOLOR =		(1<<3),
	BP_DEFAULTS_SHOWLINES =		(1<<4),
	BP_DEFAULTS_SHOWSTATUS =	(1<<5),
	BP_DEFAULTS_INSERTTABS =	(1<<6),
	BP_DEFAULTS_TABSIZE =		(1<<7),
	BP_DEFAULTS_INSERTSPACES =	(1<<8),
	BP_DEFAULTS_COUNTSPACES =	(1<<9),
	BP_DEFAULTS_EDITORWIDTH =	(1<<10)
};

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

NSString *const kBP_SHOULD_RELOAD_STYLE = @"BP_SHOULD_RELOAD_STYLE";

NSString *const kBP_TIPTYPER_WEBSITE = @"http://www.brunophilipe.com/software/tiptyper";

@implementation BPApplication
{
	NSWindowController *prefWindowController;
	NSWindow *prefWindow;
	BP_DEFAULT_TYPES changedAttributes;
	DCOAboutWindowController *aboutWindowController;
}

- (void)setKeyDocument:(BPDocument *)keyDocument
{
	self.keyDocument_showingLines = [keyDocument.displayWindow isDisplayingLines];
	self.keyDocument_showingInfo = [keyDocument.displayWindow isDisplayingInfo];
//	self.keyDocument_isLinkedToFile;
}

- (IBAction)openWebsite:(id)sender
{
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	[ws openURL:kBP_TIPTYPER_WEBSITE_URL];
}

- (IBAction)showPreferences:(id)sender
{
	if (!prefWindow)
	{
		prefWindowController = [[NSWindowController alloc] initWithWindowNibName:@"Preferences"];
		prefWindow = prefWindowController.window;

		[self configurePrefWindow];

		[prefWindow setAnimationBehavior:NSWindowAnimationBehaviorDocumentWindow];
	}
	[prefWindowController performSelector:@selector(showWindow:) withObject:self afterDelay:0.2];
}

#pragma mark - Preferences Window

- (void)configurePrefWindow
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	id aux;

	if ((aux = [defaults objectForKey:kBPDefaultBGCOLOR])) {
		[self setColor_bg:[NSKeyedUnarchiver unarchiveObjectWithData:aux]];
	} else {
		[self setColor_bg:kBP_TIPTYPER_BGCOLOR];
	}

	if ((aux = [defaults objectForKey:kBPDefaultTextColor])) {
		[self setColor_text:[NSKeyedUnarchiver unarchiveObjectWithData:aux]];
	} else {
		[self setColor_text:kBP_TIPTYPER_TXTCOLOR];
	}

	if ((aux = [defaults objectForKey:kBPDefaultFont])) {
		[self setCustomFont:[NSKeyedUnarchiver unarchiveObjectWithData:aux]];
	} else {
		[self setCustomFont:kBP_TIPTYPER_FONT];
	}

	if ((aux = [defaults objectForKey:kBPDefaultShowLines])) {
		[self.checkbox_showLines setState:([(NSNumber*)aux boolValue] ? NSOnState : NSOffState)];
	} else {
		[self.checkbox_showLines setState:NSOnState];
	}

	if ((aux = [defaults objectForKey:kBPDefaultShowStatus])) {
		[self.checkbox_showStatus setState:([(NSNumber*)aux boolValue] ? NSOnState : NSOffState)];
	} else {
		[self.checkbox_showStatus setState:NSOnState];
	}

	if ((aux = [defaults objectForKey:kBPDefaultInsertTabs])) {
		[self.checkbox_insertTabs setState:([(NSNumber*)aux boolValue] ? NSOnState : NSOffState)];
	} else {
		[self.checkbox_insertTabs setState:NSOnState];
	}

	if ((aux = [defaults objectForKey:kBPDefaultInsertSpaces])) {
		[self.checkbox_insertSpaces setState:([(NSNumber*)aux boolValue] ? NSOnState : NSOffState)];
	} else {
		[self.checkbox_insertSpaces setState:NSOffState];
	}

	if ((aux = [defaults objectForKey:kBPDefaultCountSpaces])) {
		[self.checkbox_countSpaces setState:([(NSNumber*)aux boolValue] ? NSOnState : NSOffState)];
	} else {
		[self.checkbox_countSpaces setState:NSOffState];
	}

	if ((aux = [defaults objectForKey:kBPDefaultTabSize])) {
		[self.field_tabSize setIntegerValue:[aux integerValue]];
		[self.stepper_tabSize setIntegerValue:[aux integerValue]];
	} else {
		[self.field_tabSize setIntegerValue:4];
		[self.stepper_tabSize setIntegerValue:4];
	}

	if ((aux = [defaults objectForKey:kBPDefaultEditorWidth])) {
		[self.field_editorSize setIntegerValue:[aux integerValue]];
		[self.stepper_editorSize setIntegerValue:[aux integerValue]];
	} else {
		[self.field_editorSize setIntegerValue:450];
		[self.stepper_editorSize setIntegerValue:450];
	}

	[self.textView_example setTextColor:self.color_text];
	[self.textView_example setBackgroundColor:self.color_bg];

	[[prefWindow.contentView viewWithTag:-3] performSelector:@selector(setColor:) withObject:self.color_text];
	[[prefWindow.contentView viewWithTag:-4] performSelector:@selector(setColor:) withObject:self.color_bg];
}

- (void)changeFont:(id)sender
{
	NSFontManager *fm = sender;

	[self setCustomFont:[fm convertFont:self.currentFont]];

	changedAttributes |= BP_DEFAULTS_FONT;
}

- (void)setCustomFont:(NSFont *)font
{
	self.currentFont = font;

	[self.field_currentFont setFont:[NSFont fontWithName:self.currentFont.fontName size:12]];
	[self.field_currentFont setStringValue:[NSString stringWithFormat:@"%@ %.0fpt",self.currentFont.displayName,self.currentFont.pointSize]];

	[self.textView_example setFont:self.currentFont];
}

#pragma mark - IBActions

- (IBAction)action_changeFont:(id)sender {
	[[NSFontManager sharedFontManager] setDelegate:self];

	NSFontPanel *panel = [NSFontPanel sharedFontPanel];
	[panel makeKeyAndOrderFront:self];
}

- (IBAction)action_revertDefaults:(id)sender {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[defaults removeObjectForKey:kBPDefaultBGCOLOR];
	[defaults removeObjectForKey:kBPDefaultTextColor];
	[defaults removeObjectForKey:kBPDefaultFont];
	[defaults removeObjectForKey:kBPDefaultShowStatus];
	[defaults removeObjectForKey:kBPDefaultShowLines];
	[defaults removeObjectForKey:kBPDefaultInsertTabs];
	[defaults removeObjectForKey:kBPDefaultInsertSpaces];
	[defaults removeObjectForKey:kBPDefaultCountSpaces];
	[defaults removeObjectForKey:kBPDefaultTabSize];
	[defaults removeObjectForKey:kBPDefaultEditorWidth];

	[defaults synchronize];

	changedAttributes = 0;

	[self configurePrefWindow];

	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_SHOULD_RELOAD_STYLE object:self];
}

- (IBAction)action_controlChanged:(id)sender {
	switch ([(NSControl *)sender tag]) {
		case -1: //Show lines
			changedAttributes |= BP_DEFAULTS_SHOWLINES;
			break;

		case -2: //Show status
			changedAttributes |= BP_DEFAULTS_SHOWSTATUS;
			break;

		case -3: //Font color
			self.color_text = [(NSColorWell *)sender color];
			[self.textView_example setTextColor:self.color_text];
			changedAttributes |= BP_DEFAULTS_TXTCOLOR;
			break;

		case -4: //BG color
			self.color_bg = [(NSColorWell *)sender color];
			[self.textView_example setBackgroundColor:self.color_bg];
			changedAttributes |= BP_DEFAULTS_BGCOLOR;
			break;

		case -5: //Insert tabs
			changedAttributes |= BP_DEFAULTS_INSERTTABS;
			break;

		case -6: //Tab size stepper
		{
			NSStepper *tabSize = sender;
			[self.field_tabSize setIntegerValue:tabSize.integerValue];
			changedAttributes |= BP_DEFAULTS_TABSIZE;
		}
			break;

		case -7: //Insert spaces
			changedAttributes |= BP_DEFAULTS_INSERTSPACES;
			break;

		case -8: //Count spaces as chars
			changedAttributes |= BP_DEFAULTS_COUNTSPACES;
			break;

		case -9: //Fixed editor width stepper
		{
			NSStepper *editorSize = sender;
			[self.field_editorSize setIntegerValue:editorSize.integerValue];
			changedAttributes |= BP_DEFAULTS_EDITORWIDTH;
		}
			break;
	}
}

- (IBAction)action_applyChanges:(id)sender {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if (changedAttributes & BP_DEFAULTS_FONT) {
		[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.currentFont] forKey:kBPDefaultFont];
	}
	if (changedAttributes & BP_DEFAULTS_BGCOLOR) {
		[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.color_bg] forKey:kBPDefaultBGCOLOR];
	}
	if (changedAttributes & BP_DEFAULTS_TXTCOLOR) {
		[defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.color_text] forKey:kBPDefaultTextColor];
	}
	if (changedAttributes & BP_DEFAULTS_SHOWLINES) {
		[defaults setObject:[NSNumber numberWithBool:([self.checkbox_showLines state] == NSOnState)] forKey:kBPDefaultShowLines];
	}
	if (changedAttributes & BP_DEFAULTS_SHOWSTATUS) {
		[defaults setObject:[NSNumber numberWithBool:([self.checkbox_showStatus state] == NSOnState)] forKey:kBPDefaultShowStatus];
	}
	if (changedAttributes & BP_DEFAULTS_INSERTTABS) {
		[defaults setObject:[NSNumber numberWithBool:([self.checkbox_insertTabs state] == NSOnState)] forKey:kBPDefaultInsertTabs];
	}
	if (changedAttributes & BP_DEFAULTS_INSERTSPACES) {
		[defaults setObject:[NSNumber numberWithBool:([self.checkbox_insertSpaces state] == NSOnState)] forKey:kBPDefaultInsertSpaces];
	}
	if (changedAttributes & BP_DEFAULTS_COUNTSPACES) {
		[defaults setObject:[NSNumber numberWithBool:([self.checkbox_countSpaces state] == NSOnState)] forKey:kBPDefaultCountSpaces];
	}
	if (changedAttributes & BP_DEFAULTS_TABSIZE) {
		[defaults setObject:[NSNumber numberWithInteger:[self.field_tabSize integerValue]] forKey:kBPDefaultTabSize];
	}
	if (changedAttributes & BP_DEFAULTS_EDITORWIDTH) {
		[defaults setObject:[NSNumber numberWithInteger:[self.field_editorSize integerValue]] forKey:kBPDefaultEditorWidth];
	}

	changedAttributes = 0;

	[defaults synchronize];
	[[NSNotificationCenter defaultCenter] postNotificationName:kBP_SHOULD_RELOAD_STYLE object:self];
}

- (IBAction)showAboutPanel:(id)sender {
	if (!aboutWindowController) {
		aboutWindowController = [[DCOAboutWindowController alloc] init];

		[aboutWindowController setAppCopyright:@"Copyright Bruno Philipe 2014 – All Rights Reserved"];
		[aboutWindowController setAppWebsiteURL:kBP_TIPTYPER_WEBSITE_URL];
	}

	[aboutWindowController showWindow:sender];
}

@end
