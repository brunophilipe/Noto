//
//  EditorLayoutManager.h
//  Kodex
//
//  Created by Bruno Resende on 25/05/2017.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

#import <AppKit/AppKit.h>

@class EditorLayoutManager;

@protocol EditorLayoutManagerDelegate <NSObject>

- (void)layoutManagerDidProcessEdit:(EditorLayoutManager *)layoutManager;

@end

@interface EditorLayoutManager : NSLayoutManager

@property (weak) id<EditorLayoutManagerDelegate> editorLayoutManagerDelegate;

- (NSUInteger)lineNumberForRange:(NSRange)charRange;

@end
