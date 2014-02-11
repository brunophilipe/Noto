//
//  BPDocument.m
//  TipTyper
//
//  Created by Bruno Philipe on 2/9/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import "BPDocument.h"
#import "BPDocumentWindow.h"

@interface BPDocument ()

@property (strong) BPDocumentWindow *displayWindow;
@property (strong) NSFileHandle *fileHandle;

@end

@implementation BPDocument

- (id)init
{
    self = [super init];
    if (self) {
		// Add your subclass-specific initialization here.
		self.fileData = [[NSMutableData alloc] init];
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

//- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
//{
//	// Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
//	// You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
//	NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
//	@throw exception;
//	return nil;
//}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:[url relativePath]])
	{
		NSError *error;

		[self setFileURL:url];
		[self setFileHandle:[NSFileHandle fileHandleForReadingFromURL:url error:&error]];

		if (error) {
			NSAlert *alert = [NSAlert alertWithError:error];
			[alert runModal];
			return NO;
		} else {
			[self.fileData setData:[self.fileHandle readDataOfLength:10*1000000]]; //Read first 10 Megabytes
		}
		return YES;
	} else {
		return NO;
	}
}

@end
