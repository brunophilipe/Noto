//
//  BPTextView.h
//  TipTyper
//
//  Created by Bruno Philipe on 2/23/14.
//  Copyright (c) 2014 Bruno Philipe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BPTextView : NSTextView

@property (nonatomic) BOOL shouldInsertTabsOnLineBreak;
@property (nonatomic) BOOL shouldInsertSpacesInsteadOfTabs;
@property NSUInteger tabSize;

- (void)increaseIndentation;
- (void)decreaseIndentation;

@end
