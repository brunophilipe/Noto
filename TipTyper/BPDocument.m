//
//  BPDocument.m
//  TipTyper
//
//  Created by Bruno Philipe on 2/9/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPDocument.h"
#import "BPApplication.h"
#import "BPEncodingTool.h"

@interface BPDocument ()

//@property (strong) NSFileHandle *fileHandle;

@property BOOL loadedSuccessfully;

@end

@implementation BPDocument

- (id)init
{
    self = [super init];
    if (self) {
		// Add your subclass-specific initialization here.
		[(BPApplication*)[NSApplication sharedApplication] setKeyDocument_isLinkedToFile:NO];
		[(BPApplication*)[NSApplication sharedApplication] setHasKeyDocument:YES];

		self.fileString = @"";
		self.encoding = NSUTF8StringEncoding;
    }
    return self;
}

- (NSString *)windowNibName
{
	// Override returning the nib file name of the document
	// If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
	return @"BPDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
	[super windowControllerDidLoadNib:aController];
	// Add any code here that needs to be executed once the windowController has loaded the document's window.
	[self setDisplayWindow:(BPDocumentWindow*)aController.window];
	[self.displayWindow construct];
	[self.displayWindow setDocument:self];

	[self.displayWindow updateTextViewContents];
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
	NSStringEncoding usedEncoding;
	NSError *error;
	NSString *string = [NSString stringWithContentsOfURL:url usedEncoding:&usedEncoding error:&error];

	if (string && usedEncoding > 0 && !error) {
		[self setFileString:string];
		[self setEncoding:usedEncoding];
		return YES;
	} else {
		NSAlert *alert = [NSAlert alertWithError:error];
		[alert runModal];
		*outError = error;
		return NO;
	}
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
	return [[self.displayWindow.textView string] writeToURL:url atomically:YES encoding:self.encoding error:outError];
}

- (BOOL)revertToContentsOfURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:[url relativePath]])
	{
		NSError *error;

		if ([[[[NSFileManager defaultManager] attributesOfItemAtPath:[url relativePath] error:&error] objectForKey:NSFileSize] unsignedIntegerValue] > 500 * 1000000) { //Filesize > 500MB
			NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"TipTyper doesn't support files greater than 500MB. This is a work in progress."];
			[alert runModal];
		}

		if (error) {
			NSAlert *alert = [NSAlert alertWithError:error];
			[alert runModal];
		}

		return [self readFromURL:url ofType:typeName error:outError];
	}

	return NO;
}

- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings error:(NSError **)outError {
	NSPrintInfo *prtInfo = [self printInfo];

	[prtInfo setVerticallyCentered:NO];

	NSPrintOperation *prtOpr = [NSPrintOperation printOperationWithView:self.displayWindow.textView printInfo:prtInfo];
	[prtOpr setJobTitle:self.displayName];
	return prtOpr;
}

- (void)canCloseDocumentWithDelegate:(id)delegate shouldCloseSelector:(SEL)shouldCloseSelector contextInfo:(void *)contextInfo
{
	[(BPApplication*)[NSApplication sharedApplication] setKeyDocument_isLinkedToFile:NO];
	[(BPApplication*)[NSApplication sharedApplication] setHasKeyDocument:NO];
	[super canCloseDocumentWithDelegate:delegate shouldCloseSelector:shouldCloseSelector contextInfo:contextInfo];
}

- (NSString*)reloadWithDifferentEncoding
{
	if (self.isLoadedFromFile || self.fileURL) {
		NSInteger result;
		NSString *curEncodingName = [[BPEncodingTool sharedTool] nameForEncoding:_encoding];
		NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"BP_MESSAGE_PICKENCODING", nil) defaultButton:NSLocalizedString(@"BP_GENERIC_OK", nil) alternateButton:NSLocalizedString(@"BP_GENERIC_CANCEL", nil) otherButton:nil informativeTextWithFormat:NSLocalizedString(@"BP_MESSAGE_ENCODING", nil)];

		[alert.window setTitle:(self.loadedSuccessfully ? NSLocalizedString(@"BP_MESSAGE_REOPENING", nil) : NSLocalizedString(@"BP_MESSAGE_AUTOENCODING", nil))];

		NSPopUpButton __strong *selector = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0, 0, 160, 40) pullsDown:YES];
		[selector addItemsWithTitles:[[BPEncodingTool sharedTool] getAllEncodings]];
		[selector selectItemWithTitle:curEncodingName];
		[selector setTitle:curEncodingName];
		[selector setTarget:self];
		[selector setAction:@selector(menuEncodingChanged:)];

		[alert setAccessoryView:selector];

		while ((result = [alert runModal]) == 1)
		{
			NSUInteger encoding = [[BPEncodingTool sharedTool] encodingForEncodingName:selector.selectedItem.title];
			NSString *inputString = nil;
			NSError *error;

			inputString = [[NSString alloc] initWithContentsOfURL:self.fileURL encoding:encoding error:&error];

			if (error) {
				NSAlert *alert = [NSAlert alertWithError:error];
				[alert runModal];
			}

			if (inputString) {
				//Change the local encoding to the selected
				_encoding = encoding;

//				[self.displayWindow.textView setString:inputString];
				[[self.displayWindow.infoView viewWithTag:4] setStringValue:selector.selectedItem.title];
				return inputString;
			}
		}
	} else {
		NSAlert *failedAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"BP_ERROR_ENCODING_NOFILE", nil) defaultButton:NSLocalizedString(@"BP_GENERIC_OK", nil) alternateButton:NSLocalizedString(@"BP_GENERIC_CANCEL", nil) otherButton:nil informativeTextWithFormat:@""];
		[failedAlert runModal];
	}

	return nil;
}

#pragma mark - Save Panel

- (NSString*)fileNameExtensionForType:(NSString *)typeName saveOperation:(NSSaveOperationType)saveOperation
{
	return @"txt";
}

- (BOOL)prepareSavePanel:(NSSavePanel *)savePanel
{
	[savePanel setShowsTagField:YES];

	NSView *view = [savePanel.accessoryView.subviews lastObject];

	NSPopUpButton *button = [[view subviews] lastObject];
	NSRect frame = [button frame];
	frame.size.width += 120;
	[button setFrame:frame];
	[button selectItemAtIndex:0];

	frame = view.frame;
	frame.size.width += 120;
	[view setFrame:frame];

	[savePanel setAccessoryView:view];
	[savePanel layoutIfNeeded];

	return YES;
}

#pragma mark - Actions

- (void)pickEncodingAndReload:(id)sender
{
	NSString *string = [self reloadWithDifferentEncoding];

	if (string) {
		[self setFileString:string];
		[self.displayWindow updateTextViewContents];
	}
}

- (void)menuEncodingChanged:(id)sender
{
	NSPopUpButton *button = sender;
	[button setTitle:[button selectedItem].title];
}

- (void)toggleLinesCounter:(id)sender;
{
	[self.displayWindow toggleLinesCounter];
}

- (void)toggleInfoView:(id)sender;
{
	[self.displayWindow toggleInfoView];
}

@end
