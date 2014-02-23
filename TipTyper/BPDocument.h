//
//  BPDocument.h
//  TipTyper
//
//  Created by Bruno Philipe on 2/9/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BPDocumentWindow.h"

@class BPDocumentWindow;

@interface BPDocument : NSDocument

@property (strong) NSMutableData *fileData;
@property (strong) BPDocumentWindow *displayWindow;

@property (getter = isLoadedFromFile) BOOL loadedFromFile;

@property NSInteger encoding;

- (IBAction)toggleLinesCounter:(id)sender;
- (IBAction)toggleInfoView:(id)sender;

- (IBAction)pickEncodingAndReload:(id)sender;

@end
