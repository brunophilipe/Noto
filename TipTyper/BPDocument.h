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

@property (strong) NSString *fileString;
@property (strong) BPDocumentWindow *displayWindow;

@property (getter = isLoadedFromFile) BOOL loadedFromFile;

@property NSStringEncoding encoding;

- (void)toggleLinesCounter:(id)sender;
- (void)toggleInfoView:(id)sender;

- (void)pickEncodingAndReload:(id)sender;

@end
